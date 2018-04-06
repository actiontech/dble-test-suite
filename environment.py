import ConfigParser
import logging
import os
import sys

from lib.nodes import get_ssh, get_sftp
from lib.utils import init_log_directory, setup_logging ,load_yaml_config, get_nodes

from behave.log_capture import capture
from pprint import pformat

from steps.step_reload import upload_and_replace_conf

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

def before_all(context):
    context.current_log = init_log_directory()
    setup_logging(os.path.join(CONF_PATH, 'logging.yaml'))
    logger.debug('Setup logging configfile=<{0}>'.format(os.path.join(CONF_PATH, 'logging.yaml')))
    logger.info('*' * 30)
    logger.info('*       DBLE TEST START       *')
    logger.info('*' * 30)
    logger.info('Enter hook before_all')
    test_config = "./conf/auto_dble_test.yaml"

    parsed = load_yaml_config(test_config)
    for name, values in parsed.iteritems():
        setattr(context, name, values)

    parsed = load_yaml_config(context.dble_test_config['docker_compose_path'])
    #get dble all nodes
    context.dbles = get_nodes(context, parsed, "dble")
    context.mysqls = get_nodes(context, parsed, "mysql")
    context.nodes = get_nodes(context, parsed)

    context.ssh_client = get_ssh(context.dbles, context.dble_test_config['dble_host'])
    context.ssh_sftp = get_sftp(context.dbles, context.dble_test_config['dble_host'])

    #clean last result
    osCmd= 'rm -rf {0} && mkdir {0}'.format(context.dble_test_config['result']['dir'])
    os.system(osCmd)

    steps_dir = "{0}/steps".format(os.getcwd())
    sys.path.append(steps_dir)
    init_log(context)

    if context.config.userdata["tar_local"].lower() == "true":
        context.need_download = False
    else:
        context.need_download = True
    logger.info('Exit hook <{0}>'.format('before_all'))

def after_all(context):
    logger.info('Enter hook <{0}>'.format('after_all'))

    for node in context.nodes:
        logger.debug('ip <{0}>'.format(node.ip))
        logger.debug('connection <{0}>'.format(node.sshconn))
        if node.sshconn:
            node.sshconn.close()

    logger.info('Exit hook <{0}>'.format('after_all'))
    logger.info('*' * 30)
    logger.info('*       DBLE TEST END        *')
    logger.info('*' * 30)

def before_feature(context, feature):
    logger.info('*' * 30)
    logger.info('Feature start: <{0}>'.format(feature.name))
    logger.info('Enter hook <{0}>'.format('before_feature'))
    if "log_debug" in feature.tags:
        context.execute_steps(u'Given Set the log level to "debug" and restart server in "dble-1"')
    try:
        dble_conf = context.config.userdata.pop('dble_conf')
    except KeyError:
        raise KeyError('Not define test_config in behave -D sql_cover=XXX')
    if dble_conf.lower() == "sql_cover":
        context.execute_steps(u'Given Replace the existing configuration with the conf sql_cover directory')
    elif dble_conf.lower() == "template":
        context.execute_steps(u'Given Replace the existing configuration with the conf template directory')

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
    logger.info('Enter hook after_scenario')
    #clear conns in case of the same name conn is used in after test cases
    for i in range(0, 10):
        conn_name = "conn_{0}".format(i)
        if hasattr(context, conn_name):
            conn = getattr(context, conn_name)
            conn.close()
            delattr(context, conn_name)

    if context.config.stop and scenario.status == "failed":
        context.execute_steps(u'Given Replace the existing configuration with the conf template directory')
    logger.info('Scenario end: <{0}>'.format(scenario.name))
    logger.info('#' * 30)

def before_step(context, step):
    logger.info('-' * 30)
    logger.info('Step start: <{0}>'.format(step.name))
    pass
    logger.info('Exit hook Step start <{0}>'.format(step.name))

def after_step(context, step):
    logger.info('Enter hook after_step')
    pass
    logger.info('Step end: <{0}>'.format(step.name))
    logger.info('-' * 30)