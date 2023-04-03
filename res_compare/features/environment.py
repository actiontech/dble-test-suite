

import logging
from steps.step_env import reset_dble
from steps.DbleMeta import DbleMeta
from steps.MySQLMeta import MySQLMeta
from steps.utils import create_ssh_client,load_yaml_config,init_meta,init_log_directory,setup_logging
from steps.DbleObject import DbleObject
from steps.MySQLObject import MySQLObject
from steps.RestoreEnvObject import RestoreEnvObject

logger=logging.getLogger("root")



# #判断dble_conf一项是否填写正确
# def init_dble_conf(context,dble_conf):
#     if dble_conf in ["template", "sql_cover_mixed", "sql_cover_global", "sql_cover_nosharding","sql_cover_sharding"]:
#         context.dble_conf=dble_conf
#     else:
#         assert False, ' unknown dble_conf value'

#开始测试前的动作：读取dble和mysql的配置信息,处理behave.ini的配置选项
def before_all(context):
    context.current_log = init_log_directory()
    setup_logging('./conf/logging.yaml')
    steps_logger = logging.getLogger('root')
    context.logger = steps_logger
    logger.info('*' * 30)
    logger.info('*       DBLE TEST START      *')
    logger.info('*' * 30)
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
    
    if reset:
        reset_dble(context)
    logger.info('Exit before_all')

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

def before_feature(context,feature):
    logger.info('*' * 30)
    logger.info('Feature start: <{0}><{1}>'.format(feature.filename, feature.name))

    if "setup" in feature.tags:
        context.ssh_clients = create_ssh_client(context)
    logger.info('Exit hook <before_feature>')

    
def after_feature(context,feature):
    if "setup" in feature.tags:
        for _, ssh_client in context.ssh_clients.items():
            ssh_client.close()
    logger.info('Feature end: <{0}><{1}>'.format(feature.filename, feature.name))
    logger.info('*' * 30)


def before_scenario(context, scenario):
    logger.info('#' * 30)
    logger.info('Scenario start: <{0}>'.format(scenario.name))
    logger.info('Exit  <before_scenario>')

def after_scenario(context,scenario):
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
        #根据scenario的tag进行的环境清理
        restore_obj = RestoreEnvObject(scenario)
        restore_obj.restore()

    # status-failed vs userDebug: even scenario success, reserve the config files for userDebug
    stop_scenario_for_failed = context.config.stop and scenario.status == "failed"
    if not stop_scenario_for_failed and not "skip_restart" in scenario.tags and not context.userDebug:
        reset_dble(context)
    logger.info('Exit hook <after_scenario>')
    logger.info('after_scenario end: <{0}>'.format(scenario.name))
    logger.info('#' * 30)

def before_step(context,step):
    logger.debug(step.name)

def after_step(context,step):
    if step.status == "failed":
        logger.error('Failing step location: {0}, status:{1}'.format(step.location, step.status))
    else:
        logger.info('{0}, status:{1}'.format(step.name, step.status))
