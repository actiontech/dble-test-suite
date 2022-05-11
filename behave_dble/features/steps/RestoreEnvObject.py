# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/25 AM10:46
# @Author  : irene-coming
import logging

from lib import utils

from steps.lib.ObjectFactory import ObjectFactory
from steps.mysql_steps import execute_sql_in_host

logger = logging.getLogger('root')
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
                ssh = utils.get_ssh(host_name)

                if host_name.find("dble") != -1:
                    mode = "user"
                else:
                    mode = "mysql"
                logger.debug("the value of host_name is: {0}, mode: {1}".format(host_name, mode))

                # in case of program exits unexpected, tables.txt Residue in /tmp
                rc, stdout, stderr = ssh.exec_command("find /tmp -name tables.txt")
                if len(stdout) > 0:
                    ssh.exec_command("rm -rf /tmp/tables.txt")

                for database in paras[host_name]:
                    generate_drop_tables_sql = "select concat('drop table if exists ',table_name,';') from information_schema.TABLES where table_schema='{0}' into outfile '/tmp/tables.txt'".format(database)
                    execute_sql_in_host(host_name, {"sql": generate_drop_tables_sql}, mode)

                    # MySQLDB not support source grammar,replace with ssh cmd
                    rc, stdout, stderr = ssh.exec_command("mysql -uroot -p111111 -D{0} -e 'source /tmp/tables.txt'".format(database))
                    stderr = stderr.lower()
                    assert stderr.find("error") == -1, "deletet mysql in {0}:{1} failed, err: {2}".format(host_name, database, stderr)
                    ssh.exec_command("rm -rf /tmp/tables.txt")

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