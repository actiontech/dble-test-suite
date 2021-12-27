# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging

from lib import utils

from mysql_steps import execute_sql_in_host
from lib.utils import get_sftp, get_ssh, get_node
from hamcrest import *

logger = logging.getLogger('root')


class RestoreEnvObject(object):
    def __init__(self, scenario):
        self._scenario = scenario

    def restore(self):
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
                        update_file_content(self._context, "/etc/my.cnf", host_name)
                        start_mysql(self._context, host_name)

                    # mysql = ObjectFactory.create_mysql_object(host_name)
                    # mysql.start()

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
                    m = ['log-bin', 'binlog_format', 'relay-log']
                    if k in m:
                        sed_str += "/{0}/d\n".format(k)
                    else:
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