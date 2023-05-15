package com.actiontech.dble.btrace.script;

import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;
import com.sun.btrace.annotations.Location;
import com.sun.btrace.annotations.Duration;
import com.sun.btrace.annotations.Return;
import com.sun.btrace.annotations.Kind;
import java.util.concurrent.atomic.AtomicInteger;
import com.sun.btrace.BTraceUtils;

@BTrace(unsafe = true)
public final class BtraceConnectionPing {
    private static final AtomicInteger num1 = new AtomicInteger(0);

    private BtraceConnectionPing() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.backend.mysql.nio.handler.ConnectionHeartBeatHandler",
            method = "ping"
    )
    public static void ping(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        if (num1.get() == 0) {
            num1.incrementAndGet();
            long startTime = System.currentTimeMillis();
            BTraceUtils.println("time["+startTime+"], start ... " );
            BTraceUtils.println("sending ping signal");
            BTraceUtils.println();
            Thread.sleep(10L);
            long endTime = System.currentTimeMillis();
            BTraceUtils.println("time["+endTime+"], end ... " );
            BTraceUtils.println();
        }
    }

}