from random import sample
import paramiko
from lib.ssh import SSHClient, SFTPClient
from lib.log import Logging


class Node(Logging):
    def __init__(self, ip, ssh_user, ssh_password, host_name=None):
        super(Node, self).__init__()
        self._ip = ip
        self._ssh_user = ssh_user
        self._ssh_password = ssh_password
        self._host_name = host_name
        self.sftp_connection = None

    def get_connection(self):
        if self.sftp_connection is None:
            self.logger.debug('create ssh to ip: <{0}> host_name: <{1}>'.format(self.ip, self.host_name))
            self.connection = SSHClient(self.ip, self.ssh_user, self.ssh_password)
            self.connection.connect()

        assert self.connection is not None, "get ssh to {0} fail".format(self._ip)
        return self.connection

    def get_sftp_connection(self):
        if self.sftp_connection is None:
            port = '22'
            self.sftp_connection = SFTPClient(self.ip, self.ssh_user, self.ssh_password, int(port))
            self.sftp_connection.sftp_connect()

        assert self.sftp_connection is not None, "get sftp to {0} fail".format(self._ip)
        return self.sftp_connection

    @property
    def ip(self):
        return self._ip

    @ip.setter
    def ip(self, value):
        self._ip = value

    @property
    def ssh_user(self):
        return self._ssh_user

    @ssh_user.setter
    def ssh_user(self, value):
        self._ssh_user = value

    @property
    def ssh_password(self):
        return self._ssh_password

    @ssh_password.setter
    def ssh_password(self, value):
        self._ssh_password = value

    @property
    def host_name(self):
        return self._host_name

    @host_name.setter
    def host_name(self, value):
        self._host_name = value

    def get_random_nodes(self, num=1):
        return sample(self.nodes, num)

def get_node(nodes, host):
    for node in nodes:
        if node.host_name == host or node.ip == host:
            return node
    assert False, 'Can not find node {0}'.format(host_name)

# get ssh by host or ip
def get_ssh(nodes, host):
    node = get_node(nodes, host)
    return node.get_connection()

# get sftp by host or ip
def get_sftp(nodes, host):
    node = get_node(nodes, host)
    return node.get_sftp_connection()

