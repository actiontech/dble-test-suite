# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging
import os
import shutil
import time
from functools import wraps
from logging import config
from pprint import pformat

import re
import yaml
from behave import *
from hamcrest import *
from typing import Any, Callable, Dict, List, Optional, Tuple, Union
from behave.runner import Context
from steps.lib.DbleMeta import DbleMeta
from steps.lib.MySQLMeta import MySQLMeta
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
        for _,childNode in context.cfg_dble[flag].items():
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
        for k, v in context.cfg_mysql.items():
            for ck, cv in context.cfg_mysql[k].items():
                cfg_dic = {}
                cfg_dic.update(cv)
                cfg_dic.update(context.cfg_server)

                node = MySQLMeta(cfg_dic)
                nodes.append(node)
        MySQLMeta.mysqls = tuple(nodes)

    else:
        assert False, "get_nodes expect parameter enum in 'dble', 'dble_cluser', 'mysqls'"


@Given('sleep "{num}" seconds')
def step_impl(context, num):
    int_num = int(num)
    time.sleep(int_num)


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
    for node in MySQLMeta.mysqls + DbleMeta.dbles:
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


@Given('reset replication and none system databases')
def reset_repl(context):
    global out_bytes
    import subprocess
    try:
        out_bytes = subprocess.check_output(['bash', 'compose/docker-build-behave/resetReplication.sh'])
        logger.debug("script resetReplication.sh run success!")
    except subprocess.CalledProcessError as e:
        out_bytes = e.output  # Output generated before error
        assert False, "resetReplication.sh script run with failure,output: {0}".format(out_bytes.decode('utf-8'))
    finally:
        logger.info(out_bytes.decode('utf-8'))


# delete backend mysql tables from db1 ~ db4
@Given('delete all backend mysql tables')
def delete_all_mysql_tables(context):
    global out_bytes
    import subprocess
    try:
        out_bytes = subprocess.check_output(['bash', 'delete_all_mysql_tables.sh'])
    except subprocess.CalledProcessError as e:
        out_bytes = e.output
        out_bytes = out_bytes.decode('utf-8')
        assert False, "delete_all_mysql_tables.sh script run with failure,output: {0}".format(out_bytes)
    finally:
        logger.info(out_bytes.decode('utf-8'))


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
            # 默认环境未创建group-3容器，需要时自行调用connect()，并维护ssh连接
            if group in ['Standalone', 'group1', 'group2']:
                logger.info("check steps")
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