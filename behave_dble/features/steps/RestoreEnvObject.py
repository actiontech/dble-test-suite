# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/25 AM10:46
# @Author  : irene-coming
import logging

from lib import utils

from steps.lib.ObjectFactory import ObjectFactory
from steps.mysql_steps import execute_sql_in_host
# from steps.lib.utils import get_ssh
from lib.utils import get_sftp, get_ssh,get_node

import re

from hamcrest import *

logger = logging.getLogger('environment.after_scenario')
class RestoreEnvObject(object):
    def __init__(self,scenario):
        self._scenario = scenario
        
    def restore(self):
        # if "restore_sys_time" in self._scenario.tags:
        #     utils.restore_sys_time()
        #
        # if "aft_reset_replication" in self._scenario.tags:
        #     utils.reset_repl()
        #
        if "restore_network" in self._scenario.tags:
            params_dic = self.get_tag_params("{'restore_network'")
            logger.debug("params_dic is: {0}".format(params_dic))
            if params_dic:
                paras = params_dic["restore_network"].split(",")
                # paras = paras.split(",")
            else:
                paras = ""


            logger.debug("try to restore_network: {0}".format(paras))
            for host_name in paras:
                logger.debug("the value of host_name is: {0}".format(host_name))
                cmd = "iptables -F"
                ssh = get_ssh(host_name)
                rc, stdout, stderr = ssh.exec_command(cmd)
                assert_that(len(stderr) == 0, "restore network with command:{1}, got err:{0}".format(stderr, cmd))

        if "restore_view" in self._scenario.tags:
            params_dic = self.get_tag_params("{'restore_view'")
            if params_dic:
                paras = params_dic["restore_view"]
            else:
                paras = {}

            for host_name, mysql_vars in paras.items():
                if host_name.find('dble')!=-1:
                    mode="user"
                else:
                    mode = "mysql"
                for k, v in mysql_vars.items():
                    list_value = filter(lambda x: x, v.split(","))
                    view_value=""
                    for value in list_value:
                        view_value=view_value + "{0}.{1},".format(k, value)
                    query = "drop view if exists " + view_value

                sql = query[:-1]#delete the last ','
                # logger.debug("the sql is: {0}".format(sql))
                execute_sql_in_host(host_name, {"sql": sql}, mode)

        if "restore_mysql_service" in self._scenario.tags:
            params_dic = self.get_tag_params("{'restore_mysql_service'")

            if params_dic:
                paras = params_dic["restore_mysql_service"]
            else:
                paras = {}

            logger.debug("try to restore_mysql_service: {0}".format(paras))
            for host_name, mysql_vars in paras.items():
                logger.debug("the value of host_name is: {0}".format(host_name))
                for k, v in mysql_vars.items():
                    if v:
                        mysql = ObjectFactory.create_mysql_object(host_name)
                        mysql.start()

        if "restore_global_setting" in self._scenario.tags:
            params_dic = self.get_tag_params("{'restore_global_setting'")

            if params_dic:
                paras = params_dic["restore_global_setting"]
            else:
                paras = {}

            logger.debug("try to restore_global_setting of mysqls: {0}".format(paras))

            for mysql, mysql_vars in paras.items():
                query = "set global "
                for k, v in mysql_vars.items():
                    query = query + "{0}={1},".format(k, v)

                sql = query[:-1]#delete the last ','
                execute_sql_in_host(mysql, {"sql": sql})

        if "restore_mysql_config" in self._scenario.tags:
            params_dic = self.get_tag_params("{'restore_mysql_config'")

            if params_dic:
                paras = params_dic["restore_mysql_config"]
            else:
                paras = {}

            logger.debug("try to restore_mysql_config of mysqls: {0}".format(paras))

            for host_name, mysql_vars in paras.items():
                sed_str = ""
                for k, v in mysql_vars.items():
                    sed_str += "/{0}/d\n/server-id/a {0}={1}\n".format(k, v)

                mysql = ObjectFactory.create_mysql_object(host_name)
                mysql.restart(sed_str)

        if "delete_mysql_tables" in self._scenario.tags:
            params_dic = self.get_tag_params("{'delete_mysql_tables'")

            if params_dic:
                paras = params_dic["delete_mysql_tables"]
            else:
                paras = {}

            for host_name in paras.keys():
                logger.debug("try to delete_mysql_tables of mysqls: {0}".format(host_name))

                if host_name.find("dble") != -1:
                    mode = "user"
                else:
                    mode = "mysql"
                logger.debug("the value of host_name is: {0}, mode: {1}".format(host_name, mode))

                for database in paras[host_name]:
                    generate_drop_tables_sql = "select concat('drop table if exists ',table_schema,'.',table_name,';') from information_schema.TABLES where table_schema='{0}'".format(database)
                    res, err = execute_sql_in_host(host_name, {"sql": generate_drop_tables_sql}, mode)
                    for sql_element in res:
                        drop_table_sql = sql_element[0]
                        execute_sql_in_host(host_name, {"sql": drop_table_sql}, mode)

                logger.debug("{0} tables has been delete success".format(host_name))

            logger.info("all required tables has been delete success")

    def get_tag_params(self, tagKey):
        description = self._scenario.description
        logger.debug("scenario description:{0}".format(type(description)))
        dic = None
        for line in description:
            line_no_white = line.strip()
            if line_no_white and line_no_white.startswith(tagKey):
                dic = eval(line)
                break
        return dic