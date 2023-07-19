# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import os
import re
import time
import subprocess
import logging
import MySQLdb
from behave import *
from hamcrest import *
from behave.runner import Context
from steps.lib.DbleMeta import DbleMeta
from steps.lib.DBUtil import *
from steps.lib.utils import get_node, get_ssh, create_dir, exec_command, wait_for, sleep_by_time
# from lib.utils import wait_for, create_dir
LOGGER = logging.getLogger('root')


@Given('a clean environment in all dble nodes')
def clean_dble_in_all_nodes(context):
    for node in DbleMeta.dbles:
        uninstall_dble_in_node(context, node)


def uninstall_dble_in_node(context, node):
    dble_installed = stop_dble_in_node(context, node)

    if dble_installed:
        cmd = "cd {0} && rm -rf dble".format(node.install_dir)
        node.ssh_conn.exec_command(cmd)


@given('uninstall dble in "{hostname}"')
def unistall_dble_by_hostname(context, hostname):
    node = get_node(hostname)
    uninstall_dble_in_node(context, node)



# inner or outer
def download_type(context: Context) -> str:
    if context.test_conf.get('ftp_user') \
            and context.test_conf.get('ftp_password') \
            and context.test_conf.get('dble_remote_host').startswith('ftp'):
        return 'ftp'
    return 'http'


def download_dble_package(context: Context) -> str:
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

def set_wrapper_log_level(context, node, log_level):
    ssh_client = node.ssh_conn
    wrapper_log = '{0}/dble/bin/wrapper.conf'.format(node.install_dir)
    # 判断wrapper.console.loglevel，wrapper.logfile.loglevel两个参数的值
    cmd1 = "cat {0} | grep -i 'wrapper.console.loglevel' |cut -d= -f2 ".format(wrapper_log)
    _, sto1, ste1 = ssh_client.exec_command(cmd1)
    assert_that(len(ste1) == 0, "execute cmd: {0} failed for: {1}".format(cmd1,ste1))
    cmd2 = "cat {0} | grep -i 'wrapper.logfile.loglevel' |cut -d= -f2 ".format(wrapper_log)
    _, sto2, ste2 = ssh_client.exec_command(cmd2)
    assert_that(len(ste2) == 0, "execute cmd: {0} failed for: {1}".format(cmd2,ste2))
    # 调整为debug
    if (log_level in sto1.lower()) and (log_level in sto2.lower()):
        LOGGER.debug("wrapper log level is already: {0}, do nothing!".format(log_level))
        return False
    else:
        cmd = "sed -i 's/INFO/DEBUG/g' {0}".format(wrapper_log)
        _, sto, ste = ssh_client.exec_command(cmd)
        assert_that(len(ste) == 0, "execute cmd: {0} failed for: {1}".format(cmd, ste))
        return True

def change_wrapper_java_path(context, node):
    ssh_client = node.ssh_conn
    wrapper_log = '{0}/dble/bin/wrapper.conf'.format(node.install_dir)
    # 修改wrapper中的wrapper.java.command参数值为绝对路径
    cmd = "sed -i 's/=java/=\/opt\/jdk\/bin\/java/g' {0}".format(wrapper_log)
    _, sto, ste = ssh_client.exec_command(cmd)
    assert_that(len(ste) == 0, "execute cmd: {0} failed for: {1}".format(cmd, ste))

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
    assert_that(rc, equal_to(0), f"install dble failed, got err:{ste}")
    # set wrapper log level to debug
    # set_wrapper_log_level(context, node, 'debug')
    # change wrapper.java.command to absolute path
    # change_wrapper_java_path(context, node)

@Given('install dble in "{hostname}"')
def install_dble_in_host(context, hostname):
    node = get_node(hostname)
    install_dble_in_node(context, node)


@Given('install dble in all dble nodes')
def install_dble_in_all_nodes(context):
    for node in DbleMeta.dbles:
        install_dble_in_node(context, node)


def set_dbles_log_level(context, nodes, log_level):
    for node in nodes:
        set_dble_log_level(context, node, log_level)


def set_dble_log_level(context, node, log_level):
    ssh_client = node.ssh_conn
    str_awk = "awk 'FS=\" \" {print $2}'"
    cmd = "cat {0}/dble/conf/log4j2.xml | grep -e '<asyncRoot*' | {1} | cut -d= -f2 ".format(node.install_dir, str_awk)
    _, sto, _ = ssh_client.exec_command(cmd)

    if log_level in sto:
        LOGGER.debug("dble log level is already: {0}, do nothing!".format(log_level))
        return False
    else:
        log = '{0}/dble/conf/log4j2.xml'.format(node.install_dir)
        cmd = "sed -i 's/{0}/{1}/g' {2} ".format(sto[1:-1], log_level, log)
        ssh_client.exec_command(cmd)
        return True


@Given('set log4j2 log level to "{log_level}" in "{hostname}"')
def set_dble_log_level_in_host(context, log_level, hostname):
    node = get_node(hostname)
    set_dble_log_level(context, node, log_level)


@Given('Start dble in "{hostname}"')
@When('Start dble in "{hostname}"')
@Then('Start dble in "{hostname}"')
def start_dble_in_hostname(context, hostname):
    node = get_node(hostname)
    start_dble_in_node(context, node)


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

        if context.dble_start_success != expect_success:
            cmd2 = "cat /opt/dble/logs/wrapper.log"
            rc2, sto2, ste2 = node.ssh_conn.exec_command(cmd2)
            assert_that(len(ste2) == 0, "cat /opt/dble/logs/wrapper.log failed for: {0}".format(ste2))

            cmd3 = "free -h && cat /proc/loadavg"
            rc3, sto3, ste3 = node.ssh_conn.exec_command(cmd3)
            assert_that(len(ste3) == 0, "free -h && cat /proc/loadavg failed for: {0}".format(ste3))

            ####复制一份当时失败的 dble.pid 便于后续环境问题分析,不一定存在pid文件
            cmd4 = "cp /opt/dble/dble.pid /opt/dble/logs/dble{}.pid".format(time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime()))
            rc4, sto4, ste4 = node.ssh_conn.exec_command(cmd4)
            # assert_that(len(ste4) == 0, "cp failed for: {0}".format(ste4))

            assert_that(context.dble_start_success == expect_success, "Expect restart dble {0} success {1},but wrapper log is\n{2} ,\n\nthe:'{3}' :\n{4}".format(node.host_name, expect_success, sto2, cmd3, sto3))

        if not expect_success:
            expect_err_info = context.text.strip()
            for row in expect_err_info.splitlines():
                cmd = "grep -i \"{0}\" /opt/dble/logs/wrapper.log | wc -l".format(row.strip())
                rc, sto, ste = node.ssh_conn.exec_command(cmd)
                cmd_wrapper = "cat /opt/dble/logs/wrapper.log"
                rc1, sto1, ste1 = node.ssh_conn.exec_command(cmd_wrapper)
                assert_that(str(sto).strip() != "0", "expect dble restart failed for {} \nthe wrapper.log is:\n{}".format(row, sto1))


def check_dble_started(context, node):
    if not hasattr(context, "retry_start_dble"):
        context.retry_start_dble = 0
        context.dble_start_success = False

    cmd = "cat /opt/dble/logs/wrapper.log"
    rc, sto, ste = node.ssh_conn.exec_command(cmd)
    ###当wrapper.log已经告知有参数配置错误导致dble启动失败了，就不去循环5次判断dble已经完全启动成功
    if "Wrapper Stopped" in sto:
        LOGGER.debug("dble restart failed coz config wrapper.log:\n{0}".format(sto))
        delattr(context, "retry_start_dble")

        # dble启动失败之后收集一些信息用于分析失败具体原因,问题复现后去掉
        # if "Failed to resolve the version of Java" in sto:
        #     cmd10 = 'cp -n /opt/dble/bin/wrapper.conf /opt/dble/logs && mv /opt/dble/logs/wrapper.conf /opt/dble/logs/wrapper.conf.log'
        #     cmd11 = 'env >>/opt/dble/logs/env.log && java -version>>/opt/dble/logs/env.log 2>&1'
        #     rc10, sto10, ste10 = node.ssh_conn.exec_command(cmd10)
        #     assert_that(len(ste10) == 0, "exec command failed for: {0}".format(ste10))
        #     rc11, sto11, ste11 = node.ssh_conn.exec_command(cmd11)
        #     assert_that(len(ste11) == 0, "exec command failed for: {0}".format(ste10))

        return

    dble_conn = None
    try:
        dble_conn = DBUtil(node.ip, node.manager_user, node.manager_password, "",node.manager_port, context)
        res, err = dble_conn.query("show @@version")
    except MySQLdb.Error as e:
        err = e.args
    finally:
        if dble_conn: dble_conn.close()

    context.dble_start_success = err is None
    LOGGER.debug("dble started success:{0}, loop {1}, err:{2}".format(context.dble_start_success, context.retry_start_dble, err))
    if not context.dble_start_success:
        if context.retry_start_dble < 5:
            context.retry_start_dble = context.retry_start_dble + 1
            time.sleep(5)
            check_dble_started(context, node)
        else:
            LOGGER.debug("dble started failed after 5 times try")
            # cmd = "cat /opt/dble/logs/wrapper.log"
            # rc, sto, ste = node.ssh_conn.exec_command(cmd)
            LOGGER.debug("Please check the error message in wrapper.log:\n{0}".format(sto))
            delattr(context, "retry_start_dble")
    else:
        delattr(context, "retry_start_dble")

@Given("check dble started in all nodes")
def check_dble_started_in_all_nodes(context):
    for node in DbleMeta.dbles:
        check_dble_started(context, node)
    return True


@Given("stop all dbles")
def stop_dbles(context):
    for node in DbleMeta.dbles:
        stop_dble_in_node(context, node)


@Given('stop dble in "{hostname}"')
def step_impl(context, hostname):
    stop_dble_in_hostname(context, hostname)


@Then('stop dble in "{hostname}"')
def stop_dble_in_hostname(context, hostname):
    node = get_node(hostname)
    stop_dble_in_node(context, node)


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

    if dble_pid_exist:
        # stop dble gracefully to generate .exec for code coverage
        stop_dble_cmd = "{0}/dble/bin/dble stop".format(dble_install_path)
        rc1, sto1, ste1 = ssh_client.exec_command(stop_dble_cmd)
        assert_that(len(ste1) == 0, "stop dble fail for:{0}".format(ste1))

        condition(ssh_client)

    if dble_dir_exist:
        datetime = time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())
        rm_log_cmd = "[ -f {0}/dble/logs/wrapper.log ] && cd {0}/dble/logs && tar -zcf log_{1}.tar.gz *.log".format(
            dble_install_path, datetime)
        rc, sto, ste = ssh_client.exec_command(rm_log_cmd)
        assert_that(len(ste) == 0, "tar dble logs failed for: {0}".format(ste))

        rm_log_cmd = "rm -rf {0}/dble/logs/*.log".format(dble_install_path)
        rc, sto, ste = ssh_client.exec_command(rm_log_cmd)
        assert_that(len(ste) == 0, "rm dble logs failed for: {0}".format(ste))
    return dble_dir_exist


def check_dble_exist(ssh_client, dble_install_path):
    cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}' | wc -l"
    rc, sto, ste = ssh_client.exec_command(cmd)
    dble_pid_exist = str(sto) == '1'

    exist_cmd = "[ -f {0}/dble/bin/dble ] && (echo 1) || (echo 0)".format(dble_install_path)
    cd, out, err = ssh_client.exec_command(exist_cmd)
    dble_dir_exist = str(out) == '1'  # dble install dir exist

    LOGGER.debug("dble dir exist: {0}, dble pid exist:{1}".format(dble_dir_exist, dble_pid_exist))
    return dble_pid_exist, dble_dir_exist


def restart_dbles(context, nodes):
    stop_dbles(context)
    # sleep 4s to generate .exec for code coverage
    # time.sleep(4)
    if len(nodes) > 1:
        config_zk_in_dble_nodes(context, "all zookeeper hosts")
        reset_zk_nodes(context)

    start_dble_in_order(context)


@Then('restart dble in "{hostname}" failed for')
def check_restart_dble_failed(context, hostname):
    node = get_node(hostname)
    restart_dble(context, node, False)


@Then('start dble in "{hostname}" failed for')
def check_restart_dble_failed(context, hostname):
    node = get_node(hostname)
    start_dble_in_node(context, node, False)


@Then('Restart dble in "{hostname}" success use manager port "{manager_port}"')
@Given('Restart dble in "{hostname}" success')
@Then('Restart dble in "{hostname}" success')
def step_impl(context, hostname, manager_port=None):
    node = get_node(hostname)
    if manager_port:
        node.manager_port = int(manager_port)
    restart_dble(context, node)


def restart_dble(context, node, expect_success=True):
    stop_dble_in_node(context, node)
    start_dble_in_node(context, node, expect_success)


@Then('start dble in order')
def start_dble_in_order(context):
    start_dble_in_hostname(context, "dble-1")
    for node in DbleMeta.dbles:
        if "dble-1" not in node.host_name:
            start_dble_in_node(context, node)


def start_zk_services(context):
    for node in DbleMeta.dbles:
        start_zk_service(context, node)


def start_zk_service(context, node):
    if not hasattr(context, "retry_start_zk"):
        context.retry_start_zk = 0
        context.start_zk_service = False
    ssh_client = node.ssh_conn
    cmd_start = "{0}/bin/zkServer.sh start".format(context.cfg_zookeeper['home'])
    cmd_check_port = "netstat -anp|grep 2181"
    cmd_check_pid = "ps -ef | grep 'zookeeper' | grep -v grep | awk '{print $2}'"

    rc, sto, ste = ssh_client.exec_command(cmd_start)
    rc1, sto1, ste1 = ssh_client.exec_command(cmd_check_port)
    rc2, sto2, ste2 = ssh_client.exec_command(cmd_check_pid)

    if (sto.rfind('STARTED') == -1):
        LOGGER.debug("The use of port number 2181:{0}".format(sto1))
        LOGGER.debug("the pid of zookeeper:{0}".format(sto2))
        if context.retry_start_zk < 5:
            context.retry_start_zk = context.retry_start_zk + 1
            time.sleep(5)
            start_zk_service(context, node)
        else:
            LOGGER.info("zk started failed after 5 times try")
            delattr(context, "retry_start_zk")
    else:
        context.start_zk_service = True
        delattr(context, "retry_start_zk")

    assert_that(context.start_zk_service == True, "Expect start zk successful in {0},but failed".format(node))


# zk cluster must start all,there are waiting between them, then check status
def check_zk_status(context, node):
    if not hasattr(context, "zk_retry"):
        setattr(context, "zk_retry", 0)

    cmd_status = "{0}/bin/zkServer.sh status".format(context.cfg_zookeeper['home'])
    rc, sto, ste = node.ssh_conn.exec_command(cmd_status)
    zk_running = re.search("Mode", sto, re.I)

    if not zk_running and context.zk_retry < 3:
        context.zk_retry = context.zk_retry + 1
        time.sleep(3)
        check_zk_status(context, node)
    else:
        assert_that(sto, contains_string("Mode"))


def stop_zk_service(context, node):
    ssh_client = node.ssh_conn
    cmd = "{0}/bin/zkServer.sh stop".format(context.cfg_zookeeper['home'])
    rc, sto, ste = ssh_client.exec_command(cmd)
    stop_success = "no zookeeper to stop" in sto or "... STOPPED" in sto
    assert stop_success, "stop zkServer fail for: {0}".format(ste)


def restart_zk_service(context):
    for node in DbleMeta.dbles:
        stop_zk_service(context, node)

    for node in DbleMeta.dbles:
        start_zk_service(context, node)

    for node in DbleMeta.dbles:
        check_zk_status(context, node)


@Given('config zookeeper cluster in all dble nodes with "{hosts_form}"')
def config_zk_in_dble_nodes(context, hosts_form):
    for node in DbleMeta.dbles:
        conf_zk_in_node(context, node, hosts_form)

    restart_zk_service(context)


def conf_zk_in_node(context, node, hosts_form):
    ssh_client = node.ssh_conn
    cluster_conf = "{0}/dble/conf/cluster.cnf".format(node.install_dir)
    bootstrap_conf = "{0}/dble/conf/bootstrap.cnf".format(node.install_dir)
    # zk_server_ip=context.cfg_zookeeper['ip']
    zk_server_port = context.cfg_zookeeper['port']

    myid = node.host_name.split("-")[1]
    ssh_client.exec_command("echo {} > /opt/zookeeper/data/myid".format(myid))

    zk_server_id = "zookeeper-{0}".format(myid)
    zk_server_ip = context.cfg_zookeeper[zk_server_id]['ip']
    # LOGGER.info("zk_server_ip:{0}".format(zk_server_ip))
    if hosts_form == "local zookeeper host":
        # update cluster.cnf:
        cmd1 = "sed -i -e 's/clusterEnable=.*/clusterEnable=true/g' -e 's/clusterIP=.*/clusterIP={1}:{2}/g' -e 's/# rootPath=.*/rootPath=\/dble/g' {0}".format(
            cluster_conf, zk_server_ip, zk_server_port)
        # update bootstrap.cnf:
        cmd2 = "sed -i -e 's/instanceName=.*/instanceName={0}/g' -e 's/instanceId=.*/instanceId={0}/g' -e 's/serverId=.*/serverId=server_{0}/g' {1}".format(
            myid, bootstrap_conf)
    else:
        zk_server_ip_1 = context.cfg_zookeeper['zookeeper-1']['ip']
        zk_server_ip_2 = context.cfg_zookeeper['zookeeper-2']['ip']
        zk_server_ip_3 = context.cfg_zookeeper['zookeeper-3']['ip']
        cmd1 = "sed -i -e 's/clusterEnable=.*/clusterEnable=true/g' -e 's/clusterIP=.*/clusterIP={1}:{4},{2}:{4},{3}:{4}/g' -e 's/# rootPath=.*/rootPath=\/dble/g' {0}".format(
            cluster_conf, zk_server_ip_1, zk_server_ip_2, zk_server_ip_3, zk_server_port)
        cmd2 = "sed -i -e 's/instanceName=.*/instanceName={0}/g' -e 's/instanceId=.*/instanceId={0}/g' -e 's/serverId=.*/serverId=server_{0}/g' {1}".format(
            myid, bootstrap_conf)

    rc1, sto1, ste1 = ssh_client.exec_command(cmd1)
    rc2, sto2, ste2 = ssh_client.exec_command(cmd2)
    assert_that(ste1, is_(""), "expect std err empty, but was:{0}".format(ste1))
    assert_that(ste2, is_(""), "expect std err empty, but was:{0}".format(ste2))


def disable_cluster_config_in_node(context, node):
    conf_file = "{0}/dble/conf/cluster.cnf".format(node.install_dir)
    cmd = "[ -f {0} ] && sed -i 's/clusterEnable=.*/clusterEnable=false/g' {0}".format(conf_file)

    ssh_client = node.ssh_conn
    _, _, ste = ssh_client.exec_command(cmd)
    assert_that(ste, is_(""), "expect std err empty, but was:{0}".format(ste))


@given('stop dble cluster and zk service')
def dble_cluster_to_single(context):
    for node in DbleMeta.dbles:
        stop_dble_in_node(context, node)
        disable_cluster_config_in_node(context, node)
        stop_zk_service(context, node)


@Given('replace config files in all dbles with command line config')
def replace_config(context):
    for node in DbleMeta.dbles:
        replace_config_in_node(context, node)
        # set dble log level to debug
        # set_dble_log_level(context, node, 'debug')


@Given('replace config files in "{nodeName}" with command line config')
def step_impl(context, nodeName):
    node = get_node(nodeName)
    replace_config_in_node(context, node)


def replace_config_in_node(context, node):
    LOGGER.info("source config dir: {0}, pwd:{1}".format(context.dble_conf, os.getcwd()))

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

    # for code coverage start
    # sourcejarDir = "{0}/{1}".format(os.getcwd(), "assets")
    # local_jar="{0}/{1}".format(sourcejarDir,"jacocoagent.jar")
    # remote_jar="{0}/dble/lib/{1}".format(node.install_dir,"jacocoagent.jar")
    # node.sftp_conn.sftp_put(local_jar, remote_jar)
    # for code coverage end


@Given('reset dble registered nodes in zk')
def reset_zk_nodes(context):
    if not hasattr(context, "reset_zk_time"):
        context.reset_zk_time = 0

    node = get_node("dble-1")
    ssh_client = node.ssh_conn
    resetCmd = "cd {0}/zookeeper/bin && sh zkCli.sh deleteall /dble".format(node.install_dir)
    rc, sto, ste = ssh_client.exec_command(resetCmd)
    if context.reset_zk_time < 3:
        context.reset_zk_time = context.reset_zk_time + 1
        reset_zk_nodes(context)


@Then('Monitored folling nodes online')
def step_impl(context):
    text = context.text.strip()
    expectNodes = text.splitlines()

    check_cluster_successd(context, expectNodes)
    assert_that(context.check_zk_nodes_success == True,
                "Expect the online dbles detected by zk meet expectations,but failed")


def check_cluster_successd(context, expectNodes):
    if not hasattr(context, "retry_check_zk_nodes"):
        context.retry_check_zk_nodes = 0
        context.check_zk_nodes_success = False

    realNodes = []
    cmd = "cd {0}/bin && ./zkCli.sh ls /dble/cluster-1/online|grep -v ':'|grep -v ^$ ".format(
        context.cfg_zookeeper['home'])
    cmd_ssh = get_ssh("dble-1")
    rc, sto, ste = cmd_ssh.exec_command(cmd)
    LOGGER.debug("add debug to check the result of executing {0} is :sto:{1}".format(cmd, sto))
    sub_sto = re.findall(r'[\[](.*)[\]]', sto)
    LOGGER.debug("add debug to check the result of sub_sto is :{0}".format(sub_sto))
    nodes = sub_sto[0].replace(",", " ").split()
    LOGGER.debug("add debug to check the result of nodes is:{0}".format(nodes))

    for id in nodes:
        LOGGER.info("id:{0}".format(id))
        hostname = "dble-{0}".format(id)
        realNodes.append(hostname)

    if (expectNodes == realNodes):
        context.check_zk_nodes_success = True
    if not context.check_zk_nodes_success:
        if context.retry_check_zk_nodes < 10:
            context.retry_check_zk_nodes = context.retry_check_zk_nodes + 1
            time.sleep(10)
            check_cluster_successd(context, expectNodes)
        else:
            LOGGER.info(
                "The online dbles detected by zk do not meet expectations after 10 times try,expectNodes:{0},realNodes:{1}".format(
                    expectNodes, realNodes))
            delattr(context, "retry_check_zk_nodes")
    else:
        delattr(context, "retry_check_zk_nodes")

@Then('check zk has "{flag}" the following values in "{zk_path}" with retry "{retry_param}" times in "{hostname}"')
def step_impl(context, zk_path, flag="Y", retry_param=1, hostname="dble-1"):
    strs = context.text.strip()
    strs_list = strs.splitlines()

    ssh_client = get_ssh(hostname)
    for linestr in strs_list:
        #目前取最后10行（主要是排除过多的登录信息），如果有其他需求可以自行修改
        cmd = "cd {0}/bin && (./zkCli.sh ls {1}) | tail -10 |grep -E -n \"{2}\"".format(context.cfg_zookeeper['home'],zk_path,linestr)
        LOGGER.debug("check cmd is: {}".format(cmd))
        retry_exec_command(context, ssh_client, linestr, cmd, zk_path, retry_param,flag)

@Then('check zk has "{flag}" the following values get "{zk_path}" with retry "{retry_param}" times in "{hostname}"')
def step_impl(context, zk_path, flag="Y", retry_param=1, hostname="dble-1"):
    strs = context.text.strip()
    strs_list = strs.splitlines()

    ssh_client = get_ssh(hostname)
    for linestr in strs_list:
        #目前取最后10行（主要是排除过多的登录信息），如果有其他需求可以自行修改
        cmd = "cd {0}/bin && ./zkCli.sh get {1} | tail -10 |grep -E -n \"{2}\"".format(context.cfg_zookeeper['home'],zk_path,linestr)
        LOGGER.debug("check cmd is: {}".format(cmd))
        retry_exec_command(context, ssh_client, linestr, cmd, zk_path, retry_param,flag)



def retry_exec_command(context, ssh_client, linestr, cmd, zk_path, retry_param,flag):
    if "," in str(retry_param):
        retry_times = int(retry_param.split(",")[0])
        sep_time = float(retry_param.split(",")[1])
    else:
        retry_times = int(retry_param)
        sep_time = 1

    execute_times = retry_times + 1
    for i in range(execute_times):
        try:
            rc, stdout, stderr = ssh_client.exec_command(cmd)
            assert_that(len(stderr) == 0, "the command:{1}, got err:{0}".format(stderr, cmd))

            if flag == "not":
                assert_that(len(stdout) == 0, "expect has not \"{0}\" in zk \"{1}\",but has，\nthe real output is {2}".format(linestr, zk_path, stdout))
            else:
                assert_that(len(stdout) > 0, "expect has \"{0}\" in zk \"{1}\",but has not，\nthe real output is {2}".format(linestr, zk_path, stdout))
            break
        except Exception as e:
            if flag == "not":
                LOGGER.debug("check has {0} value in zk {1} , execute {2} times".format(flag,zk_path,i+1))
            else:
                LOGGER.debug("check has value in zk {0} , execute {1} times".format(zk_path,i+1))

            if i == execute_times - 1:
                raise e
            else:
                sleep_by_time(context, sep_time)