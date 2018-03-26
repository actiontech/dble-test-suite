import time
import os
import logging
import threading
import commands
from behave import *
from hamcrest import *
from lib.nodes import *

LOGGER = logging.getLogger('steps.install')

@Given('a clean environment in all dble nodes')
def clean_dble_in_all_nodes(context):
    threads = []
    for node in context.dbles.nodes:
        threads.append(threading.Thread(target=uninstall_dble_by_ip, args=(context, node.ip)))
    for t in threads:
        t.start()
    for t in threads:
        t.join()

@When('uninstall dble by "{ip}" ')
def uninstall_dble_by_ip(context, ip):
    ssh_client = context.ssh_clients[ip]
    cmd_status = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'"
    rc, sto, ste = ssh_client.exec_command(cmd_status)
    if len(sto) == 0:
        LOGGER.info("dble status is stopped!!!")
    else:
        LOGGER.info("try to stop dble server")
        cmd = "cd {0} && (./dble/bin/dble stop)".format(context.dble_test_config['dble_basepath'])
        ssh_client.exec_command(cmd)
        rc, sto, ste = ssh_client.exec_command(cmd_status)
        if len(sto) == 0:
            LOGGER.info("stop dble successed")
        else:
            cmd = "kill {0} {1}".format(sto[0], sto[1])
            ssh_client.exec_command(cmd)
            rc, sto, ste = ssh_client.exec_command(cmd_status)
            if len(sto) == 0:
                LOGGER.info("kill dble successed")
            else:
                assert_that(False, "stop dble fialure")

    cmd = "cd {0} && rm -rf {1}".format(context.dble_test_config['dble_basepath'], "dble")
    ssh_client.exec_command(cmd)
    zknode = check_zk_node_exists(context)
    if zknode:
        check_and_clear_zk(context)

@given('uninstall dble in "{hostname}"')
def unistall_dble_by_hostname(context, hostname):
    node = Nodes(context.dbles.nodes).get_node_by_host_name(hostname)
    uninstall_dble_by_ip(context, node.ip)

@Given('install dble in all dble nodes')
def install_dble_in_all_nodes(context):
    for node in context.dbles.nodes:
        install_dble_by_ip(context, node.ip)
        update_dble_config(context, node.ip)

def install_dble_by_ip(context, ip):
    ssh_client = context.ssh_clients[ip]
    dble_packget = ""
    if context.need_download == False:
        dble_packget = "{0}".format(context.dble_test_config['dble']['local_packget'])
    else:
        context.execute_steps(u'Given download dble')
        dble_packget = "{0}".format(context.dble_test_config['dble']['remote_packget'])
    cmd = "cd {0} && rm -rf {1}".format(context.dble_test_config['dble_basepath'], dble_packget)
    ssh_client.exec_command(cmd)
    cmd = "cd {0} && cp -r {1} {2}".format(context.dble_test_config['share_path_docker'], dble_packget,
                                           context.dble_test_config['dble_basepath'])
    ssh_client.exec_command(cmd)
    cmd = "cd {0} && tar xf {1}".format(context.dble_test_config['dble_basepath'], dble_packget)
    ssh_client.exec_command(cmd)

@Given('install dble in "{hostname}"')
def install_dble_in_hostname(context, hostname):
    node = Nodes(context.dbles.nodes).get_node_by_host_name(hostname)
    install_dble_by_ip(context, node.ip)
    update_dble_config(context, node.ip)

@Then('Start dble in "{hostname}"')
def start_dble_in_hostname(context, hostname):
    node = Nodes(context.dbles.nodes).get_node_by_host_name(hostname)
    ssh_client = context.ssh_clients[node.ip]
    cmd = "cd {0} && (./dble/bin/dble start)".format(context.dble_test_config['dble_basepath'])
    ssh_client.exec_command(cmd)
    time.sleep(5)
    cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'"
    rc, sto, ste = ssh_client.exec_command(cmd)
    LOGGER.info("rc: {0}, sto: {1}, ste: {2}".format(rc, sto, ste))
    if len(sto) == 0:
        assert_that(False, "start dble service fail in 25 seconds!")
    else:
        LOGGER.info("start dble success !!!")

@Then('stop dble in "{hostname}"')
def stop_dble_in_hostname(context, hostname):
    node = Nodes(context.dbles.nodes).get_node_by_host_name(hostname)
    ssh_client = context.ssh_clients[node.ip]
    cmd = "cd {0} && (./dble/bin/dble stop)".format(context.dble_test_config['dble_basepath'])
    ssh_client.exec_command(cmd)
    time.sleep(3)
    cmd = "ps aux|grep dble|grep 'start'| grep -v grep | awk '{print $2}'"
    rc, sto, re = ssh_client.exec_command(cmd)
    if re.find(" "):
        assert_that(True, "stop dble succeed")
    else:
        assert_that(False, "stop dble service fail !")

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

def update_dble_config(context, ip):
    ssh_sftp_client = context.ssh_sftps[ip]
    ssh_client = context.ssh_clients[ip]
    dble_conf_path = context.dble_test_config['dble_basepath'] + "/dble/conf"
    cmd = "ls {0}".format(context.dble_test_config['dble_base_conf'])
    str = commands.getoutput(cmd)
    for file in str.split("\n"):
        local_file = "{0}/{1}".format(context.dble_test_config['dble_base_conf'], file)
        remove_path = "{0}/{1}".format(dble_conf_path, file)
        cmd = "cd {0}/conf && rm -rf {1}".format(context.dble_test_config['dble']['home'], file)
        ssh_client.exec_command(cmd)
        LOGGER.info("remove_path is {0}, local_file is {1}".format(remove_path, local_file))
        ssh_sftp_client.sftp_put(remove_path, local_file)

@Given('check dble is installed in "{hostname}"')
def check_dble_installed(context, hostname):
    node = Nodes(context.dbles.nodes).get_node_by_host_name(hostname)
    ssh_client = context.ssh_clients[node.ip]
    cmd = "sh {0}/dble/bin/dble status".format(context.dble_test_config['dble_basepath'])
    rc, sto, ste = ssh_client.exec_command(cmd)
    if sto.find("dble-server is running") != -1:
        return True
    return False

@Given('Set the log level to "{log_level}" and restart server in "{hostname}"')
def Log_debug(context, log_level, hostname):
    node = Nodes(context.dbles.nodes).get_node_by_host_name(hostname)
    ssh_client = context.ssh_clients[node.ip]
    str_awk = "awk 'FS=\" \" {print $2}'"
    cmd = "cat {0}/dble/conf/log4j2.xml | grep -e '<asyncRoot*' | {1} | cut -d= -f2 ".format(context.dble_test_config['dble_basepath'], str_awk)
    rc, sto, ste = ssh_client.exec_command(cmd)
    LOGGER.info("rc: {0}; sto: {1}; ste: {2}".format(rc, sto, ste))
    if log_level in sto:
        pass
    else:
        log = '{0}/dble/conf/log4j2.xml'.format(context.dble_test_config['dble_basepath'])
        cmd = "sed -i 's/{0}/{1}/g' {2} ".format(sto[1:-1], log_level, log)
        ssh_client.exec_command(cmd)
        cmd = "cd {0} && (./dble/bin/dble restart)".format(context.dble_test_config['dble_basepath'])
        ssh_client.exec_command(cmd)
        time.sleep(3)
        check_dble_installed(context, hostname)

@Given('Restart dble in "{hostname}"')
def step_impl(context, hostname):
    stop_dble_in_hostname(context, hostname)
    start_dble_in_hostname(context, hostname)
    time.sleep(3)
    check_dble_installed(context, hostname)

@Given('Restart dble by "{ip}"')
def step_impl(context, ip):
    for node in context.dbles.nodes:
        if node.ip == ip:
            context.execute_steps(u'Given Restart dble in "{0}"'.format(node.host_name))

@Given('Check and clear zookeeper stored data in all dble nodes')
def check_and_clear_zk(context):
    for node in context.dbles.nodes:
        check_zk_status(context, node.ip)
        clear_zk_data(context, node.ip)

def check_zk_status(context, ip):
    ssh_client = context.ssh_clients[ip]
    cmd = "{0}/bin/zkServer.sh status".format(context.dble_test_config['zookeeper']['home'])
    rc, sto, ste = ssh_client.exec_command(cmd)
    LOGGER.info("rc: {0}, sto: {1}, ste: {2}".format(rc, sto, ste))
    assert_that(str(sto), contains_string("Mode"))

def clear_zk_data(context, ip):
    ssh_client = context.ssh_clients[ip]
    cmd = "{0}/bin/zkCli.sh rmr /dble".format(context.dble_test_config['zookeeper']['home'])
    ssh_client.exec_command(cmd)
    cmd = "{0}/bin/zkCli.sh ls /dble".format(context.dble_test_config['zookeeper']['home'])
    rc, sto, ste = ssh_client.exec_zk_command(cmd)
    LOGGER.info("rc: {0}, sto: {1}, ste: {2}".format(rc, sto, ste))
    assert_that(ste, contains_string("Node does not exist: /dble"))

@Given('config zookeeper cluster in all dble nodes')
def config_zk_in_dble_nodes(context):
    for node in context.dbles.nodes:
        stop_dble_in_hostname(context, node.host_name)
        conf_zk_in_dble_by_hostname(context, node.host_name)
    check_and_clear_zk(context)
    order_start_all_dble(context)

def order_start_all_dble(context):
    start_dble_in_hostname(context, "dble-1")
    for node in context.dbles.nodes:
        if "dble-1" not in node.host_name:
            start_dble_in_hostname(context, node.host_name)

def conf_zk_in_dble_by_hostname(context, hostname):
    node = Nodes(context.dbles.nodes).get_node_by_host_name(hostname)
    ssh_client = context.ssh_clients[node.ip]
    conf_file = "{0}/dble/conf/myid.properties".format(context.dble_test_config['dble_basepath'])
    cmd = "cat {0} | grep 'loadZK*'|cut -d= -f2".format(conf_file)
    rc, sto, ste = ssh_client.exec_command(cmd)
    LOGGER.info("rc: {0}, sto: {1}, ste: {2}".format(rc, sto, ste))
    assert_that(ste, is_(""))
    if "false" in sto :
        cmd = "sed -i 's/false/true/g' {0}".format(conf_file)
        rc, sto, ste = ssh_client.exec_command(cmd)
        LOGGER.info("rc: {0}, sto: {1}, ste: {2}".format(rc, sto, ste))
        assert_that(ste, is_(""))
        cmd = "sed -i '/^myid/d' {0}".format(conf_file)
        rc, sto, ste = ssh_client.exec_command(cmd)
        assert_that(ste, is_(""))
        cmd = " "
        if "1" in hostname:
            cmd = "sed -i '$a myid=1' {0}".format(conf_file)
        elif "2" in hostname:
            cmd = "sed -i '$a myid=2' {0}".format(conf_file)
        else:
            cmd = "sed -i '$a myid=3' {0}".format(conf_file)
        rc, sto, ste = ssh_client.exec_command(cmd)
        assert_that(ste, is_(""))

@given('Restore and ensure that all dble nodes are not cluster-mode')
def restore_and_ensure_dble_uncluster(context):
    zknode = check_zk_node_exists(context)
    if zknode:
        conf_file = "{0}/dble/conf/myid.properties".format(context.dble_test_config['dble_basepath'])
        cmd = "cat {0} | grep 'loadZK*' | cut -d= -f2".format(conf_file)
        for node in context.dbles.nodes:
            stop_dble_in_hostname(context, node.host_name)
            ssh_client = context.ssh_clients[node.ip]
            rc, sto, ste = ssh_client.exec_command(cmd)
            LOGGER.info("rc: {0}, sto: {1}, ste: {2}".format(rc, sto, ste))
            assert_that(ste, is_(""))
            if "true" in sto:
                cmd = "sed -i 's/true/false/g' {0}".format(conf_file)
                rc, sto, ste = ssh_client.exec_command(cmd)
                LOGGER.info("rc: {0}, sto: {1}, ste: {2}".format(rc, sto, ste))
                assert_that(ste, is_(""))
                LOGGER.info("config dble node: {0} myid.properties is false".format(node.host_name))
        LOGGER.info("Start only the Dble service on the node {0}".format("dble-1"))
        check_and_clear_zk(context)
    start_dble_in_hostname(context, "dble-1")

def check_zk_node_exists(context):
    cmd = "{0}/bin/zkCli.sh ls /dble".format(context.dble_test_config['zookeeper']['home'])
    for node in context.dbles.nodes:
        ssh_client = context.ssh_clients[node.ip]
        rc, sto, ste = ssh_client.exec_zk_command(cmd)
        LOGGER.info("rc: {0}, sto: {1}, ste: {2}".format(rc, sto, ste))
        if "Node does not exist: /dble" not in sto:
            return True
    return False

def check_dble_status(context, hostname):
    node = Nodes(context.dbles.nodes).get_node_by_host_name(hostname)
    ssh_client = context.ssh_clients[node.ip]
    cmd = "cd {0} && (./dble/bin/dble status)".format(context.dble_test_config['dble_basepath'])
    rc, sto, ste = ssh_client.exec_command(cmd)
    if sto.find("dble-server is running"):
        return True
    return False