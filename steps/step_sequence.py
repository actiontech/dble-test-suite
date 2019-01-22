from lib.Node import get_node
from steps.step_reload import get_dble_conn

coding= 'utf8'
import logging
from behave import *
from lib.generate_util import *
from hamcrest import *

LOGGER = logging.getLogger('steps.sequence')

@Then('Testing the global sequence can used in table')
def step_impl(context):
    text = eval(context.text)
    tb = text.get("table")
    gen = generate()
    rand_str = gen.rand_string(20)
    dble_conn = get_dble_conn(context)

    context.execute_steps(u"""
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                    | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                                               | success           | mytest |
        | test | 111111 | conn_0 | False   | create table {0}(id {1} primary key auto_increment, name varchar(20))  | success           | mytest |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                                          | success           | mytest |
        | test | 111111 | conn_0 | False   | insert into {0}(id,name) values(1, '{2}')    | In insert Syntax, you can't set value for Autoincrement column| mytest |
        | test | 111111 | conn_0 | False   | insert into {0} set id=1, name='{2}'         | In insert Syntax, you can't set value for Autoincrement column| mytest |
        | test | 111111 | conn_0 | False   | insert into {0} set name='{2}'               | success | mytest |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}'),('{2}'),('{2}')| success | mytest |
    """.format(tb, "bigint", rand_str))

    sequnceHandlerType = text.get("sequnceHandlerType")
    if "1" == sequnceHandlerType:
        insertRow = 100
        val = "('{0}')".format(gen.rand_string(20))
        for i in range(insertRow):
            val = val + ",('{0}')".format(gen.rand_string(20))

        sql = "insert into {0} values ('{1}')".format(tb, gen.rand_string(20))
        dble_conn.query(sql)

        #check for no repeatable id, todo too little data is not able to capture the possible bug
        sql = "select count(*) from {0} having count(*) > 1 group by id;".format(tb)
        result, errMes = dble_conn.query(sql)
        assert_that(result, is_(()))

        #check for data distribution is reasonable
        sql = "explain select * from {0}".format(tb)
        result, errMes = dble_conn.query(sql)
        if type(result) == tuple:
            for i in range(len(result)):
                sql = "/*!dble:dataNode={0}*/select count(*) from {1}".format(result[i][0], tb)
                res, err = dble_conn.query(sql)
                assert_that(int(res[0][0]), greater_than_or_equal_to(insertRow/4)) # 4 is default shardings

    context.execute_steps(u"""
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                    | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                     | success | mytest |
        | test | 111111 | conn_0 | False   | create table {0}(id {1} , name varchar(20))  | success |mytest |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                | success | mytest |
        | test | 111111 | conn_0 | False   | insert into {0}(name) values('{2}')          | success | mytest |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                     | success | mytest |
        | test | 111111 | conn_0 | False   | create table {0}(id {1} auto_increment, name varchar(20), primary key (id))| success | mytest |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                | success | mytest |
        | test | 111111 | conn_0 | False   | insert into {0}(name) values('{2}')          | success | mytest |
        | test | 111111 | conn_0 | False   | insert into {0} set name='{2}'               | success | mytest |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                     | success | mytest |
        | test | 111111 | conn_0 | False   | create table {0}(idd {1}, name varchar(20))  | success | mytest |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                | please make sure your table structure has primaryKey or incrementColumn | mytest |
        | test | 111111 | conn_0 | False   | insert into {0}(name) values('{2}')          | please make sure your table structure has primaryKey or incrementColumn | mytest |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                     | success | mytest |
        | test | 111111 | conn_0 | False   | create table {0}(idd {1} auto_increment, name varchar(20), primary key(idd))| success | mytest |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                | please make sure your table structure has primaryKey or incrementColumn | mytest |
        | test | 111111 | conn_0 | False   | insert into {0}(name) values('{2}')          | please make sure your table structure has primaryKey or incrementColumn | mytest |
    """.format(tb, "bigint", rand_str))

    #use int not bigint as global sequnce
    rand_str = gen.rand_string(20)
    context.execute_steps(u"""
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                    | expect            | db     |
        | test | 111111 | conn_0 | False   | drop table if exists {0}                                               | success           | mytest |
        | test | 111111 | conn_0 | False   | create table {0}(id {1} primary key auto_increment, name varchar(20))  | success           | mytest |
        | test | 111111 | conn_0 | False   | insert into {0} values('{2}')                      | Out of range value for column | mytest |
        | test | 111111 | conn_0 | True    | insert into {0} values('{2}'),('{2}'),('{2}')      | Out of range value for column | mytest |
    """.format(tb, "int", rand_str))

# Given('append "{line}" in {seq_file}')
# def step_impl(context, line, seq_file):
#     node = get_node(context, "dble-1")
#     log = '{0}/dble/conf/log4j2.xml'.format(context.cfg_dble['install_dir'])
#     cmd = "sed -i '$a {0} {1}' {2} ".format(line, seq_file)
#     node.ssh_conn.exec_command(cmd)
