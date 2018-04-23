import time
import os
import logging
import re
from behave import *
from hamcrest import *

from lib.Node import get_node, get_ssh
from steps.step_check_sql import connect_test

LOGGER = logging.getLogger('steps.install')

@Given('a clean environment in all dble nodes')
def clean_dble_in_all_nodes(context):
    for node in context.dbles:
        uninstall_dble_in_node(context, node)

def uninstall_dble_in_node(context, node):
    ssh_client = node.ssh_conn
    cmd_status = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'"
    rc, sto, ste = ssh_client.exec_command(cmd_status)
    if len(sto) != 0:
        LOGGER.info("dble is running, try to stop")
        cmd = "cd {0} && (./dble/bin/dble stop)".format(context.dble_test_config['dble_basepath'])
        ssh_client.exec_command(cmd)
        rc, sto, ste = ssh_client.exec_command(cmd_status)

        if len(sto) != 0:
            LOGGER.info("execute dble stop fail, try to kill!")
            cmd = "kill {0} {1}".format(sto[0], sto[1])
            ssh_client.exec_command(cmd)
            rc, sto, ste = ssh_client.exec_command(cmd_status)
            assert_that(len(sto) == 0, "kill dble process fail for: {0}".format(ste))

    cmd = "cd {0} && rm -rf dble".format(context.dble_test_config['dble_basepath'])
    ssh_client.exec_command(cmd)

@given('uninstall dble in "{hostname}"')
def unistall_dble_by_hostname(context, hostname):
    node = get_node(context.dbles, hostname)
    uninstall_dble_in_node(context, node)

def install_dble_in_node(context, node):
    ssh_client =node.ssh_conn
    dble_packget = ""
    if context.need_download == False:
        dble_packget = "{0}".format(context.dble_test_config['dble']['local_packget'])
    else:
        context.execute_steps(u'Given download dble')
        dble_packget = "{0}".format(context.dble_test_config['dble']['remote_packget'])
    cmd = "cd {0} && sudo rm -rf {1}".format(context.dble_test_config['dble_basepath'], dble_packget)
    ssh_client.exec_command(cmd)
    cmd = "cd {0} && sudo cp -r {1} {2}".format(context.dble_test_config['share_path_docker'], dble_packget,
                                           context.dble_test_config['dble_basepath'])
    ssh_client.exec_command(cmd)
    cmd = "cd {0} && tar xf {1}".format(context.dble_test_config['dble_basepath'], dble_packget)
    ssh_client.exec_command(cmd)

    replace_config_in_node(context, context.dble_test_config['dble_base_conf'], node)

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
    cmd = "cd {0} && (./dble/bin/dble start)".format(context.dble_test_config['dble_basepath'])
    ssh_client.exec_command(cmd)
    context.retry = 0
    check_dble_started(context, ssh_client)

def check_dble_started(context, ssh_client):
    time.sleep(5)
    cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'"
    rc, sto, ste = ssh_client.exec_command(cmd)
    if len(sto) == 0:
        if context.retry < 5:
            context.retry = context.retry+1
            check_dble_started(context, ssh_client)
        else:
            assert_that(False, "start dble service fail in 25 seconds!")
    else:
        LOGGER.info("start dble success !!!")

@Then('stop dble in "{hostname}"')
def stop_dble_in_hostname(context, hostname):
    node = get_node(context.dbles, hostname)
    stop_dble_in_node(context, node)

def stop_dble_in_node(context, node):
    ssh_client = node.ssh_conn
    cmd = "cd {0} && (./dble/bin/dble stop)".format(context.dble_test_config['dble_basepath'])
    ssh_client.exec_command(cmd)
    time.sleep(3)
    cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'"
    rc, sto, ste = ssh_client.exec_command(cmd)
    assert_that(ste.find(" "), "stop dble  service fail for:{0}".format(ste))

@Given('download dble')
def download_dble(context):
    LOGGER.info("delete local dble  packget")
    dir_rpm = "{0}/{1}".format(context.dble_test_config['share_path_agent'],
                               context.dble_test_config['dble']['remote_packget'])
    ftp_url = "{0}{1}".format(context.dble_test_config['dble']['remote_path'],
                              context.dble_test_config['dble']['remote_packget'])
    cmd = 'rm -rf {0}'.format(dir_rpm)
    os.system(cmd)

    cmd = 'cd {0} && wget --user=ftp --password=ftp -nv {1}'.format(context.dble_test_config['share_path_agent'],
                                                                    ftp_url)
    os.popen(cmd)

    cmd = "find {0} -maxdepth 1 -name {1} | wc -l".format(context.dble_test_config['share_path_agent'],
                                                          context.dble_test_config['dble']['remote_packget'])
    str = os.popen(cmd).read()
    assert_that(str.strip(), equal_to('1'), "Download dble tar fail")

def check_dble_running_in_node(context, node):
    ssh_client = node.ssh_conn
    cmd = "sh {0}/dble/bin/dble status".format(context.dble_test_config['dble_basepath'])
    rc, sto, ste = ssh_client.exec_command(cmd)
    if sto.find("dble-server is running") != -1:
        return True
    return False

def set_dbles_log_level(context, nodes, log_level):
    for node in nodes:
        set_dble_log_level(context, node, log_level)

def set_dble_log_level(context, node, log_level):
    ssh_client = node.ssh_conn
    str_awk = "awk 'FS=\" \" {print $2}'"
    cmd = "cat {0}/dble/conf/log4j2.xml | grep -e '<asyncRoot*' | {1} | cut -d= -f2 ".format(context.dble_test_config['dble_basepath'], str_awk)
    rc, sto, ste = ssh_client.exec_command(cmd)

    if log_level in sto:
        LOGGER.info("dble log level is already: {0}, do nothing!".format(log_level))
        return False
    else:
        log = '{0}/dble/conf/log4j2.xml'.format(context.dble_test_config['dble_basepath'])
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
    time.sleep(3)
    check_dble_running_in_node(context, node)

    user = context.dble_test_config['manager_user']
    passwd = str(context.dble_test_config['manager_password'])
    port = context.dble_test_config['manager_port']
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
    if not hasattr(context, "zk_retry"):
        setattr(context, "zk_retry", 0)
    ssh_client = node.ssh_conn
    cmd_status = "{0}/bin/zkServer.sh status".format(context.dble_test_config['zookeeper']['home'])
    cmd_start = "{0}/bin/zkServer.sh start".format(context.dble_test_config['zookeeper']['home'])
    ssh_client.exec_command(cmd_start)
    time.sleep(3)
    rc, sto, ste = ssh_client.exec_command(cmd_status)
    zk_not_running = re.search("Error contacting service", sto, re.I)
    if zk_not_running and context.zk_retry < 5:
        context.zk_retry = context.zk_retry + 1
        start_zk_service(context, node)
    assert_that(sto, contains_string("Mode"))

def stop_zk_service(context, node):
    ssh_client = node.ssh_conn
    cmd = "{0}/bin/zkServer.sh stop".format(context.dble_test_config['zookeeper']['home'])
    rc, sto, ste = ssh_client.exec_command(cmd)
    stop_success = "no zookeeper to stop" in sto or "... STOPPED" in sto
    assert stop_success, "stop zkServer fail for: {0}".format(ste)

def restart_zk_service(context):
    for node in context.dbles:
        stop_zk_service(context, node)

    for node in context.dbles:
        start_zk_service(context, node)

@Given('config zookeeper cluster in all dble nodes')
def config_zk_in_dble_nodes(context):
    for node in context.dbles:
        conf_zk_in_node(context, node)

    restart_zk_service(context)

def conf_zk_in_node(context, node):
    ssh_client = node.ssh_conn
    conf_file = "{0}/dble/conf/myid.properties".format(context.dble_test_config['dble_basepath'])

    myid = node.host_name.split("-")[1]
    cmd = "sed -i -e 's/cluster=.*/cluster=zk/g' -e '/^myid/d' -e '$a myid={0}' {1}".format(myid, conf_file)
    rc, sto, ste = ssh_client.exec_command(cmd)
    assert_that(ste, is_(""))

@given('change zk cluster to single mode')
def dble_cluster_to_single(context):
    conf_file = "{0}/dble/conf/myid.properties".format(context.dble_test_config['dble_basepath'])
    cmd = "sed -i 's/cluster=.*/cluster=false/g' {0}".format(conf_file)
    for node in context.dbles:
        stop_dble_in_node(context, node)

        ssh_client = node.ssh_conn
        rc, sto, ste = ssh_client.exec_command(cmd)
        assert_that(ste, is_(""))

        stop_zk_service(context, node)

    LOGGER.info("Start only the Dble service on the node dble-1")
    start_dble_in_hostname(context, "dble-1")

def check_dble_status(context, hostname):
    ssh_client = get_ssh(context.dbles, hostname)
    cmd = "cd {0} && (./dble/bin/dble status)".format(context.dble_test_config['dble_basepath'])
    rc, sto, ste = ssh_client.exec_command(cmd)
    if sto.find("dble-server is running"):
        return True
    return False

def replace_config(context, sourceCfgDir):
    for node in context.dbles:
        replace_config_in_node(context,sourceCfgDir,node)

def replace_config_in_node(context, sourceCfgDir, node):
    LOGGER.info("source config dir: {0}".format(sourceCfgDir))

    osCmd = 'rm -rf {0} && cp -r {0}_bk {0}'.format(sourceCfgDir)
    os.system(osCmd)

    cmd = 'rm -rf {0}/dble/conf_*'.format(context.dble_test_config['dble_basepath'])
    node.ssh_conn.exec_command(cmd)
    cmd = 'cp -r {0}/dble/conf {0}/dble/conf_bk'.format(context.dble_test_config['dble_basepath'])
    node.ssh_conn.exec_command(cmd)

    files = os.listdir(sourceCfgDir)
    for file in files:
        local_file = "{0}/{1}".format(sourceCfgDir, file)
        remove_file = "{0}/dble/conf/{1}".format(context.dble_test_config['dble_basepath'], file)
        node.sftp_conn.sftp_put(remove_file, local_file)