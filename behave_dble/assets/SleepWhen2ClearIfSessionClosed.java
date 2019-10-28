package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;

@BTrace(unsafe = true)
public final class SleepWhen2ClearIfSessionClosed {
    private SleepWhen2ClearIfSessionClosed() {

    }
    @OnMethod(
            clazz = "com.actiontech.dble.backend.mysql.nio.handler.MultiNodeDdlHandler",
            method = "clearIfSessionClosed"
    )
    public static void sleepWhen2ClearIfSessionClosed(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into clearIfSessionClosed,start sleep");
        BTraceUtils.print(" __________________________ ");
        Thread.sleep(20000L);
        BTraceUtils.print("sleep end ");
        BTraceUtils.print(" __________________________ ");
    }

}

