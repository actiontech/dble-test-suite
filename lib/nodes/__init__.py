from random import sample
import paramiko
from lib.ssh import SSHClient, SFTPClient
from lib.log import Logging


class Node(Logging):
    def __init__(self, ip, ssh_user, ssh_password, host_name=None, mysql_port=None):
        super(Node, self).__init__()
        self._ip = ip
        self._ssh_user = ssh_user
        self._ssh_password = ssh_password
        self._host_name = host_name
        self._mysql_port = mysql_port
        self._sshconn = None
        self.sftp_connection = None

    def create_connection(self):
        if self.sshconn is None:
            self.logger.debug('create ssh to ip: <{0}> host_name: <{1}>'.format(self.ip, self.host_name))
            self.sshconn = SSHClient(self.ip, self._ssh_user, self.ssh_password)
            self.sshconn.connect()

        assert self.sshconn is not None, "get ssh to {0} fail".format(self._ip)
        return self.sshconn

    def get_sftp_connection(self):
        if self.sftp_connection is None:
            port = '22'
            self.sftp_connection = SFTPClient(self.ip, self._ssh_user, self._ssh_password, int(port))
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
    def sshconn(self):
        if self._sshconn is None:
            self.logger.debug('create ssh to ip: <{0}> host_name: <{1}>'.format(self.ip, self.host_name))
            self._sshconn = SSHClient(self.ip, self._ssh_user, self._ssh_password)
            self._sshconn.connect()

        assert self._sshconn is not None, "get ssh to {0} fail".format(self._ip)
        return self._sshconn

    @sshconn.setter
    def sshconn(self, value):
        self._sshconn = value

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

def get_node(nodes, host):
    for node in nodes:
        if node.host_name == host or node.ip == host:
            return node
    assert False, 'Can not find node {0}'.format(host_name)

# get ssh by host or ip
def get_ssh(nodes, host):
    node = get_node(nodes, host)
    return node.sshconn

# get sftp by host or ip
def get_sftp(nodes, host):
    node = get_node(nodes, host)
    return node.get_sftp_connection()

