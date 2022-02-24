# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import MySQLdb
import logging

from hamcrest.library.collection.isdict_containingkey import has_key

import json

from behave import *
from hamcrest import *
from lib.DBUtil import *
from lib.utils import get_node, get_ssh

LOGGER = logging.getLogger('root')

@Then('get {path} on zkCli.sh for {info} on dble-1')
def get_zk_meta_on_zkCli_sh(context, path, info):
    # zk_method : zk cmd means : ls ,get, rmr, set, config ... etc...you can run help on zkCli.sh for more info
    # /dble/cluster-1/conf/sharding
    # info is function name such as:enum_func
    # hostname is dble-1 ,dble-2,dble-3
    cmd = "cd {0}/bin && ./zkCli.sh get {1}|grep '{2}'".format(context.cfg_zookeeper['home'], path, info)
    # node = str(hostname)
    cmd_ssh = get_ssh("dble-1")
    rc, sto, ste = cmd_ssh.exec_command(cmd)
    func_name = []
    assert_that(sto, not_(empty()), "sto is not empty and it is : {0}".format(sto))
    LOGGER.debug("the sto is empty : {0}".format(sto))
    outcome_dict = json.loads(sto)
    LOGGER.debug("add debug to check the result of executing {0} is :sto:{1}".format(cmd, outcome_dict))
    assert_that(outcome_dict, has_key("function"), "we have a key named function and they are:{0}".format(outcome_dict))
    LOGGER.debug("{0} function is : {1} ".format(path, outcome_dict.get('function')))
    func_list = outcome_dict['function']
    for func_obj in func_list:
        if func_obj.get('name'):
            LOGGER.debug("{0} function is : {1} ".format(path, func_obj.get('name')))
            func_name.append(func_obj['name'])
        else:
            LOGGER.debug("there are no keys named name in {0} ".format(path))
    LOGGER.debug("we find function name are : {0}".format(func_name))
    return func_name

















