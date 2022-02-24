# -*- coding: utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2019/8/14 PM4:13
# @Author  : zhaohongjie@actionsky.com

import random

class SQLContext:
    # cols in form {col1:int, col2:char,...}
    # cols+targetCol = all table columns
    def __init__(self, table=None, cols=None, targetCol=None):
        self.table = table
        self.cols = cols
        self.targetCol = targetCol

    def get_columns_def(self):
        cols_str = ""
        if self.targetCol is not None:
            for k,v in self.cols.items():
                cols_str = cols_str + k + " " + v + ","

        if self.targetCol is not None:
            for k, v in self.targetCol.items():
                cols_str = cols_str + k + " " + v + ","

        assert len(cols_str)>0, "columns is empty!!! raw cols:{0}, raw targetCol: {1}".format(self.cols, self.targetCol)

        # delete the last useless ","
        cols_str = cols_str[:-1]
        return cols_str

    def get_prepare_sqls(self):
        cols_def = self.get_columns_def()

        prepare_sqls = [
            "drop table if exists {0}".format(self.table),
            "create table {0}({1})".format(self.table, cols_def)
        ]

        return prepare_sqls

    def get_after_sqls(self):
    #check CRUD success after large column or packet query
        after_sqls = [
            "create table if not exists zhj_test_tb(id int);",
            "insert into zhj_test_tb values(1);",
            "select * from zhj_test_tb;",
            "drop table zhj_test_tb"
        ]
        return after_sqls

    def get_int_value(self):
        return random.randint(1,100)

    def get_char_value(self):
        return "zhj"

    def get_bool_value(self):
        return 0

    def get_enum_value(self,type):
        # type in format: ENUM('x-small', 'small', 'medium', 'large', 'x-large')
        # 5 stands for length of "ENUM("
        # -1 stands for length of ")"
        enum_values_str = type[5:-1]
        enum_values = enum_values_str.split(",")
        return random.choice(enum_values)

    def get_cols_values(self):
        cols_values = []
        cols_types = self.cols.values()
        for type in cols_types:
            type = type.lower()
            if type.startswith("int"):
                value = self.get_int_value()
            elif type.startswith("char"):
                value = "'" + self.get_char_value() + "'"
            elif type.startswith("bool"):
                value = self.get_bool_value()
            elif type.startswith("enum"):
                value = self.get_enum_value(type)
            else:
                assert False, "column type: {0} is not supported!!!".format(type)

            cols_values.append(str(value))

        cols_values = ",".join(cols_values)
        print("other columns values: {0}".format(cols_values))
        return cols_values

    def generate_pre_post(self):
        cols_keys = ",".join(self.cols.keys())
        target_col_key = ",".join(self.targetCol.keys())

        cols_values = self.get_cols_values()

        pre = 'insert into {0}({1},{2}) values ({3},"'.format(self.table, cols_keys, target_col_key, cols_values)
        post = '")'

        return pre, post

    def get_size_char(self, size_in_byte):
        print("char size:{0}".format(size_in_byte))

        char = ""
        while size_in_byte > 0:
            size_in_byte = size_in_byte - 1
            char += "a"
        return char

    def get_large_query(self, size_in_byte, isColumnSize=True):
        """

        :param size_in_byte:
        :param isColumnSize: True means size_in_byte is column size, False means query size
        :return:
        """
        pre, post = self.generate_pre_post()

        if isColumnSize:
            size_char = size_in_byte
        else:
            size_char = size_in_byte - len(pre) - len(post)


        mid = self.get_size_char(size_char)
        large_query = pre + mid + post
        return large_query

    def get_queries(self, size_in_byte, isColumnSize=True):
        large_query = self.get_large_query(size_in_byte, isColumnSize)
        prepare_queries = self.get_prepare_sqls()
        after_queries = self.get_after_sqls()

        prepare_queries.append(large_query)

        queries = prepare_queries + after_queries

        return queries