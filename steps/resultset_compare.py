# -*- coding: utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
# @Time    : 2018/8/24 PM2:52
# @Author  : zhaohongjie@actionsky.com

import re
from behave import *
from hamcrest import *

@Then('check resultsets "{rs_A_name}" and "{rs_B_name}" are same in following columns')
def step_impl(context, rs_A_name, rs_B_name):
    rs_A = getattr(context, rs_A_name)
    rs_B = getattr(context, rs_B_name)
    assert len(rs_A)==len(rs_B), "len {0}:{2}, and len {1}:{3}, expect length equal.".format(rs_A_name, rs_B_name,len(rs_A), len(rs_B))
    for rowA, rowB in zip(rs_A, rs_B):
        for row in context.table:
            idx = int(row['column_index'])
            assert rowA[idx] == rowB[idx], "{0} and {1} are not same in column {2}".format(rowA, rowB, row["column"])


@Then('check resultsets "{rs_parent_name}" including resultset "{rs_child_name}" in following columns')
def step_impl(context, rs_parent_name, rs_child_name):
    rs_parent = getattr(context, rs_parent_name)
    rs_child = getattr(context, rs_child_name)
    for row_child in rs_child:
        isFound = False
        for row_parent in rs_parent:
            for row_idx in context.table:
                idx = int(row_idx['column_index'])
                isFound = str(row_parent[idx]) == str(row_child[idx])
                if not isFound: break
            if isFound: break
        assert isFound, "expect {0} row {1} found in {2}".format(rs_child_name, row_child, rs_parent_name)

@Then('check resultsets "{rs_A_name}" does not including resultset "{rs_B_name}" in following columns')
def step_impl(context, rs_A_name, rs_B_name):
    rs_A = getattr(context, rs_A_name)
    rs_B = getattr(context, rs_B_name)
    for row_B in rs_B:
        isFound = True
        for row_A in rs_A:
            for row_idx in context.table:
                idx = int(row_idx['column_index'])
                isFound = row_A[idx] == row_B[idx]
                if not isFound: break
            assert not isFound, "expect {0} row {1} not found in {2}".format(rs_B_name, row_child, rs_A_name)

#loop all rows confirm not exist, once exist, throw assertion error
@Then('check resultset "{rs_name}" has not lines with following column values')
def step_impl(context, rs_name):
    rs = getattr(context, rs_name)
    for rs_row in rs:
        isFound = False
        for row in context.table:
            idx = int(row["column_index"])
            val = row["value"]
            isFound = val == rs_row[idx]
            if not isFound: break
        assert not isFound, "expect {0} not in resultset of {1}".format(rs_row, rs_name)

#once found expect, break loop
@Then('check resultset "{rs_name}" has lines with following column values')
def step_impl(context, rs_name):
    rs = getattr(context, rs_name)
    isFound = False
    for rs_row in rs:
        isFound = False
        for row in context.table:
            idx = int(row["column_index"])
            val = row["value"]
            isFound = str(val) == str(rs_row[idx])
            if not isFound: break
        if isFound: break
    assert isFound, "expect line not found in resultset {0}".format(rs_name)