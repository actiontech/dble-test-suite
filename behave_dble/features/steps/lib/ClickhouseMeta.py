# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2023/8/3
# @Author  : wujinling

from steps.lib.ServerMeta import ServerMeta
class ClickhouseMeta(ServerMeta):
    clickhouses = ()
    def __init__(self, config_dic):
        """
        create a data model of a server, including the server ssh user/password, prepare a long live ssh connection, and a long live sftp connection
        :param str port:
        :param str user:
        :param str password:
        """
        super(ClickhouseMeta, self).__init__(config_dic)
        self.clickhouse_port = self._config_dic.pop("port")
        self.clickhouse_user = self._config_dic.pop("user")
        self.clickhouse_password = self._config_dic.pop("password")

    @property
    def clickhouse_port(self):
        return self._clickhouse_port

    @clickhouse_port.setter
    def clickhouse_port(self, value):
        self._clickhouse_port = value

    @property
    def clickhouse_user(self):
        return self._clickhouse_user

    @clickhouse_user.setter
    def clickhouse_user(self, value):
        self._clickhouse_user = value

    @property
    def clickhouse_password(self):
        return self._clickhouse_password

    @clickhouse_password.setter
    def clickhouse_password(self, value):
        self._clickhouse_password = str(value)

    @property
    def clickhouse_init_shell(self):
        return self._clickhouse_init_shell