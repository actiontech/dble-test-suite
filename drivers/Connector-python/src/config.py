# -*- coding: UTF-8 -*-
import yaml
import os

def getConfig(conf_path):
    os.chdir(conf_path)
    f = open("auto_dble_test.yaml")
    yconf = yaml.load(f)
    # return yconf

    cfg_dble = yconf['cfg_dble']
    dble_host = '10.186.31.25'
    dble__port = 7131
    dble_user = cfg_dble['client_user']
    dble_passwd = str(cfg_dble['client_password'])
    dble_database = 'schema1'

    cfg_mysql = yconf['cfg_mysql']
    mysql_host = '10.186.31.25'
    mysql_port = 7144
    mysql_user = cfg_mysql['user']
    mysql_passwd = str(cfg_mysql['password'])
    mysql_database = 'schema1'


    dble_config = {
        'host': dble_host,
        'port': dble__port,
        'user': dble_user,
        'passwd': dble_passwd,
        'database': dble_database
    }
    mysql_config = {
        'host': mysql_host,
        'port': mysql_port,
        'user': mysql_user,
        'passwd': mysql_passwd,
        'database': mysql_database
    }
    return dble_config,mysql_config

# aa = getConfig('C:\Users\ThinkPad\dble\conf')
#
# print aa