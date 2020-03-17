# -*- coding: utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2018/4/2 PM6:56
# @Author  : zhaohongjie@actionsky.com
import datetime
import logging
import random
import re
import time

import MySQLdb
from behave import *
from hamcrest import *

from lib.DBUtil import DBUtil
from lib.XMLUtil import get_child_nodes
from lib.Node import get_node
from step_reload import get_abs_path

LOGGER = logging.getLogger('steps')
console_logger = logging.getLogger('mydebug')

def get_sql(type):
    if type == "read":
        sql="select 1 "
    else:
        sql="drop table if exists char_columns"

    return sql

@Then('execute sql in "{hostname}"')
@Then('execute sql in "{hostname}" in "{user}" mode')
def step_impl(context,hostname, user=""):
    if len(user.strip()) == 0:
        node = get_node(context.mysqls, hostname)
        ip = node._ip
        port = node._mysql_port
    else:
        node = get_node(context.dbles, hostname)
        ip = node._ip
        if user == 'admin':
            port = context.cfg_dble['manager_port']
        else:
            port = context.cfg_dble['client_port']
    exec_sql(context, ip, port)
        
def exec_sql(context, ip, port):
    '''
    if row["sql"] is none, just create connection
    if row["db"] is none, query without default database
    '''
    for row in context.table:
        user = row["user"]
        passwd = row["passwd"]
        bClose = row["toClose"].lower()=="true"
        charset = row.get("charset",None)
        if charset is not None:
            setattr(context, "charset", charset)

        sql = row["sql"]
        if sql == "default_read":
            sql = get_sql("read")
        elif sql == "default_write":
            sql = get_sql("write")

        conn_type = row["conn"]
        expect = row["expect"]
        db = row["db"]
        if db is None: db = ''
        do_exec_sql(context, ip, user, passwd, db, port, sql=sql, bClose=bClose, conn_type=conn_type, expect=expect)

        if charset is not None:
            delattr(context, "charset")


def do_exec_sql(context,ip, user, passwd, db, port,sql,bClose, conn_type, expect):
        conn = None
        try:
            err=None
            if conn_type.lower() == "new":
                conn = DBUtil(ip, user, passwd, db, port, context)
            else:
                if hasattr(context, conn_type):
                    conn = getattr(context, conn_type)
                    LOGGER.debug("get conn: {0}".format(conn_type))
                else:
                    conn = DBUtil(ip, user, passwd, db, port, context)
                    setattr(context, conn_type, conn)
                    LOGGER.debug("create conn: {0} and setattr on context for this conn".format(conn_type))
        except MySQLdb.Error,e:
            err = e.args
        finally:
            LOGGER.debug("get or create conn:{0} got err:{1}".format(conn_type, err))

            if err is not None:
                context.logger.info("exec sql err is {0} {1}".format(err[0], err[1]))
            elif sql is not None and len(sql)>0:
                need_check_sharding = re.search(r'\/\*dest_node:(.*?)\*\/', sql, re.I)

                LOGGER.debug("sql:{0}, conn:{1}, err:{2}".format(sql,conn,err))

                if need_check_sharding:
                    cidx = need_check_sharding.start()
                    sql = sql[:cidx]
                    shardings = need_check_sharding.group(1)
                    turn_on_general_log(context, shardings, user, passwd)

                starttime = datetime.datetime.now()
                res,err = conn.query(sql)
                endtime = datetime.datetime.now()

                if need_check_sharding:
                    check_for_dest_sharding(context, sql, shardings, user, passwd)

            hasObj = re.search(r"has\{(.*?)\}", expect, re.I)
            hasnotObj = re.search(r"hasnot\{(.*?)\}", expect, re.I)
            lengthObj = re.search(r"length\{(.*?)\}", expect, re.I)
            matchObj = re.search(r"match\{(.*?)\}",expect,re.I)
            isBalance = re.search(r"balance\{(.*?)\}",expect, re.I)
            executeTime = re.search(r"execute_time\{(.*?)\}",expect, re.I)
            hasString = re.search(r"hasStr\{(.*?)\}", expect, re.I)
            hasNoString = re.search(r"hasNoStr\{(.*?)\}", expect, re.I)

            if expect == "success":
                assert_that(err is None, "expect no err, but outcomes '{0}'".format(err))
            elif hasObj or hasnotObj or lengthObj or matchObj or isBalance or hasString or hasNoString:
                assert_that(err is None, "expect no err, but outcomes '{0}'".format(err))
                if hasObj:
                    expectRS=hasObj.group(1)
                    context.logger.info("expectRS type is tuple:{0}".format(isinstance(eval(expectRS), tuple)))
                    context.logger.info("res type is tuple:{0}".format(isinstance(res, tuple)))
                    context.logger.info("expect resultset:{0}, real res:{1}".format(eval(expectRS), res))
                    hasResultSet(res, expectRS, True)
                if hasnotObj:
                    notExpectRS=hasnotObj.group(1)
                    # context.logger.info("debug notExpectRS:{0}".format(notExpectRS))
                    context.logger.info("not expect resultset:{0}, real res:{1}".format(eval(notExpectRS), res))
                    hasResultSet(res, notExpectRS, False)
                if lengthObj:
                    expectRS = lengthObj.group(1)
                    context.logger.info("expect resultset:{0}, length equal to real res length:{1}".format(eval(expectRS), len(res)))
                    assert_that(len(res),equal_to(eval(expectRS)),"sql resultset records count is not as expected")
                if matchObj:
                    match_Obj = matchObj.group(1)
                    context.logger.info("expect match_obj:{0}".format(match_Obj))
                    match_Obj_Split = re.split(r'[;,\s]', match_Obj.encode('ascii'))
                    context.logger.info("expect match_Obj_Split:{0}".format(match_Obj_Split))
                    matchResultSet(context,res, match_Obj_Split,len(match_Obj_Split)-1)
                if isBalance:
                    bal_num = isBalance.group(1)
                    balance(context,res,int(bal_num))
                if hasString:
                    expectRS = hasString.group(1)
                    assert_that(str(res), contains_string(str(expectRS)),
                                "expect containing text: {0}, resultset:{1}".format(expectRS, res))
                if hasNoString:
                    notExpectRS = hasNoString.group(1)
                    assert str(notExpectRS) not in str(res), "not expect containing text: {0}, resultset:{1}".format(
                        notExpectRS, res)
                    
            elif executeTime:
                expectRS = executeTime.group(1)
                duration = (endtime - starttime).seconds
                context.logger.info(" expect duration is :{0},real duration is{1} ".format(eval(expectRS), duration))
                assert_that(duration, equal_to(eval(expectRS)))

            else:
                assert_that(err,not_none(), "exec sql:{1} Err is None, expect:{0}".format(expect, sql))
                assert_that(err[1], contains_string(expect), "expect text: {0}, read err:{1}".format(expect,err))

        LOGGER.debug("to close {0} {1}".format(conn_type, bClose))
        if bClose:
            if conn is not None:
                conn.close()

            if hasattr(context, conn_type):
                delattr(context, conn_type)

def hasResultSet(res, expectRS, bHas):
    resExpect = eval(expectRS)
    real = False
    if isinstance(resExpect, list):#for multi-resultset
        for subResExpect in resExpect:
            assert isinstance(res, list), "expect mult-resultset, but real not"
            real = findFromMultiRes(res, subResExpect)
            assert real == bHas, "expect {0} in resultset {1}".format(resExpect, bHas)
    else:#for single query resultset
        if len(resExpect) == len(res) and type(resExpect[0])==type(res[0]):
            real = cmp(sorted(list(resExpect)),sorted(list(res)))==0
            # LOGGER.debug("***zhj debug 1")
        else:
            real = res.__contains__(resExpect)

            if not real == bHas:
                unicode_expect = resExpect.decode('utf8')
                expect_tuple = map(lambda x: filter(lambda y: y == unicode_expect, x), res)
                real = len(expect_tuple) > 0
                # LOGGER.debug("***zhj debug 2, len expect_tuple {0}".format(len(expect_tuple)))

        assert real == bHas, "expect {0} in resultset {1}".format(resExpect, bHas)

def matchResultSet(context,res,expect,num):
    subRes_list = []
    tmp = []
    partOfExpect = expect[0:num]
    if not isinstance(res[0], tuple):
        tmp.append(res)
    else:
        tmp = res
    for i in range(len(tmp)):
        strip =  re.sub('\s','',str(tmp[i]))
        subRes = re.split(r'[;,\s]',strip)
        partOfSubRes = subRes[0:num]
        context.logger.info("partOfSubRes:{0} length{1}".format((partOfSubRes),len(partOfSubRes)))
        context.logger.info("partOfExpect:{0} length{1}".format((partOfExpect), len(partOfExpect)))
        if cmp(partOfSubRes,partOfExpect)==0:
            subRes_list.append(partOfSubRes)

    context.logger.info("expect subRes_list:{0}".format(subRes_list))
    assert_that(subRes_list, not_none(), "expect subRes_list not None, but it is")

# the expext resultset must wholely in the same tuple of the mult-res list
# for example: res=[((1,2)),((3,4))], expect=((2,3)) shuold return False
def findFromMultiRes(res, expect):
    assert len(res)>0, "resultset is empty"
    if isinstance(expect, str): expLen = 1
    else: expLen = len(expect)
    for item in res:
        if item.__contains__(expect[0]):
            k = 1
            for subExpect in expect[1:]:
                if item.__contains__(subExpect): k = k+1
            if expLen == k: return True
    return False

def turn_on_general_log(context, shardings, user, passwd):
    sharding_list = shardings.split(",")

    fullpath = get_abs_path(context, "schema.xml")

    parentNode = {'tag':'root'}
    dataNode_info = {'tag':'dataNode'}
    dataHost_info = {'tag':'dataHost'}
    for sharding in sharding_list:
        dataNode_info['kv_map'] = {'name': sharding}
        dataNodes = get_child_nodes(parentNode, dataNode_info, fullpath)
        assert len(dataNodes)==1, "find more than 1 dataNodes match!!!"
        dataNode = dataNodes[0]
        db = dataNode.get('database')
        dataHost = dataNode.get("dataHost")

        dataHost_info['kv_map'] = {'name':dataHost}
        dataHosts=get_child_nodes(parentNode, dataHost_info, fullpath)
        assert len(dataHosts)==1, "find more than 1 dataHosts match!!!"
        dataHost = dataHosts[0]
        ip_port = dataHost.find("writeHost").get("url")
        ip=ip_port.split(":")[0]

        node = get_node(context.mysqls, ip)
        conn = DBUtil(ip, user, passwd, db, node.mysql_port, context)

        res, err = conn.query("set global log_output='file'")
        assert err is None, "get general log file fail for {0}".format(err[1])

        res, err = conn.query("set global general_log=off")
        assert err is None, "set general log off fail for {0}".format(err[1])

        res, err = conn.query("show variables like 'general_log_file'")
        assert err is None, "get general log file fail for {0}".format(err[1])

        general_log_file = res[0][1]
        rc, sto, ste = node.ssh_conn.exec_command('rm -rf {0}'.format(general_log_file))
        assert len(ste)==0, "rm general_log_file fail for {0}".format(ste)

        res, err = conn.query("set global general_log=on")
        assert err is None, "set general log on fail for {0}".format(err[1])

        conn.close()

def balance(context, RS, expectRS): #Float a value up and down

    re_num = int (re.sub("\D","",str(RS[0])))  #get the number from result of dble
    a = abs(re_num - expectRS)
    b = expectRS *0.15
    assert a<=b, "expect {0} in resultset {1}".format(expectRS, re_num)



#at present , it works only for insert
def check_for_dest_sharding(context, sql, shardings, user, passwd):
    sharding_list = shardings.split(",")

    sql_glog = sql.split("values")

    fullpath = get_abs_path(context, "schema.xml")

    parentNode = {'tag':'root'}
    dataNode_info = {'tag':'dataNode'}
    dataHost_info = {'tag':'dataHost'}
    for sharding in sharding_list:
        dataNode_info['kv_map'] = {'name': sharding}
        dataNodes = get_child_nodes(parentNode, dataNode_info, fullpath)
        assert len(dataNodes)==1, "find more than 1 dataNodes match!!!"
        dataNode = dataNodes[0]
        db = dataNode.get('database')
        dataHost = dataNode.get("dataHost")

        dataHost_info['kv_map'] = {'name':dataHost}
        dataHosts=get_child_nodes(parentNode, dataHost_info, fullpath)
        assert len(dataHosts)==1, "find more than 1 dataHosts match!!!"
        dataHost = dataHosts[0]
        ip_port = dataHost.find("writeHost").get("url")
        ip=ip_port.split(":")[0]

        node = get_node(context.mysqls, ip)
        conn = DBUtil(ip, user, passwd, db, node.mysql_port, context)

        res, err = conn.query("show variables like 'general_log_file'")
        assert err is None, "get general log file fail for {0}".format(err[1])

        general_log_file = res[0][1]

        rc, sto, ste = node.ssh_conn.exec_command('grep -i -F -n "{0}" {1}'.format(sql_glog[1], general_log_file))
        assert len(ste)==0, "grep sql in general_log_file fail for {0}".format(ste)
        assert len(sto)>0, "can not found the sql general log in expect sharding node"

        res, err = conn.query("set global general_log=off")
        assert err is None, "set general log on fail for {0}".format(err[1])

        conn.close()

@Then('connect "{hostname}" to insert "{num}" of data for "{tablename}"')
@Then('connect "{hostname}" to insert "{num}" of data for "{dbname}"."{tablename}"')
def step_impl(context,hostname,num, tablename,dbname="schema1"):
    sql = ("insert into {0} (id,name) values".format(tablename))
    end = int(num)
    for i in range(1, end + 1):
        inspection_num = 'NJ' + str(100000 + i)
        if (i == end):
            sql = sql +("({0},'{1}');".format(i, inspection_num))
        else:
            sql = sql + ("({0},'{1}'),".format(i, inspection_num))
        
    do_batch_sql(context,hostname,dbname, sql)

@Then('connect "{hostname}" to execute "{num}" of select')
@Then('connect "{hostname}" to execute "{num}" of select for "{tablename}"')
@Then('connect "{hostname}" to execute "{num}" of select for "{dbname}"."{tablename}"')
def step_impl(context, hostname, num, tablename="", dbname="schema1"):
    end = int(num)
    for i in range(1, end + 1):
        if 0 == i % 1000:
            time.sleep(60)
        if context.text:
            sql = context.text.strip()
        else:
            id == random.randint(1, end)
            sql = ("select name from {0} where id ={1};".format(tablename, i))
        do_batch_sql(context,hostname, dbname, sql)
    
def do_batch_sql(context, hostname, db, sql):
    conn = None
    node = get_node(context.dbles, hostname)
    ip = node._ip
    user = context.cfg_dble['client_user']
    passwd = context.cfg_dble['client_password']
    port = context.cfg_dble['client_port']
    try:
        conn = DBUtil(ip, user, passwd, db, port, context)
        res, err = conn.query(sql)
    except MySQLdb.Error,e:
        errMsg = e.args
        context.logger.info("try to create conn and exec sql:{0} failed:{1}".format(sql,errMsg))
    finally:
        try:
            conn.close()
        except:
            context.logger.info("close conn failed!")
    assert_that(err is None, "excute batch sql: '{0}' failed! outcomes:'{1}'".format(sql, err))
    
@Then('execute sql "{sql}" in "{host}" with "{results}" result')
def step_impl(context,sql,host,results):
    node = get_node(context.mysqls, host)
    ip = node._ip
    port = node._mysql_port
    resultList = []
    for row in context.table:
        user = row["user"]
        passwd = row["passwd"]
        bClose = row["toClose"].lower()=="true"
        charset = row.get("charset",None)
        if charset is not None:
            setattr(context, "charset", charset)
        conn_type = row["conn"]
        expect = row["expect"]
        db = row["db"]
        if db is None: db = ''

        resultList = getattr(context,results)
        for result in resultList:
            sql = sql + ' ' +'"{0}"'.format(result)
            do_exec_sql(context, ip, user, passwd, db, port, sql=sql, bClose=bClose, conn_type=conn_type, expect=expect)
        if charset is not None:
            delattr(context, "charset")
