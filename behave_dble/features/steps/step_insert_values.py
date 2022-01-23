# -*- coding: utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2018/5/3 PM4:44
# @Author  : zhaohongjie@actionsky.com
from SqlUtil import do_exec_sql
from lib.generate_util import generate


@Given('create table for insert')
def step_impl(context):
    ip = context.cfg_dble['dble']['ip']
    port = context.cfg_dble['client_port']

    sql = "drop table if exists test_table"
    do_exec_sql(context, ip, "test", "111111", "schema1", port, sql, False, "conn_0", "success")

    sql="""CREATE TABLE `test_table` (
        `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
        `k` int(10) unsigned NOT NULL DEFAULT '0',
        `c` char(10) NOT NULL DEFAULT '',
        `pad` char(60) NOT NULL DEFAULT '',
        PRIMARY KEY (`id`),
        KEY `k_1` (`k`)
        )"""
    do_exec_sql(context, ip, "test", "111111", "schema1", port, sql, True, "conn_0", "success")

@Then('insert "{num}" rows at one time')
def step_impl(context, num):
    sql = "insert into test_table values"
    gen = generate()
    value_nu = int(num)
    for i in range(1, value_nu):
        c_str = gen.rand_string(10)
        pad_str = gen.rand_string(60)
        sql += "({0}, {0}, '{1}', '{2}'),".format(i, c_str, pad_str)

    c_str = gen.rand_string(10)
    pad_str = gen.rand_string(60)
    sql += "({0}, {0}, '{1}', '{2}')".format(i+1, c_str, pad_str)

    ip = context.cfg_dble['dble']['ip']
    port = context.cfg_dble['client_port']
    do_exec_sql(context, ip, "test", "111111", "schema1", port, sql, True, "conn_0", "success")

