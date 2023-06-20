# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午12:58
# @Author  : irene-coming

import logging
import os
import time
import re

from steps.mysql_steps import *
from behave import *
from hamcrest import *
from steps.lib.QueryMeta import QueryMeta
from steps.lib.generate_util import generate
from steps.lib.utils import get_node
from steps.prepared_query import *

logger = logging.getLogger('root')

@When('execute admin cmd "{adminsql}" success')
@Given('execute admin cmd "{adminsql}" success')
@Then('execute admin cmd "{adminsql}"')
@Then('execute admin cmd "{adminsql}" get the following output')
@Then('execute admin cmd "{adminsql}" with user "{user}" passwd "{passwd}"')
@Then('execute admin cmd "{adminsql}" with "{result}" result')
def exec_admin_cmd(context, adminsql, user="", passwd="", result=""):
    node = get_node("dble-1")
    if len(user.strip()) == 0:
        user = node.manager_user
    if len(passwd.strip()) == 0:
        passwd = str(node.manager_password)
    if len(result.strip()) != 0:
        adminsql = "{0} {1}".format(adminsql, getattr(context, result)[0][0])
    if context.text: expect = context.text
    else: expect = "success"

    context.execute_steps(u"""
    Then execute sql in "dble-1" in "admin" mode
        | user    | passwd | sql      | expect   |
        | {0}     | {1}    | {2}      | {3}      |
    """.format(user, passwd, adminsql, expect))

@When('execute sql in "{host_name}" in "{mode_name}" mode')
@Given('execute sql in "{host_name}" in "{mode_name}" mode')
@Then('execute sql in "{host_name}" in "{mode_name}" mode')
def step_impl(context, host_name, mode_name):
    for row in context.table:
        execute_sql_in_host(host_name, row.as_dict(), mode_name)

@Then('execute sql "{sql}" in "{host}" with "{results}" result')
def step_impl(context,sql,host,results):
    for row in context.table:
        dict = row.as_dict()
        resultList = getattr(context,results)
        for result in resultList:
            sql = sql + ' ' +'"{0}"'.format(result)
            dict.update({"sql": sql})

            execute_sql_in_host(host, dict, "mysql")

@Then('insert "{num}" rows at one time')
def step_impl(context, num):
    sql = "insert into test_table values"
    gen = generate()
    value_nu = int(num)
    for i in range(1, value_nu):
        c_str = gen.rand_string(10)
        pad_str = gen.rand_string(60)
        sql += "({0}, {0}, '{1}', '{2}'),".format(i, c_str, pad_str)

    c_str = gen.rand_string(10)
    pad_str = gen.rand_string(60)
    sql += "({0}, {0}, '{1}', '{2}')".format(i+1, c_str, pad_str)

    execute_sql_in_host("dble-1", {"sql":sql}, "user")


@Then('connect "{hostname}" to insert "{num}" of data for "{tablename}"')
@Then('connect "{hostname}" to insert "{num}" of data for "{dbname}"."{tablename}"')
@Then('connect "{hostname}" to insert "{num}" of data for "{tablename}" with user "{user}"')
def step_impl(context, hostname, num, tablename, dbname="schema1",user="test"):
    sql = ("insert into {0} (id,name) values".format(tablename))
    end = int(num)
    for i in range(1, end + 1):
        inspection_num = 'NJ' + str(100000 + i)
        if (i == end):
            sql = sql + ("({0},'{1}');".format(i, inspection_num))
        else:
            sql = sql + ("({0},'{1}'),".format(i, inspection_num))

    execute_sql_in_host(hostname, {"sql":sql,"db":dbname,"user":user}, "user")

@Then('initialize mysql-off-step sequence table')
def step_impl(context):
    mysql_node = get_node("mysql-master1")

    # copy dble's dbseq.sql to local
    dble_node = get_node("dble-1")
    source_remote_file = "{0}/dble/conf/dbseq.sql".format(dble_node.install_dir)
    target_remote_file = "{0}/data/dbseq.sql".format(mysql_node.install_path)
    local_file  = "{0}/dbseq.sql".format(os.getcwd())

    ssh_client = mysql_node.ssh_conn;

    cmd="rm -rf {0}".format(local_file)
    ssh_client.exec_command(cmd)

    context.ssh_sftp.sftp_get(source_remote_file, local_file)
    mysql_node.sftp_conn.sftp_put(local_file, target_remote_file)

    cmd = "mysql -utest -p111111 db1 < {0}".format(target_remote_file)
    ssh_client.exec_command(cmd)

    #execute dbseq.sql at the node configed in sequence file
    execute_sql_in_host("mysql-master1", info_dic={"sql":"insert into DBLE_SEQUENCE values ('`schema1`.`test_auto`', 3, 1)", "db":"db1"})

@Given('execute single sql in "{host_name}" and save resultset in "{result_key}"')
@Given('execute single sql in "{host_name}" in "{mode_name}" mode and save resultset in "{result_key}"')
def step_impl(context, host_name, result_key, mode_name=None):
    row = context.table[0]
    info_dict = row.as_dict()
    key = result_key
    res, _ = execute_sql_in_host(host_name, info_dict, mode_name)

    setattr(context, result_key, res)
    context.logger.debug("the {0} is {1}".format(key, getattr(context, result_key)))

@Then('execute admin cmd  in "{host}" at background')
@Then('execute "{mode_name}" cmd  in "{host}" at background')
@Then('execute "{mode_name}" cmd  in "{host}" at background with "{flag}" in file name')
def step_impl(context, host, mode_name="admin", host_ip="127.0.0.1", flag="Y"):
    node = get_node(host)

    context.logger.debug("btrace is running, start query!!!")
    # time.sleep(5)
    for row in context.table:
        if mode_name=="admin":
            query_meta = QueryMeta(row.as_dict(), "admin", node)
        else:
            query_meta = QueryMeta(row.as_dict(), "user", node)

        if flag=="Y":
            cmd = u"nohup mysql -u{} -p{} -P{} -c -D{} -h{} -e\"{}\" >/opt/dble/logs/dble_{}_query.log 2>&1 &".format(query_meta.user, query_meta.passwd, query_meta.port, query_meta.db, host_ip, query_meta.sql,mode_name)
        else:
            cmd = u"nohup mysql -u{} -p{} -P{} -c -D{} -h{} -e\"{}\" >/opt/dble/logs/dble_{}_query_{}.log 2>&1 &".format(query_meta.user, query_meta.passwd, query_meta.port, query_meta.db, host_ip, query_meta.sql,mode_name,flag)
        rc, sto, ste = node.ssh_conn.exec_command(cmd)
        assert len(ste) == 0, "impossible err occur"


@Then('execute sql in "{host_name}" and the result should be consistent with mysql')
def step_impl(context, host_name, mode_name="user"):
    for row in context.table:
        dble_res, dble_err = execute_sql_in_host(host_name, row.as_dict(), mode_name)
        mysql_res, mysql_err = execute_sql_in_host("mysql", row.as_dict(), "mysql")
        if len(dble_res) == len(mysql_res):
            sorted_dble_result = sorted(dble_res, key=str)
            sorted_mysql_result = sorted(mysql_res, key=str)
            assert sorted_dble_result == sorted_mysql_result, "dble and mysql resultSet not same, dbleResult: {0}, mysqlResultSet: {1}".format(dble_res, mysql_res)
        else:
            assert False, "dble and mysql resultSet not same, dbleResultSet's length:{0}, mysqlResultSet's length:{1}".format(len(dble_res), len(mysql_res))

    context.logger.info("resultSets of all sql executed in dble and mysql are same")


@Then('check mysql "{addr}:{port}" in "{hostname}" heartbeat recover ok')
@Then('check mysql "{addr}:{port}" in "{hostname}" heartbeat recover ok retry "{retry}" times')
def step_impl(context, addr, port, hostname, retry=1):
    node = get_node(hostname)
    get_query = "select count(*) from dble_db_instance where last_heartbeat_ack='ok' and heartbeat_status='idle' and addr='{}' and port='{}'".format(addr, port)
    get_times = "mysql -uroot -p111111 -P9066 -c -Ddble_information -h127.0.0.1 -e\"{}\" ".format(get_query)
    if "," in str(retry):
        retry_times = int(retry.split(",")[0])
        sep_time = float(retry.split(",")[1])
    else:
        retry_times = int(retry)
        sep_time = 1
    execute_times = retry_times + 1
    for i in range(execute_times):
        try:
            rc, sto, ste = node.ssh_conn.exec_command(get_times)
            num_sto = int(re.findall("\d+", sto)[0])
            assert num_sto > 0, "\nThe execute query is:{}\nReturn result is '{}'".format(get_times, num_sto)
            break
        except Exception as e:
            logger.info(f"check times in result not out yet, execute {i + 1} times")
            if i == execute_times - 1:
                raise e
            else:
                sleep_by_time(context, sep_time)


##只是mysqldb包装过的PrepStmts sql
@Then('execute PrepStmts sql "{sql}" with conn "{conn}" and params "{params}"')
def step_impl(context, conn, sql, params):
    conn = DbleObject.dble_long_live_conns.get(conn, None)
    assert conn, "conn '{0}' is not exists in dble_long_live_conns".format(conn)
    sql_cmd = sql.strip()
    assert params, "params cannot be empty"
    params_regex = r'\((.*?)\)' # 匹配括号内的内容，以分号作为分隔符
    params_match = re.findall(params_regex, params) # 找到所有匹配结果
    logger.debug("the params_match:'{}'".format(params_match))
    params_list = [p.split(',') for p in params_match] # 将每个匹配结果按逗号分隔成一个列表
    results = []
    for params_tuple in params_list:
        res, err = conn.execute_ps(sql_cmd, *params_tuple)
        assert_that(err, is_(None), "execute sql:'{}({})' failed for: {}".format(sql_cmd, ",".join(params_tuple), err))
        logger.debug("the PrepStmts sql:'{}({})'".format(sql_cmd, ",".join(params_tuple)))
        results.append(res) # 将返回结果保存在结果列表中
    return results


###用mysql.connector类库模拟jdbc的useServerPrepStmts
@Then('execute prepared sql "{sql}" with params "{params}" on db "{database}" and user "{user}"')
def step_impl(context, sql, params, user, database):
    connection = mysql.connector.connect(host='172.100.9.1', database=database.format(database), user=user.format(user), port=8066, password='111111',autocommit=True)
    sql_cmd = sql.strip()
    assert params, "params cannot be empty"
    params_regex = r'\((.*?)\)' # 匹配括号内的内容，以分号作为分隔符
    params_match = re.findall(params_regex, params) # 找到所有匹配结果
    logger.debug("the params_match:'{}'".format(params_match))
    params_list = [p.split(',') for p in params_match] # 将每个匹配结果按逗号分隔成一个列表
    results = []
    for params_tuple in params_list:
        result = execute_prepared_query(connection, sql_cmd, *params_tuple)
        assert_that(result, is_(object), "execute sql:'{}({})' failed for: {}".format(sql_cmd, ",".join(params_tuple), result))
        logger.debug("the PrepStmts sql:'{}({})' result:{}".format(sql_cmd, ",".join(params_tuple),result))
        results.append(result) # 将返回结果保存在结果列表中
    return results

###用字符拼接成大包下发sql
@Then('connect "{hostname}" to execute "{sql}" large data "{num}" on db "{dbname}" with user "{user}"')
def step_impl(context, hostname, num, sql,user="test",dbname="schema1"):
    num_expression = eval(num)
    sql_pre = sql.strip() #自主拼接需要的句式
    inspection_num = 'a' * int(num_expression)
    sql = sql_pre + ("'{}');".format(inspection_num))
    logger.debug("the sql is : {} ,the sql length:'{}',the sql_pre length:'{}'".format(sql[0:512],len(sql),len(sql_pre)))
    execute_sql_in_host(hostname, {"sql":sql,"db":dbname,"user":user}, "user")

@Then('connect "{hostname}" to execute mulit "{sql_pre}" and "{sql_after}" large data "{num}" on db "{dbname}" with user "{user}"')
def step_impl(context, hostname, num, sql_pre, sql_after, user="test", dbname="schema1"):
    num_expression = eval(num)
    sql_pre = sql_pre.strip() #自主拼接需要的句式
    sql_after = sql_after.strip()
    inspection_num = 'c' * int(num_expression)
    sql_mid = sql_pre + ("'{}'".format(inspection_num))
    sql = sql_mid + sql_after
    logger.debug("the sql is : {} ".format(sql[0:512]))
    execute_sql_in_host(hostname, {"sql":sql,"db":dbname,"user":user}, "user")

@Then('execute large data prepared sql "{sql}" data "{num}" with params "{params}" on db "{database}" and user "{user}"')
def step_imp(context, sql, params ,num, user, database):
    connection = mysql.connector.connect(host='172.100.9.1', database=database.format(database), user=user.format(user), port=8066, password='111111',autocommit=True)
    sql_pre= sql.strip()
    results = []
    data_exp = eval(num)
    data =  'r' * int(data_exp)
    sql_cmd = sql_pre + ("('{}');".format(data))
    result = execute_prepared_query(connection, sql_cmd, params)
    assert_that(result, is_(object), "execute sql:'{}' failed for: {}".format(sql_cmd, result))
    logger.debug("the PrepStmts sql:'{}' result:{}  the sql_cmd length :{},the sql_pre length :{}".format(sql_cmd[0:512] ,result,len(sql_cmd),len(sql_pre)))
    results.append(result)
    return results