#环境处理的steps
import os,logging,time,MySQLdb
from behave import *
from hamcrest import *
from steps.utils import wait_for,log_it,get_node,exec_command
from steps.DbleMeta import DbleMeta
from steps.DBUtil import DBUtil

logger = logging.getLogger('root')

INIT_SCOPE = ('compare_mysql', 'group1', 'group2','group3')

@Given('a clean environment in all dble nodes')
def clean_dble_in_all_nodes(context):
    for node in DbleMeta.dbles:
        uninstall_dble_in_node(context, node)

def uninstall_dble_in_node(context, node):
    dble_installed = stop_dble_in_node(context, node)

    if dble_installed:
        cmd = "cd {0} && rm -rf dble".format(node.install_dir)
        node.ssh_conn.exec_command(cmd)

@given('I clean mysql deploy environment')
def delete_mysqls(context):
    for name, ssh_conn in context.ssh_clients.items():
        if name in INIT_SCOPE:
            logger.info(f'delete {name}')
            delete_mysql(ssh_conn)

@log_it
def delete_mysql(ssh_conn):
    cmd = "dbdeployer sandboxes | awk '{print $1}' | xargs -r -n 1 dbdeployer delete"
    rc, sto, ste = ssh_conn.exec_command(cmd)
    assert_that(rc, equal_to(0), ste)

    cmd = 'dbdeployer sandboxes'
    rc, sto, ste = ssh_conn.exec_command(cmd)
    assert_that(rc, equal_to(0), ste)
    assert_that(sto, empty(), 'MySQL实例没有清理干净')

@Given('Start dble in "{hostname}"')
@When('Start dble in "{hostname}"')
@Then('Start dble in "{hostname}"')
def start_dble_in_hostname(context, hostname):
    node = get_node(hostname)
    start_dble_in_node(context, node)

@Given('replace config files in "{nodeName}" with command line config')
def step_impl(context, nodeName):
    node = get_node(nodeName)
    replace_config_in_node(context, node)

@Given('install dble in "{hostname}"')
def install_dble_in_host(context, hostname):
    node = get_node(hostname)
    install_dble_in_node(context, node)



def install_dble_in_node(context, node):
    if context.need_download:
        dble_packet = download_dble_package(context)
    else:
        dble_packet = os.path.join(context.cfg_sys['share_path_docker'], "actiontech-dble.tar.gz")

    ssh_client = node.ssh_conn

    cmd = "cd {0} && rm -rf dble".format(node.install_dir)
    rc, _, ste = ssh_client.exec_command(cmd)
    assert_that(len(ste) == 0, "exec with command:{0}, got err:{1}".format(cmd, ste))


    cmd = "tar xf {0} -C {1}".format(dble_packet, node.install_dir)
    rc, _, ste = ssh_client.exec_command(cmd)
    assert_that(rc, equal_to(0), f"install dble failed, got err:{ste}"),

#重置dble
def reset_dble(context):
    for node in DbleMeta.dbles:
        replace_config_in_node(context, node)
        restart_dbles(context, node)

def restart_dbles(context,node):
    stop_dble_in_node(context, node)
    start_dble_in_node(context, node)


def stop_dble_in_node(context, node):
    ssh_client = node.ssh_conn
    dble_install_path = node.install_dir
    dble_pid_exist, dble_dir_exist = check_dble_exist(ssh_client, dble_install_path)

    @wait_for(context, text="Stop dble failed! dble process still exists", duration=6, interval=1)
    def condition(ssh_client):
        cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}' | wc -l"
        rc, sto, ste = ssh_client.exec_command(cmd)
        if len(ste) == 0:
            return str(sto) == '0'
        return False

def start_dble_in_node(context, node, expect_success=True):
    ssh_client = node.ssh_conn
    dble_install_path = node.install_dir
    dble_pid_exist, dble_dir_exist = check_dble_exist(ssh_client, dble_install_path)

    if not dble_dir_exist:
        logger.info('start dble {0} skip, dble_dir_exist is {1}'.format(node.host_name, dble_dir_exist))
    else:
        cmd = "{0}/dble/bin/dble start".format(node.install_dir)
        ssh_client.exec_command(cmd)
        check_dble_started(context, node)
        assert_that(context.dble_start_success == expect_success,
                    "Expect restart dble {0} success {1}".format(node.host_name, expect_success))

        if not expect_success:
            expect_err_info = context.text.strip()
            for row in expect_err_info.splitlines():
                cmd = "grep -i \"{0}\" /opt/dble/logs/wrapper.log | wc -l".format(row.strip())
                rc, sto, ste = node.ssh_conn.exec_command(cmd)
                assert_that(str(sto).strip() != "0", "expect dble restart failed for {0}".format(row))


def replace_config_in_node(context, node):
    logger.info("source config dir: {0}, pwd:{1}".format(context.dble_conf, os.getcwd()))

    sourceCfgDir = "{0}/{1}".format(os.getcwd(), context.dble_conf)
    osCmd = 'rm -rf {0} && cp -r {0}_bk {0}'.format(sourceCfgDir)
    os.system(osCmd)

    ssh_client = node.ssh_conn
    dble_install_path = node.install_dir
    dble_pid_exist, dble_dir_exist = check_dble_exist(ssh_client, dble_install_path)

    if dble_dir_exist:
        cmd = 'rm -rf {0}/dble/conf_*'.format(node.install_dir)
        ssh_client.exec_command(cmd)

        cmd = 'cp -r {0}/dble/conf {0}/dble/conf_bk'.format(dble_install_path)
        ssh_client.exec_command(cmd)
    else:
        cmd = 'mkdir -p {0}/dble/conf'.format(dble_install_path)
        ssh_client.exec_command(cmd)

    files = os.listdir(sourceCfgDir)
    for file in files:
        local_file = "{0}/{1}".format(sourceCfgDir, file)
        remote_file = "{0}/dble/conf/{1}".format(node.install_dir, file)
        node.sftp_conn.sftp_put(local_file, remote_file)

def check_dble_started(context, node):
    if not hasattr(context, "retry_start_dble"):
        context.retry_start_dble = 0
        context.dble_start_success = False

    dble_conn = None
    try:
        dble_conn = DBUtil(node.ip, node.manager_user, node.manager_password, "",
                           node.manager_port, context)
        res, err = dble_conn.query("show @@version")
    except MySQLdb.Error as e:
        err = e.args
    finally:
        if dble_conn: dble_conn.close()

    context.dble_start_success = err is None
    logger.debug(
        "dble started success:{0}, loop {1}, err:{2}".format(context.dble_start_success, context.retry_start_dble, err))
    if not context.dble_start_success:
        if context.retry_start_dble < 5:
            context.retry_start_dble = context.retry_start_dble + 1
            time.sleep(5)
            check_dble_started(context, node)
        else:
            logger.debug("dble started failed after 5 times try")
            cmd = "cat /opt/dble/logs/wrapper.log"
            rc, sto, ste = node.ssh_conn.exec_command(cmd)
            logger.debug("Please check the error message in wrapper.log:\n{0}".format(sto))
            delattr(context, "retry_start_dble")
    else:
        delattr(context, "retry_start_dble")

def check_dble_exist(ssh_client, dble_install_path):
    cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}' | wc -l"
    rc, sto, ste = ssh_client.exec_command(cmd)
    dble_pid_exist = str(sto) == '1'

    exist_cmd = "[ -f {0}/dble/bin/dble ] && (echo 1) || (echo 0)".format(dble_install_path)
    cd, out, err = ssh_client.exec_command(exist_cmd)
    dble_dir_exist = str(out) == '1'  # dble install dir exist

    logger.debug("dble dir exist: {0}, dble pid exist:{1}".format(dble_dir_exist, dble_pid_exist))
    return dble_pid_exist, dble_dir_exist

def download_type(context) -> str:
    if context.test_conf.get('ftp_user') \
            and context.test_conf.get('ftp_password') \
            and context.test_conf.get('dble_remote_host').startswith('ftp'):
        return 'ftp'
    return 'http'



def download_dble_package(context) -> str:
    dble_remote_path = context.test_conf["dble_remote_path"].format(
        DBLE_VERSION=context.test_conf['dble_version'],
        DBLE_PACKAGE_TIMESTAMP=context.test_conf['dble_package_timestamp'])
    remote_path = f'{context.test_conf["dble_remote_host"]}{dble_remote_path}'

    package_name = os.path.basename(remote_path)
    local_path = os.path.join(context.cfg_sys['share_path_docker'], package_name)

    # if not os.path.exists(local_path):
    kwargs = {'l': local_path,
                'r': remote_path}
    if download_type(context) == 'http':
        cmd = 'wget -q -O {l} {r}'.format(**kwargs)
        rc, _, ste = exec_command(cmd)
        assert_that(rc, equal_to(0), ste)
    else:
        kwargs.update({'u': context.test_conf['ftp_user'],
                        'p': context.test_conf['ftp_password']})

        cmd = 'wget -q -O {l} --ftp-user={u} --ftp-password={p} {r}'.format(
            **kwargs)
        rc, _, ste = exec_command(cmd)
        assert_that(rc, equal_to(0), ste)
    # else:
    #     LOGGER.debug('DBLE package is existing, not need download')

    return local_path