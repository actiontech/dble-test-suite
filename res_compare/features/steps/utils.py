from hamcrest import *
import time,logging,os,yaml,shutil
from typing import Any, Callable, Dict, List, Optional, Tuple, Union
from functools import wraps
from steps.SSHUtil import SSHClient
from behave.runner import Context
from pprint import pformat
from steps.DbleMeta import DbleMeta
from steps.MySQLMeta import MySQLMeta
from logging import config
import shlex
import subprocess


logger=logging.getLogger("root")



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
    else:
        assert False, "get_nodes expect parameter enum in 'dble', 'dble_cluser', 'mysqls'"


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


def get_mysql_cnf_path(install_path):
    return install_path + '/my.sandbox.cnf'

def get_node(host):
    logger.debug("try to get meta of '{}'".format(host))
    for node in MySQLMeta.mysqls + DbleMeta.dbles:
        if node.host_name == host or node.ip == host:
            return node
    assert False, 'Can not find node {0}'.format(host)


# get ssh by host or ip
def get_ssh(host):
    node = get_node(host)
    return node.ssh_conns

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
