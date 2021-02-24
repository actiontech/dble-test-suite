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
public final class BtraceAboutConnection {
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
}