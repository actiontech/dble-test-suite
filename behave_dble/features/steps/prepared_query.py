# -*- coding: utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2023/6/1
# @Author  : quexiuping

import mysql.connector
import argparse
import logging

logger = logging.getLogger('root')

def create_conn(args):
    host = args.host
    user = args.user
    password = args.password
    database = args.database
    port = args.port
    connection = mysql.connector.connect(host=host,database=database,user=user,port=port,password=password,autocommit=True)
    return connection

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Usage example: python3 prepared.py --host 172.100.9.1 --user test --password 111111 --database schema1 --port 8066")
    parser.add_argument('--host', type=str, default='172.100.9.1')
    parser.add_argument('--user', type=str, default='test')
    parser.add_argument('--password', type=str, default='111111')
    parser.add_argument('--database', type=str, default='schema1', help="database")
    parser.add_argument('--port', type=int, default=8066, help="port")

    args = parser.parse_args()
    connection = create_conn(args)
    # print(args)
def execute_prepared_query(connection, sql_query, params):
    try:
        cursor = connection.cursor(prepared=True)
        result = []
        cursor.execute(sql_query, params)
        while True:
            result.append(cursor.fetchall())
            if cursor.nextset() is None: break
        # connection.commit()
        cursor.close()
        logger.debug(("The sql using the prepared statement successfully,the query is:{}").format(sql_query))

    except mysql.connector.Error as error:
        logger.info("query failed {}".format(error))
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
            logger.debug("connection is closed")


##可以通过修改文件来执行python文件达到需要的query类型
# sql_query = "select * from test where id = %s or name =%s"
# params = (1,'id')
#
# execute_prepared_query(connection, sql_query, params)
