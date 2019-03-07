import os

from behave_dble.features.steps.lib.DBUtil import DBUtil
from behave_dble.features.steps.lib.Node import get_node

coding= 'utf8'
import logging
from behave import *
from hamcrest import *

from step_reload import get_dble_conn
from lib.generate_util import generate

LOGGER = logging.getLogger('steps.sequence')

@Then('test queries with table using global sequence')
def step_impl(context):
    text = eval(context.text)
    tb = text.get("table")
    sequnceHandlerType = text.get("sequnceHandlerType")

    gen = generate()
    rand_str = gen.rand_string(20)
    dble_conn = get_dble_conn(context)

    #can not assign value to sequenceColumn, and can assgin value to columns without sequenceColumn
    context.execute_steps(u"""
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                    | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                                               | success           | schema1 |
        | test | 111111 | conn_0 | False   | create table {0}(id {1} primary key auto_increment, name varchar(20))  | success           | schema1 |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                                          | success           | schema1 |
        | test | 111111 | conn_0 | False   | insert into {0}(name) values('{2}')          | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into {0}(id,name) values(1, '{2}')    | In insert Syntax, you can't set value for Autoincrement column| schema1 |
        | test | 111111 | conn_0 | False   | insert into {0} set id=1, name='{2}'         | In insert Syntax, you can't set value for Autoincrement column| schema1 |
        | test | 111111 | conn_0 | False   | insert into {0} set name='{2}'               | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}'),('{2}'),('{2}')| success | schema1 |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                     | success | schema1 |
        | test | 111111 | conn_0 | False   | create table {0}(id {1} , name varchar(20))  | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into {0}(name) values('{2}')          | success | schema1 |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                     | success | schema1 |
        | test | 111111 | conn_0 | False   | create table {0}(idd {1}, name varchar(20))  | success | schema1 |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                | please make sure your table structure has primaryKey or incrementColumn | schema1 |
        | test | 111111 | conn_0 | False   | insert into {0}(name) values('{2}')          | please make sure your table structure has primaryKey or incrementColumn | schema1 |
        | test | 111111 | conn_0 | True    | drop table if exists {0}                     | success | schema1 |
    """.format(tb, "bigint", rand_str))

    #use int not bigint as global sequnce
    rand_str = gen.rand_string(20)
    context.execute_steps(u"""
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                    | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                                               | success           | schema1 |
        | test | 111111 | conn_0 | False   | create table {0}(id {1} primary key auto_increment, name varchar(20))  | success           | schema1 |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                      | Out of range value for column | schema1 |
        | test | 111111 | conn_0 | True    | insert into {0} values('{2}'),('{2}'),('{2}')      | Out of range value for column | schema1 |
    """.format(tb, "int", rand_str))


    # if "1" == sequnceHandlerType:
    # prepare table for test
    context.execute_steps(u"""
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                    | expect   | db     |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                                               | success  | schema1 |
        | test | 111111 | conn_0 | True    | create table {0}(id {1} primary key auto_increment, name varchar(20))  | success  | schema1 |
    """.format(tb, "bigint", rand_str))

    insertRow = 1000
    val = "('{0}')".format(gen.rand_string(20))
    for i in range(insertRow):
        val = val + ",('{0}')".format(gen.rand_string(20))
    sql = "insert into {0} values ('{1}')".format(tb, gen.rand_string(20))
    dble_conn.query(sql)

    # check for no repeatable id, attention: too little data is not able to capture the possible bug
    sql = "select count(*) from {0} having count(*) > 1 group by id;".format(tb)
    result, errMes = dble_conn.query(sql)
    assert_that(result, is_(()))

    # check for data distribution is reasonable
    sql = "explain select * from {0}".format(tb)
    result, errMes = dble_conn.query(sql)
    if type(result) == tuple:
        for i in range(len(result)):
            sql = "/*!dble:dataNode={0}*/select count(*) from {1}".format(result[i][0], tb)
            res, err = dble_conn.query(sql)
            assert_that(int(res[0][0]), greater_than_or_equal_to(insertRow / 4))  # 4 is default shardings

    # check for no id continuous
    if "1" == sequnceHandlerType:
        sql = "select max(id)-min(id) from {0};".format(tb)
        result, errMes = dble_conn.query(sql)
        assert_that(result[0][0], is_((insertRow)))

@Then('execute sqlFile to initialize sequence table')
def step_impl(context):
    # copy dble's dbseq.sql to local
    source_remote_file = "{0}/dble/conf/dbseq.sql".format(context.cfg_dble["install_dir"])
    target_remote_file = "{0}/data/dbseq.sql".format(context.cfg_mysql["install_path"])
    local_file  = "{0}/dbseq.sql".format(os.getcwd())

    node = get_node(context.mysqls, "mysql-master1")
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