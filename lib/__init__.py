import logging

from functools import wraps
from pprint import pformat


def log_it(func):
    logger = logging.getLogger('lib')

    @wraps(func)
    def logged_function(*args, **kwargs):
        logger.info('Start function: <{0}>'.format(func.__name__))
        logger.debug('<{0}> args: <{1}>'.format(func.__name__, pformat(args)))
        logger.debug('<{0}> kwargs: <{1}>'.format(func.__name__, pformat(kwargs)))
        result = func(*args, **kwargs)
        logger.debug('<{0}> result : <{1}>'.format(func.__name__, pformat(result)))
        logger.info('End function <{0}>'.format(func.__name__))
        return result

    return logged_function