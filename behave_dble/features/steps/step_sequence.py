# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import os
import threading
from behave_dble.features.steps.lib.utils import get_node

coding= 'utf8'
import logging
from behave import *
from hamcrest import *

from step_reload import get_dble_conn

LOGGER = logging.getLogger('steps.sequence')

def insertOneRow(context, table, rowsPerThread):
    conn = get_dble_conn(context)
    sql = "insert into {0} values('abc')".format(table)
    context.logger.debug("execute query in subthread")
    for i in range(rowsPerThread):
        res, errMsg = conn.query(sql)
        assert errMsg is None, "expect '{0}' success, but get: {1}".format(sql, errMsg)
    conn.close()

@Then('insert "{totalsRowsInsert:d}" rows to global sequence table "{table}" in "{threadNum:d}" thread')
def step_impl(context, totalsRowsInsert, table, threadNum):
    realThreadNum = min(totalsRowsInsert, threadNum)
    rowsPerThread = totalsRowsInsert/threadNum
    roundantRows = totalsRowsInsert%threadNum

    threadsList = []
    for k in range(realThreadNum):
        if k < roundantRows:
            rowsPerThread = rowsPerThread + 1
        LOGGER.debug("rowsPerThread to insert : {0}".format(rowsPerThread))
        thd_name = "insert_thd_{0}".format(k)
        thd = threading.Thread(target=insertOneRow, name=thd_name, args=(context, table, rowsPerThread))
        threadsList.append(thd)

    for i in range(realThreadNum):
        threadsList[i].start()

    for i in range(realThreadNum):
        threadsList[i].join()

@Then('execute sqlFile to initialize sequence table')
def step_impl(context):
    node = get_node("mysql-master1")

    # copy dble's dbseq.sql to local
    dble_node = get_node("dble-1")
    source_remote_file = "{0}/dble/conf/dbseq.sql".format(dble_node.install_dir)
    target_remote_file = "{0}/data/dbseq.sql".format(node.install_path)
    local_file  = "{0}/dbseq.sql".format(os.getcwd())

    ssh_client = node.ssh_conn;

    cmd="rm -rf {0}".format(local_file)
    ssh_client.exec_command(cmd);

    context.ssh_sftp.sftp_get(source_remote_file, local_file)
    node.sftp_conn.sftp_put(local_file, target_remote_file)

    cmd = "mysql -utest -p111111 db1 < {0}".format(target_remote_file)
    ssh_client.exec_command(cmd)

    #execute dbseq.sql at the node configed in sequence file
    context.execute_steps(u"""
    Then execute sql in "mysql-master1"
        | user | passwd | conn   | toClose | sql                                                               | expect  | db     |
        | test | 111111 | conn_0 | True    | insert into DBLE_SEQUENCE values ('`schema1`.`test_auto`', 3, 1)  | success | db1    |
    """)