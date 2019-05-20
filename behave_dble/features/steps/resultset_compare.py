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
    # headings in form "columnName-columnIndex"
    col_idx_list = []
    for str in context.table.headings:
        assert str.rfind('-')!=-1, "context.table heading format error. expect:columnName-columnIndex"
        idx = int(str.split("-")[-1])
        col_idx_list.append(idx)

    rs = getattr(context, rs_name)
    for expect_row in context.table:
        isFound = False
        for rs_row in rs:
            for i in range(len(expect_row)):
                expect_col = expect_row[i]
                col_idx = col_idx_list[i]
                real_col = rs_row[col_idx]
                isFound = unicode(real_col) == unicode(expect_col)
                if not isFound: break
        assert not isFound, "expect line not in resultset {0}".format(rs_name)
        context.logger.info("expect row:{0}, not found".format(expect_row))

#once found expect, break loop
@Then('check resultset "{rs_name}" has lines with following column values')
def step_impl(context, rs_name):
    # headings in form "columnName-columnIndex"
    col_idx_list = []
    for str in context.table.headings:
        assert str.rfind('-')!=-1, "context.table heading format error. expect:columnName-columnIndex"
        idx = int(str.split("-")[-1])
        col_idx_list.append(idx)

    rs = getattr(context, rs_name)
    for expect_row in context.table:
        isFound = False
        for rs_row in rs:
            for i in range(len(expect_row)):
                col_idx = col_idx_list[i]
                real_col = rs_row[col_idx]
                if ( expect_row[i].rfind('+') != -1 ):
                    expect =expect_row[i].split("+")
                    expect_min = int(expect[0])
                    expect_max = int(expect[-1])+expect_min
                    real_col = int(real_col)
                    isFound = (real_col >= expect_min) and (real_col <= expect_max)
                    context.logger.info("col index:{0}, expect col_min:{1}<= real_col:{2}<=col_max:{3}".format(i, expect_min, real_col, expect_max))
                else:
                    expect_col = expect_row[i]
                    if (expect_row[i].rfind('$') != -1):
                        dble_version =  context.cfg_dble['ftp_path'].split('/')[-2]
                        expect_col = expect_col.replace("${version}",dble_version)
                    isFound = unicode(real_col) == unicode(expect_col)
                    # context.logger.debug("col index:{0}, expect col:{1}, real_col:{2}".format(i,expect_col,real_col))
                if not isFound: break
            if isFound: break
        assert isFound, "expect line not found in resultset {0}".format(rs_name)
        context.logger.info("expect row:{0}, is found".format(expect_row))
