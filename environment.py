# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging
import os
import sys

from lib.Node import get_ssh, get_sftp
from lib.utils import init_log_directory, setup_logging ,load_yaml_config, get_nodes
from steps.step_install import replace_config, set_dbles_log_level, restart_dbles, disable_cluster_config_in_node

CONF_PATH = './conf'
logger = logging.getLogger('environment')

class MyCls(object):pass

def init_log(context):
    context.logger=logging.getLogger('{0}'.format("dble"))
    context.logger.setLevel(logging.INFO)
    formatter=logging.Formatter('[%(asctime)s %(filename)s L:%(lineno)d %(levelname)s] %(message)s','%H:%M:%S')
    context.log_file = "./logs/log/{0}.log".format("dble")
    file_handler=logging.FileHandler(context.log_file)
    file_handler.setFormatter(formatter)
    context.logger.addHandler(file_handler)

    context.config.setup_logging()

def before_all(context):
    context.current_log = init_log_directory()
    setup_logging(os.path.join(CONF_PATH, 'logging.yaml'))
    logger.debug('Setup logging configfile=<{0}>'.format(os.path.join(CONF_PATH, 'logging.yaml')))
    logger.info('*' * 30)
    logger.info('*       DBLE TEST START       *')
    logger.info('*' * 30)
    logger.info('Enter hook before_all')

    test_config = context.config.userdata["test_config"].lower() #"./conf/auto_dble_test.yaml"

    parsed = load_yaml_config("./conf/"+test_config)
    for name, values in parsed.iteritems():
        setattr(context, name, values)

    parsed = load_yaml_config(context.dble_test_config['docker_compose_path'])
    context.is_cluster = context.config.userdata["is_cluster"].lower() == "true"
    if context.is_cluster:
        context.dbles = get_nodes(context, parsed, "dble")
    else:
        context.dbles = get_nodes(context, parsed, "dble-1")

    context.mysqls = get_nodes(context, parsed, "mysql")

    context.ssh_client = get_ssh(context.dbles, context.dble_test_config['dble_host'])
    context.ssh_sftp = get_sftp(context.dbles, context.dble_test_config['dble_host'])

    steps_dir = "{0}/steps".format(os.getcwd())
    sys.path.append(steps_dir)
    init_log(context)
    try:
        dble_conf = context.config.userdata.pop('dble_conf')
    except KeyError:
        raise KeyError('Not define userdata dble_conf, usage: behave -D dble_conf=XXX ...')

    reinstall = context.config.userdata["reinstall"].lower() == "true"
    context.logger.info("need to reinstall dble: {0}".format(reinstall))
    if reinstall:
        if context.config.userdata["tar_local"].lower() == "true":
            context.need_download = False
        else:
            context.need_download = True
    else:
        if dble_conf.lower() == "sql_cover":
            replace_config(context, context.dble_test_config['dble_sql_conf'])
        elif dble_conf.lower() == "template":
            replace_config(context, context.dble_test_config['dble_base_conf'])

        if not context.is_cluster:
            for node in context.dbles:
                disable_cluster_config_in_node(context, node)

        set_dbles_log_level(context, context.dbles, 'debug')
        restart_dbles(context, context.dbles)

    logger.info('Exit hook <{0}>'.format('before_all'))

def after_all(context):
    logger.info('Enter hook <{0}>'.format('after_all'))

    for node in context.dbles:
        if node.ssh_conn:
            node.ssh_conn.close()
    for node in context.mysqls:
        if node.ssh_conn:
            node.ssh_conn.close()

    logger.info('*' * 30)
    logger.info('*       Exit hook after_all， DBLE TEST END        *')
    logger.info('*' * 30)

def before_feature(context, feature):
    logger.info('*' * 30)
    logger.info('Feature start: <{0}>'.format(feature.name))

def after_feature(context, feature):
    logger.info('Feature end: <{0}>'.format(feature.name))
    logger.info('*' * 30)

def before_scenario(context, scenario):
    logger.info('#' * 30)
    logger.info('Scenario start: <{0}>'.format(scenario.name))
    pass
    logger.info('Exit hook before_scenario')

def after_scenario(context, scenario):
    logger.info('Enter hook after_scenario')
    #clear conns in case of the same name conn is used in after test cases
    for i in range(0, 10):
        conn_name = "conn_{0}".format(i)
        if hasattr(context, conn_name):
            conn = getattr(context, conn_name)
            conn.close()
            delattr(context, conn_name)

    if not (context.config.stop and scenario.status == "failed"):
        replace_config(context,  context.dble_test_config['dble_base_conf'])
    logger.info('Scenario end: <{0}>'.format(scenario.name))
    logger.info('#' * 30)
def before_step(context, step):
    logger.info('*' * 30)
    logger.info('step start: <{0}>'.format(step.name))

def after_step(context, step):
    logger.info('step end: <{0}>, status:{1}'.format(step.name, step.status))
    logger.info('*' * 30)