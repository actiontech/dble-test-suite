# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging
import os
import configparser
from pprint import pformat
from steps.RestoreEnvObject import RestoreEnvObject
from steps.DbleMeta import DbleMeta
from steps.MySQLMeta import MySQLMeta
from steps.MySQLObject import MySQLObject
from steps.DbleObject import DbleObject
from steps.utils import setup_logging, load_yaml_config, init_meta, restore_sys_time, reset_repl, get_sftp, get_ssh, \
    create_ssh_client, init_log_directory, handle_env_variables
from steps.step_env import replace_config, restart_dbles, disable_cluster_config_in_node, \
    install_dble_in_all_nodes
from behave.contrib.scenario_autoretry import patch_scenario_with_autoretry
from behave.tag_matcher import ActiveTagMatcher, setup_active_tag_values

logger = logging.getLogger('root')

active_tag_value_provider = {
    'mysql_version': '5.7',
    'dble_topo': 'single'
}

active_tag_matcher = ActiveTagMatcher(active_tag_value_provider)


def init_dble_conf(context, para_dble_conf):
    para_dble_conf_lower = para_dble_conf.lower()
    if para_dble_conf_lower in ["sql_cover_mixed", "sql_cover_global", "template", "sql_cover_nosharding",
                                "sql_cover_sharding"]:
        conf = "{0}{1}".format(context.cfg_sys['dble_conf_dir_in_behave'], para_dble_conf_lower)
    else:
        assert False, 'cmdline dble_conf\'s value can only be one of ["template", "sql_cover_mixed", "sql_cover_global", "sql_cover_nosharding","sql_cover_sharding"]'

    context.dble_conf = conf


def before_all(context):
    context.current_log = init_log_directory()

    setup_logging('./conf/logging.yaml')
    steps_logger = logging.getLogger('root')
    context.logger = steps_logger

    logger.info('*' * 30)
    logger.info('*       DBLE TEST START      *')
    logger.info('*' * 30)
<<<<<<< HEAD
    logger.info('Enter before_all')
    #读取dble mysql的配置信息
    userdata=context.config.userdata
    test_conf_path="./conf/"+ userdata.get("test_config")
    test_conf=load_yaml_config(test_conf_path)
    for key,value in test_conf.items():
        setattr(context, key, value)#put items of conf in context
    #处理behave.ini的配置选项
    #是否重置dble
    reset = userdata["reset"].lower() == "true" 
    #是否是userdebug
    context.userDebug = userdata["user_debug"].lower() == "true"
    #dble_conf 配置文件
    context.dble_conf="conf/dble_conf/"+userdata["dble_conf"].lower()
    init_meta(context,"single")
    init_meta(context,"mysqls")
    context.need_download = userdata["install_from_local"].lower() != "true"
=======
    logger.info('Enter hook before_all')

    ud = context.config.userdata
    try:
        test_config = ud.pop('test_config')  # "./conf/auto_dble_test.yaml"
    except KeyError:
        raise KeyError('Not define test_config') from KeyError

    parsed = load_yaml_config("./conf/"+ test_config)
    for name, values in parsed.items():
        setattr(context, name, values)

    handle_env_variables(context, ud)
    setup_active_tag_values(active_tag_value_provider, context.test_conf)

    context.userDebug = ud["user_debug"].lower() == "true"
    init_meta(context, context.test_conf['dble_topo'])
    if context.test_conf['dble_topo']=="single":
        for node in DbleMeta.dbles:
            disable_cluster_config_in_node(context, node)

    init_meta(context, "mysqls")
    # optimize later
    context.ssh_client = get_ssh(context.cfg_dble['single']['dble-1']['hostname'])
    context.ssh_sftp = get_sftp(context.cfg_dble['single']['dble-1']['hostname'])
    try:
        para_dble_conf = ud.pop('dble_conf')
    except KeyError:
        raise KeyError('Not define userdata dble_conf, usage: behave -D dble_conf=XXX ...')
    init_dble_conf(context, para_dble_conf)
    reinstall = ud["reinstall"].lower() == "true"
    reset = ud["reset"].lower() == "true"

    logger.info("run test with environment reinstall: {0}, reset: {1}".format(reinstall, reset))

    context.need_download = ud["install_from_local"].lower() != "true"

    if reinstall:
        install_dble_in_all_nodes(context)

>>>>>>> 2f7703afcf3660bcd333d148aadbabb77ea086b0
    if reset:
        reset_dble(context)
    else:
        logger.info('give new install')
    logger.info('Exit hook <{0}>'.format('before_all'))


def reset_dble(context):
    replace_config(context)
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
    logger.info('*       Exit hook after_all, DBLE TEST END        *')
    logger.info('*' * 30)


def before_feature(context, feature):
    logger.info('*' * 30)
    logger.info('Feature start: <{0}><{1}>'.format(feature.filename, feature.name))

    if active_tag_matcher.should_exclude_with(feature.tags):
        feature.skip(reason="DISABLED ACTIVE-TAG")
    else:
        for scenario in feature.scenarios:
            if "auto_retry" in scenario.tags:
                patch_scenario_with_autoretry(scenario, max_attempts=context.test_conf['auto_retry'] + 1)

    if "setup" in feature.tags:
        context.ssh_clients = create_ssh_client(context)

    logger.info('Exit hook <before_feature>')


def after_feature(context, feature):
    if "setup" in feature.tags:
        for _, ssh_client in context.ssh_clients.items():
            ssh_client.close()
    logger.info('Feature end: <{0}><{1}>'.format(feature.filename, feature.name))
    logger.info('*' * 30)


def before_scenario(context, scenario):
    logger.info('#' * 30)
    logger.info('Scenario start: <{0}>'.format(scenario.name))
    if active_tag_matcher.should_exclude_with(scenario.effective_tags):
        scenario.skip("DISABLED ACTIVE-TAG")
    logger.info('Exit hook <before_scenario>')


def after_scenario(context, scenario):
    logger.info('Enter hook after_scenario')
    # clear conns in case of the same name conn is used in after test cases
    for i in range(0, 10):
        conn_name = "conn_{0}".format(i)
        if hasattr(context, conn_name):
            conn = getattr(context, conn_name)
            conn.close()
            delattr(context, conn_name)
    for conn_id, conn in MySQLObject.mysql_long_live_conns.items():
        logger.debug("to close mysql conn: {}".format(conn_id))
        conn.close()
    for conn_id, conn in DbleObject.dble_long_live_conns.items():
        logger.debug("to close dble conn: {}".format(conn_id))
        conn.close()

    MySQLObject.mysql_long_live_conns.clear()
    DbleObject.dble_long_live_conns.clear()

    if not context.userDebug:
        if "init_dble_meta" in scenario.tags:
            init_meta(context, "single")

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
    logger.info('Exit hook <after_scenario>')
    logger.info('after_scenario end: <{0}>'.format(scenario.name))
    logger.info('#' * 30)


def before_step(context, step):
    logger.debug(step.name)


def after_step(context, step):
    if step.status == "failed":
        logger.error('Failing step location: {0}, status:{1}'.format(step.location, step.status))
    else:
        logger.info('{0}, status:{1}'.format(step.name, step.status))
