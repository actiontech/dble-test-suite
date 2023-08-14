package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceSlowQueryLog {
    private BtraceSlowQueryLog() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.log.slow.SlowQueryLogProcessor",
            method = "writeLog"
    )
    public static void writeLog(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into writeLog");
        BTraceUtils.println("---------------");
        BTraceUtils.Threads.jstack();
        BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss"));
        Thread.sleep(1L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }

}