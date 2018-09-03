import time
import os
import logging
import re
from behave import *
from behave.textutil import text
from hamcrest import *

from lib.Node import get_node, get_ssh
from steps.step_check_sql import connect_test

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
    ssh_client =node.ssh_conn
    if context.need_download:
        context.execute_steps(u'Given download dble')
    dble_packget = "{0}".format(context.cfg_dble['packet_name'])

    cmd = "cd {0} && rm -rf {1}".format(context.cfg_dble['install_dir'], dble_packget)
    ssh_client.exec_command(cmd)

    cmd = "cd {0} && cp -r {1} {2}".format(context.cfg_sys['share_path_docker'], dble_packget,
                                           context.cfg_dble['install_dir'])
    ssh_client.exec_command(cmd)
    cmd = "cd {0} && tar xf {1}".format(context.cfg_dble['install_dir'], dble_packget)
    ssh_client.exec_command(cmd)

    replace_config_in_node(context, context.cfg_dble['base_conf'], node)

@Given('install dble in "{hostname}"')
def install_dble_in_host(context, hostname):
    node = get_node(context.dbles, hostname)
    install_dble_in_node(context, node)

@Given('install dble in all dble nodes')
def install_dble_in_all_nodes(context):
    for node in context.dbles:
        install_dble_in_node(context, node)

@Then('Start dble in "{hostname}"')
def start_dble_in_hostname(context, hostname):
    node = get_node(context.dbles, hostname)
    start_dble_in_node(context, node)

def start_dble_in_node(context, node):
    ssh_client = node.ssh_conn
    cmd = "cd {0} && (./dble/bin/dble start)".format(context.cfg_dble['install_dir'])
    ssh_client.exec_command(cmd)
    context.retry = 0
    check_dble_started(context, ssh_client)

def check_dble_started(context, ssh_client):
    time.sleep(5)
    cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'"
    rc, sto, ste = ssh_client.exec_command(cmd)
    context.dble_status="success"
    if len(sto) == 0:
        if context.retry < 5:
            context.retry = context.retry+1
            check_dble_started(context, ssh_client)
        else:
            assert_that(False,"start dble service fail in 25 seconds!")
            context.dble_status = "fail"
    else:
        LOGGER.info("start dble success !!!")

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
    dble_exist = check_dble_exist(ssh_client, dble_install_path)

    if dble_exist:
        cmd = "cd {0} && (./dble/bin/dble stop)".format(dble_install_path)
        ssh_client.exec_command(cmd)
        time.sleep(3)
        cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'"
        rc, sto, ste = ssh_client.exec_command(cmd)
        assert_that(ste.find(" "), "stop dble  service fail for:{0}".format(ste))
    return dble_exist

def check_dble_exist(ssh_client, dble_install_path):
    exist_cmd = "if [ -d {0}/dble ];then echo 1;else echo 0; fi".format(dble_install_path)
    cd, out, err = ssh_client.exec_command(exist_cmd)
    dble_exist = str(out)=='1'# dble install dir exist
    LOGGER.debug("dble dir exist: {0}".format(dble_exist))
    return dble_exist

@Given('download dble')
def download_dble(context):
    LOGGER.info("delete local dble packet")
    rpm_local_path = "{0}/{1}".format(context.cfg_sys['share_path_agent'],
                               context.cfg_dble['packet_name'])
    rpm_ftp_url = "{0}{1}".format(context.cfg_dble['ftp_path'],
                              context.cfg_dble['packet_name'])
    cmd = 'rm -rf {0}'.format(rpm_local_path)
    os.system(cmd)

    cmd = 'cd {0} && wget --user=ftp --password=ftp -nv {1}'.format(context.cfg_sys['share_path_agent'],
                                                                    rpm_ftp_url)
    os.popen(cmd)

    cmd = "find {0} -maxdepth 1 -name {1} | wc -l".format(context.cfg_sys['share_path_agent'],
                                                          context.cfg_dble['packet_name'])
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

@Given('Set the log level to "{log_level}"')
def change_log_level(context, log_level, hostname):
    node = get_node(context.dbles, hostname)
    set_dble_log_level(context, node, log_level)

def restart_dbles(context, nodes):
    for node in nodes:
        restart_dble(context, node)

    if len(nodes) > 1:
        config_zk_in_dble_nodes(context)
        restart_zk_service(context)

def restart_dble(context, node):
    stop_dble_in_node(context, node)
    start_dble_in_node(context, node)

    if context.dble_status=="success":
        user = context.cfg_dble['manager_user']
        passwd = str(context.cfg_dble['manager_password'])
        port = context.cfg_dble['manager_port']
        LOGGER.info("############################manager_user:{0}".format(user))
        connect_test(context, node.ip, user, passwd, port)

@Given('Restart dble in "{hostname}"')
def step_impl(context, hostname):
    node = get_node(context.dbles, hostname)
    restart_dble(context, node)

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

@Given('config zookeeper cluster in all dble nodes')
def config_zk_in_dble_nodes(context):
    for node in context.dbles:
        conf_zk_in_node(context, node)

    restart_zk_service(context)

def conf_zk_in_node(context, node):
    ssh_client = node.ssh_conn
    conf_file = "{0}/dble/conf/myid.properties".format(context.cfg_dble['install_dir'])
    zk_server_ip=context.cfg_zookeeper['ip']
    zk_server_port=context.cfg_zookeeper['port']

    myid = node.host_name.split("-")[1]
    cmd = "sed -i -e 's/cluster=.*/cluster=zk/g' -e 's/ipAddress=.*/ipAddress={2}/g' -e 's/port=.*/port={3}/g' -e 's/myid=.*/myid={0}/g' {1}".format(myid, conf_file, zk_server_ip, zk_server_port)
    rc, sto, ste = ssh_client.exec_command(cmd)
    assert_that(ste, is_(""))

def disable_cluster_config_in_node(context, node):
    conf_file = "{0}/dble/conf/myid.properties".format(context.cfg_dble['install_dir'])
    cmd = "sed -i 's/cluster=.*/cluster=false/g' {0}".format(conf_file)

    ssh_client = node.ssh_conn
    rc, sto, ste = ssh_client.exec_command(cmd)
    assert_that(ste, is_(""))

@given('change zk cluster to single mode')
def dble_cluster_to_single(context):
    for node in context.dbles:
        stop_dble_in_node(context, node)
        disable_cluster_config_in_node(context, node)
        stop_zk_service(context, node)

    LOGGER.info("Start only the Dble service on the node dble-1")
    start_dble_in_hostname(context, "dble-1")

def replace_config(context, sourceCfgDir):
    for node in context.dbles:
        replace_config_in_node(context,sourceCfgDir,node)

def replace_config_in_node(context, sourceCfgDir, node):
    LOGGER.info("source config dir: {0}".format(sourceCfgDir))

    osCmd = 'rm -rf {0} && cp -r {0}_bk {0}'.format(sourceCfgDir)
    os.system(osCmd)

    ssh_client = node.ssh_conn
    dble_install_path = context.cfg_dble['install_dir']
    dble_exist = check_dble_exist(ssh_client, dble_install_path)

    if dble_exist:
        cmd = 'rm -rf {0}/dble/conf_*'.format(context.cfg_dble['install_dir'])
        ssh_client.exec_command(cmd)

    cmd = 'cp -r {0}/dble/conf {0}/dble/conf_bk'.format(dble_install_path)
    ssh_client.exec_command(cmd)

    files = os.listdir(sourceCfgDir)
    for file in files:
        local_file = "{0}/{1}".format(sourceCfgDir, file)
        remove_file = "{0}/dble/conf/{1}".format(context.cfg_dble['install_dir'], file)
        node.sftp_conn.sftp_put(remove_file, local_file)