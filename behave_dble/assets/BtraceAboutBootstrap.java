package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutBootstrap {
    private BtraceAboutBootstrap() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.services.manager.handler.WriteDynamicBootstrap",
            method = "changeValue"
    )
    public static void WriteDynamicBootstrap(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into WriteDynamicBootstrap");
        BTraceUtils.println("---------------");
        Thread.sleep(10000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }


}