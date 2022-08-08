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
public final class BtraceAboutConnection {
    private static final AtomicInteger num1 = new AtomicInteger(0);
    private static final AtomicInteger num2 = new AtomicInteger(0);

    private BtraceAboutConnection() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.backend.datasource.PhysicalDbInstance",
            method = "getConnection"
    )
    public static void getConnection(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time["+startTime+"], start ... " );
        BTraceUtils.println("getting connection");
        BTraceUtils.println();
        Thread.sleep(10L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time["+endTime+"], end ... " );
        BTraceUtils.println();
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

    @OnMethod(
            clazz = "com.actiontech.dble.net.connection.PooledConnection",
//             location=@Location(value=Kind.LINE,line=373) for 3.22.01
            location=@Location(value=Kind.LINE,line=382)

    )
    public static void evict(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        if(num2.get() == 0) {
            num2.incrementAndGet();
            BTraceUtils.println("get into evict");
            BTraceUtils.println("---------------");
            Thread.sleep(10L);
            BTraceUtils.println("sleep end ");
            BTraceUtils.println("---------------");
        }
    }

}