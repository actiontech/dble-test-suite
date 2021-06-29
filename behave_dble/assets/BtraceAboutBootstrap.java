package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutBootstrap {
    private BtraceAboutBootstrap() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.DbleThreadPoolProvider",
            method = "reRegisterSelector"
    )
    public static void reRegisterSelector(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into reRegister");
        BTraceUtils.println("---------------");
        BTraceUtils.Threads.jstack();
        BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss"));
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }

}
