# -*- coding: UTF-8 -*-
import MySQLdb

class QueryDB:
    # def __init__(self, strHost, strUser, strPassword, strDataBase, strPort):
    def __init__(self, strHost, strUser, strPassword, strDataBase, strPort, context):
        self._context = context
        self._host = strHost
        context.logger.info('create query connection with host:{0},user:{1},passwd:{2},db:{3},port:{4}'.format(strHost,strUser,strPassword,strDataBase, strPort))
        try:
            # self._conn = MySQLdb.connect(host = strHost, user = strUser, passwd = strPassword, db = strDataBase, port = strPort, autocommit=True, charset = "utf8", use_unicode = True)
            self.conn = MySQLdb.connect(host = strHost, user = strUser, passwd = strPassword, db = strDataBase, port = strPort, autocommit=True)
            self.cur = self.conn.cursor()
        except MySQLdb.Error,e:
            errMsg = e.args
            # context.logger.debug("create connect err: {0}".format(errMsg))
            raise

    #execute sql
    def execute_sql(self, sql):
        try:
            result = None
            errMsg = None
            ex = self.cur.execute
            ex(sql)
            result = self.cur.fetchall()
            #print str(result)
        except Exception, e:
            errMsg = e.args
        finally:
            self.conn.commit()
        return result, errMsg

    # create a table
    def createTable(self, sql):
        try:
            ex = self.cur.execute
            ex(sql)
            self.conn.commit()
        except Exception, e:
            print (e)
            return str(e)

    # insert single record
    def insert(self, name, value):
        try:
            self.cur.execute('insert into ' + name + ' values (%s,%s);', value)
            self.conn.commit()
        except Exception, e:
            return e

    # insert more records
    def insertMore(self, name, values):
        try:
            self.cur.executemany('insert into ' + name + ' values (%s,%s)', values)
        except Exception, e:
            print (e)

    # get record count from db table
    def getCount(self, name):
        try:
            count = self.cur.execute('select * from ' + name + ';')
            print (count)
            return count
        except Exception, e:
            print (e)

    def select(self, sql):
        try:
            self.cur.execute(sql)
            result = self.cur.fetchone()
            return result
        except Exception, e:
            print (e)

    # select last record from database
    def selectLast(self, name):
        try:
            self.cur.execute('SELECT * FROM ' + name + ' ORDER BY id DESC;')
            result = self.cur.fetchone()
            return result
        except Exception, e:
            print (e)

    # select next n records from database
    def selectNRecord(self, name, n):
        try:
            self.cur.execute('select * from ' + name + ';')
            results = self.cur.fetchmany(n)
            return results
        except Exception, e:
            print (e)

    # select all records
    def selectAll(self, name):
        try:
            self.cur.execute('select * from ' + name + ';')
            self.cur.scroll(0, mode='absolute')  # reset cursor location (mode = absolute | relative)
            results = self.cur.fetchall()
            return results
        except Exception, e:
            print (e)

    # delete a record
    def deleteByID(self, name, id):
        try:
            self.cur.execute('delete from ' + name + ' where id=%s;', id)
        except Exception, e:
            print (e)

    # delete some record
    def deleteSome(self, name):
        pass

    # drop the table
    def dropTable(self, name,context):
        try:
            context.logger.info("drop table if EXISTS {0}".format(name))
            self.cur.execute('drop table if exists ' + name + ';')
            self.conn.commit()
        except Exception, e:
            print (e)

    # drop the database
    def dropDB(self, name):
        try:
            self.cur.execute('drop database ' + name + ';')
        except Exception, e:
            print (e)


# if __name__ == '__main__':
#     result = None
#     errMes = None
#     testDB = QueryDB("10.186.23.12","test","test","mytest",8066)
#     sql = "select id from sbtest1"
#     result, errMes = testDB.execute_sql(sql)
#     if type(result) == tuple:
#         for i in range(len(result)):
#             print result[i][0]
    #print result
    # exp = Explain(result)
    # rot = exp.route_datanode()
    # sql, node = exp.get_realsql()
    # print rot
    # for i in range(len(node)):
    #     print node[i], sql[i]
    #
    # router_node = []
    # if type(result) == tuple:
    #     for i in range(len(result)):
    #         # print result[i][0]
    #         if result[i][1] == "BASE SQL":
    #             router_node.append(result[i][0])
    #         # sql = "/*!{0}:dataNode={1}*/select count(*) from {2}".format("dble", result[i][0], "mytest_test1")
    #         # result, errMes = testDB.execute_sql(sql)
    # print router_node


