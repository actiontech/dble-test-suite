package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;

import java.util.concurrent.atomic.AtomicBoolean;

@BTrace(unsafe = true)
public final class BtraceAbout2377 {
    static AtomicBoolean aBoolean = new AtomicBoolean(false);

    @OnMethod(
            clazz = "com.actiontech.dble.backend.datasource.PhysicalDbGroup",
            method = "unBindRwSplitSession"
    )
    public static void acquire(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        if (aBoolean.compareAndSet(false, true)) {
            BTraceUtils.println("get into 15s sleep");
            BTraceUtils.println();
            Thread.sleep(15 * 1000L);
            BTraceUtils.println("stop");
            BTraceUtils.println();
        }
    }
}