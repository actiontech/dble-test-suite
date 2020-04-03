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

from .DbleMeta import DbleMeta
from .MySQLMeta import MySQLMeta


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

    if flag=="dble":
        cfg_dic = {}
        cfg_dic.update(context.cfg_dble[flag])
        cfg_dic.update(context.cfg_server)

        node = DbleMeta(cfg_dic)
        nodes.append(node)
    elif flag == "dble_cluster":
        for _, childNode in context.cfg_dble[flag].iteritems():
            cfg_dic = {}
            cfg_dic.update(childNode)
            cfg_dic.update(context.cfg_server)

            node = DbleMeta(cfg_dic)
            nodes.append(node)
    elif flag == "mysqls":
        for k, v in context.cfg_mysql.iteritems():
            for ck, cv in context.cfg_mysql[k].iteritems():
                cfg_dic = {}
                cfg_dic.update(cv)
                cfg_dic.update(context.cfg_server)

                node = MySQLMeta(cfg_dic)
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

def get_node(nodes, host):
    for node in nodes:
        if node.host_name == host or node.ip == host:
            return node
    assert False, 'Can not find node {0}'.format(host)

# get ssh by host or ip
def get_ssh(nodes, host):
    node = get_node(nodes, host)
    return node.ssh_conn

# get sftp by host or ip
def get_sftp(nodes, host):
    node = get_node(nodes, host)
    return node.sftp_conn