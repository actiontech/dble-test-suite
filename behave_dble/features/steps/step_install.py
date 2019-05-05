import os
import re
import time

import MySQLdb
from behave import *
from hamcrest import *

from lib.DBUtil import *
from lib.Node import get_node, get_ssh

LOGGER = logging.getLogger('steps.install')

@Given('a clean environment in all dble nodes')
def clean_dble_in_all_nodes(context):
    for node in context.dbles:
        uninstall_dble_in_node(context, node)

def uninstall_dble_in_node(context, node):
    dble_installed = stop_dble_in_node(context, node)

    if dble_installed:
        cmd = "cd {0} && rm -rf dble".format(context.cfg_dble['install_dir'])
        node.ssh_conn.exec_command(cmd)

@given('uninstall dble in "{hostname}"')
def unistall_dble_by_hostname(context, hostname):
    node = get_node(context.dbles, hostname)
    uninstall_dble_in_node(context, node)

def install_dble_in_node(context, node):
    if context.need_download:
        download_dble(context)

    ssh_client =node.ssh_conn
    dble_packget = "{0}".format(context.cfg_dble['packet_name'])

    cmd = "cd {0} && rm -rf {1} dble".format(context.cfg_dble['install_dir'], dble_packget)
    ssh_client.exec_command(cmd)

    cmd = "cd {0} && cp -r {1} {2}".format(context.cfg_sys['share_path_docker'], dble_packget,
                                           context.cfg_dble['install_dir'])
    ssh_client.exec_command(cmd)
    cmd = "cd {0} && tar xf {1}".format(context.cfg_dble['install_dir'], dble_packget)
    ssh_client.exec_command(cmd)

@Given('install dble in "{hostname}"')
def install_dble_in_host(context, hostname):
    node = get_node(context.dbles, hostname)
    install_dble_in_node(context, node)

@Given('install dble in all dble nodes')
def install_dble_in_all_nodes(context):
    for node in context.dbles:
        install_dble_in_node(context, node)

@Given('download dble')
def download_dble(context):
    LOGGER.info("delete local dble packet")
    rpm_local_path = "{0}/{1}".format(context.cfg_sys['share_path_agent'],
                               context.cfg_dble['packet_name'])
    rpm_ftp_url = "{0}{1}".format(context.cfg_dble['ftp_path'],
                              context.cfg_dble['packet_name'])
    cmd = 'rm -rf {0}'.format(rpm_local_path)
    exit_status = os.system(cmd)
    LOGGER.debug("cmd:{0}, exit_status:{1}".format(cmd, exit_status))

    cmd = 'cd {0} && wget --user=ftp --password=ftp -nv {1}'.format(context.cfg_sys['share_path_agent'],
                                                                    rpm_ftp_url)
    LOGGER.info(cmd)
    os.popen(cmd)

    cmd = "find {0} -maxdepth 1 -name {1} | wc -l".format(context.cfg_sys['share_path_agent'],
                                                          context.cfg_dble['packet_name'])
    LOGGER.info(cmd)
    str = os.popen(cmd).read()
    assert_that(str.strip(), equal_to('1'), "Download dble tar fail")

def set_dbles_log_level(context, nodes, log_level):
    for node in nodes:
        set_dble_log_level(context, node, log_level)

def set_dble_log_level(context, node, log_level):
    ssh_client = node.ssh_conn
    str_awk = "awk 'FS=\" \" {print $2}'"
    cmd = "cat {0}/dble/conf/log4j2.xml | grep -e '<asyncRoot*' | {1} | cut -d= -f2 ".format(context.cfg_dble['install_dir'], str_awk)
    rc, sto, ste = ssh_client.exec_command(cmd)

    if log_level in sto:
        LOGGER.info("dble log level is already: {0}, do nothing!".format(log_level))
        return False
    else:
        log = '{0}/dble/conf/log4j2.xml'.format(context.cfg_dble['install_dir'])
        cmd = "sed -i 's/{0}/{1}/g' {2} ".format(sto[1:-1], log_level, log)
        ssh_client.exec_command(cmd)
        return True

@Then('Start dble in "{hostname}"')
def start_dble_in_hostname(context, hostname):
    node = get_node(context.dbles, hostname)
    start_dble_in_node(context, node)

def start_dble_in_node(context, node, expect_success=True):
    ssh_client = node.ssh_conn
    cmd = "{0}/dble/bin/dble start".format(context.cfg_dble['install_dir'])
    ssh_client.exec_command(cmd)

    check_dble_started(context, node)

    assert_that(context.dble_start_success==expect_success, "Expect restart dble success {0}".format(expect_success))

    if not expect_success:
        expect_errInfo = context.text.strip()
        cmd = "grep -i \"{0}\" /opt/dble/logs/wrapper.log | wc -l".format(expect_errInfo)
        rc, sto, ste = node.ssh_conn.exec_command(cmd)
        assert_that(sto, not equal_to_ignoring_whitespace("0"), "expect dble restart failed for {0}".format(expect_errInfo))

def check_dble_started(context, node):
    if not hasattr(context, "retry_start_dble"):
        context.retry_start_dble = 0
        context.dble_start_success= False
        
    ip = node._ip
    dble_conn = None
    try:
        dble_conn = DBUtil(ip, context.cfg_dble['manager_user'], context.cfg_dble['manager_password'], "",
                           context.cfg_dble['manager_port'], context)
        res, err = dble_conn.query("show @@version")
    except MySQLdb.Error, e:
        err = e.args
    finally:
        if dble_conn:dble_conn.close()

    context.dble_start_success = err is None
    LOGGER.info("dble started success:{0}, loop {1}, err:{2}".format(context.dble_start_success, context.retry_start_dble, err))
    if not context.dble_start_success:
        if context.retry_start_dble < 5:
            context.retry_start_dble = context.retry_start_dble+1
            time.sleep(5)
            check_dble_started(context,node)
        else:
            LOGGER.info("dble started failed after 5 times try")
            delattr(context, "retry_start_dble")
    else:
        delattr(context, "retry_start_dble")

@Given("stop all dbles")
def stop_dbles(context):
    for node in context.dbles:
        stop_dble_in_node(context, node)

@Then('stop dble in "{hostname}"')
def stop_dble_in_hostname(context, hostname):
    node = get_node(context.dbles, hostname)
    stop_dble_in_node(context, node)

def stop_dble_in_node(context, node):
    ssh_client = node.ssh_conn
    dble_install_path = context.cfg_dble['install_dir']
    dble_pid_exist,dble_dir_exist = check_dble_exist(ssh_client, dble_install_path)

    if dble_pid_exist:
        cmd_guard = "ps -ef|grep dble|grep 'start'| grep -v grep | awk '{print $3}' | xargs kill -9"
        cmd_core = "ps -ef|grep dble|grep 'start'| grep -v grep | awk '{print $2}' | xargs kill -9"
        rc1, sto1, ste1 = ssh_client.exec_command(cmd_guard)
        rc2, sto2, ste2 = ssh_client.exec_command(cmd_core)
        assert_that(len(ste1)==0 and len(ste2)==0, "kill dble process fail for:{0},{1}".format(ste1,ste2))

    if dble_dir_exist:
        datetime=time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())
        rm_log_cmd="[ -f {0}/dble/logs/dble.log ] && cd {0}/dble/logs && tar -zcf log_{1}.tar.gz *.log".format(dble_install_path, datetime)
        rc, sto, ste = ssh_client.exec_command(rm_log_cmd)
        assert_that(len(ste)==0, "tar dble logs failed for: {0}".format(ste))

        rm_log_cmd="rm -rf {0}/dble/logs/*.log".format(dble_install_path)
        rc, sto, ste = ssh_client.exec_command(rm_log_cmd)
        assert_that(len(ste)==0, "rm dble logs failed for: {0}".format(ste))
    return dble_dir_exist

def check_dble_exist(ssh_client, dble_install_path):
    cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}' | wc -l"
    rc, sto, ste = ssh_client.exec_command(cmd)
    dble_pid_exist = str(sto)=='1'

    exist_cmd = "[ -f {0}/dble/bin/dble ] && (echo 1) || (echo 0)".format(dble_install_path)
    cd, out, err = ssh_client.exec_command(exist_cmd)
    dble_dir_exist = str(out)=='1'# dble install dir exist

    LOGGER.debug("dble dir exist: {0}, dble pid exist:{1}".format(dble_dir_exist, dble_pid_exist))
    return dble_pid_exist, dble_dir_exist

def restart_dbles(context, nodes):
    stop_dbles(context)

    if len(nodes) > 1:
        config_zk_in_dble_nodes(context,"all zookeeper hosts")
        reset_zk_nodes(context)

    start_dble_in_order(context)

@Then('restart dble in "{hostname}" failed for')
def check_restart_dble_failed(context,hostname):
    node = get_node(context.dbles, hostname)
    restart_dble(context, node, False)

@Given('Restart dble in "{hostname}" success')
def step_impl(context, hostname):
    node = get_node(context.dbles, hostname)
    restart_dble(context, node)

def restart_dble(context, node, expect_success=True):
    stop_dble_in_node(context, node)
    start_dble_in_node(context, node, expect_success)

@Then('start dble in order')
def start_dble_in_order(context):
    start_dble_in_hostname(context, "dble-1")
    for node in context.dbles:
        if "dble-1" not in node.host_name:
            start_dble_in_node(context, node)

def start_zk_services(context):
    for node in context.dbles:
        start_zk_service(context, node)

def start_zk_service(context, node):
    ssh_client = node.ssh_conn
    cmd_start = "{0}/bin/zkServer.sh start".format(context.cfg_zookeeper['home'])
    rc, sto, ste = ssh_client.exec_command(cmd_start)
    assert_that(sto, contains_string("STARTED"))

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
    for node in context.dbles:
        stop_zk_service(context, node)

    for node in context.dbles:
        start_zk_service(context, node)

    for node in context.dbles:
        check_zk_status(context, node)

@Given('config zookeeper cluster in all dble nodes with "{hosts_form}"')
def config_zk_in_dble_nodes(context,hosts_form):
    for node in context.dbles:
        conf_zk_in_node(context, node,hosts_form)

    restart_zk_service(context)

def conf_zk_in_node(context,node,hosts_form):
    ssh_client = node.ssh_conn
    conf_file = "{0}/dble/conf/myid.properties".format(context.cfg_dble['install_dir'])
    # zk_server_ip=context.cfg_zookeeper['ip']
    zk_server_port=context.cfg_zookeeper['port']

    myid = node.host_name.split("-")[1]
    zk_server_id = "zookeeper-{0}".format(myid)
    zk_server_ip = context.cfg_zookeeper[zk_server_id]['ip']
    # LOGGER.info("zk_server_ip:{0}".format(zk_server_ip))
    if hosts_form == "local zookeeper host":
        cmd = "sed -i -e 's/cluster=.*/cluster=zk/g' -e 's/ipAddress=.*/ipAddress={2}:{3}/g' -e '/port=.*/d' -e 's/myid=.*/myid={0}/g' -e 's/serverID=.*/serverID=server_{0}/g' {1}".format(myid, conf_file, zk_server_ip, zk_server_port)
    else:
        zk_server_ip_1 = context.cfg_zookeeper['zookeeper-1']['ip']
        zk_server_ip_2 = context.cfg_zookeeper['zookeeper-2']['ip']
        zk_server_ip_3 = context.cfg_zookeeper['zookeeper-3']['ip']
        cmd = "sed -i -e 's/cluster=.*/cluster=zk/g' -e 's/ipAddress=.*/ipAddress={2}:{5},{3}:{5},{4}:{5}/g' -e '/port=.*/d' -e 's/myid=.*/myid={0}/g' -e 's/serverID=.*/serverID=server_{0}/g' {1}".format(myid, conf_file, zk_server_ip_1,zk_server_ip_2,zk_server_ip_3,zk_server_port)

    rc, sto, ste = ssh_client.exec_command(cmd)
    assert_that(ste, is_(""), "expect std err empty, but was:{0}".format(ste))

def disable_cluster_config_in_node(context, node):
    conf_file = "{0}/dble/conf/myid.properties".format(context.cfg_dble['install_dir'])
    cmd = "[ -f {0} ] && sed -i 's/cluster=.*/cluster=false/g' {0}".format(conf_file)

    ssh_client = node.ssh_conn
    rc, sto, ste = ssh_client.exec_command(cmd)
    assert_that(ste, is_(""), "expect std err empty, but was:{0}".format(ste))

@given('stop dble cluster and zk service')
def dble_cluster_to_single(context):
    for node in context.dbles:
        stop_dble_in_node(context, node)
        disable_cluster_config_in_node(context, node)
        stop_zk_service(context, node)

@Given('replace config files in all dbles with command line config')
def replace_config(context):
    for node in context.dbles:
        replace_config_in_node(context,node)

@Given('replace config files in "{nodeName}" with command line config')
def step_impl(context, nodeName):
    node = get_node(context.dbles, nodeName)
    replace_config_in_node(context, node)

def replace_config_in_node(context, node):
    LOGGER.info("source config dir: {0}, pwd:{1}".format(context.dble_conf, os.getcwd()))

    sourceCfgDir = "{0}/{1}".format(os.getcwd(),context.dble_conf)
    osCmd = 'rm -rf {0} && cp -r {0}_bk {0}'.format(sourceCfgDir)
    os.system(osCmd)

    ssh_client = node.ssh_conn
    dble_install_path = context.cfg_dble['install_dir']
    dble_pid_exist,dble_dir_exist = check_dble_exist(ssh_client, dble_install_path)

    if dble_dir_exist:
        cmd = 'rm -rf {0}/dble/conf_*'.format(context.cfg_dble['install_dir'])
        ssh_client.exec_command(cmd)

        cmd = 'cp -r {0}/dble/conf {0}/dble/conf_bk'.format(dble_install_path)
        ssh_client.exec_command(cmd)
    else:
        cmd = 'mkdir -p {0}/dble'.format(dble_install_path)
        ssh_client.exec_command(cmd)

    files = os.listdir(sourceCfgDir)
    for file in files:
        local_file = "{0}/{1}".format(sourceCfgDir, file)
        remote_file = "{0}/dble/conf/{1}".format(context.cfg_dble['install_dir'], file)
        LOGGER.info("sftp from: {0} to {1}".format(local_file, remote_file))
        node.sftp_conn.sftp_put(local_file, remote_file)

@Given('reset dble registered nodes in zk')
def reset_zk_nodes(context):
    resetCmd = "cd {0}/zookeeper/bin && sh zkCli.sh rmr /dble".format(context.cfg_dble["install_dir"])
    ssh_client = get_ssh(context.dbles, "dble-1")
    ssh_client.exec_command(resetCmd)

@Then ('Monitored folling nodes online')
def step_impl(context):
    text = context.text.strip().encode('utf-8')
    expectNodes = text.splitlines()
    
    check_cluster_successd(context, expectNodes)
    assert_that(context.check_zk_nodes_success == True, "Expect the online dbles detected by zk meet expectations,but failed")
    
def check_cluster_successd(context, expectNodes):
    if not hasattr(context, "retry_check_zk_nodes"):
        context.retry_check_zk_nodes = 0
        context.check_zk_nodes_success = False

    realNodes = []
    cmd = "cd {0}/bin && ./zkCli.sh ls /dble/cluster-1/online ".format(context.cfg_zookeeper['home'])
    cmd_ssh = get_ssh(context.dbles, "dble-1")
    rc, sto, ste = cmd_ssh.exec_command(cmd)
    sub_sto = re.findall(r'[[](.*)[]]', sto[-15:])
    nodes = sub_sto[0].replace(",", " ").split()

    for id in nodes:
        LOGGER.info("id:{0}".format(id))
        hostname = "dble-{0}".format(id)
        realNodes.append(hostname)

    if (expectNodes == realNodes):
        context.check_zk_nodes_success = True
    if not context.check_zk_nodes_success:
        if context.retry_check_zk_nodes < 5:
            context.retry_check_zk_nodes = context.retry_check_zk_nodes + 1
            time.sleep(10)
            check_cluster_successd(context, expectNodes)
        else:
            LOGGER.info("The online dbles detected by zk do not meet expectations after 5 times try,expectNodes:{0},realNodes:{1}".format(expectNodes, realNodes))
            delattr(context, "retry_check_zk_nodes")
    else:
        delattr(context, "retry_check_zk_nodes")

    