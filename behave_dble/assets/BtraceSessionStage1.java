package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;
import static com.sun.btrace.BTraceUtils.println;
import static com.sun.btrace.BTraceUtils.str;

import com.sun.btrace.annotations.Kind;
import com.sun.btrace.annotations.Location;

@BTrace(unsafe = true)
public final class BtraceSessionStage1 {

    private BtraceSessionStage1() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.server.NonBlockingSession",
            method = "setBackendResponseTime",
            location = @Location(Kind.RETURN)
    )
    public static void setBackendResponseTime(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into setBackendResponseTime " );
        BTraceUtils.println("------- get into setBackendResponseTime -------");
        BTraceUtils.println();
        Thread.sleep(1L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into setBackendResponseTime " );
        BTraceUtils.println();
    }

}