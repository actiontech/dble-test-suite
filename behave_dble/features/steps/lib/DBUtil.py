# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import MySQLdb
import logging

logger = logging.getLogger('lib')
class DBUtil:
    def __init__(self, strHost, strUser, strPassword, strDataBase, strPort, context):
        self._context = context
        self._host = strHost
        self._port = strPort
        logger.debug(
            'create query connection with host:{0},user:{1},passwd:{2},db:{3},port:{4}'.format(strHost, strUser,
                                                                                               strPassword, strDataBase,
                                                                                               strPort))
        try:
            if hasattr(context, "charset"):
                mycharset= getattr(context, "charset")
                self._conn = MySQLdb.connect(host=strHost, user=strUser, passwd=str(strPassword), db=strDataBase, port=strPort,
                                         autocommit=True, charset=mycharset)
                logger.debug("conn charset is : {0}".format(mycharset))
            else:
                self._conn = MySQLdb.connect(host=strHost, user=strUser, passwd=str(strPassword), db=strDataBase, port=strPort,
                                         autocommit=True)
            self._cursor = self._conn.cursor()
        except MySQLdb.Error, e:
            errMsg = e.args
            context.logger.info("create connect err: {0}".format(errMsg))
            raise

    def query(self, sql):
        try:
            result = None
            errMsg = None
            logger.debug("execute sql:{0} in {1}:{2}".format(sql[0:500], self._host, self._port))
            self._cursor.execute(sql)
            result = []
            while True:
                result.append(self._cursor.fetchall())
                if self._cursor.nextset() is None: break
        except MySQLdb.Error,e:
            errMsg = e.args
        except UnicodeEncodeError, codeErr:
            errMsg = ((codeErr.args[1],codeErr.args[4]))
        finally:
            pass

        if errMsg is not None:
            showErr = "host:{1} execute sql:{2} err: {0}".format(errMsg, self._host, sql[0:500])
            self._context.logger.info(showErr);
        else:
            logger.debug("{0}:{1} sql executed without err".format(self._host, self._port))
            for row in result:
                logger.debug(row[0:300])

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
        if hasattr(self, '_conn') and self._conn != None:
            self._conn.close()
            self._conn = None
    def commit(self):
        self._conn.commit()