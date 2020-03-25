# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging
import os
import shutil
import time
from functools import wraps
from logging import config
from pprint import pformat

import yaml
from behave import *
from hamcrest import *

from features.steps.lib.Node import Node

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

def init_log_dir(log_dir):
    if os.path.exists(log_dir):
        shutil.rmtree(log_dir)
    os.mkdir(log_dir)

def setup_logging(logging_cfg_file):
    init_log_dir('logs')
    if os.path.exists(logging_cfg_file):
        with open(logging_cfg_file, 'rt') as f:
            dict_config = yaml.load(f.read(), Loader=yaml.FullLoader)
        logging.config.dictConfig(dict_config)
    else:
        print 'No such logging config file : <{0}>'.format(logging_cfg_file)
        exit(1)

@log_it
def load_yaml_config(config_path):
    with open(config_path, 'r') as f:
        parsed = yaml.load(f, Loader=yaml.FullLoader)
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

def restore_sys_time():
    import os
    res = os.system("ntpdate -u 0.centos.pool.ntp.org")
    assert res == 0, "restore sys time fail"
    logger.debug("restore sys time success")