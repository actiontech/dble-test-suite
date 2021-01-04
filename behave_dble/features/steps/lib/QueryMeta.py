# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/5 上午11:16
# @Author  : irene-coming

class QueryMeta(object):
    def __init__(self, info_dict, mode, meta):
        if mode == "mysql":
            self.init_mysql_query_meta(info_dict, meta)
        elif mode == "admin":
            self.init_dble_admin_query_meta(info_dict, meta)
        elif mode == "user":
            self.init_dble_client_query_meta(info_dict, meta)
        else:
            assert False, "execute queries mode can only be one of [mysql, admin, user], but mode is '{}'".format(mode)

    def init_mysql_query_meta(self, info_dic, meta):
        if info_dic is None: info_dic = {}

        self._user = info_dic.get("user", meta.mysql_user)
        self._passwd = str(info_dic.get("passwd", meta.mysql_password))
        self._port = info_dic.get("port", meta.mysql_port)
        self._ip = info_dic.get("ip", meta.ip)

        self._bClose = info_dic.get("toClose", "true")
        self._charset = info_dic.get("charset", None)
        self._conn_id = info_dic.get("conn", None)
        self._expect = info_dic.get("expect", "success")
        self._db = info_dic.get("db", "")
        self._sql = info_dic.get("sql")

    def init_dble_admin_query_meta(self, info_dic, meta):
        if info_dic is None: info_dic = {}

        self._user = info_dic.get("user", meta.manager_user)
        self._passwd = str(info_dic.get("passwd", meta.manager_password))
        self._port = info_dic.get("port", meta.manager_port)
        self._ip = info_dic.get("ip", meta.ip)

        self._bClose = info_dic.get("toClose","true")
        self._charset = info_dic.get("charset", None)
        self._conn_id = info_dic.get("conn", None)
        self._expect = info_dic.get("expect", "success")
        self._db = info_dic.get("db", "")
        self._sql = info_dic.get("sql")

    def init_dble_client_query_meta(self, info_dic, meta):
        if info_dic is None: info_dic = {}

        self._user = info_dic.get("user",meta.client_user)
        self._passwd = str(info_dic.get("passwd", meta.client_password))
        self._port = info_dic.get("port",meta.client_port)
        self._ip = info_dic.get("ip", meta.ip)

        self._bClose = info_dic.get("toClose", "true")
        self._charset = info_dic.get("charset", None)
        self._conn_id = info_dic.get("conn", None)
        self._expect = info_dic.get("expect", "success")
        self._db = info_dic.get("db", "")
        self._sql = info_dic.get("sql")

    @property
    def user(self):
        return self._user

    @property
    def passwd(self):
        return self._passwd

    @property
    def port(self):
        return self._port

    @property
    def ip(self):
        return self._ip

    @property
    def bClose(self):
        return self._bClose

    @property
    def charset(self):
        return self._charset

    @property
    def conn_id(self):
        return self._conn_id

    @property
    def expect(self):
        return self._expect

    @property
    def db(self):
        return self._db

    @property
    def sql(self):
        return self._sql