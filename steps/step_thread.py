import threading 
class DbleThread(threading.Thread): #The timer class is derived from the class threading.Thread
    def __init__(self, context, conn, sql, toClose):
        threading.Thread.__init__(self) 
        self.thread_stop = False
        self.context = context
        self.conn = conn
        self.toClose = toClose
        self.thread_id = self.conn._conn.thread_id()
        self.sql = sql

    def run(self): #Overwrite run() method, put what you want the thread do here
        self.context.logger.info("sub-thread {0} start run, thread_stop:{1}".format(self.thread_id, self.thread_stop))
        while not self.thread_stop:
            self.context.logger.info("sub-thread {0} start exec sql: {1}".format(self.thread_id,self.sql))
            self.conn.query(self.sql)
            self.context.logger.info("after exec sql in sqlthread")
            self.stop()

    def stop(self):
        self.thread_stop = True
        if self.toClose:
            self.conn.close()

        self.context.logger.info("sqlthread {0} is stoped".format(self.thread_id))
