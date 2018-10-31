import yaml
import os
import shutil
import time
import logging
from behave import *
from hamcrest import *
from logging import config

from functools import wraps
from pprint import pformat

from lib.Node import Node

logger = logging.getLogger('lib')

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
def get_nodes(context , flag):
    nodes = []
    ssh_user = context.cfg_sys['ssh_user']
    ssh_password = context.cfg_sys['ssh_password']

    if flag=="dble":
        ip = context.cfg_dble[flag]["ip"]
        hostname = context.cfg_dble[flag]["hostname"]
        node = Node(ip, ssh_user, ssh_password, hostname, context.cfg_dble["client_port"])
        nodes.append(node)
    elif flag == "dble_cluster":
        for _, childNode in context.cfg_dble[flag].iteritems():
            hostname = childNode["hostname"]
            ip = childNode["ip"]
            node = Node(ip, ssh_user, ssh_password, hostname, context.cfg_dble["client_port"])
            nodes.append(node)
    elif flag == "mysqls":
        for k, v in context.cfg_mysql.iteritems():
            if isinstance(v, dict) and v.has_key("master1"):#for mysql groups
                for ck, cv in context.cfg_mysql[k].iteritems():
                    ip = cv["ip"]
                    hostname = cv["hostname"]
                    port = cv["port"]
                    logger.debug("**********mysql ip:{0}, hostname: {1}, port: {2}".format(ip, hostname, port))
                    node = Node(ip, ssh_user, ssh_password, hostname, port)
                    nodes.append(node)
    else:
        assert False, "get_nodes expect parameter enum in 'dble', 'dble_cluser', 'mysqls'"
    return nodes

@Given('sleep "{num}" seconds')
def step_impl(context, num):
    int_num = int(num)
    time.sleep(int_num)