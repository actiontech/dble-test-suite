import yaml
import os
import shutil
import time
import logging

from logging import config

from functools import wraps
from pprint import pformat

from lib.Node import Node


def log_it(func):
    logger = logging.getLogger('lib')

    @wraps(func)
    def logged_function(*args, **kwargs):
        logger.info('Start function: <{0}>'.format(func.__name__))
        logger.debug('<{0}> args: <{1}>'.format(func.__name__, pformat(args)))
        logger.debug('<{0}> kwargs: <{1}>'.format(func.__name__, pformat(kwargs)))
        result = func(*args, **kwargs)
        logger.debug('<{0}> result : <{1}>'.format(func.__name__, pformat(result)))
        logger.info('End function <{0}>'.format(func.__name__))
        return result

    return logged_function

def init_log_directory(symbolic=False):
    logs_dir = 'logs'
    symbolic_link = 'log'
    cwd = os.getcwd()

    if not os.path.exists(logs_dir):
        os.mkdir(logs_dir)

    os.chdir(logs_dir)

    if symbolic:
        suffix = time.strftime('%Y_%m_%d_%H_%M_%S', time.localtime())
        current_log = 'log_' + suffix
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

def setup_logging(logging_path):
    if os.path.exists(logging_path):
        with open(logging_path, 'rt') as f:
            dict_config = yaml.load(f.read())
        logging.config.dictConfig(dict_config)
    else:
        print 'No such logging config file : <{0}>'.format(logging_path)
        exit(1)

@log_it
def load_yaml_config(config_path):
    with open(config_path, 'r') as f:
        parsed = yaml.load(f)
    return parsed

@log_it
def get_nodes(context, docker_compose , rexg=''):
    mysql_configs = [
        context.dble_test_config['compare_mysql'],
        context.dble_test_config['mysql_master1'],
        context.dble_test_config['mysql_master2'],
        context.dble_test_config['mysql_slave1'],
        context.dble_test_config['mysql_slave2'],
    ]
    nodes = []
    for _, container_info in docker_compose['services'].iteritems():
        if container_info['hostname'].startswith(rexg):
            ip = container_info['networks']['net']['ipv4_address']
            ssh_user = context.dble_test_config['ssh_user']
            ssh_password = context.dble_test_config['ssh_password']
            mysql_port = get_port_by_ip(mysql_configs, ip)
            host_name = container_info['hostname']
            node = Node(ip, ssh_user, ssh_password, host_name, mysql_port)
            nodes.append(node)
    return nodes

def get_port_by_ip(mysql_configs, ip):
    for mysql in mysql_configs:
        if mysql['ip'] == ip:
            return mysql['port']

    return None
    # assert False, "can not find mysql port in {0}".format(ip)





