from time import sleep, time,strftime
import sys, threading

class KThread(threading.Thread):

    def __init__(self, *args, **kwargs):
        threading.Thread.__init__(self, *args, **kwargs)
        self.killed = False

    def start(self):
        """Start the thread."""
        self.__run_backup = self.run
        self.run = self.__run  # Force the Thread to install our trace.
        threading.Thread.start(self)

    def __run(self):
        sys.settrace(self.globaltrace)
        self.__run_backup()
        self.run = self.__run_backup

    def globaltrace(self, frame, why, arg):
        if why == 'call':
            return self.localtrace
        else:
            return None

    def localtrace(self, frame, why, arg):
        if self.killed:
            if why == 'line':
                raise SystemExit()
        return self.localtrace

    def kill(self):
        self.killed = True


class Timeout(Exception):pass

def timeout(seconds):
    def timeout_decorator(func):
        def _new_func(oldfunc, result, oldfunc_args, oldfunc_kwargs):
            result.append(oldfunc(*oldfunc_args, **oldfunc_kwargs))
        def _(*args, **kwargs):
            result = []
            err = None
            new_kwargs = {  # create new args for _new_func, because we want to get the func return val to result list
                'oldfunc': func,
                'result': result,
                'oldfunc_args': args,
                'oldfunc_kwargs': kwargs
            }
            thd = KThread(target=_new_func, args=(), kwargs=new_kwargs)
            thd.start()
            s_time = time()
            thd.join(seconds)
            alive = thd.isAlive()
            end_time = time()
            all_time = end_time-s_time
            # print ("!!!!!!!!!!!!!!!!!!!!!!!!!!!{0}".format(str(all_time)))
            # context.logger.info("totall hang time:{0}".format(all_time))
            thd.kill()  # kill the child thread
            if alive:
                # print ("##########################:alive")
                # raise Timeout(u'function run too long, timeout %d seconds.' % seconds)
                try:

                    # context.logger.info("function run too long, timeout {0}seconds".format(seconds))
                    raise Timeout(u'function run too long, timeout %d seconds.' % seconds), Timeout(u'function run too long, timeout %d seconds.' % seconds)
                finally:
                    # context.logger.info("function run too long, timeout {0}seconds".format(seconds))
                    return u'function run too long, timeout %d seconds.' % seconds, u'function run too long, timeout %d seconds.' % seconds
            else:
                # print ("##########################:killed")
                # context.logger.info("hang thread has bean killed!")
                return result, err
        _.__name__ = func.__name__
        _.__doc__ = func.__doc__
        return _
    return timeout_decorator


#
# @timeout(5)
# def method_timeout(seconds, text):
#     print 'start', seconds, text
#     sleep(seconds)
#     print 'finish', seconds, text
#     return seconds
#
# if __name__ == '__main__':
#     for sec in range(1, 10):
#         try:
#             print '*' * 20
#             print method_timeout(sec, 'test waiting %d seconds' % sec)
#         except Timeout, e:
#             print e