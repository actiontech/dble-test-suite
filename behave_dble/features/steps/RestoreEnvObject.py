# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/25 AM10:46
# @Author  : irene-coming
import logging

from lib import utils

from steps.lib.ObjectFactory import ObjectFactory
from steps.mysql_steps import execute_sql_in_host

logger = logging.getLogger('environment.after_scenario')
class RestoreEnvObject(object):
    def __init__(self,scenario):
        self._scenario = scenario
        
    def restore(self):
        # if "restore_sys_time" in self._scenario.tags:
        #     self.restore_sys_time()
        #
        # if "aft_reset_replication" in self._scenario.tags:
        #     utils.reset_repl()
        #
        # if "restore_letter_sensitive" in self._scenario.tags:
        #     sedStr= """
        #     /lower_case_table_names/d
        #     /server-id/a lower_case_table_names = 0
        #     """
        #     restore_letter_sensitive_dic = self.get_case_tag_params(self._scenario.description, "{'restore_letter_sensitive'")
        #
        #     if restore_letter_sensitive_dic:
        #         paras = restore_letter_sensitive_dic["restore_letter_sensitive"]
        #     else:
        #         paras = ['mysql-master1','mysql-master2','mysql-slave1','mysql-slave2']
        #
        #     logger.debug("try to restore lower_case_table_names of mysqls: {0}".format(paras))
        #     for mysql_name in paras:
        #         mysql = MySQLObject(mysql_name)
        #         mysql.update_config_with_sedStr_and_restart(context, sedStr)
        # if "restore_general_log" in self._scenario.tags:
        #     params_dic = self.get_case_tag_params(self._scenario.description, "{'restore_general_log'")
        #
        #     if params_dic:
        #         paras = params_dic["restore_general_log"]
        #     else:
        #         paras = ['mysql-master1', 'mysql-master2', 'mysql-slave1', 'mysql-slave2']
        #
        #     logger.debug("try to restore general_log of mysqls: {0}".format(paras))
        #     # for mysql_host in paras:
        #     #     turn_off_general_log(context,mysql_host)
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