# -*- coding: UTF-8 -*-
# from behave import *
import mysql.connector
import os
from preprocess import makedirfile
# from compare import compareFile
from config import getConfig
from comparefunc import comparelist

configs = getConfig('C:\Users\ThinkPad\dble\conf')
dble_config = configs[0]
mysql_config= configs[1]

curr_path = os.path.abspath(__file__)
currdir = os.path.dirname(curr_path)
parentdir = os.path.dirname(currdir)
# sqlpath = parentdir + '\\sql_cover\\route_sharding.sql'
sqlpath = parentdir + '\\sql_cover\\test.sql'

filedic = makedirfile('result','dbleResults.txt','mysqlResults.txt','compareResults.txt')

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
comparedf = open(filedic['compareResults.txt'], 'a')

# to execute the sqls and compare the ResultSet
sqlf = open(sqlpath, 'r')
sqls = sqlf.readlines()
for sql in sqls:
    if sql[:1] != '#':
        sql = sql.strip('\n') + ';'
        dblecur.execute(sql)
        dbleconn.commit()
        mysqlcur.execute(sql)
        mysqlconn.commit()
        execstr = '============' + sql + '============'
        dblef.write(execstr + '\n')
        mysqlf.write(execstr + '\n')
        comparedf.write(execstr + '\n')
        try:
            dblerows = dblecur.fetchall()
            mysqlrows = mysqlcur.fetchall()
            if len(dblerows) > 0:
                for row in dblerows:
                    # print dblerows
                    dblef.write(str(row) + '\n')
            if len(mysqlrows) > 0:
                for row in mysqlrows:
                    # print row
                    mysqlf.write(str(row) + '\n')
            comparers = comparelist(dblerows,mysqlrows)
            if len(comparers)>0:
                for row in comparers:
                    # print comparers
                    comparedf.write(str(row) + '\n')
        except mysql.connector.Error as e:
            print('connect fails!{}'.format(e))

#close the files
sqlf.close()
comparedf.close()
dblef.close()
mysqlf.close()
#close the dble and mysql
dblecur.close()
mysqlcur.close()
dbleconn.close()
mysqlconn.close()


