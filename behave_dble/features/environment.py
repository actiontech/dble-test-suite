# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging
import os
import configparser
import time
from pprint import pformat
from steps.RestoreEnvObject import RestoreEnvObject
from steps.lib.DbleMeta import DbleMeta
from steps.lib.MySQLMeta import MySQLMeta
from steps.lib.MySQLObject import MySQLObject
from steps.lib.DbleObject import DbleObject
from steps.lib.utils import setup_logging, load_yaml_config, init_meta, restore_sys_time, reset_repl, get_sftp, get_ssh, \
    create_ssh_client, init_log_directory, handle_env_variables
from steps.mysql_steps import restart_mysql
from steps.step_install import replace_config, set_dbles_log_level, restart_dbles, disable_cluster_config_in_node,check_dble_alived_in_all_nodes, \
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

    init_meta(context, "clickhouses")
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

    # case开始前先判断dble是否存活，不存活就启动dble
    if not check_dble_alived_in_all_nodes(context):
        logger.info('maybe the last after_scenario start dble failed!>')
        reset_dble(context)

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

        if "stop_tcpdump" in scenario.tags:
            params_dic = restore_obj.get_tag_params("{'stop_tcpdump'")
            logger.debug("params_dic is: {0}".format(params_dic))
            if params_dic:
                paras = params_dic["stop_tcpdump"].split(",")
            else:
                paras = ""

            logger.debug("try to stop tcpdump thread: {0}".format(paras))
            for host_name in paras:
                logger.debug("the value of host_name is: {0}".format(host_name))
                # 可能来不及抓包case就结束了，sleep 10s抓取更多信息
                time.sleep(10)
                context.execute_steps(u'Given stop and destroy tcpdump threads list in "{0}"'.format(host_name))

        if "cp_btrace_log" in scenario.tags:
            params_dic = restore_obj.get_tag_params("{'cp_btrace_log'")
            logger.debug("params_dic is: {0}".format(params_dic))
            if params_dic:
                paras = params_dic["cp_btrace_log"].split(",")
            else:
                paras = ""

            logger.debug("try to copy btrace log to dble log directory: {0}".format(paras))
            for host_name in paras:
                logger.debug("the value of host_name is: {0}".format(host_name))
                ssh_client = get_ssh(host_name)
                rc, sto, ste = ssh_client.exec_command("find /opt/dble -name *.java.log | wc -l")
                logger.debug(f"btrace log file count is: {sto}")
                if int(sto) > 0:
                    mv_cmd = "mv /opt/dble/*.java.log /opt/dble/logs"
                    ssh_client.exec_command(mv_cmd)


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
