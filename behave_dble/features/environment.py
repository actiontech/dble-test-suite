# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging

from steps.RestoreEnvObject import RestoreEnvObject
from steps.lib.DbleMeta import DbleMeta
from steps.lib.MySQLMeta import MySQLMeta
from steps.lib.MySQLObject import MySQLObject
from steps.lib.utils import setup_logging ,load_yaml_config, init_meta,restore_sys_time,reset_repl, get_sftp,get_ssh
from steps.mysql_steps import restart_mysql
from steps.step_install import replace_config, set_dbles_log_level, restart_dbles, disable_cluster_config_in_node, \
    install_dble_in_all_nodes, reset_zk_nodes

logger = logging.getLogger('root')

def init_dble_conf(context, para_dble_conf):
    para_dble_conf_lower = para_dble_conf.lower()
    if para_dble_conf_lower in ["sql_cover_mixed", "sql_cover_global", "template", "sql_cover_nosharding","sql_cover_sharding"]:
        conf = "{0}{1}".format(context.cfg_sys['dble_conf_dir_in_behave'], para_dble_conf_lower)
    else:
        assert False, 'cmdline dble_conf\'s value can only be one of ["template", "sql_cover_mixed", "sql_cover_global", "sql_cover_nosharding","sql_cover_sharding"]'

    context.dble_conf = conf

def before_all(context):
    setup_logging('./conf/logging.yaml')
    steps_logger = logging.getLogger('root')
    context.logger = steps_logger

    logger.info('*' * 30)
    logger.info('*       DBLE TEST START      *')
    logger.info('*' * 30)
    logger.info('Enter hook before_all')

    test_config = context.config.userdata["test_config"].lower() #"./conf/auto_dble_test.yaml"
    #convert auto_dble_test.yaml attr to context attr
    parsed = load_yaml_config("./conf/"+test_config)
    for name, values in parsed.iteritems():
        setattr(context, name, values)

    context.userDebug = context.config.userdata["user_debug"].lower() == "true"
    context.is_cluster = context.config.userdata["is_cluster"].lower() == "true"
    if context.is_cluster:
        init_meta(context, "dble_cluster")
    else:
        init_meta(context, "dble")
        for node in DbleMeta.dbles:
            disable_cluster_config_in_node(context, node)

    init_meta(context, "mysqls")
    context.ssh_client = get_ssh(context.cfg_dble['dble']['hostname'])
    context.ssh_sftp = get_sftp(context.cfg_dble['dble']['hostname'])

    try:
        para_dble_conf = context.config.userdata.pop('dble_conf')
    except KeyError:
        raise KeyError('Not define userdata dble_conf, usage: behave -D dble_conf=XXX ...')
    init_dble_conf(context, para_dble_conf)
    reinstall = context.config.userdata["reinstall"].lower() == "true"
    reset = context.config.userdata["reset"].lower() == "true"

    logger.info("run test with environment reinstall: {0}, reset: {1}".format(reinstall, reset))

    context.need_download = context.config.userdata["install_from_local"].lower() != "true"

    if reinstall:
        reset_zk_nodes(context)
        install_dble_in_all_nodes(context)

    if reset:
        reset_dble(context)
    else:
        logger.info('give new install')
    logger.info('Exit hook <{0}>'.format('before_all'))

def reset_dble(context):
    replace_config(context)
    set_dbles_log_level(context, DbleMeta.dbles, 'debug')
    restart_dbles(context, DbleMeta.dbles)

def after_all(context):
    logger.info('Enter hook <{0}>'.format('after_all'))

    for node in DbleMeta.dbles:
        if node.ssh_conn:
            node.ssh_conn.close()
    for node in MySQLMeta.mysqls:
        if node.ssh_conn:
            node.ssh_conn.close()

    logger.info('*' * 30)
    logger.info('*       Exit hook after_all， DBLE TEST END        *')
    logger.info('*' * 30)

def before_feature(context, feature):
    logger.info('*' * 30)
    logger.info('Feature start: <{0}><{1}>'.format(feature.filename,feature.name))

    if "setup" in feature.tags:
        # delete the begin and end """
        for desc in feature.description[1:-1]:
            logger.info(desc)
            context.execute_steps(desc)

def after_feature(context, feature):
    logger.info('Feature end: <{0}><{1}>'.format(feature.filename,feature.name))
    logger.info('*' * 30)

def before_scenario(context, scenario):
    logger.info('#' * 30)
    logger.info('Scenario start: <{0}>'.format(scenario.name))

def after_scenario(context, scenario):
    logger.info('Enter hook after_scenario')
    #clear conns in case of the same name conn is used in after test cases
    for i in range(0, 10):
        conn_name = "conn_{0}".format(i)
        if hasattr(context, conn_name):
            conn = getattr(context, conn_name)
            conn.close()
            delattr(context, conn_name)
    for conn_id,conn in MySQLObject.long_live_conns.items():
        logger.debug("to close mysql conn: {}".format(conn_id))
        conn.close()
    MySQLObject.long_live_conns.clear()

    if not context.userDebug:
        if "restore_sys_time" in scenario.tags:
            restore_sys_time()

        if "aft_reset_replication" in scenario.tags:
            reset_repl()

        restore_obj = RestoreEnvObject(scenario)
        restore_obj.restore()

    # status-failed vs userDebug: even scenario success, reserve the config files for userDebug
    stop_scenario_for_failed = context.config.stop and scenario.status == "failed"
    if not stop_scenario_for_failed and not "skip_restart" in scenario.tags and not context.userDebug:
        reset_dble(context)

    logger.info('after_scenario end: <{0}>'.format(scenario.name))
    logger.info('#' * 30)

def before_step(context, step):
    logger.debug(step.name)

def after_step(context, step):
    logger.info('{0}, status:{1}'.format(step.name, step.status))

