package com.actiontech.dble.assets;

import com.sun.btrace.annotations.*;

import static com.sun.btrace.BTraceUtils.Strings.strcat;
import static com.sun.btrace.BTraceUtils.jstack;
import static com.sun.btrace.BTraceUtils.println;
import static com.sun.btrace.BTraceUtils.str;
import static com.sun.btrace.BTraceUtils.Reflective;
import com.sun.btrace.BTraceUtils;

@BTrace(unsafe = true)
public class BtraceMultiNodeMergeAndOrderHandler {

    @OnMethod(
            clazz="com.actiontech.dble.backend.mysql.nio.handler.query.impl.MultiNodeMergeAndOrderHandler",
            //location=@Location(value=Kind.LINE,line=162) for 2.20.04
            location=@Location(value=Kind.LINE,line=186)
    )
    public static void groupByBucket(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception  {
        BTraceUtils.println("get into rowEofResponse");
        BTraceUtils.println("---------------");
        BTraceUtils.Threads.jstack();
        Thread.sleep(5000L);
        BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss") + ", end rowEofResponse");
        BTraceUtils.println("---------------");
    }
}