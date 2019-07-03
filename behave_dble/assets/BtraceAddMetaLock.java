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
public final class BtraceAddMetaLock {
    private BtraceAddMetaLock() {

    }
    @OnMethod(
            clazz = "com.actiontech.dble.meta.ProxyMetaManager",
            method = "addMetaLock",
            location=@Location(value=Kind.LINE,line=113)
    )
    public static void sleepWhenAddMetaLockDuring(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("enter metalock and start sleep");
        BTraceUtils.println("---------------");
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }
}