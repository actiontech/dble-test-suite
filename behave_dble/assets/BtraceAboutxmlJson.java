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

    @OnMethod(
            clazz = "com.actiontech.dble.singleton.HaConfigManager",
            method = "updateDbGroupConf"
    )
    public static void updateDbGroupConf(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time["+startTime+"], start ... " );
        BTraceUtils.println("befroe updateDbGroupConf ...");
        BTraceUtils.println();
        Thread.sleep(120000L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time["+endTime+"], end ... " );
        BTraceUtils.println();
    }


}