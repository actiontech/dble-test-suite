# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/5 下午5:38
# @Author  : irene-coming

import MySQLdb
import logging

logger = logging.getLogger('lib.MysqlConnUtil')
class MysqlConnUtil:
    def __init__(self, *args, **kwargs):
        logger.debug('create query connection with args:{}, kwargs:{}'.format(args, kwargs))
        try:
            self._conn = MySQLdb.connect(*args, **kwargs)
            self._kwargs = kwargs
        except MySQLdb.Error, e:
            errMsg = e.args
            logger.debug("create connect err: {0}".format(errMsg))
            raise

    def execute(self, sql):
        dest_info = "{}:{}".format(self._kwargs.get("host",None), self._kwargs.get("port",None))
        try:
            cursor = self._conn.cursor()
            result = None
            errMsg = None
            logger.debug("try to execute sql:{0} in {1}".format(sql[0:500], dest_info))
            cursor.execute(sql)
            result = []
            while True:
                result.append(cursor.fetchall())
                if cursor.nextset() is None: break

            cursor.close()
        except MySQLdb.Error,e:
            errMsg = e.args
        except UnicodeEncodeError, codeErr:
            errMsg = ((codeErr.args[1],codeErr.args[4]))
        finally:
            pass

        if errMsg is not None:
            showErr = "execute sql in {} failed for: {}".format(dest_info, errMsg)
            logger.debug(showErr);
        else:
            logger.debug("execute sql in {} success, resultset: ".format(dest_info))
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