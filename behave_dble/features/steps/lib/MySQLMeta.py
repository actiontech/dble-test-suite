# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM1:44
# @Author  : irene-coming

from .ServerMeta import ServerMeta
class MySQLMeta(ServerMeta):
    def __init__(self, config_dic):
        """
        create a data model of a server, including the server ssh user/password, prepare a long live ssh connection, and a long live sftp connection
        :param str port:
        :param str user:
        :param str password:
        :param str install_path:
        """
        super(MySQLMeta, self).__init__(config_dic)
        self.mysql_port = self._config_dic.pop("port")
        self.mysql_user = self._config_dic.pop("user")
        self.mysql_password = self._config_dic.pop("password")
        self.install_path = self._config_dic.pop("install_path")

    @property
    def mysql_port(self):
        return self._mysql_port

    @mysql_port.setter
    def mysql_port(self, value):
        self._mysql_port = value

    @property
    def mysql_user(self):
        return self._mysql_user

    @mysql_user.setter
    def mysql_user(self, value):
        self._mysql_user = value

    @property
    def mysql_password(self):
        return self._mysql_password

    @mysql_password.setter
    def mysql_password(self, value):
        self._mysql_password = value

    @property
    def install_path(self):
        return self._install_path

    @install_path.setter
    def install_path(self, value):
        self._install_path = value
        self._mysql_init_shell = "{0}/support-files/mysql.server".format(self.install_path)

    @property
    def mysql_init_shell(self):
        return self._mysql_init_shell