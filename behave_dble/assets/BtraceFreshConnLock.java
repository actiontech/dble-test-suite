package com.actiontech.dble.btrace.script;

import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;
import com.sun.btrace.annotations.Location;
import com.sun.btrace.annotations.Duration;
import com.sun.btrace.annotations.Return;
import com.sun.btrace.annotations.Kind;

import com.sun.btrace.BTraceUtils;

@BTrace(unsafe = true)
public final class BtraceFreshConnLock {
    private BtraceFreshConnLock() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.services.manager.response.ReloadConfig",
            method = "reloadWithoutCluster",
            location=@Location(value=Kind.LINE,line=154)
    )
    public static void reloadWithoutCluster(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time["+startTime+"], start ... " );
        BTraceUtils.println("get reload lock");
        BTraceUtils.println();
        Thread.sleep(10L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time["+endTime+"], end ... " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.meta.ReloadManager",
            method = "startReload"
    )
    public static void startReload(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time["+startTime+"], start ... " );
        BTraceUtils.println("get reload lock");
        BTraceUtils.println();
        Thread.sleep(10L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time["+endTime+"], end ... " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "freshConnGetRealodLocekAfter"
    )
    public static void freshConnGetRealodLocekAfter(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time["+startTime+"], start ... " );
        BTraceUtils.println("freshConnGetRealodLocekAfter");
        BTraceUtils.println();
        Thread.sleep(10L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time["+endTime+"], end ... " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "stopConnGetFrenshLocekAfter"
    )
    public static void stopConnGetFrenshLocekAfter(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time["+startTime+"], start ... " );
        BTraceUtils.println("stopConnGetFrenshLocekAfter");
        BTraceUtils.println();
        Thread.sleep(10L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time["+endTime+"], end ... " );
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.ConnectionPoolProvider",
            method = "getConnGetFrenshLocekAfter"
    )
    public static void getConnGetFrenshLocekAfter(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time["+startTime+"], start ... " );
        BTraceUtils.println("getConnGetFrenshLocekAfter");
        BTraceUtils.println();
        Thread.sleep(10L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time["+endTime+"], end ... " );
        BTraceUtils.println();
    }
}