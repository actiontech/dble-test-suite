package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;

@BTrace(unsafe = true)
public final class SleepWhenAddMetaLock {
    private SleepWhenAddMetaLock() {

    }
    @OnMethod(
            clazz = "com.actiontech.dble.meta.ProxyMetaManager",
            method = "addMetaLock"
    )
    public static void sleepWhenAddMetaLock(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into addMetaLock,start sleep ");
        BTraceUtils.print(" __________________________ ");
        Thread.sleep(30000L);
        BTraceUtils.print("sleep end ");
        BTraceUtils.print(" __________________________ ");
    }
}