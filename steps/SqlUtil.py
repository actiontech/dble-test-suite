# -*- coding: utf-8 -*-
# @Time    : 2018/4/2 PM6:56
# @Author  : zhaohongjie@actionsky.com
import datetime
import re

import MySQLdb
from behave import *
from hamcrest import *

from lib.DBUtil import DBUtil
from lib.XMLUtil import get_node_attr_by_kv
from lib.Node import get_node



def get_sql(type):
    if type == "read":
        sql="select 1 "
    else:
        sql="drop table if exists char_columns"

    return sql

@Then('execute sql in "{hostname}"')
@Then('execute sql in "{hostname}"use"{user}"')
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

        sql = row["sql"]
        if sql == "default_read":
            sql = get_sql("read")
        elif sql == "default_write":
            sql = get_sql("write")

        conn_type = row["conn"]
        expect = row["expect"]
        db = row["db"]
        if db is None: db = ''

        if sql == "batch_insert":
            table_name = row["tb"]
            end = int(row["count"])
            context.logger.info("1111111111111111111111111111111111the count is {0}".format(end))
            for i in range(1, end):
                inspection_num = 'NJ' + str(100000 + i)
                id == int(i)
                sql = ("insert into {0} (id,name) values({1},'{2}');".format(table_name,i,inspection_num))
                do_exec_sql(context, ip, user, passwd, db, port, sql=sql, bClose=bClose, conn_type=conn_type,
                            expect=expect)
        elif sql =="batch_select":
            table_name = row["tb"]
            end = int(row["count"])
            for i in range(1, end):
                id == int(i)
                sql = ("select name from {0} where id ={1};".format(table_name,i))
                do_exec_sql(context, ip, user, passwd, db, port, sql=sql, bClose=bClose, conn_type=conn_type,
                            expect=expect)
        else:
            do_exec_sql(context, ip, user, passwd, db, port, sql=sql, bClose=bClose, conn_type=conn_type, expect=expect)

def do_exec_sql(context,ip, user, passwd, db, port,sql,bClose, conn_type, expect):
        conn = None
        try:
            err=None
            if conn_type.lower() == "new":
                conn = DBUtil(ip, user, passwd, db, port, context)
            else:
                if hasattr(context, conn_type):
                    conn = getattr(context, conn_type)
                    context.logger.info("get conn: {0}".format(conn_type))
                else:
                    conn = DBUtil(ip, user, passwd, db, port, context)
                    setattr(context, conn_type, conn)
                    context.logger.info("create conn: {0} and setattr on context for this conn".format(conn_type))
        except MySQLdb.Error,e:
            err = e.args
        finally:
            context.logger.info("get or create conn:{0} got err:{1}".format(conn_type, err))

            if err is not None:
                context.logger.info("exec sql err is {0} {1}".format(err[0], err[1]))
            elif sql is not None and len(sql)>0:
                need_check_sharding = re.search(r'\/\*dest_node:(.*?)\*\/', sql, re.I)

                context.logger.info("sql:{0}, conn:{1}, err:{2}".format(sql,conn,err))

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


                if bClose:
                    conn.close()

            hasObj = re.search(r"has\{(.*?)\}", expect, re.I)
            hasnotObj = re.search(r"hasnot\{(.*?)\}", expect, re.I)
            lengthObj = re.search(r"length\{(.*?)\}", expect, re.I)
            matchObj = re.search(r"match\{(.*?)\}",expect,re.I)
            isBalance = re.search(r"balance\{(.*?)\}",expect, re.I)
            executeTime = re.search(r"execute\{(.*?)\}",expect, re.I)


            if expect == "success":
                assert_that(err is None, "expect no err, but outcomes '{0}'".format(err))
            elif hasObj or hasnotObj or lengthObj or matchObj or isBalance:
                assert_that(err is None, "expect no err, but outcomes '{0}'".format(err))
                if hasObj:
                    expectRS=hasObj.group(1)
                    context.logger.info("expectRS type is :{0}".format(isinstance(eval(expectRS), tuple)))
                    context.logger.info("res type is :{0}".format(isinstance(res, tuple)))
                    context.logger.info("expect resultset:{0}, real res:{1}".format(eval(expectRS), res))
                    hasResultSet(res, expectRS, True)
                if hasnotObj:
                    notExpectRS=hasnotObj.group(1)
                    # context.logger.info("debug notExpectRS:{0}".format(notExpectRS))
                    hasResultSet(res, notExpectRS, False)
                if lengthObj:
                    expectRS = lengthObj.group(1)
                    context.logger.info("expect resultset:{0}, real res:{1}".format(eval(expectRS), len(res)))
                    assert_that(len(res),equal_to(eval(expectRS)))
                if matchObj:
                    match_Obj = matchObj.group(1)
                    context.logger.info("expect match_obj:{0}".format(match_Obj))
                    match_Obj_Split = re.split(r'[;,\s]', match_Obj.encode('ascii'))
                    context.logger.info("expect match_Obj_Split:{0}".format(match_Obj_Split))
                    matchResultSet(context,res, match_Obj_Split,len(match_Obj_Split)-1)
                if isBalance:
                    bal_num = isBalance.group(1)
                    balance(context,res,int(bal_num))

            elif executeTime:
                expectRS = executeTime.group(1)
                duration = (endtime - starttime).seconds
                context.logger.info(" expect duration is :{0},real duration is{1} ".format(eval(expectRS), duration))
                assert_that(duration, equal_to(eval(expectRS)))

            else:
                assert_that(err, not None, "Err is None, expect:{0}".format(expect))
                assert_that(err[1], contains_string(expect), "expect text: {0}".format(expect))

        context.logger.info("to close {0} {1}".format(conn_type, bClose))
        if bClose and conn is not None:
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
        if len(resExpect) == len(res):
            if cmp(sorted(list(resExpect)),sorted(list(res)))==0:
                real = True
        else:
            real = res.__contains__(resExpect)
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
    assert_that(subRes_list,not None)

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

    from steps.step_reload import get_abs_path
    fullpath = get_abs_path(context, "schema.xml")

    parentNode = {'tag':'root'}
    childNode = {'tag':'dataNode', 'attr':['dataHost','database']}
    for sharding in sharding_list:
        childNode['kv_map'] = {'name': sharding}
        dic = get_node_attr_by_kv(parentNode, childNode, fullpath)
        ip = dic.get("dataHost")
        db = dic.get('database')
        node = get_node(context.mysqls, ip)
        conn = DBUtil(ip, user, passwd, db, node.mysql_port, context)

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

def balance(context, expectRS, bHas): #Float a value up and down

    re_num = int (re.sub("\D","",str(expectRS[0])))

    a = abs(re_num - bHas)
    b = bHas *0.2
    if(a < b):
        rs = True
    else:
        rs = False
    assert rs == True, "expect {0} in resultset {1}".format(expectRS, bHas)



#at present , it works only for insert
def check_for_dest_sharding(context, sql, shardings, user, passwd):
    sharding_list = shardings.split(",")

    sql_glog = sql.split("values")

    from steps.step_reload import get_abs_path
    fullpath = get_abs_path(context, "schema.xml")

    parentNode = {'tag': 'root'}
    childNode = {'tag': 'dataNode', 'attr': ['dataHost', 'database']}
    for sharding in sharding_list:
        childNode['kv_map'] = {'name': sharding}
        dic = get_node_attr_by_kv(parentNode, childNode, fullpath)
        ip = dic.get("dataHost")
        db = dic.get('database')
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