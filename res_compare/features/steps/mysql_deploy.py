# coding=utf-8
"""
    Author:     Andy Liu
    Email :     liuan@actionsky.com
    Created:    2022/6/17
    Copyright (C) 2016-2023 ActionTech.
    License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
"""
import logging
import os
from sre_constants import IN

from behave import given,use_step_matcher
from behave.runner import Context
from hamcrest import assert_that, empty, equal_to, is_not, not_none
from typing import List
from utils import get_ssh, log_it
from SSHUtil import SSHClient
from utils import wait_for, create_dir
from typing import Dict,List, Optional
from hamcrest import assert_that, has_key, none
from DBUtil import DBUtil



LOGGER = logging.getLogger('root')
use_step_matcher('cfparse')

INIT_SCOPE = ('compare_mysql', 'group1', 'group2','group3')


# @given('I clean mysql deploy environment')
# def delete_mysqls(context: Context):
#     for name, ssh_conn in context.ssh_clients.items():
#         if name in INIT_SCOPE:
#             LOGGER.info(f'delete {name}')
#             delete_mysql(ssh_conn)
                

@log_it
def delete_mysql(ssh_conn: SSHClient):
    cmd = "dbdeployer sandboxes | awk '{print $1}' | xargs -r -n 1 dbdeployer delete"
    rc, sto, ste = ssh_conn.exec_command(cmd)
    assert_that(rc, equal_to(0), ste)

    cmd = 'dbdeployer sandboxes'
    rc, sto, ste = ssh_conn.exec_command(cmd)
    assert_that(rc, equal_to(0), ste)
    assert_that(sto, empty(), 'MySQL实例没有清理干净')


@given('I deploy mysql')
def deploy_mysqls(context: Context):
    mysql_version = context.test_conf["mysql_version"]
    mysql_sandbox = context.constant["mysql_sandbox_dir"]
    conf = f'--sandbox-directory {mysql_sandbox} --port-as-server-id --remote-access % --bind-address 0.0.0.0' \
           f' -c skip-name-resolve --gtid'
    mysql_cnf_list = [
        # "default_authentication_plugin=mysql_native_password",
        "secure_file_priv=",
        "local-infile=1",
        "sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES",
        # "session_track_schema=1",
        # "session_track_state_change=1",
        # "session_track_system_variables=\"*\"",
    ]
    mysql_cnf_param = ' '.join(["--my-cnf-options={}".format(x) for x in mysql_cnf_list])

    single_cmd = f'dbdeployer deploy single {mysql_version} --port 3306 {conf} {mysql_cnf_param}'
    repl_cmd = f'dbdeployer deploy replication --topology=master-slave {mysql_version} --base-port 3305 ' \
               f'--concurrent {conf} {mysql_cnf_param}'

    for group, info in context.cfg_mysql.items():
        if group in INIT_SCOPE:
            ssh_conn = context.ssh_clients[group]
            if len(info) == 1:
                rc, sto, ste = ssh_conn.exec_command(single_cmd)
                assert_that(rc, equal_to(0), ste)
            else:
                rc, sto, ste = ssh_conn.exec_command(f'{repl_cmd} --nodes {len(info)}')
                assert_that(rc, equal_to(0), ste)

            cmd = 'dbdeployer sandboxes --catalog'
            rc, sto, ste = ssh_conn.exec_command(cmd)
            assert_that(rc, equal_to(0), ste)

            version = sto.split()[1]
            cmd = f'ln -sf /root/opt/mysql/{version}/bin/mysql /usr/bin/'
            rc, sto, ste = ssh_conn.exec_command(cmd)
            assert_that(rc, equal_to(0), ste)


@given('I reset the mysql uuid')
def reset_mysql_server_uuid(context: Context):
    sandbox_home = os.path.join('/root/sandboxes/', context.constant["mysql_sandbox_dir"])

    @wait_for(context)
    def condition(ssh_conn_: SSHClient, cmd_: str) -> bool:
        rc_, _, _ = ssh_conn_.exec_command(cmd_)
        LOGGER.debug(f'host-<{ssh_conn_.host}> Expected rc-<0> Actual rc-<{rc_}>')
        return bool(rc_ == 0)

    for group, group_info in context.cfg_mysql.items():
        if group in INIT_SCOPE:
            ssh_conn = context.ssh_clients[group]
            if len(group_info) == 1:
                LOGGER.info(f'reset mysql server-uuid on node: <{group}>')
                get_uuid = f'cat {sandbox_home}/data/auto.cnf'
                
                rc, old_uuid, ste = ssh_conn.exec_command(get_uuid)
                assert_that(rc, equal_to(0), ste)

                cmd = f'rm -f {sandbox_home}/data/auto.cnf'
                rc, _, ste = ssh_conn.exec_command(cmd)
                assert_that(rc, equal_to(0), ste)
                cmd = f'bash {sandbox_home}/restart'
                rc, _, ste = ssh_conn.exec_command(cmd)
                assert_that(rc, equal_to(0), ste)

                rc, new_uuid, ste = ssh_conn.exec_command(get_uuid)
                assert_that(rc, equal_to(0), ste)
                assert_that(old_uuid, is_not(equal_to(new_uuid)), '重置uuid失败')

                check_connectivity = f'bash {sandbox_home}/use -BN -e "select 1"'
                condition(ssh_conn_=ssh_conn, cmd_=check_connectivity)
            else:
                count = len(group_info)
                for idx in range(1, count):
                    cmd = f'cat {sandbox_home}/node{idx}/data/auto.cnf'
                    rc, _, ste = ssh_conn.exec_command(cmd)
                    assert_that(rc, equal_to(0), ste)

                    cmd = f'rm -f {sandbox_home}/node{idx}/data/auto.cnf'
                    rc, _, ste = ssh_conn.exec_command(cmd)
                    assert_that(rc, equal_to(0), ste)

                cmd = f'cat {sandbox_home}/master/data/auto.cnf'
                rc, _, ste = ssh_conn.exec_command(cmd)
                assert_that(rc, equal_to(0), ste)

                cmd = f'rm -f {sandbox_home}/master/data/auto.cnf'
                rc, _, ste = ssh_conn.exec_command(cmd)
                assert_that(rc, equal_to(0), ste)

                restart_mysql = f'bash {sandbox_home}/restart_all'
                rc, _, ste = ssh_conn.exec_command(restart_mysql)
                assert_that(rc, equal_to(0), ste)

                for idx in range(1, count):
                    check_connectivity = f'bash {sandbox_home}/node{idx}/use -BN -e "select 1"'
                    condition(ssh_conn_=ssh_conn, cmd_=check_connectivity)

                check_connectivity = f'bash {sandbox_home}/master/use -BN -e "select 1"'
                condition(ssh_conn_=ssh_conn, cmd_=check_connectivity)


@given('I create mysql test user')
def create_mysql_test_user(context: Context):
    privileges = context.constant['client_privilege']
    if context.test_conf['mysql_version'].startswith('8'):
        privileges.extend(context.constant['client_privilege_extend_mysql_8'])
    client_privilege = ', '.join(privileges)
    sandbox_home = os.path.join('/root/sandboxes/', context.constant["mysql_sandbox_dir"])
    mysql_cnf = create_dir(context.current_log, 'mysql_cnf')

    for group, group_info in context.cfg_mysql.items():
        # group1 
        # group2
        # compare 
        if group in INIT_SCOPE:
            ssh_conn = context.ssh_clients[group]
            if len(group_info) == 1:
                cmd_prefix = f'bash {sandbox_home}/use -u root'
            else:
                cmd_prefix = f'bash {sandbox_home}/master/use -u root'

            for inst, _ in group_info.items():
                user = context.cfg_mysql[group][inst]['user']
                password = context.cfg_mysql[group][inst]['password']
                cmd = f"{cmd_prefix} -e \"CREATE USER '{user}'@'%' IDENTIFIED BY '{password}'\""
                rc, _, ste = ssh_conn.exec_command(cmd)
                assert_that(rc, equal_to(0), ste)

                cmd = f"{cmd_prefix} -e \"GRANT ALL PRIVILEGES ON *.* TO '{user}'@'%' WITH GRANT OPTION\""
                rc, _, ste = ssh_conn.exec_command(cmd)
                assert_that(rc, equal_to(0), ste)

                # client_user = context.cfg_mysql[group][inst]['client_user']
                # client_password = context.cfg_mysql[group][inst]['client_password']
                # cmd = f"{cmd_prefix} -e \"CREATE USER '{client_user}'@'%' IDENTIFIED BY '{client_password}'\""
                # rc, _, ste = ssh_conn.exec_command(cmd)
                # assert_that(rc, equal_to(0), ste)

                # cmd = f"{cmd_prefix} -e \"GRANT {client_privilege} ON *.* TO '{client_user}'@'%'\""
                # rc, _, ste = ssh_conn.exec_command(cmd)
                # assert_that(rc, equal_to(0), ste)

                # MySQL可以免密登录
                lines = ['[client]\n',
                         f"user={context.cfg_mysql[group][inst]['user']}\n",
                         f"password={context.cfg_mysql[group][inst]['password']}\n",
                         f"socket=/tmp/mysql_sandbox{context.cfg_mysql[group][inst]['port']}.sock\n",
                          "local-infile=1"]
                with open(f'{mysql_cnf}/{group}_{inst}.cnf', 'w', encoding='utf8') as f:
                    f.writelines(lines)

                ssh_conn.put(f'{mysql_cnf}/{group}_{inst}.cnf', '/etc/my.cnf')

                cmd = 'echo "if [ -f ~/.bash_aliases ]; then" >> /root/.bashrc && ' \
                      'echo "	. ~/.bash_aliases" >> /root/.bashrc && ' \
                      'echo "fi" >> /root/.bashrc'
                rc, _, ste = ssh_conn.exec_command(cmd)
                assert_that(rc, equal_to(0), ste)

                lines = []
                for inst_, inst_info_ in group_info.items():
                    idx = inst_.split('-')[1]
                    lines.append(f'alias mysql{idx}=\'mysql -u{inst_info_["user"]} -p{inst_info_["password"]}'
                                 f' -S /tmp/mysql_sandbox{inst_info_["port"]}.sock\'\n')

                with open(f'{mysql_cnf}/bash_aliases_{group}', 'w', encoding='utf8') as f:
                    f.writelines(lines)

                ssh_conn.put(f'{mysql_cnf}/bash_aliases_{group}', '/root/.bash_aliases')

                # 主从复制MySQL group只需在主实例上创建用户
                break


@given('I create databases named {db_names:strings+} on {alias_names:strings+}')
def create_databases(context: Context, db_names: List[str], alias_names: List[str]):
    for alias_name in alias_names:
        mysql_info = get_mysql_info_by_alias(context, alias_name)
        for db_name in db_names:
            create_database(context, mysql_info, db_name)


@log_it
def get_mysql_info_by_alias(context: Context, alias_name: str) -> Dict[str, str]:
    if '.' in alias_name:
        group_name, inst_name = alias_name.split('.', 1)
    else:
        group_name, inst_name = alias_name, 'inst-1'

    assert_that(context.cfg_mysql, has_key(group_name), f'Can not find MySQL group <{group_name}>')
    assert_that(context.cfg_mysql[group_name], has_key(inst_name), f'Can not find MySQL instance <{alias_name}>')

    return context.cfg_mysql[group_name][inst_name]


@log_it
def create_database(context: Context, mysql: Dict[str, str], db_name: str):
    @wait_for(context, f'Create database <{db_name}> failed', 10, 3)
    def condition(db_conn_: DBUtil, db_name_: str) -> bool:
        res, err = db_conn_.query(
            f"SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='{db_name_}';")
        if err is None and res is not None:
            return bool(len(res) == 1)
        return False



    # with DBUtil(mysql['ip'], mysql['user'], mysql['password'], "",mysql['port'],context) as db_conn:
    conn = DBUtil(mysql['ip'], mysql['user'], mysql['password'], "",mysql['port'],context)
    _,err = conn.query(f'CREATE DATABASE IF NOT EXISTS `{db_name}`')    
    assert_that(err, none(), err)
    condition(db_conn_=conn, db_name_=db_name)   
    
    
    
@given('I create symbolic link for mysql in dble cluster')
@given('I create symbolic link for mysql in {nodes_name:string+}')
def deploy_mysql_in_node(context: Context, nodes_name: Optional[List[str]] = None):
    if context.test_conf["mysql_version"] == '5.7':
        version = '5.7.25'
    else:
        version = '8.0.18'

    if nodes_name is None:
        nodes_name = [node_name for node_name, _ in context.dbles[context.test_conf['dble_topo']].items()]

    mysql_cnf = create_dir(context.current_log, 'mysql_cnf')

    for node_name in nodes_name:
        ssh_conn = context.ssh_clients.get(node_name)
        assert_that(node_name, not_none(), f'Can not find dble node: <{node_name}>')

        cmd = f'ln -sf /root/opt/mysql/{version}/bin/mysql /usr/bin/'
        rc, _, ste = ssh_conn.exec_command(cmd)
        assert_that(rc, equal_to(0), ste)

        lines = ['[client]\n',
                 f"password=111111\n"]
        with open(f'{mysql_cnf}/{node_name}.cnf', 'w', encoding='utf8') as f:
            f.writelines(lines)

        ssh_conn.put(f'{mysql_cnf}/{node_name}.cnf', '/etc/my.cnf')
