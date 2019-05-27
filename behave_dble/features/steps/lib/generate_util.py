# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
import string
import random
import time

class generate():
    def __init__(self):
        pass

    def rand_string(self,length):
        return ''.join(random.choice(string.ascii_lowercase + string.ascii_uppercase + string.digits)
                       for i in range(length)
                       )

    def rand_integer(self,start,stop=100):
        return random.randint(start,stop)

    def rand_float(self,start,stop=100):
        return random.uniform(start,stop)

    def rand_odd_or_even(self,start,stop=100,step=1):
        return random.randrange(start,stop,step)

    def strTimeProp(self,start, end, format, prop):

        stime = time.mktime(time.strptime(start, format))
        etime = time.mktime(time.strptime(end, format))

        ptime = stime + prop * (etime - stime)

        return time.strftime(format, time.localtime(ptime))

    def randomDate(self,start, end, prop,format="%Y-%m-%d"):
        return self.strTimeProp(start, end,prop,format)

    #print randomDate("1/1/2008 1:30 PM", "1/1/2009 4:50 AM", random.random())