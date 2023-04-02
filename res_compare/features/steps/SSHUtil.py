# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import logging
from steps.Logging import Logging
from typing import List, Optional, Tuple
import os,stat
import paramiko
import time

LOGGER = logging.getLogger()

class NotInitializedConnectionError(Exception):
    pass

class SSHClient:
    def __init__(self, host: str, user: str, password: str):
        self._host: str = host
        self._user: str = user
        self._password: str = password
        self._ssh: Optional[paramiko.SSHClient] = None

    def connect(self, **kwargs) -> None:
        self._ssh = paramiko.SSHClient()
        self._ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        default = {'hostname': self._host, 'port': 22, 'username': self._user, 'password': self._password,
                'timeout': 60}
        if kwargs and isinstance(kwargs, dict):
            default.update(kwargs)
        LOGGER.debug(f'Create ssh connect : <{default}>')
        retry = 10
        while retry > 0:
            try:
                self._ssh.connect(**default)
            except Exception as e:
                retry -= 1
                time.sleep(2)
                LOGGER.debug(f'create connect: <{default}> failed { 10- retry} times \n {e}')
                continue
            else:
                LOGGER.debug(f'connect success <{default}>')
                break

    def exec_command(self, command: str, timeout: int = 60, **kwargs) -> Tuple[int, str, str]:
        if self._ssh is not None:
            LOGGER.info(f'<{self._host}>: Execute command: <{command}>')
            _, stdout, stderr = self._ssh.exec_command(
                command, timeout=timeout, **kwargs)
            rc = stdout.channel.recv_exit_status()
            sto = stdout.read().decode().strip('\n')
            ste = stderr.read().decode().strip('\n')
            LOGGER.debug(f'<{self._host}>: Execute command: <{command}> Return code: <{rc}>, Stdout: <{sto}>, Stderr: <{ste}>')
            return rc, sto, ste
        raise NotInitializedConnectionError('Not Initialized ssh Connection')

    def _open_sftp(self) -> paramiko.sftp_client.SFTPClient:
        if self._ssh is not None:
            return self._ssh.open_sftp()
        raise NotInitializedConnectionError('Not Initialized ssh Connection')

    def put(self, local_path: str, remote_path: str, **kwargs) -> None:
        LOGGER.info(f'<{self._host}>: sftp put local <{local_path}> to remote <{remote_path}>')
        with self._open_sftp() as sftp:
            sftp.put(local_path, remote_path, **kwargs)

    def get(self, remote_path: str, local_path: str, **kwargs) -> None:
        LOGGER.info(f'<{self._host}>: sftp get remote <{remote_path}> to local <{local_path}>')
        with self._open_sftp() as sftp:
            sftp.get(remote_path, local_path, **kwargs)

    def put_dir(self, local_dir: str, remote_dir: str):
        LOGGER.info(f'<{self._host}>: sftp put local dir <{local_dir}> to remote dir <{remote_dir}>')
        local_dir = local_dir.rstrip('/')
        remote_dir = remote_dir.rstrip('/')
        all_files = self._get_all_files_in_local_dir(local_dir)

        self.exec_command(f'[ -d {remote_dir} ] && echo 0 || mkdir -p {remote_dir}')

        with self._open_sftp() as sftp:
            for local_fp in all_files:
                local_fn = local_fp.removeprefix(local_dir + '/')
                remote_fp = os.path.join(remote_dir, local_fn)
                if len(local_fn.split(os.path.sep)) > 1:
                    dp = os.path.dirname(remote_fp)
                    self.exec_command(f'[ -d {dp} ] && echo 0 || mkdir -p {dp}')
                LOGGER.info(f'<{self._host}>: sftp put local <{local_fp}> to remote <{remote_fp}>')
                sftp.put(local_fp, remote_fp)


    def get_dir(self, remote_dir: str, local_dir: str):
        LOGGER.info(f'<{self._host}>: sftp get remote dir <{remote_dir}> to local dir <{local_dir}>')
        local_dir = local_dir.rstrip('/')
        remote_dir = remote_dir.rstrip('/')
        all_files = self._get_all_files_in_remote_dir(remote_dir)

        if not os.path.exists(local_dir):
            os.makedirs(local_dir)

        with self._open_sftp() as sftp:
            for remote_fp in all_files:
                remote_fn = remote_fp.removeprefix(remote_dir + '/')
                local_fp = os.path.join(local_dir, remote_fn)
                if len(remote_fn.split(os.path.sep)) > 1:
                    dp = os.path.dirname(local_fp)
                    if not os.path.exists(dp):
                        os.makedirs(dp)
                LOGGER.info(f'<{self._host}>: sftp get remote <{remote_fp}> to local <{local_fp}>')
                sftp.get(remote_fp, local_fp)

    def _get_all_files_in_local_dir(self, local_dir):
        all_files = []
        local_dir = local_dir.rstrip('/')

        files = os.listdir(local_dir)
        for f in files:
            fp = os.path.join(local_dir, f)
            if os.path.isdir(fp):
                all_files.extend(self._get_all_files_in_local_dir(fp))
            else:
                all_files.append(fp)
        return all_files

    def _get_all_files_in_remote_dir(self, remote_dir: str) -> List[str]:
        all_files = []
        remote_dir = remote_dir.rstrip('/')

        with self._open_sftp() as sftp:
            files = sftp.listdir_attr(remote_dir)
            for f in files:
                fp = os.path.join(remote_dir, f.filename)
                if stat.S_ISDIR(f.st_mode):
                    all_files.extend(self._get_all_files_in_remote_dir(fp))
                else:
                    all_files.append(fp)
            return all_files

    def close(self) -> None:
        if self._ssh is not None:
            self._ssh.close()
            LOGGER.debug(f'close ssh client: <{self._host}>')
        else:
            LOGGER.debug(f'ssh client is already closed: <{self._host}>')

    @property
    def host(self) -> str:
        return self._host



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
        except Exception as e:
            raise

    def sftp_put(self, local_path, remote_path):
        try:
            self.logger.info('sftp put local_path:{1}, remote_path:{0}'.format(remote_path, local_path))
            self._sftp_ssh.put(local_path, remote_path)
        except Exception as e:
            self.logger.debug("sftp put exception: {0}".format(e.message))
            raise

    def sftp_get(self, remote_path, local_path):
        try:
            self.logger.info('sftp get remote_path:{0}, local_path:{1}'.format(remote_path, local_path))
            self._sftp_ssh.get(remote_path, local_path)
        except Exception as e:
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