# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import os
import re
import time
import subprocess

import MySQLdb
from behave import *
from hamcrest import *

from lib.MySQLMeta import MySQLMeta
from lib.DbleMeta import DbleMeta
from lib.DBUtil import *
from lib.utils import get_node, get_ssh

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

def get_dble_install_packet_name(context):
    dble_packet = context.cfg_dble['packet_name']

    if dble_packet.find("{0}") != -1:
        cmd = "curl -s 'https://github.com/actiontech/dble/releases/latest' | awk -F '/' '{print $8}'"
        version = subprocess.check_output(cmd,shell=True)
        version = version.strip("\n")
        dble_packet = dble_packet.format(version)

    LOGGER.debug("dble packet to install: {0}".format(dble_packet))
    return dble_packet

def get_download_ftp_path(context):
    ftp_path = context.cfg_dble['ftp_path']

    if ftp_path.find("{0}") != -1:
        cmd = "curl -s 'https://github.com/actiontech/dble/releases/latest' | awk -F '/' '{print $8}'"
        version = subprocess.check_output(cmd,shell=True)
        version = version.strip("\n")
        ftp_path = ftp_path.format(version)

    LOGGER.debug("download dble ftp path : {0}".format(ftp_path))
    return ftp_path

def install_dble_in_node(context, node):
    dble_packet = get_dble_install_packet_name(context)

    if context.need_download:
        download_dble(context, dble_packet)

    ssh_client =node.ssh_conn

    cmd = "cd {0} && rm -rf dble".format(node.install_dir)
    ssh_client.exec_command(cmd)

    cmd = "cd {0} && cp -r {1} {2}".format(context.cfg_sys['share_path_docker'], dble_packet,
                                           node.install_dir)
    ssh_client.exec_command(cmd)
    cmd = "cd {0} && tar xf {1}".format(node.install_dir, dble_packet)
    ssh_client.exec_command(cmd)

@Given('install dble in "{hostname}"')
def install_dble_in_host(context, hostname):
    node = get_node(hostname)
    install_dble_in_node(context, node)

@Given('install dble in all dble nodes')
def install_dble_in_all_nodes(context):
    for node in DbleMeta.dbles:
        install_dble_in_node(context, node)

def download_dble(context, dble_packet_name):
    LOGGER.debug("delete local dble packet")
    rpm_local_path = "{0}/{1}".format(context.cfg_sys['share_path_docker'],
                                      dble_packet_name)
    ftp_path = get_download_ftp_path(context)
    rpm_ftp_url = "{0}{1}".format(ftp_path,
                                  dble_packet_name)
    cmd = 'rm -rf {0}'.format(rpm_local_path)
    exit_status = os.system(cmd)
    LOGGER.debug("cmd:{0}, exit_status:{1}".format(cmd, exit_status))

    if context.cfg_dble['packet_name'].find("{0}") == -1:
        cmd = 'cd {0} && wget --user=ftpuser --password=ftpuser -nv {1}'.format(context.cfg_sys['share_path_docker'],
                                                                        rpm_ftp_url)
    else:
        cmd = 'cd {0} && wget {1}'.format(context.cfg_sys['share_path_docker'],
                                                                    rpm_ftp_url)

    LOGGER.debug(cmd)
    os.popen(cmd)

    cmd = "find {0} -maxdepth 1 -name {1} | wc -l".format(context.cfg_sys['share_path_docker'],
                                                          dble_packet_name)
    LOGGER.debug(cmd)
    str = os.popen(cmd).read()
    assert_that(str.strip(), equal_to('1'), "Download dble tar fail")

def set_dbles_log_level(context, nodes, log_level):
    for node in nodes:
        set_dble_log_level(context, node, log_level)

def set_dble_log_level(context, node, log_level):
    ssh_client = node.ssh_conn
    str_awk = "awk 'FS=\" \" {print $2}'"
    cmd = "cat {0}/dble/conf/log4j2.xml | grep -e '<asyncRoot*' | {1} | cut -d= -f2 ".format(node.install_dir, str_awk)
    rc, sto, ste = ssh_client.exec_command(cmd)

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
    dble_pid_exist,dble_dir_exist = check_dble_exist(ssh_client, dble_install_path)

    if not dble_dir_exist:
        logger.info('start dble {0} skip, dble_dir_exist is {1}'.format(node.host_name, dble_dir_exist))
    else:
        cmd = "{0}/dble/bin/dble start".format(node.install_dir)
        ssh_client.exec_command(cmd)

        check_dble_started(context, node)

        assert_that(context.dble_start_success==expect_success, "Expect restart dble {0} success {1}".format(node.host_name, expect_success))

        if not expect_success:
            expect_err_info = context.text.strip()
            for row in expect_err_info.splitlines():
                cmd = "grep -i \"{0}\" /opt/dble/logs/wrapper.log | wc -l".format(row.strip())
                rc, sto, ste = node.ssh_conn.exec_command(cmd)
                assert_that(str(sto).strip() is not "0", "expect dble restart failed for {0}".format(row))

def check_dble_started(context, node):
    if not hasattr(context, "retry_start_dble"):
        context.retry_start_dble = 0
        context.dble_start_success= False
        
    dble_conn = None
    try:
        dble_conn = DBUtil(node.ip, node.manager_user, node.manager_password, "",
                           node.manager_port, context)
        res, err = dble_conn.query("show @@version")
    except MySQLdb.Error, e:
        err = e.args
    finally:
        if dble_conn:dble_conn.close()

    context.dble_start_success = err is None
    LOGGER.debug("dble started success:{0}, loop {1}, err:{2}".format(context.dble_start_success, context.retry_start_dble, err))
    if not context.dble_start_success:
        if context.retry_start_dble < 5:
            context.retry_start_dble = context.retry_start_dble+1
            time.sleep(5)
            check_dble_started(context,node)
        else:
            LOGGER.debug("dble started failed after 5 times try")
            cmd = "cat /opt/dble/logs/wrapper.log"
            rc, sto, ste = node.ssh_conn.exec_command(cmd)
            LOGGER.debug("Please check the error message in wrapper.log:\n{0}".format(sto))
            delattr(context, "retry_start_dble")
    else:
        delattr(context, "retry_start_dble")
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
    dble_pid_exist,dble_dir_exist = check_dble_exist(ssh_client, dble_install_path)

    if dble_pid_exist:
        #stop dble gracefully to generate .exec for code coverage
        #stop_dble_cmd="{0}/dble/bin/dble stop".format(dble_install_path)
        #rc1, sto1, ste1 = ssh_client.exec_command(stop_dble_cmd)
        #assert_that(len(ste1) == 0, "stop dble fail for:{0}".format(ste1))

        cmd_guard = "ps -ef|grep dble|grep 'start'| grep -v grep | awk '{print $3}' | xargs -r kill -9"
        cmd_core = "ps -ef|grep dble|grep 'start'| grep -v grep | awk '{print $2}' | xargs -r kill -9"
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
    #sleep 4s to generate .exec for code coverage
    #time.sleep(4)
    if len(nodes) > 1:
        config_zk_in_dble_nodes(context,"all zookeeper hosts")
        reset_zk_nodes(context)

    start_dble_in_order(context)

@Then('restart dble in "{hostname}" failed for')
def check_restart_dble_failed(context,hostname):
    node = get_node(hostname)
    restart_dble(context, node, False)

@Then('start dble in "{hostname}" failed for')
def check_restart_dble_failed(context,hostname):
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
    cmd_check_port ="netstat -anp|grep 2181"
    cmd_check_pid = "ps -ef | grep 'zookeeper' | grep -v grep | awk '{print $2}'"
    
    rc, sto, ste = ssh_client.exec_command(cmd_start)
    rc1, sto1, ste1 = ssh_client.exec_command(cmd_check_port)
    rc2, sto2, ste2 = ssh_client.exec_command(cmd_check_pid)
   
    if (sto.rfind('STARTED') == -1):
        LOGGER.debug("The use of port number 2181:{0}".format(sto1))
        LOGGER.debug("the pid of zookeeper:{0}".format(sto2))
        if context.retry_start_zk<5:
            context.retry_start_zk =context.retry_start_zk+1
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
def config_zk_in_dble_nodes(context,hosts_form):
    for node in DbleMeta.dbles:
        conf_zk_in_node(context, node,hosts_form)

    restart_zk_service(context)

def conf_zk_in_node(context,node,hosts_form):
    ssh_client = node.ssh_conn
    cluster_conf = "{0}/dble/conf/cluster.cnf".format(node.install_dir)
    bootstrap_conf = "{0}/dble/conf/bootstrap.cnf".format(node.install_dir)
    # zk_server_ip=context.cfg_zookeeper['ip']
    zk_server_port=context.cfg_zookeeper['port']

    myid = node.host_name.split("-")[1]
    zk_server_id = "zookeeper-{0}".format(myid)
    zk_server_ip = context.cfg_zookeeper[zk_server_id]['ip']
    # LOGGER.info("zk_server_ip:{0}".format(zk_server_ip))
    if hosts_form == "local zookeeper host":
        # update cluster.cnf:
        cmd1 = "sed -i -e 's/clusterEnable=.*/clusterEnable=true/g' -e 's/clusterIP=.*/clusterIP={1}:{2}/g' -e 's/# rootPath=.*/rootPath=\/dble/g' {0}".format(cluster_conf, zk_server_ip, zk_server_port)
        # update bootstrap.cnf:
        cmd2 = "sed -i -e 's/instanceName=.*/instanceName={0}/g' -e 's/instanceId=.*/instanceId={0}/g' -e 's/serverId=.*/serverId=server_{0}/g' {1}".format(myid, bootstrap_conf)
    else:
        zk_server_ip_1 = context.cfg_zookeeper['zookeeper-1']['ip']
        zk_server_ip_2 = context.cfg_zookeeper['zookeeper-2']['ip']
        zk_server_ip_3 = context.cfg_zookeeper['zookeeper-3']['ip']
        cmd1 = "sed -i -e 's/clusterEnable=.*/clusterEnable=true/g' -e 's/clusterIP=.*/clusterIP={1}:{4},{2}:{4},{3}:{4}/g' -e 's/# rootPath=.*/rootPath=\/dble/g' {0}".format(cluster_conf, zk_server_ip_1,zk_server_ip_2,zk_server_ip_3,zk_server_port)
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
    rc, sto, ste = ssh_client.exec_command(cmd)
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
        replace_config_in_node(context,node)
        # set dble log level to debug
        set_dble_log_level(context, node, 'debug')

@Given('replace config files in "{nodeName}" with command line config')
def step_impl(context, nodeName):
    node = get_node(nodeName)
    replace_config_in_node(context, node)

def replace_config_in_node(context, node):
    LOGGER.info("source config dir: {0}, pwd:{1}".format(context.dble_conf, os.getcwd()))

    sourceCfgDir = "{0}/{1}".format(os.getcwd(),context.dble_conf)
    osCmd = 'rm -rf {0} && cp -r {0}_bk {0}'.format(sourceCfgDir)
    os.system(osCmd)

    ssh_client = node.ssh_conn
    dble_install_path = node.install_dir
    dble_pid_exist,dble_dir_exist = check_dble_exist(ssh_client, dble_install_path)

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

    #for code coverage start
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
    rc, sto, ste=ssh_client.exec_command(resetCmd)
    if context.reset_zk_time < 3:
	    context.reset_zk_time = context.reset_zk_time + 1
	    reset_zk_nodes(context)
	
    
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
    cmd = "cd {0}/bin && ./zkCli.sh ls /dble/cluster-1/online|grep -v ':'|grep -v ^$ ".format(context.cfg_zookeeper['home'])
    cmd_ssh = get_ssh("dble-1")
    rc, sto, ste = cmd_ssh.exec_command(cmd)
    LOGGER.debug("add debug to check the result of executing {0} is :sto:{1}".format(cmd,sto))
    sub_sto = re.findall(r'[[](.*)[]]', sto)
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
            LOGGER.info("The online dbles detected by zk do not meet expectations after 10 times try,expectNodes:{0},realNodes:{1}".format(expectNodes, realNodes))
            delattr(context, "retry_check_zk_nodes")
    else:
        delattr(context, "retry_check_zk_nodes")

