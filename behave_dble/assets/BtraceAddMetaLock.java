package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAddMetaLock {
    private BtraceAddMetaLock() {

    }

@OnMethod(
            clazz = "com.actiontech.dble.meta.ProxyMetaManager",
            method = "addMetaLock"
    )
    public static void sleepWhenAddMetaLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into addMetaLock,start sleep ");
        BTraceUtils.println(" __________________________ ");
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println(" __________________________ ");
    }

@OnMethod(
            clazz = "com.actiontech.dble.backend.mysql.nio.handler.MultiNodeDDLExecuteHandler",
            method = "execute"
    )
    public static void sleepWhenClearIfSession(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into clearIfSessionClosed,start sleep ");
        BTraceUtils.println(" __________________________ ");
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println(" __________________________ ");
    }

@OnMethod(
            clazz = "com.actiontech.dble.backend.mysql.nio.handler.SingleNodeDDLHandler",
            method = "execute"
    )
    public static void sleepWhensingTable(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into clearIfSessionClosed,start sleep ");
        BTraceUtils.println(" __________________________ ");
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println(" __________________________ ");
    }
}