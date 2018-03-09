import yaml
import os
import shutil
import time
import logging
from logging import config
from lib import log_it
from lib.nodes import Node, Nodes

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
def get_all_nodes(context, docker_compose):
    nodes = Nodes()
    for _, node_info in docker_compose['services'].iteritems():
        ip = node_info['networks']['net']['ipv4_address']
        ssh_user = context.dble_test_config['ssh_user']
        ssh_password = context.dble_test_config['ssh_password']
        host_name = node_info['hostname']
        node = Node(ip, ssh_user, ssh_password, host_name)
        if 'ports' in node_info:
            node.is_ports = True
        nodes.add_node(node)
    return nodes

@log_it
def get_nodes(context, rexg, docker_compose):
    nodes = Nodes()
    for _, node_info in docker_compose['services'].iteritems():
        if node_info['hostname'].startswith(rexg):
            ip = node_info['networks']['net']['ipv4_address']
            ssh_user = context.dble_test_config['ssh_user']
            ssh_password = context.dble_test_config['ssh_password']
            host_name = node_info['hostname']
            node = Node(ip, ssh_user, ssh_password, host_name)
            if 'ports' in node_info:
                node.is_ports = True
            nodes.add_node(node)
    return nodes

@log_it
def create_ssh_client(nodes):
    ssh_clients = {}

    for node in nodes.nodes:
        ssh_client = node.get_connection()
        ssh_clients[node.ip] = ssh_client

    return ssh_clients

def create_sftp_client(nodes):
    ssh_sftps = {}
    for node in nodes.nodes:
        ssh_sftp = node.get_sftp_connection()
        ssh_sftps[node.ip] = ssh_sftp

    return ssh_sftps



