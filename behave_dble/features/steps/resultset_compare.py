# -*- coding: utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
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
    assert len(rs_A)==len(rs_B), "len {}:{}, and len {}:{}, expect length equal.\n{} is {} ,\n{} is {}".format(rs_A_name, len(rs_A), rs_B_name, len(rs_B), rs_A_name, rs_A, rs_B_name, rs_B)
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
        assert isFound, "expect '{}' row {} found in '{}',but \n'{}' is {},\n'{}' is {}".format(rs_child_name, row_child, rs_parent_name, rs_parent_name, rs_parent, rs_child_name, rs_child)

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
            assert not isFound, "expect '{}' row {} not found in '{}',but \n'{}' is {},\n'{}' is {}".format(rs_B_name, row_B, rs_A_name, rs_A_name, rs_A, rs_B_name, row_B)

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
            assert not isFound, "expect line '{}' not in resultset '{}',but '{}' is \n{}".format(expect_row, rs_name, rs_name, "\n".join(map(str, rs)))
        context.logger.debug("expect row:{0}, not found".format(expect_row))


@Then('check resultset "{rs_name}" has lines with following column values')
@Then('check resultset "{rs_name}" has lines with following column values and has "{exp_line}" lines')
def step_impl(context, rs_name, exp_line=0):
    col_idx_list = []
    check_line = False

    for str1 in context.table.headings:
        if str1.rfind('expect_result_line') != -1:
            check_line = True
            continue
        else:
            # headings in form "columnName-columnIndex"
            assert str1.rfind('-') != -1, "context.table heading format error. expect:columnName-columnIndex"
            idx = int(str1.split("-")[-1])
            col_idx_list.append(idx)

    rs = getattr(context, rs_name)
    if exp_line != 0:
        actual_lines = len(rs) #先记录结果集的行数
        assert int(actual_lines) == int(exp_line), "Actual lines: {}, Expected lines: {}, \nThe actual result is:\n{}".format(actual_lines, exp_line, "\n".join(map(str, rs)))

    not_found = []  # 记录没有找到的期望行
    for expect_row in context.table:
        isFound = False
        real_line = 0
        expect_line = 0
        for rs_row in rs:
            real_line = real_line + 1
            for i in range(len(expect_row)):
                if check_line:  # need to check the number of rows,the comparison need to start from the second column
                    col_idx = col_idx_list[i - 1]
                else:
                    col_idx = col_idx_list[i]

                if expect_row[i].rfind('expect_result_line:') != -1:  # Get the expected number of rows when comparing the number of rows
                    expect_line = int(expect_row[i].split(":")[-1])
                    continue

                real_col = rs_row[col_idx]
                if expect_row[i].rfind('+') != -1:  # actual result tolerance,in the format:"expect_result+tolerance_scope"
                    expect = expect_row[i].split("+")
                    expect_min = int(expect[0])
                    expect_max = int(expect[-1]) + expect_min
                    real_col = int(real_col)
                    isFound = (real_col >= expect_min) and (real_col <= expect_max)
                    context.logger.debug("col index:{0}, expect col_min:{1}<= real_col:{2}<=col_max:{3}".format(i, expect_min, real_col,expect_max))
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
                    # 忽略结果字母大小写的检验
                    elif expect_col.rfind('/*IGNORECASE*/') != -1:
                        expect = expect_col.replace('/*IGNORECASE*/', '')
                        if real_col.lower() == expect.lower():
                            isFound = True
                            break
                        else:
                            isFound = False

                    elif expect_row[i].rfind('[0-9].[0-9]') != -1:
                        isFound = fnmatchcase(real_col, expect_col)
                        context.logger.debug("col index:{0}, expect col:{1}, real_col:{2}".format(i, expect_col, real_col))
                    elif check_line:
                        isFound = (str(real_col) == str(expect_col)) and (real_line == expect_line)
                    else:
                        isFound = (str(real_col).strip() == str(expect_col).strip())
                        # context.logger.debug("col index:{0}, expect col:{1}, real_col:{2}".format(i,expect_col,real_col))
                if not isFound:
                    break
            if isFound:
                break
        if not isFound:
            not_found.append(expect_row)  # 将没有找到的期望行加入列表
        else:
            context.logger.debug("expect row:{0}, is found".format(expect_row))

    if not_found:  # 如果有数据行没有找到，则抛出异常
        assert False, "Opps!! in resultset '{1}' not found row\n{0}, \nThe actual result is:\n{2}".format("\n".join(map(str, not_found)), rs_name, "\n".join(map(str, rs)))



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
