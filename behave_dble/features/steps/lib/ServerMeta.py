# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/1 PM1:53
# @Author  : irene-coming
from .SSHUtil import SSHClient, SFTPClient

class ServerMeta(object):
    def __init__(self, config_dic):
        """
        create a data model of a server, including the server ssh user/password, prepare a long live ssh connection, and a long live sftp connection
        :param str ip:
        :param str ssh_user:
        :param str ssh_password:
        :param str host_name:
        """
        self._config_dic = config_dic.copy()
        self.ip = self._config_dic.pop("ip")
        self.ssh_user = self._config_dic.pop("ssh_user")
        self.ssh_password = self._config_dic.pop("ssh_password")
        self.host_name = self._config_dic.pop("hostname")

        self._ssh_conn = None
        self._sftp_conn = None

    @property
    def ip(self):
        return self._ip

    @ip.setter
    def ip(self, value):
        self._ip = value

    @property
    def ssh_conn(self):
        if self._ssh_conn is None:
            self._ssh_conn = SSHClient(self.ip, self.ssh_user, self.ssh_password)
            self._ssh_conn.connect()

            assert self._ssh_conn is not None, "get ssh to {0} fail".format(self._ip)
        return self._ssh_conn

    @ssh_conn.setter
    def ssh_conn(self, value):
        self._ssh_conn = value

    @property
    def sftp_conn(self):
        if self._sftp_conn is None:
            port = '22'
            self._sftp_conn = SFTPClient(self.ip, self.ssh_user, self.ssh_password, int(port))
            self._sftp_conn.sftp_connect()
            assert self._sftp_conn is not None, "get sftp to {0} fail".format(self._ip)
        return self._sftp_conn

    @sftp_conn.setter
    def sftp_conn(self, value):
        self._sftp_conn = value

    @property
    def host_name(self):
        return self._host_name

    @host_name.setter
    def host_name(self, value):
        self._host_name = value

    def close_ssh(self):
        self.ssh_conn.close()
        self.ssh_conn = None
