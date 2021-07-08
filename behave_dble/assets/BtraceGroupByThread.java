package com.actiontech.dble.assets;

import com.sun.btrace.annotations.*;

import static com.sun.btrace.BTraceUtils.Strings.strcat;
import static com.sun.btrace.BTraceUtils.jstack;
import static com.sun.btrace.BTraceUtils.println;
import static com.sun.btrace.BTraceUtils.str;
import static com.sun.btrace.BTraceUtils.Reflective;
import com.sun.btrace.BTraceUtils;

@BTrace(unsafe = true)
public class BtraceGroupByThread {

    @OnMethod(
            clazz="com.actiontech.dble.backend.mysql.nio.handler.query.impl.groupby.directgroupby.GroupByBucket",
            method="start"
    )
    public static void groupByBucket(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception  {
        BTraceUtils.println("get into groupByBucket.start");
        BTraceUtils.println("---------------");
        BTraceUtils.Threads.jstack();
        Thread.sleep(1000L);
        BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss") + ", end groupByBucket.start");
        BTraceUtils.println("---------------");
    }
}