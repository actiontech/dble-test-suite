# -*- coding: utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2018/8/24 PM2:52
# @Author  : zhaohongjie@actionsky.com

import re
from behave import *
from hamcrest import *
from fnmatch import fnmatchcase

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
            assert not isFound, "expect {0} row {1} not found in {2}".format(rs_B_name, row_B, rs_A_name)

#loop all rows confirm not exist, once exist, throw assertion error
@Then('check resultset "{rs_name}" has not lines with following column values')
def step_impl(context, rs_name):
    # headings in form "columnName-columnIndex"
    col_idx_list = []
    for str1 in context.table.headings:
        assert str1.rfind('-')!=-1, "context.table heading format error. expect:columnName-columnIndex"
        idx = int(str1.split("-")[-1])
        col_idx_list.append(idx)

    rs = getattr(context, rs_name)
    for expect_row in context.table:
        isFound = False
        for rs_row in rs:
            for i in range(len(expect_row)):
                expect_col = expect_row[i]
                col_idx = col_idx_list[i]
                real_col = rs_row[col_idx]
                isFound = str(real_col) == str(expect_col)
                if not isFound: break
            assert not isFound, "expect line not in resultset {0}".format(rs_name)
        context.logger.debug("expect row:{0}, not found".format(expect_row))

#once found expect, break loop
@Then('check resultset "{rs_name}" has lines with following column values')
def step_impl(context, rs_name):

    col_idx_list = []
    check_line =False

    for str1 in context.table.headings:
        if str1.rfind('expect_result_line')!=-1:
            check_line =True
            continue
        else:
            # headings in form "columnName-columnIndex"
            assert str1.rfind('-')!=-1, "context.table heading format error. expect:columnName-columnIndex"
            idx = int(str1.split("-")[-1])
            col_idx_list.append(idx)

    rs = getattr(context, rs_name)
    for expect_row in context.table:
        isFound = False
        real_line = 0
        expect_line = 0
        for rs_row in rs:
            real_line = real_line +1
            for i in range(len(expect_row)):
                if check_line: #need to check the number of rows,the comparison need to start from the second column
                    col_idx = col_idx_list[i - 1]
                else:
                    col_idx = col_idx_list[i]

                if expect_row[i].rfind('expect_result_line:') != -1: #Get the expected number of rows when comparing the number of rows
                    expect_line = int(expect_row[i].split(":")[-1])
                    continue

                real_col = rs_row[col_idx]
                if expect_row[i].rfind('+') != -1: #actual result tolerance,in the format:"expect_result+tolerance_scope"
                    expect = expect_row[i].split("+")
                    expect_min = int(expect[0])
                    expect_max = int(expect[-1])+expect_min
                    real_col = int(real_col)
                    isFound = (real_col >= expect_min) and (real_col <= expect_max)
                    context.logger.debug("col index:{0}, expect col_min:{1}<= real_col:{2}<=col_max:{3}".format(i, expect_min, real_col, expect_max))
                else:
                    expect_col = expect_row[i]
                    if expect_col.rfind('/*AllowDiff*/') != -1:
                        isFound = True
                    # allow expect line can have multi possibilities
                    elif expect_col.rfind("//") != -1:
                        expect = expect_col.split("//")
                        for x in expect:
                            if str(real_col).strip() == str(x).strip():
                                # context.logger.debug("isFound:true")
                                isFound = True
                                # context.logger.info("col index:{0}, expect col:{1}, real_col:{2}".format(i, x, real_col))
                                break
                            else:
                                isFound = False
                    elif expect_row[i].rfind('[0-9].[0-9]') != -1:
                        # dble_version =  context.cfg_dble['ftp_path'].split('/')[-2]
                        # expect_col = expect_col.replace("${version}",dble_version)
                        isFound = fnmatchcase(real_col,expect_col)
                        context.logger.info(
                            "col index:{0}, expect col:{1}, real_col:{2}".format(i, expect_col, real_col))
                    elif check_line:
                        isFound = (str(real_col) == str(expect_col)) and (real_line == expect_line)
                    else:
                        isFound = (str(real_col).strip() == str(expect_col).strip())
                        # context.logger.debug("col index:{0}, expect col:{1}, real_col:{2}".format(i,expect_col,real_col))
                if not isFound: break
            if isFound: break
        assert isFound, "expect line '{}' not found in resultset {}".format(expect_row, rs_name)
        context.logger.info("expect row:{0}, is found".format(expect_row))

@Then('check "{rs_name}" only has "{num}" connection of "{host}"')
def step_impl(context,rs_name,num,host):
    rs = getattr(context, rs_name)
    stoList = re.findall(host,str(rs))
    assert str(len(stoList)) == num, "expect only has {0} {1} connection, but has {2}".format(num,host,len(stoList))


@Then('check "{rs_name1}" is calculated by "{rs_name2}" according to a certain relationship with "{table_type}"')
def step_impl(context, rs_name1, rs_name2, table_type):
    rs1 = getattr(context, rs_name1)
    rs2 = getattr(context, rs_name2)
    if table_type == "sharding_table":
        expect_num = int((500000 - rs2[0][0])/50000)
    else:
        expect_num = int((1000000 - rs2[0][0])/50000)
    assert int(rs1) == expect_num, "expect file num is {0}, but is {1}".format(expect_num, rs1)
