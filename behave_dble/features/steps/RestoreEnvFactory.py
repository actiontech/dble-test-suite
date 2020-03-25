# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/25 AM10:46
# @Author  : irene-coming
import logging
logger = logging.getLogger('after_scenario')
class RestoreEnvFactory(object):
    def __init__(self,scenario):
        self._scenario = scenario
        
    def restore(self):
        if "restore_sys_time" in self._self._scenario.tags:
            self.restore_sys_time()

        if "aft_reset_replication" in self._scenario.tags:
            Utils.reset_repl(context)

        if "restore_letter_sensitive" in self._scenario.tags:
            sedStr= """
            /lower_case_table_names/d
            /server-id/a lower_case_table_names = 0
            """
            restore_letter_sensitive_dic = self.get_case_tag_params(self._scenario.description, "{'restore_letter_sensitive'")

            if restore_letter_sensitive_dic:
                paras = restore_letter_sensitive_dic["restore_letter_sensitive"]
            else:
                paras = ['mysql-master1','mysql-master2','mysql-slave1','mysql-slave2']

            logger.debug("try to restore lower_case_table_names of mysqls: {0}".format(paras))
            for mysql_name in paras:
                mysql = MySQLObject(mysql_name)
                mysql.update_config_with_sedStr_and_restart(context, sedStr)

        if "restore_general_log" in self._scenario.tags:
            params_dic = self.get_case_tag_params(self._scenario.description, "{'restore_general_log'")

            if params_dic:
                paras = params_dic["restore_general_log"]
            else:
                paras = ['mysql-master1', 'mysql-master2', 'mysql-slave1', 'mysql-slave2']

            logger.debug("try to restore general_log of mysqls: {0}".format(paras))
            for mysql_host in paras:
                turn_off_general_log(context,mysql_host)
        if "restore_global_setting" in tags:

    def get_case_tag_params(descriptionList, tagKey):
        restore_letter_sensitive_dic = None
        for line in descriptionList:
            line_no_white = line.strip()
            if line_no_white and line_no_white.startswith(tagKey):
                restore_letter_sensitive_dic = eval(line)
                break
        return restore_letter_sensitive_dic