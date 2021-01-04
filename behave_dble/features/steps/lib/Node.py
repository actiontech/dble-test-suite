# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
from random import sample

from . Logging import Logging
from . SSHUtil import SSHClient, SFTPClient


class Node(Logging):
    def __init__(self, ip, ssh_user, ssh_password, host_name=None, mysql_port=None):
        super(Node, self).__init__()
        self._ip = ip
        self._ssh_user = ssh_user
        self._ssh_password = ssh_password
        self._host_name = host_name
        self._mysql_port = mysql_port
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
            self._ssh_conn = SSHClient(self.ip, self._ssh_user, self._ssh_password)
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
            self._sftp_conn = SFTPClient(self.ip, self._ssh_user, self._ssh_password, int(port))
            self._sftp_conn.sftp_connect()
            assert self._sftp_conn is not None, "get sftp to {0} fail".format(self._ip)
        return self._sftp_conn

    @sftp_conn.setter
    def sftp_conn(self, value):
        self._sftp_conn = value

    @property
    def mysql_port(self):
        return self._mysql_port

    @mysql_port.setter
    def mysql_port(self, value):
        self._mysql_port = value

    @property
    def host_name(self):
        return self._host_name

    @host_name.setter
    def host_name(self, value):
        self._host_name = value

    def get_random_nodes(self, num=1):
        return sample(self.nodes, num)