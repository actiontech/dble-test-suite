# -*- coding: UTF-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# from behave import *
import mysql.connector
import os
from preprocess import makedirfile
from config import getConfig
from comparefunc import comparelist


# configs = getConfig('C:\Users\ThinkPad\dble\conf')
configs = getConfig('F:\Actionskyworkspace\dble\dble\conf')
dble_config = configs[0]
mysql_config = configs[1]

curr_path = os.path.abspath(__file__)
currdir = os.path.dirname(curr_path)
parentdir = os.path.dirname(currdir)
# sqlpath = parentdir + '\\sql_cover\\route_sharding.sql'
sqlpath = parentdir + '\\sql_cover\\test.sql'

# get the sql file path and name, then create the log files
spath = os.path.dirname(sqlpath)
sname = os.path.basename(sqlpath)
pass_log = sname.split('.')[0] + '_pass.log'
fail_log = sname.split('.')[0] + '_fail.log'
filedic = makedirfile('result', 'dbleResults.txt', 'mysqlResults.txt', pass_log, fail_log)

try:
    dbleconn = mysql.connector.connect(**dble_config)
    print 'dble is connected !'
except mysql.connector.Error as e:
    print('connect fails!{}'.format(e))
dblecur = dbleconn.cursor(buffered=True)

try:
    mysqlconn = mysql.connector.connect(**mysql_config)
    print 'mysql is connected !'
except mysql.connector.Error as e:
    print('connect fails!{}'.format(e))

mysqlcur = mysqlconn.cursor(buffered=True)

dblef = open(filedic['dbleResults.txt'], 'a')
mysqlf = open(filedic['mysqlResults.txt'], 'a')
passf = open(filedic[pass_log], 'a')
failf = open(filedic[fail_log], 'a')

# to execute the sqls and compare the ResultSet
sqlf = open(sqlpath, 'r')
sqls = sqlf.readlines()
lineNum = 1
for sql in sqls:
    sql = sql.strip('\n')
    sqlstr = '===File：' + sqlpath + ', id:' + str(lineNum) + ', sql:' + sql + '==='
    dblef.write(sqlstr + '\n')
    mysqlf.write(sqlstr + '\n')

    if sql[:1] != '#':
        sql = sql.strip('\n') + ';'
        execstr = '===File：' + sqlpath + ', id:' + str(lineNum) + ', sql:' + sql + '==='
        # exec sql with dble
        try:
            dblecur.execute(sql)
            dbleconn.commit()
            try:
                dblerows = dblecur.fetchall()
                if len(dblerows) > 0:
                    for row in dblerows:
                        dblef.write(str(row) + '\n')
            except mysql.connector.Error as e:
                # print('connect fails!{}'.format(e))
                dblerows = format(e)
                dblef.write(str(dblerows) + '\n')
        except mysql.connector.Error as e:
            # print('connect fails!{}'.format(e))
            dblerows = format(e)
            dblef.write(str(dblerows) + '\n')

        # exec sql with mysql
        try:
            mysqlcur.execute(sql)
            mysqlconn.commit()
            try:
                mysqlrows = mysqlcur.fetchall()
                if len(mysqlrows) > 0:
                    for row in mysqlrows:
                        mysqlf.write(str(row) + '\n')
            except mysql.connector.Error as e:
                # print('connect fails!{}'.format(e))
                mysqlrows = format(e)
                mysqlf.write(str(mysqlrows) + '\n')
        except mysql.connector.Error as e:
            # print('connect fails!{}'.format(e))
            mysqlrows = format(e)
            mysqlf.write(str(mysqlrows) + '\n')
        # compare the two results
        comparers = comparelist(dblerows, mysqlrows)
        (key, value), = comparers.items()
        if key == 's':
            passf.write(execstr + '\n')
            if len(value) > 0:
                for row in value:
                    passf.write(str(row) + '\n')
        else:
            failf.write(execstr + '\n')
            if len(value) > 0:
                for row in value:
                    failf.write(str(row) + '\n')

    lineNum = lineNum + 1

# close the files
sqlf.close()
passf.close()
failf.close()
dblef.close()
mysqlf.close()
# close the dble and mysql
dblecur.close()
mysqlcur.close()
dbleconn.close()
mysqlconn.close()
