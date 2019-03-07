#encoding: utf-8
import sys   #引用sys模块进来，并不是进行sys的第一次加载
reload(sys)  #重新加载sys
sys.setdefaultencoding('utf8')  ##调用setdefaultencoding函数

import logging
import os

from lib.DBUtil import DBUtil
from lib.Node import get_sftp,get_ssh
from lib.generate_util import generate

from behave import *
from hamcrest import *
from step_reload import get_admin_conn, get_dble_conn

LOGGER = logging.getLogger('steps.function')

@then('Test the data types supported by the sharding column in "{sql_name}"')
def test_data_type(context, sql_name):
    LOGGER.info("test all data types")
    sql_path = "sharding_func/{0}".format(sql_name)
    context.execute_steps(u'Then execute sql in "{0}" to check read-write-split work fine and log dest slave'.format(sql_path))

def create_node_conn(context):
    context.manager_conn = get_admin_conn(context)
    sql = "show @@datanode"
    result, error = context.manager_conn.query(sql)
    context.manager_conn.close()

    datanode = {}
    if type(result) == tuple:
        for i in range(len(result)):

            datanode[result[i][0]] = result[i][1]
    port = 3306
    node_conn = {}
    for node in datanode.keys():
        user = context.cfg_mysql['user']
        password = context.cfg_mysql['password']
        host = datanode[node].split('/')[0]
        db = datanode[node].split('/')[1]
        LOGGER.info("{0} create, host:{1}, db:{2}".format(node, host, db))
        conn = DBUtil(host, user, password, db, port, context)
        node_conn[node] = conn
    return node_conn

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
    assert_that(str(errMes[1]), contains_string("bad insert sql, sharding column/joinKey:ID not provided"))

    sql = "insert into {0} values (1+1, '{1}')".format(tb, name)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("Not Supported of Sharding Value EXPR"))

    conn.query(drop_sql)

    sql = "create table {0}(data varchar(10))".format(tb)
    conn.query(sql)

    sql = "insert into {0} values ('{1}')".format(tb, name)
    result, errMes = conn.query(sql)
    assert_that(str(errMes[1]), contains_string("bad insert sql, sharding column/joinKey:ID not provided"))

    conn.query(drop_sql)

@Then('get query plan and make sure it is optimized')
def step_impl(context):
    for row in context.table:
        sql = row["query"]
        conn = get_dble_conn(context)
        res,err = conn.query(sql)
        assert len(res) == int(row["expect_result_count"]), "query: {0}'s execute plan seems not optimized, the plan:{1}".format(sql,res)

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
    ''')

@Given('create local and server file "{filename}" and fill with text')
def step_impl(context, filename):
    LOGGER.debug("*** debug context.text:{0}".format(context.text))

    # remove old file in behave resides server
    if os.path.exists(filename):
        os.remove(filename)

    with open(filename, 'w') as fp:
        fp.write(context.text)

    # cp file to dble
    remote_file = "{0}/dble/{1}".format(context.cfg_dble['install_dir'],filename)
    context.ssh_sftp.sftp_put(filename, remote_file)

    # create file in compare mysql
    remote_file = "{0}/data/{1}".format(context.cfg_mysql['install_path'], filename)
    compare_mysql_sftp = get_sftp(context.mysqls, context.cfg_mysql['compare_mysql']['master1']['hostname'])
    compare_mysql_sftp.sftp_put(filename, remote_file)

@Given('clean loaddata.sql used data')
def step_impl(context):
    context.execute_steps(
    u'''
      Given remove local and server file "test1.txt"
      Given remove local and server file "test2.txt"
      Given remove local and server file "test3.txt"
      Given remove local and server file "test4.txt"
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
    dble_node_ssh = get_ssh(context.mysqls, context.cfg_mysql['compare_mysql']['master1']['hostname'])
    rc, stdout, stderr = dble_node_ssh.exec_command(cmd)
    assert len(stderr)==0, "rm file in compare mysql fail for {0}".format(stderr)


@Given ('update file content "{filename}" in "{hostname}"')
def update_file_content(context,filename, hostname):
    sed_cmd_str = context.text.strip()
    sed_cmd_list = sed_cmd_str.splitlines()
    sed_cmd = "sed -i"
    for cmd in sed_cmd_list:
        sed_cmd += " -e '{0}'".format(cmd.strip())

    sed_cmd += " {0}".format(filename)

    context.logger.info("sed cmd is :{0}".format(sed_cmd))
    if hostname.startswith('dble'):
        ssh = get_ssh(context.dbles,hostname)
    else:
        ssh = get_ssh(context.mysqls, hostname)
    rc, stdout, stderr = ssh.exec_command(sed_cmd)
    assert_that(len(stderr)==0, "update file content with:{1}, got err:{0}".format(stderr, sed_cmd))

@Given ('delete file "{filename}" on "{hostname}"')
def step_impl(context,filename,hostname):
    cmd = "rm -rf {0}".format(filename)
    ssh = get_ssh(context.dbles,hostname)
    rc, stdout, stderr = ssh.exec_command(cmd)
    assert_that(len(stderr)==0 ,"get err {0} with deleting {1}".format(stderr,filename))


@Then ('check following "{flag}" exist in file "{filename}" in "{hostname}"')
def step_impl(context,flag,filename,hostname):
    strs = context.text.strip()
    strs_list = strs.splitlines()

    ssh = get_ssh(context.dbles,hostname)
    for str in strs_list:
        cmd = "grep \'{0}\' {1}".format(str,filename)
        rc, stdout, stderr = ssh.exec_command(cmd)
        if flag =="not":
            assert_that(len(stdout) == 0,"expect \"{0}\" not exist in file {1},but exist".format(str,filename))
        else:
            assert_that(len(stdout) > 0, "expect \"{0}\" exist in file {1},but not".format(str, filename))

@Then ('check following "{flag}" exist in dir "{dirname}" in "{hostname}"')
def step_impl(context,flag,dirname,hostname):
    strs = context.text.strip()
    strs_list = strs.splitlines()

    ssh = get_ssh(context.dbles, hostname)
    for str in strs_list[1:]:
        cmd = "find {0} -name {1}".format(dirname, str)
        rc, stdout, stderr = ssh.exec_command(cmd)
        if flag == "not":
            assert_that(len(stdout) == 0, "expect \"{0}\" not exist in dir {1},but exist".format(str, dirname))
        else:
            assert_that(len(stdout) > 0, "expect \"{0}\" exist in dir {1},but not".format(str, dirname))
