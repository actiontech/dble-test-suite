#encoding: utf-8
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import sys   #引用sys模块进来，并不是进行sys的第一次加载

reload(sys)  #重新加载sys
sys.setdefaultencoding('utf8')  ##调用setdefaultencoding函数

import logging
import os
import re

import time

from lib.DBUtil import DBUtil
from lib.utils import get_sftp,get_ssh,get_node
from lib.generate_util import generate

from behave import *
from hamcrest import *
from step_reload import get_admin_conn, get_dble_conn
logger = logging.getLogger('steps.function')

@then('Test the data types supported by the sharding column in "{sql_name}"')
def test_data_type(context, sql_name):
    logger.info("test all data types")
    sql_path = "sharding_func/{0}".format(sql_name)
    context.execute_steps(u'Then execute sql in "{0}" to check read-write-split work fine and log dest slave'.format(sql_path))

@Then('Test the use of limit by the sharding column')
def test_use_limit(context):
    map = eval(context.text)
    tb = map["table"]
    t_key = map["key"]
    
    conn = get_dble_conn(context)

    drop_sql = "drop table if exists {0}".format(tb)
    conn.query(drop_sql)

    gen = generate()
    name = gen.rand_string(10)

    sql = "create table {0}({1} int, data varchar(10))".format(tb, t_key)
    conn.query(sql)

    sql = "alter table {0} drop column {1}".format(tb, t_key)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("The columns may be sharding keys or ER keys, are not allowed to alter sql"))

    sql = "update {0} set {1} = 1".format(tb, t_key)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("Sharding column can't be updated"))

    sql = "insert into {0} (data) values ('{1}')".format(tb, name)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("bad insert sql, shardingColumn/joinColumn:ID not provided"))

    sql = "insert into {0} values (1+1, '{1}')".format(tb, name)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("Not Supported of Sharding Value EXPR"))

    conn.query(drop_sql)

    sql = "create table {0}(data varchar(10))".format(tb)
    conn.query(sql)

    sql = "insert into {0} values ('{1}')".format(tb, name)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("bad insert sql, shardingColumn/joinColumn:ID not provided"))

    conn.query(drop_sql)

@Then('get query plan and make sure it is optimized')
@then('execute query and get expect result count')
def step_impl(context):
    for row in context.table:
        sql = row["query"]
        conn = get_dble_conn(context)
        res,err = conn.query(sql)
        assert len(res) == int(row["expect_result_count"]), "query: {0}'s execute result seems not as except, real result:{1}".format(sql,res)

@Given('prepare loaddata.sql data for sql test')
def step_impl(context):
    context.execute_steps(
    u'''
      #1.1 no line in file
      Given create local and server file "test1.txt" and fill with text
      """
      """
      #1.2 empty line in file
      Given create local and server file "test2.txt" and fill with text
      """

      """
      #1.3 chinese character and special character
      Given create local and server file "test3.txt" and fill with text
      """
      1,aaa,0,0,3.1415,20180905121530
      2,中,1,1,-3.1415,20180905121530
      3,$%'";:@#^&*_+-=|\<.>/?`~,5,0,0.0010,20180905
      """
      #1.4 with replace into in load data
      Given create local and server file "test4.txt" and fill with text
      """
      1,1,,
      """    
      #1.5 more than 1w lines in file
      Given create local and server file "test.txt" and fill with text
      """
      10000+lines
      """   
    ''')

@Given('create filder content "{fildername}" in "{hostname}"')
def step_impl(context, fildername,hostname):
    cmd = "mkdir {0}".format(fildername)
    context.logger.info("sed cmd is :{0}".format(cmd))
    if hostname.startswith('dble'):
        ssh = get_ssh(hostname)
    else:
        ssh = get_ssh(hostname)
    rc, stdout, stderr = ssh.exec_command(cmd)
    assert_that(len(stderr) == 0, "create filder content with:{1}, got err:{0}".format(stderr, cmd))

@Given('create local and server file "{filename}" with "{num}" lines')    
@Given('create local and server file "{filename}" and fill with text')
def step_impl(context, filename, num=None):
    logger.debug("*** debug context.text:{0}".format(context.text))

    text = context.text

    # remove old file in behave resides server
    if os.path.exists(filename):
        os.remove(filename)
    
    if num is None:
        if cmp(text,'10000+lines')==0:
            with open(filename, 'w') as fp:
                col1 = 1
                col2 = col1 +1
                col3 = "abcd"
                col4 = "1234"
                for i in xrange(15000):
                    data = str(col1)+','+str(col2)+','+str(col3)+','+str(col4)
                    fp.write(data + '\n')
                    col1= col1+1
                    col2 = col2+1
        elif text.find("68888") == 1:
            s = "a"
            with open(filename, 'w') as fp:
                fp.writelines(s + ",")
                for i in xrange(68888):
                    fp.writelines(s)

        else:
            with open(filename, 'w') as fp:
                fp.write(context.text)
    else:
        num_int = int(num)
        with open(filename, 'w') as fp:
            col1 = 1
            col2 = col1 +1
            col3 = "abcd"
            col4 = "1234"
            for i in xrange(num_int):
                data = str(col1)+','+str(col2)+','+str(col3)+','+str(col4)
                fp.write(data + '\n')
                col1= col1+1
                col2 = col2+1

    # cp file to dble
    dble_node = get_node("dble-1")
    remote_file = "{0}/dble/{1}".format(dble_node.install_dir,filename)
    context.ssh_sftp.sftp_put(filename, remote_file)

    # create file in compare mysql
    compare_mysql_node = get_node("mysql")
    compare_mysql_sftp = compare_mysql_node.sftp_conn
    remote_file = "{0}/data/{1}".format(compare_mysql_node.install_path, filename)
    compare_mysql_sftp.sftp_put(filename, remote_file)

@Given('clean loaddata.sql used data')
def step_impl(context):
    context.execute_steps(
    u'''
      Given remove local and server file "test1.txt"
      Given remove local and server file "test2.txt"
      Given remove local and server file "test3.txt"
      Given remove local and server file "test4.txt"
      Given remove local and server file "test.txt"
    ''')

@Given('remove local and server file "{filename}"')
def step_impl(context, filename):
    # remove file in behave resides server
    if os.path.exists(filename):
        os.remove(filename)

    # remove file in dble
    cmd = "rm -rf {0}".format(filename)
    rc, stdout, stderr = context.ssh_client.exec_command(cmd)
    assert len(stderr)==0, "rm file in dble fail for {0}".format(stderr)

    # remove file in compare mysql
    dble_node_ssh = get_ssh(context.cfg_mysql['compare_mysql']['master1']['hostname'])
    rc, stdout, stderr = dble_node_ssh.exec_command(cmd)
    assert len(stderr)==0, "rm file in compare mysql fail for {0}".format(stderr)

@Given ('delete file "{filename}" on "{hostname}"')
def step_impl(context,filename,hostname):
    cmd = "rm -rf {0}".format(filename)
    ssh = get_ssh(hostname)
    rc, stdout, stderr = ssh.exec_command(cmd)
    assert_that(len(stderr)==0 ,"get err {0} with deleting {1}".format(stderr,filename))

@Then('execute oscmd in "{hostname}" by parameter from resultset "{rs_name}"')
@Given('execute oscmd in "{hostname}" and "{num}" less than result')
@Given('execute oscmd in "{hostname}"')
def step_impl(context,hostname,num=None,rs_name=None):
    cmd = context.text.strip()
    ssh = get_ssh(hostname)

    if rs_name is not None:
        param_value = getattr(context, rs_name)
        assert param_value, "expect parameter not found in {0}".format(rs_name)
        cmd = cmd.format(param_value)

    rc, stdout, stderr = ssh.exec_command(cmd)
    stderr =  stderr.lower()
    assert stderr.find("error") == -1, "execute cmd: {0}  err:{1}".format(cmd,stderr)
    if num is not None:
        assert int(stdout) >= int(num), "expect {0} less than result {1} ,but not ".format(num, int(stdout))

@Then('check following text exist "{flag}" in file "{filename}" after line "{checkFromLine}" in host "{hostname}"')
def check_text_from_line(context,flag,filename,hostname,checkFromLine):
    checkFromLineNum=getattr(context,checkFromLine,0)
    check_text(context,flag,filename,hostname,checkFromLineNum)

@Then('check following text exist "{flag}" in file "{filename}" in host "{hostname}"')
def check_text(context,flag,filename,hostname,checkFromLine=0):
    strs = context.text.strip()
    strs_list = strs.splitlines()

    ssh = get_ssh(hostname)
    for str in strs_list:
        cmd = "tail -n +{2} {1} | grep -n \'{0}\'".format(str,filename,checkFromLine)
        rc, stdout, stderr = ssh.exec_command(cmd)
        if flag =="N":
            assert_that(len(stdout) == 0,"expect \"{0}\" not exist in file {1},but exist".format(str,filename))
        else:#default take flag as Y
            assert_that(len(stdout) > 0, "expect \"{0}\" exist in file {1},but not".format(str, filename))

@Then ('check following "{flag}" exist in dir "{dirname}" in "{hostname}"')
def step_impl(context,flag,dirname,hostname):
    strs = context.text.strip()
    strs_list = strs.splitlines()

    ssh = get_ssh(hostname)
    for str in strs_list[1:]:
        cmd = "find {0} -name {1}".format(dirname, str)
        rc, stdout, stderr = ssh.exec_command(cmd)
        if flag == "not":
            assert_that(len(stdout) == 0, "expect \"{0}\" not exist in dir {1},but exist".format(str, dirname))
        else:
            assert_that(len(stdout) > 0, "expect \"{0}\" exist in dir {1},but not".format(str, dirname))

@Then('get id binary named "{binary_name}" from "{rs_name}" and add 0 if binary length less than 64 bits')
def step_impl(context, binary_name, rs_name):
    binary = getattr(context, rs_name)[0][0]
    binary_str = str(binary)
    binary_len = len(binary_str)
    while (binary_len < 64):
        binary_str = '0' + binary_str
        binary_len = binary_len + 1
    assert_that(len(binary_str) == 64), "expect binary length is 64 , not {0}".format(len(binary_str))
    logger.debug("binary {} is: {}".format(binary_name,binary_str))
    setattr(context, binary_name, binary_str)


@Then('get binary range start "{start_index}" end "{end_index}" from "{binary_name}" named "{binary_sub_name}"')
def step_impl(context, start_index, end_index, binary_name, binary_sub_name):
    binary = getattr(context, binary_name)
    start_index = int(start_index)
    end_index = int(end_index)
    binary_sub = binary[start_index:end_index + 1]
    setattr(context, binary_sub_name, binary_sub)
    logger.debug("{} is: {}".format(binary_sub_name, binary_sub))


@When('connect "{binary_a}" and "{binary_b}" to get new binary "{binary_c}"')
def step_impl(context, binary_a, binary_b, binary_c):
    binary_a = getattr(context, binary_a)
    binary_b = getattr(context, binary_b)
    binary_str = binary_a + binary_b
    setattr(context, binary_c, binary_str)
    logger.debug("{} is: {}".format(binary_c, binary_str))


@Then('convert binary "{binary_sub5}"  to decimal "{decimal_sub5}"')
@Then('convert binary "{binary_sub5}"  to decimal "{decimal_sub5}" and check value is "{value}"')
def step_impl(context, binary_sub5, decimal_sub5, value=''):
    binary = getattr(context, binary_sub5)
    sql = "select conv({0},2,10)".format(binary)
    result = get_result(context, sql)
    setattr(context, decimal_sub5, result[0][0])
    logger.debug("{} is: {}\n".format(decimal_sub5, getattr(context, decimal_sub5)))
    if len(value.strip()) != 0:
        assert_that(result[0][0] == value), "expect value is {0}, but is {1}".format(value, result[0][0])


@Then('convert decimal "{decimal_sub}" to datatime "{dt_name}"')
def step_impl(context, decimal_sub, dt_name):
    unixtime = int(getattr(context, decimal_sub)) / 1000
    logger.debug("unixtime is {0}".format(unixtime))
    sql = "select from_unixtime('{0}')".format(unixtime)
    logger.debug("sql is {0}".format(sql))
    result = get_result(context, sql)
    logger.debug("result is {0}\n".format(result))
    setattr(context, dt_name, result[0][0])
    logger.debug("{} is: {}\n".format(dt_name, getattr(context, dt_name)))


@Then('get datatime "{dt_name2}" by "{dt_name1}" minus "1970-01-01"')
def step_impl(context, dt_name2, dt_name1):
    dt_name1_str = getattr(context, dt_name1)
    sql = "select datediff('{0}','1970-01-01')".format(dt_name1_str)
    result = get_result(context, sql)
    setattr(context, dt_name2, result[0][0])
    logger.debug("context.{0} is {1}\n".format(dt_name1, getattr(context, dt_name1)))
    logger.debug("context.{0} is {1}\n".format(dt_name2, getattr(context, dt_name2)))


@Then('datatime "{dt_name1}" plus start_time "{sys_time}" to get "{dt_name2}"')
def step_impl(context, dt_name1, sys_time, dt_name2):
    dt_name1_str = getattr(context, dt_name1)
    start_time = getattr(context, sys_time)[0][0]
    sql = "select date_add('{0}', interval {1} day)".format(start_time, dt_name1_str)
    result = get_result(context, sql)
    setattr(context, dt_name2, result[0][0])
    logger.debug("context.{0} is {1}\n".format(dt_name2, getattr(context, dt_name2)))


@Then('check time "{t1}" equal to "{t2}"')
def step_impl(context, t1, t2):
    t1_result = getattr(context, t1)
    t2_result = getattr(context, t2)
    t1_result = t1_result[0][0]
    t2_result = t2_result.split(' ')[0]
    assert_that(t2_result == t1_result), "expect {0} == {1}, but not !".format(t1, t2)


@When('connect ssh execute cmd "{cmd}"')
def step_impl(context, cmd):
    rc, sto, err = context.ssh_client.exec_command(cmd)
    assert_that(err, is_(''), "expect no err, but err is: {0}".format(err))

@Then('revert to current time by "{curtime}"')
def step_impl(context, curtime):
    ct = str(getattr(context, curtime)[0][0])
    ct = ct.replace('-', '/')
    cmd = 'date -s "{0}"'.format(ct)
    rc, sto, err = context.ssh_client.exec_command(cmd)
    assert_that(err, is_(''), "expect no err, but err is: {0}".format(err))

@Then('add some data in "{mapFile}" in dble "{hostname}"')
def step_impl(context,mapFile,hostname):
    node = get_node(hostname)
    targetFile = "{0}/dble/conf/{1}".format(node.install_dir, mapFile)
    text = str(context.text)
    cmd = "echo '{0}' > {1}".format(text, targetFile)
    ssh = node.ssh_conn
    rc, sto, err = ssh.exec_command(cmd)
    assert_that(err, is_(''), "expect no err, but err is: {0}".format(err))

@Then('add {time_param} to current time "{curTime}" in "{mapFile}" in dble "{hostname}"')
def step_impl(context,time_param,curTime,mapFile,hostname):
    node = get_node(hostname)
    targetFile = "{0}/dble/conf/{1}".format(node.install_dir, mapFile)
    text = "{0}={1}".format(time_param,getattr(context,curTime)[0][0])
    context.logger.info("{0} = {1}".format(time_param,getattr(context,curTime)[0][0]))
    sed_cmd_str = "sed -i '$a {0}' {1}".format(text,targetFile)
    ssh = node.ssh_conn
    rc, sto, err = ssh.exec_command(sed_cmd_str)
    logger.debug("execute cmd: {0}\n".format(sed_cmd_str))
    context.logger.info("execute cmd: {0}".format(sed_cmd_str))
    assert_that(err, is_(''), "expect no err, but err is: {0}".format(err))

@Then('change {time_param} to current time "{curTime}" in "{mapFile}" in dble "{hostname}"')
def step_impl(context,time_param,curTime,mapFile,hostname):
    node = get_node(hostname)
    targetFile = "{0}/dble/conf/{1}".format(node.install_dir, mapFile)
    text = "{0}={1}".format(time_param,getattr(context,curTime)[0][0])
    context.logger.info("{0} = {1}".format(time_param,getattr(context,curTime)[0][0]))
    sed_cmd_str = "sed -i '/{0}/c {1}' {2}".format(time_param,text,targetFile)
    ssh = node.ssh_conn
    rc, sto, err = ssh.exec_command(sed_cmd_str)
    print (("execute cmd: {0}\n\n\n".format(sed_cmd_str)))
    logger.debug("execute cmd: {0}\n".format(sed_cmd_str))
    context.logger.info("execute cmd: {0}".format(sed_cmd_str))
    assert_that(err, is_(''), "expect no err, but err is: {0}".format(err))

def get_result(context, sql):
    dble_conn = get_dble_conn(context)
    result, error = dble_conn.query(sql)
    assert error is None, "execute usersql {0}, get error:{1}".format(sql, error)
    return result

@Then('execute oscmd many times in "{host}" and result is same')
def step_impl(context,host):
    cmd = context.text.strip()
    retry = 0
    result = 0
    count = 0
    while retry<20:
        time.sleep(10)
        rc, stdout, stderr = context.ssh_client.exec_command(cmd)
        stderr =  stderr.lower()
        assert stderr.find("error") == -1, "execute cmd: {0}  err:{1}".format(host,stderr)
        if int(stdout) != result:
            result = int(stdout)
            retry = retry + 1
            count = 0
            continue
        else:
            count = count + 1
            if count >2 : break
    assert count >2, "result is not same"

@Given('get resultset of oscmd in "{host}" with pattern "{pattern}" named "{resultName}"')
def impl_step(context,host,pattern,resultName):
    if host.startswith('dble'):
        ssh = get_ssh(host)
    else:
        ssh = get_ssh(host)
    oscmd = context.text.strip()
    rc, stdout, stderr = ssh.exec_command(oscmd)
    assert_that(len(stderr) == 0, 'expect no err ,but: {0}'.format(stderr))
    results = list(set(re.findall(pattern,stdout)))
    assert_that(len(results)),"regular matching result is empty"
    context.logger.info("regular matching result:{0}".format(results))
    setattr(context,resultName,results)

@Then('get result of oscmd named "{result}" in "{hostname}"')
def step_impl(context,result,hostname):
    cmd = context.text.strip()
    if hostname.startswith("dble"):
        ssh = get_ssh(hostname)
    else:
        ssh = get_ssh(hostname)
    rc, stdout, stderr = ssh.exec_command(cmd)
    context.logger.info("execute cmd:{0}".format(cmd))
    stderr = stderr.lower()
    assert stderr.find("error") == -1, "execute cmd:{0} error:{1}".format(cmd, stderr)
    setattr(context,result,stdout)

@Then('check result "{result}" value is "{value}"')
def step_impl(context,result,value):
    rs = getattr(context,result)
    assert int(rs) == int(value),"expect result is {0},but is {1}".format(value,rs)

@Then('check result "{result}" value less than "{value}"')
def step_impl(context,result,value):
    rs = getattr(context,result)
    assert int(rs) < int(value),"expect result {0} less than {1},but not".format(rs,value)

@Given('connect "{host1}" with user "{role}" in "{host2}" to execute sql')
@Given('connect "{host1}" with user "{role}" in "{host2}" to execute sql after "{oscmd}"')
def step_impl(context,host1,role,host2,oscmd='cd /usr/local/mysql/data'):
    user = ''
    password = ''
    port = ''
    if host1.startswith('dble'):
        node = get_node(host1)
        if role == "admin":
            user = node.manager_user
            password = node.manager_password
            port = node.manager_port
        else:
            user = node.client_user
            password = node.client_password
            port = node.client_port
    else:
        node = get_node(host1)
        user = node.mysql_user
        password = node.mysql_password
        port = node.mysql_port
    ip = node.ip

    if host2.startswith('dble'):
        ssh = get_ssh(host2)
    else:
        ssh = get_ssh(host2)

    sql_cmd_str = context.text.strip()
    sql_cmd_list = sql_cmd_str.splitlines()
    context.logger.info("sql list: {0}".format(sql_cmd_list))
    for sql_cmd in sql_cmd_list:
        cmd = '{5} && mysql -h{0} -u{1} -p{2} -P{3} -c -e"{4}"'.format(ip, user, password, port,sql_cmd,oscmd)
        stdin, stdout, stderr = ssh.exec_command(cmd)
        context.logger.info("execute cmd:{0}".format(cmd))
        stderr = stderr.lower()
        assert stderr.find("error") == -1, "execute cmd: {0}  err:{1}".format(cmd,stderr)
        time.sleep(3)

@Then('check log "{file}" output in "{host}"')
def step_impl(context,file,host):
    sshClient = get_ssh(host)
    retry = 0
    isFound = False
    while retry < 5:
        time.sleep(2)  # a interval wait for query run into
        cmd = "cat {0} | grep '{1}' -c".format(file, context.text.strip())
        rc, sto, ste = sshClient.exec_command(cmd)
        assert len(ste) == 0, "check err:{0}".format(ste)
        isFound = int(sto) == 1
        if isFound:
            context.logger.debug("expect text is found in {0}s".format((retry + 1) * 2))
            break
        retry = retry + 1
    assert isFound, "can not find expect text '{0}' in {1}".format(context.text, file)


@Then('check the occur times of following key in file "{filename}" in "{hostname}"')
def step_impl(context, filename, hostname):
    ssh = get_ssh(hostname)
    for row in context.table:
        str = row["key"]
        num = row["occur_times"]
        cmd = "grep \'{0}\' {1}|wc -l".format(str, filename)
        rc, stdout, stderr = ssh.exec_command(cmd)
        assert_that(stdout == num,
                    "expect the occur times of \"{0}\" is {1} in {2},but the actual value is {3}".format(str, num, filename,
                                                                                                    stdout))

@Then('get index:"{column_index}" column value of "{adminsql}" named as "{rs_name}"')
def step_impl(context, column_index, adminsql, rs_name):
    manager_conn = get_admin_conn(context)
    result, error = manager_conn.query(adminsql)
    assert error is None, "execute adminsql {0} to get the value of column, get error:{1}".format(adminsql, error)
    id = result[0][int(column_index)]
    setattr(context, rs_name, id)

@Then('kill dble front connection "{session_id}" in "{hostname}" with manager command')
def step_impl(context, session_id, hostname):
    rs = getattr(context, session_id)
    manager_conn = get_admin_conn(context)
    adminsql = "kill @@connection {0}".format(rs)
    result, error = manager_conn.query(adminsql)
    assert error is None, "execute adminsql {0} to kill dble front session, get error:{1}".format(adminsql, error)

@Then('check path "{path}" in "{hostname}" should {exist_or_not}')
def step_impl(context, path, hostname, exist_or_not):
    ssh = get_ssh(hostname)
    cmd = "find " + path
    rc, stdout, stderr = ssh.exec_command(cmd)
    logger.debug("rc:{0}, stdout:{1}, stderr:{2}\n".format(rc, stdout,stderr))
    assert (exist_or_not == "not exist" and stderr != "") or (exist_or_not == "exist" and stderr == "")

@Given('I remove path "{path}" in "{hostname}" if exist')
def step_impl(context, path, hostname):
    ssh = get_ssh(hostname)
    cmd = "rm -rf " + path
    rc, stdout, stderr = ssh.exec_command(cmd)
    logging.debug("rc:{0}, stdout:{1}, stderr:{2}\n".format(rc, stdout, stderr))

@Given('upload file "{filename}" to "{hostname}" success')
def step_impl(context, filename, hostname):
    node = get_node(hostname)
    local_file = filename
    only_filename=local_file.split("/")[-1]
    logger.debug("filename is ".format(only_filename))
    remote_file = "{0}/{1}".format(node.install_dir,only_filename)
    node.sftp_conn.sftp_put(local_file, remote_file)
