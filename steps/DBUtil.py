import MySQLdb
from killthread import *

class DBUtil:
    def __init__(self, strHost, strUser, strPassword, strDataBase, strPort, context):
        self._context = context
        self._host = strHost
        self._db=strDataBase
        self._port = strPort
        context.logger.info('create query connection with host:{0},user:{1},passwd:{2},db:{3},port:{4},this:{5}'.format(strHost,strUser,strPassword,strDataBase, strPort,self))
        try:
            self._conn = MySQLdb.connect(host = strHost, user = strUser, passwd = strPassword, db = strDataBase, port = strPort, autocommit=True)
        except MySQLdb.Error,e:
            errMsg = e.args
            context.logger.debug("create connect err: {0}".format(errMsg))
            raise

    @timeout(3)
    def query(self, sql):
        try:
            cursor = self._conn.cursor()
            result = None
            errMsg = None
            self._context.logger.info("execute sql:{0} in {1}:{2}".format(sql[0:500], self._host, self._port))
            cursor.execute(sql)
            result = []
            while True:
                result.append(cursor.fetchall())
                if cursor.nextset() is None: break
        except MySQLdb.Error,e:
            errMsg = e.args
        finally:
            pass

        if errMsg is not None:
            showErr = "host:{1} execute sql err: {0}".format(errMsg, self._host)
            self._context.logger.info(showErr);
        else:
            self._context.logger.info("{0}:{1} sql executed without err".format(self._host, self._port))
            for row in result:
                self._context.logger.info(row[0:300])

        if result!=None and len(result)==1:
            res = result[0]
        else:
            res = result
        return res, errMsg

    def autocommit(self, isautocommit):
        self._conn.autocommit(isautocommit)

    def __del__(self):
        self.close()

    def close(self):
        if self._conn != None:
            self._conn.close()
            self._conn = None

class DBnodb:
    def __init__(self, strHost, strUser, strPassword, strPort, context):
        self._context = context
        self._host = strHost
        context.logger.info(
            'create query connection with host:{0},user:{1},passwd:{2},port:{3}'.format(strHost, strUser,strPassword, strPort))
        try:
            self._conn = MySQLdb.connect(host=strHost, user=strUser, passwd=strPassword, port=strPort,
                                         autocommit=True)
        except MySQLdb.Error, e:
            errMsg = e.args
            context.logger.debug("create connect err: {0}".format(errMsg))
            raise

    def query(self, sql, toClose=True):
        try:
            cursor = self._conn.cursor()
            result = None
            errMsg = None
            cursor.execute(sql)
            result = cursor.fetchall()
        except MySQLdb.Error, e:
            errMsg = e.args
        finally:
            if (toClose):
                cursor.close()
                self.close()

        self._context.logger.info("execute sql:{0} in {1}".format(sql[0:500], self._host))
        if errMsg is not None:
            showErr = "host:{1} execute sql err: {0}".format(e.args, self._host)
            self._context.logger.info(showErr);
        else:
            self._context.logger.info("sql executed without err")
            for row in result:
                self._context.logger.info(row[0:300])

        return result, errMsg

    def autocommit(self, isautocommit):
        self._conn.autocommit(isautocommit)

    def __del__(self):
        self.close()

    def close(self):
        if self._conn != None:
            self._conn.close()
            self._conn = None
