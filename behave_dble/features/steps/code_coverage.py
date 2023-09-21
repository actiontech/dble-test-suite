# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.

import os
import logging
import time
from behave import *
from hamcrest import *
from steps.lib.DbleMeta import DbleMeta

logger = logging.getLogger('root')


@Given('check code coverage and change bootstrap conf')
def init_code_coverage_conf(context):
    code_coverage = context.config.userdata["code_coverage"].lower()
    logger.debug(f"code_coverage is {code_coverage}")

    code_conf_str = '-javaagent:lib/jacocoagent.jar=output=file,append=true,destfile=/opt/dble/logs/dble_jacoco.exec'
    files = os.listdir('dble_conf')
    for file in files:
        if file.endswith('_bk'):
            filename = "dble_conf/" + file + "/bootstrap.cnf"

            if code_coverage == "true":
                with open(filename, 'a', encoding='utf-8') as fp:
                    fp.write('\n')
                    fp.write(code_conf_str)
                logger.debug(f"{filename} add code coverage config end")

            else:
                with open(filename, 'r', encoding='utf-8') as fp:
                    content = fp.read()
                    index = content.find(code_conf_str)
                    if index != -1:
                        new_content = content.replace(code_conf_str, '')
                        with open(filename, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        logger.debug(f"{filename} remove code coverage config end")
                    else:
                        logger.debug(f"{filename} no code coverage config")


@Given('execute command to general code coverage html report')
def general_jacoco_report(context):
    dble_remote_host = context.test_conf.get('dble_remote_host')
    code_coverage = context.config.userdata["code_coverage"].lower()
    logger.debug(f"general html repport code_coverage is {code_coverage}")

    if code_coverage == "true" and dble_remote_host.startswith('ftp'):
        ftp_user = context.test_conf.get('ftp_user')
        ftp_passwd = context.test_conf.get('ftp_password')
        dble_version = context.test_conf['dble_version']
        dble_remote_path = context.test_conf["dble_remote_path"].format(DBLE_VERSION=dble_version)
        remote_path = f'{context.test_conf["dble_remote_host"]}{dble_remote_path}'
        source_jar = f'dble-{dble_version}-sources.jar'
        source_path = f'{os.path.dirname(remote_path)}/{source_jar}'

        for node in DbleMeta.dbles:
            logger.debug('download dble source jar begin')
            kwargs = {'local': f'{node.install_dir}/dble/logs/{source_jar}', 'remote': source_path, 'u': ftp_user,
                      'p': ftp_passwd}
            wget_cmd = 'wget -q -O {local} --ftp-user={u} --ftp-password={p} {remote}'.format(**kwargs)
            rc, _, ste = node.ssh_conn.exec_command(wget_cmd)
            logger.debug('download dble source jar end')
            assert_that(rc, equal_to(0), ste)

            logger.debug('copy jacococli.jar begin')
            local_jar = f"{os.getcwd()}/assets/jacococli.jar"
            remote_jar = f"{node.install_dir}/dble/lib/jacococli.jar"
            node.sftp_conn.sftp_put(local_jar, remote_jar)
            logger.debug('copy jacococli.jar end')

            logger.debug('general html report begin')
            report_cmd = f"java -jar {node.install_dir}/dble/lib/jacococli.jar " \
                         f"report {node.install_dir}/dble/logs/dble_jacoco.exec " \
                         f"--classfiles {node.install_dir}/dble/lib/dble-{dble_version}.jar " \
                         f"--sourcefiles {node.install_dir}/dble/logs/{source_jar} " \
                         f"--html {node.install_dir}/dble/logs/code_coverage"
            rc, _, ste = node.ssh_conn.exec_command(report_cmd)
            logger.debug('general html report end')
            assert_that(rc, equal_to(0), ste)

            datetime = time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())
            tar_cmd = f"cd {node.install_dir}/dble/logs && tar -zcf code_coverage_{datetime}.tar.gz code_coverage"
            rc, sto, ste = node.ssh_conn.exec_command(tar_cmd)
            assert_that(len(ste) == 0, "tar dble code coverage failed for: {0}".format(ste))
