# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/4/4 下午3:54
# @Author  : irene-coming
import logging
import re

from .ObjectFactory import ObjectFactory
from hamcrest import *

logger = logging.getLogger('MySQLObject')

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
                assert self._real_err is None, "expect no err, but outcomes '{0}'".format(self._real_err)
                break
            dest_host = re.search(r'dest_node:(.*)', self._expect, re.I)
            if dest_host:
                shardings_host = dest_host.group(1)
                if  self._sql.lower().startswith("insert into"):
                    target = self._sql.split("values")[1]
                else:
                    target = self._sql

                mysql = ObjectFactory.create_mysql_object(shardings_host)
                mysql.check_query_in_general_log(target, expect_exist=True)
                break

            hasObj = re.search(r"has\{(.*?)\}", self._expect, re.I)
            if hasObj:
                assert_that(self._real_err is None, "expect query success, but failed for '{0}'".format(self._real_err))
                expectRS = hasObj.group(1)
                logger.debug("expect resultset:{0}, real res:{1}".format(eval(expectRS), self._real_res))
                self.hasResultSet(self._real_res, expectRS, True)
                break

            hasnotObj = re.search(r"hasnot\{(.*?)\}", self._expect, re.I)
            if hasnotObj:
                assert_that(self._real_err is None, "expect query success, but failed for '{0}'".format(self._real_err))
                notExpectRS = hasnotObj.group(1)
                logger.debug("not expect resultset:{0}, real res:{1}".format(eval(notExpectRS), self._real_res))
                self.hasResultSet(self._real_res, notExpectRS, False)
                break

            lengthObj = re.search(r"length\{(.*?)\}", self._expect, re.I)
            if lengthObj:
                assert_that(self._real_err is None, "expect query success, but failed for '{0}'".format(self._real_err))
                expectRS = lengthObj.group(1)
                logger.debug(
                    "expect resultset:{0}, length equal to real res length:{1}".format(eval(expectRS), len(self._real_res)))
                assert_that(len(self._real_res), equal_to(eval(expectRS)), "sql resultset records count is not as expected")
                break

            matchObj = re.search(r"match\{(.*?)\}", self._expect, re.I)
            if matchObj:
                assert_that(self._real_err is None, "expect query success, but failed for '{0}'".format(self._real_err))
                match_Obj = matchObj.group(1)
                logger.debug("expect match_obj:{0}".format(match_Obj))
                match_Obj_Split = re.split(r'[;,\s]', match_Obj.encode('ascii'))
                logger.debug("expect match_Obj_Split:{0}".format(match_Obj_Split))
                self.matchResultSet(self._real_res, match_Obj_Split, len(match_Obj_Split) - 1)
                break

            isBalance = re.search(r"balance\{(.*?)\}", self._expect, re.I)
            if isBalance:
                assert_that(self._real_err is None, "expect query success, but failed for '{0}'".format(self._real_err))
                bal_num = isBalance.group(1)
                self.balance(context, self._real_res, int(bal_num))
                break

            hasString = re.search(r"hasStr\{(.*?)\}", self._expect, re.I)
            if hasString:
                assert_that(self._real_err is None, "expect query success, but failed for '{0}'".format(self._real_err))
                expectRS = hasString.group(1)
                assert_that(str(self._real_res), contains_string(str(expectRS)),
                            "expect containing text: {0}, resultset:{1}".format(expectRS, self._real_res))
                break

            hasNoString = re.search(r"hasNoStr\{(.*?)\}", self._expect, re.I)
            if hasNoString:
                assert_that(self._real_err is None, "expect query success, but failed for '{0}'".format(self._real_err))
                notExpectRS = hasNoString.group(1)
                assert str(notExpectRS) not in str(self._real_res), "not expect containing text: {0}, resultset:{1}".format(
                    notExpectRS, self._real_res)
                break


            executeTime = re.search(r"execute_time\{(.*?)\}", self._expect, re.I)
            if executeTime:
                expectRS = executeTime.group(1)
                duration = self._time_cost.seconds
                logger.debug("expect duration is :{0},real duration is{1} ".format(eval(expectRS), duration))
                assert_that(duration, equal_to(eval(expectRS)))
                break

            if self._expect.lower() == "error totally whack":
                assert_that(self._real_err, not_none(), "exec sql:{1} Err is None, expect:{0}".format(self._expect, sql))
                break


            assert_that(self._real_err, not_none(), "exec sql:{0} success, but expect fail for:{1}".format(self._sql, self._expect))
            assert_that(self._real_err[1], contains_string(self._expect), "expect text: {0}, read err:{1}".format(self._expect, self._real_err))
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
            if len(resExpect) == len(res) and type(resExpect[0]) == type(res[0]):
                real = cmp(sorted(list(resExpect)), sorted(list(res))) == 0
            else:
                real = res.__contains__(resExpect)

                if not real == bHas:
                    unicode_expect = resExpect.decode('utf8')
                    expect_tuple = map(lambda x: filter(lambda y: y == unicode_expect, x), res)
                    real = len(expect_tuple) > 0
                    # LOGGER.debug("***zhj debug 2, len expect_tuple {0}".format(len(expect_tuple)))

            assert real == bHas, "expect {0} in resultset {1}".format(resExpect, bHas)

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
            if cmp(partOfSubRes, partOfExpect) == 0:
                subRes_list.append(partOfSubRes)

        logger.debug("expect subRes_list:{0}".format(subRes_list))
        assert_that(subRes_list, not_none(), "expect subRes_list not None, but it is")

    # the expext resultset must wholely in the same tuple of the mult-res list
    # for example: res=[((1,2)),((3,4))], expect=((2,3)) shuold return False
    def findFromMultiRes(self, res, expect):
        assert len(res)>0, "resultset is empty"
        if isinstance(expect, str): expLen = 1
        else: expLen = len(expect)
        for item in res:
            if item.__contains__(expect[0]):
                k = 1
                for subExpect in expect[1:]:
                    if item.__contains__(subExpect): k = k+1
                if expLen == k: return True
        return False

    def balance(self, RS, expectRS): #Float a value up and down
        re_num = int (re.sub("\D","",str(RS[0])))  #get the number from result of dble
        a = abs(re_num - expectRS)
        b = expectRS *0.15
        assert a<=b, "expect {0} in resultset {1}".format(expectRS, re_num)