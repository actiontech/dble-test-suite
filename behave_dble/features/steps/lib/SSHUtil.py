# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import paramiko

from . Logging import Logging


class SSHClient(Logging):
    def __init__(self, host, user, password):
        super(SSHClient, self).__init__()
        self._host = host
        self._user = user
        self._password = password
        self._ssh = None

    def connect(self):
        self.logger.info('Create ssh client for ip <{0}>'.format(self._host))
        self._ssh = paramiko.SSHClient()
        self._ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self._ssh.connect(self._host, port=22, username=self._user, password=self._password, timeout=60)

    def exec_command(self, command, timeout=60):
        stdin, stdout, stderr = self._ssh.exec_command(command, timeout=timeout)
        rc = stdout.channel.recv_exit_status()
        sto = stdout.read().strip('\n')
        ste = stderr.read().strip('\n')
        self.logger.debug('<{0}>: Execute command: <{1}> '
                          'Return code <{2}>, Stdout[0:200]: <{3}>, Stderr <{4}>'.format(self._host, command, rc, sto[0:200], ste))
        return rc, sto, ste

    def close(self):
        self.logger.info('<{0}>: close ssh client'.format(self._host))
        if self._ssh:
            self._ssh.close()


class SFTPClient(Logging):
    def __init__(self, host, user, password, port=22):
        super(SFTPClient, self).__init__()
        self._host = host
        self._user = user
        self._password = password
        self._sftp_ssh = None
        self.port = port

    def sftp_connect(self):
        try:
            self.logger.info('Create ssh sftp client for ip <{0}>'.format(self._host))
            t = paramiko.Transport((self._host, self.port))
            t.connect(username = self._user, password = self._password)
            self._sftp_ssh = paramiko.SFTPClient.from_transport(t)
        except Exception, e:
            raise

    def sftp_put(self, local_path, remote_path):
        try:
            self.logger.info('sftp put local_path:{1}, remote_path:{0}'.format(remote_path, local_path))
            self._sftp_ssh.put(local_path, remote_path)
        except Exception, e:
            self.logger.debug("sftp put exception: {0}".format(e.message))
            raise

    def sftp_get(self, remote_path, local_path):
        try:
            self.logger.info('sftp get remote_path:{0}, local_path:{1}'.format(remote_path, local_path))
            self._sftp_ssh.get(remote_path, local_path)
        except Exception, e:
            self.logger.debug("sftp get exception: {0}".format(e.message))
            raise

    def sftp_close(self):
        try:
            self._sftp_ssh.close()
        except:
            raise

# if __name__ == '__main__':
#     remoteip = '172.100.9.1'
#     username = 'root'
#     password = 'sshpass'
#     port = '22'
#     remote_des_file = '/home/test'
#     local_des_file = '/home/test'
#     csftp = SFTPClient(remoteip, username, password, int(port))
#     csftp.sftp_connect()
#     csftp.sftp_put(remote_des_file, local_des_file)