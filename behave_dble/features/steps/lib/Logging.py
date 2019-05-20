# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
import logging

from abc import ABCMeta


class Logging(object):
    __metaclass__ = ABCMeta

    def __init__(self):
        self._logger = self._get_logger()

    def _get_logger(self):
        return logging.getLogger(self._logger_name)

    @property
    def _logger_name(self):
        return 'lib.' + self.__class__.__name__

    @property
    def logger(self):
        return self._logger