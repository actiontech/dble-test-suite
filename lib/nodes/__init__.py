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
        self._sftp_conn = None

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
    return node.sftp_conn

