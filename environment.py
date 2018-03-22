import ConfigParser
import logging
import os
import sys
from lib.utils import init_log_directory, setup_logging ,load_yaml_config, get_all_nodes, create_ssh_client, create_sftp_client, get_nodes, Nodes

from behave.log_capture import capture
from pprint import pformat

CONF_PATH = './conf'
logger = logging.getLogger('environment')
root = logging.getLogger('root')

class MyCls(object):pass

def init_log(context):
    context.logger=logging.getLogger('{0}'.format("dble"))
    context.logger.setLevel(logging.INFO)
    formatter=logging.Formatter('[%(asctime)s %(filename)s L:%(lineno)d %(levelname)s] %(message)s','%H:%M:%S')
    context.log_file = "./logs/{0}/{1}.log".format("result","dble")
    file_handler=logging.FileHandler(context.log_file)
    file_handler.setFormatter(formatter)
    context.logger.addHandler(file_handler)

    context.config.setup_logging()

def init_ssh(context):
    if (not hasattr(context, "ssh_client")) or context.ssh_client is None:
        context.ssh_client = context.ssh_clients[context.dble_test_config['dble_host']]
    if (not hasattr(context, "ssh_sftp")) or context.ssh_sftp is None:
        context.ssh_sftp = context.ssh_sftps[context.dble_test_config['dble_host']]

def before_all(context):
    context.current_log = init_log_directory()
    setup_logging(os.path.join(CONF_PATH, 'logging.yaml'))
    logger.debug('Setup logging configfile=<{0}>'.format(os.path.join(CONF_PATH, 'logging.yaml')))
    logger.info('*' * 30)
    logger.info('*       DBLE TEST START       *')
    logger.info('*' * 30)
    logger.info('Enter hook <{0}>'.format('before_all'))
    # try:
    #     test_config = context.config.userdata.pop('test_config')
    # except KeyError:
    #     raise KeyError('Not define test_config in behave -D test_config=XXX')
    test_config = "./conf/auto_dble_test.yaml"

    parsed = load_yaml_config(test_config)
    for name, values in parsed.iteritems():
        setattr(context, name, values)

    parsed = load_yaml_config(context.dble_test_config['docker_compose_path'])
    #get dble all nodes
    context.dbles = get_nodes(context, "dble", parsed)
    context.mysqls = get_nodes(context, "mysql", parsed)
    context.nodes = get_all_nodes(context, parsed)

    context.ssh_clients = create_ssh_client(context.nodes)
    context.ssh_sftps = create_sftp_client(context.nodes)

    #clean last result
    osCmd= 'rm -rf {0} && mkdir {0}'.format(context.dble_test_config['result']['dir'])
    os.system(osCmd)
    steps_dir = "{0}/steps".format(os.getcwd())
    sys.path.append(steps_dir)
    init_log(context)
    init_ssh(context)
    if context.config.userdata["tar_local"].lower() == "true":
        context.need_download = False
    else:
        context.need_download = True
    logger.info('Exit hook <{0}>'.format('before_all'))

def after_all(context):
    logger.info('Enter hook <{0}>'.format('after_all'))

    for node in context.nodes.nodes:
        logger.debug('ip <{0}>'.format(node.ip))
        logger.debug('connection <{0}>'.format(node.connection))
        if node.connection:
            node.connection.close()

    logger.info('Exit hook <{0}>'.format('after_all'))
    logger.info('*' * 30)
    logger.info('*       DBLE TEST END        *')
    logger.info('*' * 30)

def before_feature(context, feature):
    logger.info('*' * 30)
    logger.info('Feature start: <{0}>'.format(feature.name))
    logger.info('Enter hook <{0}>'.format('before_feature'))
    if "log_debug" in feature.tags:
        context.execute_steps(u'Given Set the log level to debug and restart server')
    try:
        sql_cover = context.config.userdata.pop('sql_cover')
    except KeyError:
        raise KeyError('Not define test_config in behave -D sql_cover=XXX')
    flag = True
    if sql_cover.lower() == "true":
        if flag:
            context.execute_steps(u'Given Replace the existing configuration with the conf sql_cover directory')
            flag = False
    elif sql_cover.lower() == "false":
        context.execute_steps(u'Given Replace the existing configuration with the conf template directory')
    else:
        pass
    logger.info('Exit hook <{0}>'.format('befor_feature'))

def after_feature(context, feature):
    logger.info('Enter hook <{0}>'.format('after_feature'))
    if "log_debug" in feature.tags:
        context.execute_steps(u'Given Reset the Log level and restart server')
    logger.info('Exit hook <{0}>'.format('after_feature'))
    logger.info('Feature end: <{0}>'.format(feature.name))
    logger.info('*' * 30)

def before_scenario(context, scenario):
    logger.info('#' * 30)
    logger.info('Scenario start: <{0}>'.format(scenario.name))
    logger.info('Enter hook <{0}>'.format('before_scenario'))
    pass
    logger.info('Exit hook <{0}>'.format('before_scenario'))

def after_scenario(context, scenario):
    logger.info('Enter hook <{0}>'.format('after_scenario'))
    #clear conns in case of the same name conn is used in after test cases
    for i in range(0, 10):
        conn_name = "conn_{0}".format(i)
        if hasattr(context, conn_name):
            conn = getattr(context, conn_name)
            conn.close()
            delattr(context, conn_name)
    logger.info('Exit hook <{0}>'.format('after_scenario'))
    logger.info('Scenario end: <{0}>'.format(scenario.name))
    logger.info('#' * 30)

def before_step(context, step):
    logger.info('-' * 30)
    logger.info('Step start: <{0}>'.format(step.name))
    logger.info('Enter hook <{0}>'.format('before_step'))
    pass
    logger.info('Exit hook <{0}>'.format('before_step'))

def after_step(context, step):
    logger.info('Enter hook <{0}>'.format('after_step'))
    pass
    logger.info('Exit hook <{0}>'.format('after_step'))
    logger.info('Step end: <{0}>'.format(step.name))
    logger.info('-' * 30)