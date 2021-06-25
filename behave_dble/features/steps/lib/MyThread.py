# -*- coding: utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2018/4/13 PM6:17
# @Author  : zhaohongjie@actionsky.com

#At present, the multi-thread query only works for 2 thread
import logging
from threading import Thread

logger = logging.getLogger('root')
class MyThread(Thread):
    def __init__(self, threadID, func, sql_queue, sql_res_queue, current_thd_idx):
        Thread.__init__(self, name=threadID)
        self._sql_queue = sql_queue
        self._func = func
        self._sql_res_queue=sql_res_queue
        prelen=len("sql_thread_")
        self._thread_idx = threadID[prelen:]
        self.current_thd_idx = current_thd_idx
    def run(self):
        while True:
            if (self._thread_idx == self.current_thd_idx[0] or self._thread_idx == self.current_thd_idx[1]) and self._sql_queue.qsize() > 0:
                sql_item = self._sql_queue.get()
                sql = sql_item.get("sql")
                logger.info("exec sql: {0} in thread: {1}".format(sql, self.getName()))
                res, err = self._func(sql)
                sql_item['res'] = res
                sql_item['err'] = err
                self._sql_res_queue.put(sql_item)
                self._sql_queue.task_done()
            elif self.current_thd_idx[0] == -1:
                logger.info("try to exit from sql thread!")
                return
            else:
                logger.info("self.current_thd_idx[0]: {0}".format(self.current_thd_idx[0]))