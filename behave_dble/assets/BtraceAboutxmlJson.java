package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutxmlJson {
    private BtraceAboutxmlJson() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.config.ServerConfig",
            method = "syncJsonToLocal"
    )
    public static void syncJsonToLocal(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into sleep");
        BTraceUtils.println("---------------");
        Thread.sleep(60000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }
}