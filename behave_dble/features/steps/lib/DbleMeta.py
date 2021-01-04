# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM5:13
# @Author  : irene-coming

from ServerMeta import ServerMeta


class DbleMeta(ServerMeta):
    dbles = ()
    def __init__(self, config_dic):
        """
        create a data model of a server, including the server ssh user/password, prepare a long live ssh connection, and a long live sftp connection
        :param str install_dir:
        :param str client_user:
        :param str client_password:
        :param str client_port:
        :param str manager_user:
        :param str manager_password:
        :param str manager_port:
        """
        super(DbleMeta, self).__init__(config_dic)

        self._install_path = self._config_dic.pop("install_dir")
        self._client_user = self._config_dic.pop("client_user")
        self._client_password = self._config_dic.pop("client_password")
        self._client_port = self._config_dic.pop("client_port")
        self._manager_user = self._config_dic.pop("manager_user")
        self._manager_password = self._config_dic.pop("manager_password")
        self._manager_port = self._config_dic.pop("manager_port")

    @property
    def install_dir(self):
        return self._install_path

    @install_dir.setter
    def install_dir(self, value):
        self._install_path = value

    @property
    def client_user(self):
        return self._client_user

    @client_user.setter
    def client_user(self, value):
        self._client_user = value

    @property
    def client_password(self):
        return self._client_password

    @client_password.setter
    def client_password(self, value):
        self._client_password = value

    @property
    def client_port(self):
        return self._client_port

    @client_port.setter
    def client_port(self, value):
        self._client_port = value

    @property
    def manager_user(self):
        return self._manager_user

    @manager_user.setter
    def manager_user(self, value):
        self._manager_user = value

    @property
    def manager_password(self):
        return self._manager_password

    @manager_password.setter
    def manager_password(self, value):
        self._manager_password = value

    @property
    def manager_port(self):
        return self._manager_port

    @manager_port.setter
    def manager_port(self, value):
        self._manager_port = value