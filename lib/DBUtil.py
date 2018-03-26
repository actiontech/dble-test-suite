import MySQLdb
from killthread import *

class DBUtil:
    def __init__(self, strHost, strUser, strPassword, strDataBase, strPort, context):
        self._context = context
        self._host = strHost
        self._port = strPort
        context.logger.info(
            'create query connection with host:{0},user:{1},passwd:{2},db:{3},port:{4}'.format(strHost, strUser,
                                                                                               strPassword, strDataBase,
                                                                                               strPort))
        try:
            self._conn = MySQLdb.connect(host=strHost, user=strUser, passwd=str(strPassword), db=strDataBase, port=strPort,
                                         autocommit=True)
        except MySQLdb.Error, e:
            errMsg = e.args
            context.logger.debug("create connect err: {0}".format(errMsg))
            raise

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

    def dropTable(self, table_name):
        try:
            self._context.logger.info("drop table if EXISTS {0}".format(table_name))
            self.qeury('drop table if exists ' + table_name + ';')
        except Exception, e:
            print (e)

    def autocommit(self, isautocommit):
        self._conn.autocommit(isautocommit)

    def __del__(self):
        self.close()

    def close(self):
        if self._conn != None:
            self._conn.close()
            self._conn = None


class DBcheck:
    def __init__(self, strHost, strUser, strPassword, context):
        self._context = context
        self._host = strHost
        self._user = strUser
        self._passwd = strPassword

    def conn_client(self, db):
        self._context.logger.info(
            'create query connection with host:{0},user:{1},passwd:{2},port:{3}'.format(self._host, self._user,
                                                                                        self._passwd,
                                                                                        self._context.dble_test_config['client_port']))
        try:
            self._conn = MySQLdb.connect(host=self._host, user=self._user, passwd=self._passwd,
                                         port=self._context.dble_test_config['client_port'], db=db,
                                         autocommit=True)
        except MySQLdb.Error, e:
            errMsg = e.args
            self._context.logger.debug("create connect err: {0}".format(errMsg))
            return "login client failure"
        return "login client succeed"

    def conn_manager(self):
        self._context.logger.info(
            'create query connection with host:{0},user:{1},passwd:{2},port:{3}'.format(self._host, self._user,
                                                                                        self._passwd,
                                                                                        self._context.dble_test_config['manager_port']))
        try:
            self._conn = MySQLdb.connect(host=self._host, user=self._user, passwd=self._passwd,
                                         port=self._context.dble_test_config['manager_port'],
                                         autocommit=True)
        except MySQLdb.Error, e:
            errMsg = e.args
            self._context.logger.debug("create connect err: {0}".format(errMsg))
            return "login manager failure"
        return "login manager succeed"