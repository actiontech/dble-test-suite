# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午3:54
# @Author  : irene-coming
import logging
import re
import operator
import collections
import time

from steps.ObjectFactory import ObjectFactory
from hamcrest import *

logger = logging.getLogger('root')


class PostQueryCheck(object):
    def __init__(self, real_res, real_err=None, time_cost=0, query_meta=None):
        self._expect = query_meta.expect
        self._real_res = real_res
        self._real_err = real_err
        self._time_cost = time_cost
        self._sql = query_meta.sql

    def check_result(self):
        while True:
            if self._expect == "success":
                logger.debug("sql: {0}, expect no err, but outcomes: {1}".format(self._sql, self._real_err))
                assert self._real_err is None, "sql: {0}, expect no err, but outcomes '{1}'".format(self._sql, self._real_err)
                break
            dest_host = re.search(r'dest_node:(.*)', self._expect, re.I)
            if dest_host:
                shardings_host = dest_host.group(1)
                if self._sql.lower().startswith("insert into"):
                    target = self._sql.split("values")[1]
                else:
                    target = self._sql

                mysql = ObjectFactory.create_mysql_object(shardings_host)
                mysql.check_query_in_general_log(target, expect_exist=True)
                break

            hasObj = re.search(r"has\{(.*?)\}", self._expect, re.I)
            if hasObj:
                assert_that(self._real_err is None, "sql: {0}, expect query success, but failed for '{1}'".format(self._sql, self._real_err))
                expectRS = hasObj.group(1)
                logger.debug("sql: {0}, expect resultSet:{1}, real resultSet:{2}".format(self._sql, eval(expectRS), self._real_res))
                self.hasResultSet(self._real_res, expectRS, True)
                break

            hasnotObj = re.search(r"hasnot\{(.*?)\}", self._expect, re.I)
            if hasnotObj:
                assert_that(self._real_err is None, "sql: {0}, expect query success, but failed for '{1}'".format(self._sql, self._real_err))
                notExpectRS = hasnotObj.group(1)
                logger.debug("sql: {0}, not expect resultSet:{1}, real resultSet:{2}".format(self._sql, eval(notExpectRS), self._real_res))
                self.hasResultSet(self._real_res, notExpectRS, False)
                break

            lengthObj = re.search(r"length\{(.*?)\}", self._expect, re.I)
            if lengthObj:
                assert_that(self._real_err is None, "sql: {0}, expect query success, but failed for '{1}'".format(self._sql, self._real_err))
                expectRS = lengthObj.group(1)
                logger.debug(
                    "sql: {0}, expect resultSet:{1}, length equal to real resultSet length:{2}".format(self._sql, eval(expectRS), len(self._real_res)))
                assert_that(len(self._real_res), equal_to(eval(expectRS)), "sql:{0}, resultSet records count is not as expected".format(self._sql))
                break

            matchObj = re.search(r"match\{(.*?)\}", self._expect, re.I)
            if matchObj:
                assert_that(self._real_err is None, "sql:{0}, expect query success, but failed for '{1}'".format(self._sql, self._real_err))
                match_Obj = matchObj.group(1)
                logger.debug("expect match_obj:{0}".format(match_Obj))
                match_Obj_Split = re.split(r'[;,\s]', str(match_Obj.encode('ascii')))
                logger.debug("expect match_Obj_Split:{0}".format(match_Obj_Split))
                self.matchResultSet(self._real_res, match_Obj_Split, len(match_Obj_Split) - 1)
                break

            isBalance = re.search(r"balance\{(.*?)\}", self._expect, re.I)
            if isBalance:
                assert_that(self._real_err is None, "sql: {0}, expect query success, but failed for '{1}'".format(self._sql, self._real_err))
                bal_res = isBalance.group(1)
                if "," in bal_res:
                    bal_num=bal_res.split(",")[0]
                    bal_per=bal_res.split(",")[1]
                else:
                    bal_num=bal_res
                    bal_per=0.2    
                self.balance(self._real_res, int(bal_num),float(bal_per))
                break

            hasString = re.search(r"hasStr\{(.*?)\}", self._expect, re.I)
            if hasString:
                assert_that(self._real_err is None, "sql: {0}, expect query success, but failed for '{1}'".format(self._sql, self._real_err))
                expectRS = hasString.group(1)
                assert_that(str(self._real_res), contains_string(str(expectRS)),
                            "sql: {0}, expect resultSet containing text: {1}, resultSet:{2}".format(self._sql, expectRS, self._real_res))
                break

            hasNoString = re.search(r"hasNoStr\{(.*?)\}", self._expect, re.I)
            if hasNoString:
                assert_that(self._real_err is None, "sql: {0}, expect query success, but failed for '{1}'".format(self._sql, self._real_err))
                notExpectRS = hasNoString.group(1)
                assert str(notExpectRS) not in str(self._real_res), "sql: {0}, resultSet:{1}, expect not containing text: {2},".format(self._sql, self._real_res, notExpectRS)
                break

            executeTime = re.search(r"execute_time\{(.*?)\}", self._expect, re.I)
            if executeTime:
                expectRS = executeTime.group(1)
                duration = self._time_cost.seconds
                logger.debug("sql: {0}, expect duration is :{1},real duration is{2} ".format(self._sql, eval(expectRS), duration))
                assert_that(duration, equal_to(eval(expectRS)), "sql: {0}, executeTime not equal to expected".format(self._sql))
                break

            hasEqual = re.search(r"equal\{(.*?)\}", self._expect, re.I)
            if hasEqual:
                assert_that(self._real_err is None, "sql: {0}, expect query success, but failed for '{1}'".format(self._sql, self._real_err))
                expectRs = hasEqual.group(1)  # expectRs type is str, method eval() can change expectRs to tuple
                assert len(eval(expectRs)) == len(self._real_res), "sql: {0}, expect resultSet length is {1}, but real resultSet length is {2}".format(self._sql, len(eval(expectRs)), len(self._real_res))
                sorted_expectRs = sorted(eval(expectRs), key=str)
                sorted_realRs = sorted(self._real_res, key=str)
                logger.debug("sql: {0}, expect resultSet:{1}, real resultSet:{2}".format(self._sql, sorted_expectRs, sorted_realRs))
                assert sorted_expectRs == sorted_realRs, "sql: {0}, expect resultSet not same with real resultSet, expect resultSet: {1}, real resultSet: {2}".format(self._sql, sorted_expectRs, sorted_realRs)
                break

            if self._expect.lower() == "error totally whack":
                assert_that(self._real_err, not_none(),
                            "exec sql:{0} Err is None, expect:{1}".format(self._sql, self._expect))
                break

            assert_that(self._real_err, not_none(),
                        "exec sql:{0} success, but expect failed for:{1}".format(self._sql, self._expect))
            assert_that(self._real_err[1], contains_string(self._expect),
                        "exec sql: {0}, expect query failed for: {1}, real err:{2}".format(self._sql, self._expect, self._real_err))
            break

    def hasResultSet(self, res, expectRS, bHas):
        resExpect = eval(expectRS)
        real = False
        if isinstance(resExpect, list):  # for multi-resultset
            for subResExpect in resExpect:
                assert isinstance(res, list), "expect mult-resultset, but real not"
                real = self.findFromMultiRes(res, subResExpect)
                assert real == bHas, "expect {0} in resultset {1}".format(resExpect, bHas)
        else:  # for single query resultset
            assert type(resExpect[0]) is tuple, "expect result format not expected, please check"
            resExpect_list = list(map(list, resExpect))
            realRS_list = list(map(list, res))
            for i in resExpect_list:
                real = realRS_list.__contains__(i)
                if real:
                    realRS_list.remove(i)          # prevent duplication in expected results
                assert real == bHas, "sql: {0}, expect {1} in resultSet {2}, but not".format(self._sql, resExpect, bHas)

    def matchResultSet(self, res, expect, num):
        subRes_list = []
        tmp = []
        partOfExpect = expect[0:num]
        if not isinstance(res[0], tuple):
            tmp.append(res)
        else:
            tmp = res
        for i in range(len(tmp)):
            strip = re.sub('\s', '', str(tmp[i]))
            subRes = re.split(r'[;,\s]', strip)
            partOfSubRes = subRes[0:num]
            logger.debug("partOfSubRes:{0} length{1}".format((partOfSubRes), len(partOfSubRes)))
            logger.debug("partOfExpect:{0} length{1}".format((partOfExpect), len(partOfExpect)))
            if operator.eq(partOfSubRes, partOfExpect) == 1:
                subRes_list.append(partOfSubRes)

        logger.debug("expect subRes_list:{0}".format(subRes_list))
        assert_that(subRes_list, not_none(), "expect subRes_list not None, but it is")

    # the expext resultset must wholely in the same tuple of the mult-res list
    # for example: res=[((1,2)),((3,4))], expect=((2,3)) shuold return False
    def findFromMultiRes(self, res, expect):
        assert len(res) > 0, "resultset is empty"
        if isinstance(expect, str):
            expLen = 1
        else:
            expLen = len(expect)
        for item in res:
            if item.__contains__(expect[0]):
                k = 1
                for subExpect in expect[1:]:
                    if item.__contains__(subExpect): k = k + 1
                if expLen == k: return True
        return False

    def balance(self, RS, expectRS,percent):  # Float a value up and down
        if percent<0 or percent>1:
            logger.debug("wrong value of percent")
            return False
        re_num = int(re.sub("\D", "", str(RS[0])))  # get the number from result of dble
        a = abs(re_num - expectRS)
        b = expectRS * percent
        assert a <= b, "expect {0} in resultset {1}".format(expectRS, re_num)
