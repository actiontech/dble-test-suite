# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
from cmath import inf
import logging
import os
import shutil
import time
from datetime import datetime
from functools import wraps
from logging import config
from pprint import pformat
from environs import Env
import shlex
import subprocess
from behave.userdata import UserData
import re
import yaml
from behave import *
from hamcrest import *
from typing import Any, Callable, Dict, List, Optional, Tuple, Union
from behave.runner import Context
from steps.lib.DbleMeta import DbleMeta
from steps.lib.MySQLMeta import MySQLMeta
from steps.lib.ClickhouseMeta import ClickhouseMeta
from steps.lib.SSHUtil import SSHClient

logger = logging.getLogger('root')


def log_it(func):
    @wraps(func)
    def logged_function(*args, **kwargs):
        logger.info('Start function: <{0}>'.format(func.__name__))
        logger.debug('<{0}> args: <{1}>'.format(func.__name__, pformat(args)))
        logger.debug('<{0}> kwargs: <{1}>'.format(func.__name__, pformat(kwargs)))
        result = func(*args, **kwargs)
        logger.debug('<{0}> result segment : <{1}>'.format(func.__name__, pformat(result)[0:200]))
        logger.info('End function <{0}>'.format(func.__name__))
        return result

    return logged_function


# def init_log_dir(log_dir):
#     if os.path.exists(log_dir):
#         shutil.rmtree(log_dir)
#     os.mkdir(log_dir)


# def setup_logging(logging_cfg_file):
#     init_log_dir('logs')
#     if os.path.exists(logging_cfg_file):
#         with open(logging_cfg_file, 'rt') as f:
#             dict_config = yaml.load(f.read(), Loader=yaml.FullLoader)
#         logging.config.dictConfig(dict_config)

def setup_logging(logging_path: str):
    """
    读取logging配置
    如果配置文件不存在则抛出异常FileNotFoundError

    :param logging_path: logging
    :return:
    """
    with open(logging_path, 'rt', encoding='utf8') as f:
        dict_config = yaml.load(f.read(), Loader=yaml.FullLoader)
    config.dictConfig(dict_config)
    logging.debug(f'Setup logging configfile=<{logging_path}>')


@log_it
def load_yaml_config(config_path):
    with open(config_path, 'r') as f:
        parsed = yaml.load(f, Loader=yaml.FullLoader)
    return parsed


@log_it
def init_meta(context, flag):
    if flag == "single":
        nodes = []
        for _, childNode in context.cfg_dble[flag].items():
            cfg_dic = {}
            cfg_dic.update(childNode)
            cfg_dic.update(context.cfg_server)
            node = DbleMeta(cfg_dic)

        DbleMeta.dbles = (node,)
    elif flag == "cluster":
        nodes = []
        for _, childNode in context.cfg_dble[flag].items():
            cfg_dic = {}
            cfg_dic.update(childNode)
            cfg_dic.update(context.cfg_server)

            node = DbleMeta(cfg_dic)
            nodes.append(node)
        DbleMeta.dbles = tuple(nodes)
    elif flag == "mysqls":
        nodes = []
        for k, _ in context.cfg_mysql.items():
            for _, cv in context.cfg_mysql[k].items():
                cfg_dic = {}
                cfg_dic.update(cv)
                cfg_dic.update(context.cfg_server)

                node = MySQLMeta(cfg_dic)
                nodes.append(node)
        MySQLMeta.mysqls = tuple(nodes)
    elif flag == "clickhouses":
        nodes = []
        for k, _ in context.cfg_clickhouse.items():
            for _, cv in context.cfg_clickhouse[k].items():
                cfg_dic = {}
                cfg_dic.update(cv)
                cfg_dic.update(context.cfg_server)

                node = ClickhouseMeta(cfg_dic)
                nodes.append(node)
        ClickhouseMeta.clickhouses = tuple(nodes)

    else:
        assert False, "get_nodes expect parameter enum in 'dble', 'dble_cluser', 'mysqls', 'clickhouse'"


@Given('sleep "{num}" seconds')
def sleep_by_time(context, num):
    # int_num = int(num)
    float_num = float(num)
    startt = time.time()
    # logger.debug("current datetime: {}".format(datetime.now()))
    while time.time() < startt + float_num:
        pass
    # logger.debug("after datetime: {}".format(datetime.now()))


@Given('update config of mysql "{mysql_version}" in "{mysql_type}" type in "{host_name}" with sed cmds')
def update_file_content(context, mysql_version, host_name, mysql_type, sed_str=None):
    if not sed_str and len(context.text) > 0:
        sed_str = context.text

    if host_name == "behave":
        node = None
    else:
        node = get_node(host_name)

    mysql_cnf_path = get_mysql_cnf_path(node.install_path)

    # replace all vars in file name with corresponding node attribute value
    vars = re.findall(r'\{(.*?)\}', mysql_cnf_path, re.I)
    logger.debug("debug vars: {}".format(vars))
    for var in vars:
        mysql_cnf_path = mysql_cnf_path.replace("{" + var + "}", getattr(node, var))

    update_file_with_sed(sed_str, mysql_cnf_path, node)


# def get_mysql_cnf_path(version='5.7.25', type='single'):
#     prefix = version.replace('.', '_')
#     if type == 'single':
#         prefix = 'msb_' + prefix
#     return f"/root/sandboxes/{prefix}/my.sandbox.cnf"

def get_mysql_cnf_path(install_path):
    return install_path + '/my.sandbox.cnf'


@Given('update file content "{filename}" in "{host_name}" with sed cmds')
def update_file_content(context, filename, host_name, sed_str=None):
    if not sed_str and len(context.text) > 0:
        sed_str = context.text

    if host_name == "behave":
        node = None
    else:
        node = get_node(host_name)

    # replace all vars in file name with corresponding node attribute value
    vars = re.findall(r'\{(.*?)\}', filename, re.I)
    logger.debug("debug vars: {}".format(vars))
    for var in vars:
        filename = filename.replace("{" + var + "}", getattr(node, var))

    update_file_with_sed(sed_str, filename, node)


def update_file_with_sed(sed_str, filename, node):
    sed_cmd = merge_cmd_strings(filename, sed_str)
    if node:
        rc, stdout, stderr = node.ssh_conn.exec_command(sed_cmd)
        assert_that(len(stderr) == 0, "update file content with:{1}, got err:{0}".format(stderr, sed_cmd))
    else:
        status = os.system(sed_cmd)
        assert status == 0, "change {0} failed".format(filename)


def merge_cmd_strings(filename, sedStr):
    sed_cmd_str = sedStr.strip()
    sed_cmd_list = sed_cmd_str.splitlines()
    cmd = "sed -i"
    for sed_cmd in sed_cmd_list:
        cmd += " -e '{0}'".format(sed_cmd.strip())
    cmd += " {0}".format(filename)
    logger.debug("sed cmd: {0}".format(cmd))
    return cmd


# restore system time in behave docker, but due to all dockers use one kernel, other dockers system time will change too
def restore_sys_time():
    import subprocess
    res = subprocess.Popen('ntpdate -u 0.centos.pool.ntp.org', shell=True, stdout=subprocess.PIPE)
    out, err = res.communicate()
    assert_that(err is None, "expect no err, but err is: {0}".format(err))


def get_node(host):
    logger.debug("try to get meta of '{}'".format(host))
    for node in MySQLMeta.mysqls + DbleMeta.dbles + ClickhouseMeta.clickhouses:
        if node.host_name == host or node.ip == host:
            return node
    assert False, 'Can not find node {0}'.format(host)


# get ssh by host or ip
def get_ssh(host):
    node = get_node(host)
    return node.ssh_conn


# get sftp by host or ip
def get_sftp(host):
    node = get_node(host)
    return node.sftp_conn


@Given('rebuild all mysql group')
def reset_repl(context):
    context.ssh_clients = create_ssh_client(context)
    context.execute_steps(
        u'''
        Given I clean mysql deploy environment
        Given I deploy mysql
        Given I reset the mysql uuid
        Given I create mysql test user
        Given I create databases named db1, db2, db3, db4 on group1, group2, group3
        Given I create databases named schema1,schema2,schema3,testdb,db1,db2,db3,db4 on compare_mysql
        ''')


def exec_command(cmd: Union[str, List[str]], capture_output: bool = True, shell: bool = False, text: bool = True,
                 **other_run_kwargs) -> Tuple[int, str, str]:
    """
    本地调用子进程

    :param cmd: 要执行的命令。如果调用的命令里包含管道符'|'则需要设置shell为True
    :param capture_output: 如果 capture_output 设为 true,stdout 和 stderr 将会被捕获
    :param shell: 是否将命令直接通过shell执行
    :param text: std、ste是否以文本的形式返回
    :param other_run_kwargs: run支持的其他参数, https://docs.python.org/zh-cn/3.7/library/subprocess.html#subprocess.run
    :return: (re, 标准输出, 标准错误输出)
    """
    logger.info(f'Execute command: <{cmd}>')
    if not shell and isinstance(cmd, str):
        cmd = shlex.split(cmd)
    cp = subprocess.run(cmd, capture_output=capture_output,
                        shell=shell, text=text, **other_run_kwargs)
    result = (cp.returncode, cp.stdout.strip('\n'), cp.stderr.strip('\n'))
    logger.debug(
        f'Return code <{result[0]}>, Stdout: <{result[1]}>, Stderr <{result[2]}>')
    return result


def create_ssh_client(context: Context) -> Dict[str, SSHClient]:
    """
    向测试容器建立ssh连接

    :param context: behave context
    :return: 以容器名为key,ssh连接为value的字典
    """
    ssh_clients = {}
    dble_topo = context.test_conf['dble_topo']

    for name, info in context.cfg_dble[dble_topo].items():
        ssh_client = SSHClient(
            info['ip'], context.constant['ssh_user'], context.constant['ssh_password'])
        ssh_client.connect()
        ssh_clients[name] = ssh_client

    for group, group_info in context.cfg_mysql.items():
        for _, info in group_info.items():
            ssh_client = SSHClient(
                info['ip'], context.constant['ssh_user'], context.constant['ssh_password'])
            if group in ['compare_mysql', 'group1', 'group2', 'group3']:
                ssh_client.connect()
            ssh_clients[f'{group}'] = ssh_client
            # 一个group只用建立一个连接
            break
    return ssh_clients


def wait_for(context, text: str = 'Timeout', duration: int = 10, interval: int = 3, prefix: int = 0) -> Callable[
    [Callable[..., bool]], Callable[..., Any]]:
    """
    轮询装饰器

    :param context: behave context
    :param text: 超时情况下的报错信息
    :param duration: 超时时间
    :param interval: 检测频率
    :param prefix: 前置等待时间
    :return:
    """

    def decorator(condition: Callable[..., bool]) -> Callable[..., Any]:
        @wraps(condition)
        def wrapper(*args, **kwargs) -> Any:
            start_time = time.time()
            time.sleep(prefix * context.test_conf['time_weight'])
            timeout = duration * context.test_conf['time_weight']
            while time.time() - start_time < timeout:
                if condition(*args, **kwargs):
                    return
                time.sleep(interval * context.test_conf['time_weight'])
            assert_that(False, text)

        return wrapper

    return decorator


@log_it
def create_dir(*dirs: str) -> str:
    dp = os.path.join(*dirs)
    if not os.path.exists(dp):
        os.makedirs(dp)
    return dp


def init_log_directory(symbolic: bool = True) -> str:
    """
    初始化日志目录，返回当前日志目录的路径

    :param symbolic: 是否已软连接的模式,保留多个日志目录
    :return: 当前日志目录的Path对象
    """
    logs_dir = 'logs'
    symbolic_link = 'log'
    cwd = os.getcwd()

    if not os.path.exists(logs_dir):
        os.mkdir(logs_dir)

    os.chdir(logs_dir)

    if symbolic:
        suffix = time.strftime('%Y_%m_%d_%H_%M_%S', time.localtime())
        current_log = 'log_' + suffix
        logger.info('step_check')
        if os.path.exists(current_log):
            shutil.move(current_log, current_log + '_bak')

        os.mkdir(current_log)
        if os.path.exists(symbolic_link):
            os.remove(symbolic_link)

        os.symlink(current_log, symbolic_link)
    else:
        if os.path.exists(symbolic_link):
            shutil.rmtree(symbolic_link)
        os.mkdir(symbolic_link)

    os.chdir(cwd)

    return os.path.join(logs_dir, symbolic_link)


def handle_env_variable(context: Context, userdata: UserData, var: str, default_value=None, method: str = 'str',
                        check: Optional[Callable[..., None]] = None):
    method = method.lower()
    upper = var.upper()
    lower = var.lower()
    env = Env()
    if os.path.exists('conf/secret/.env'):
        logger.debug('USE ENVIRONMENT behave_dble/conf/secret/.env')
        env.read_env('conf/secret/.env')
    else:
        logger.debug('DO NOT EXIST behave_dble/conf/secret/.env')
    assert_that(method, is_in(['str', 'bool', 'int']))
    env_method = {'str': env.str,
                  'bool': env.bool,
                  'int': env.int}
    ud_method = {'bool': userdata.getbool,
                 'int': userdata.getint}
    built_in_method = {'str': str,
                       'bool': bool,
                       'int': int}

    # 所有使用的环境变量必须已DBLE_为前缀
    with env.prefixed("DBLE_"):
        if default_value is None:
            var = env_method[method](upper, context.test_conf.get(lower))
        else:
            var = env_method[method](upper, default_value)
    if method == 'str':
        context.test_conf[lower] = userdata.pop(upper, var)
    else:
        context.test_conf[lower] = ud_method[method](upper, var)
        userdata.pop(upper, None)

    logger.info(f"{upper}=<{context.test_conf.get(lower)}> \n"
                f'priority 1: behave -D {upper}=xxx\n'
                f'priority 2: behave.ini - behave.userdata.{upper}\n'
                f'priority 3: os environment DBLE_{upper}\n'
                f'priority 4: behave_dble/conf/secret/.env DBLE_{upper}\n'
                f'priority 5: conf/aute_dble_test.yaml - test_conf.{lower}')

    if check is None:
        assert_that(context.test_conf[lower],
                    instance_of(built_in_method[method]))
    else:
        check()


def handle_env_variables(context: Context, userdata: UserData):
    handle_env_variable(context, userdata, 'time_weight', method='int')
    handle_env_variable(context, userdata, 'auto_retry', method='int')
    handle_env_variable(context, userdata, 'dble_version')
    # handle_env_variable(context, userdata, 'dble_package_timestamp')
    handle_env_variable(context, userdata, 'dble_remote_host')
    handle_env_variable(context, userdata, 'dble_remote_path')

    def dble_topo_check() -> None:
        assert_that(context.test_conf['dble_topo'], is_in(['single', 'cluster']), 'Not support dble topo')

    handle_env_variable(context, userdata, 'dble_topo', check=dble_topo_check)

    def mysql_version_check() -> None:
        assert_that(context.test_conf['mysql_version'], is_in(['5.7', '8.0']), 'Not support mysql version')

    handle_env_variable(context, userdata, 'mysql_version', check=mysql_version_check)

    def dble_conf_check() -> None:
        assert_that(context.test_conf['dble_conf'], is_in(['default', 'global', 'mixed', 'nosharding', 'sharding']),
                    'Not support dble conf')

    handle_env_variable(context, userdata, 'dble_conf', check=dble_conf_check)

    def ftp_user_check() -> None:
        assert_that(context.test_conf['ftp_user'], any_of(instance_of(str), none()))  # type: ignore

    handle_env_variable(context, userdata, 'ftp_user', check=ftp_user_check)

    def ftp_password_check() -> None:
        assert_that(context.test_conf['ftp_password'], any_of(instance_of(str), none()))  # type: ignore

    handle_env_variable(context, userdata, 'ftp_password', check=ftp_password_check)

    def code_coverage_check() -> None:
        assert_that(context.test_conf['code_coverage'], any_of(instance_of(str), none()))  # type: ignore

    handle_env_variable(context, userdata, 'code_coverage', check=code_coverage_check)
