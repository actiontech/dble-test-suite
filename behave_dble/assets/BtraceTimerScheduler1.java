package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;
import java.util.Random;

@BTrace(unsafe = true)
public final class BtraceTimerScheduler1 {
    private BtraceTimerScheduler1() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.singleton.DDLTraceHelper",
            method = "printDDLOutOfLimit"
    )
    public static void printDDLOutOfLimit(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("---------- get into printDDLOutOfLimit ---------- " + BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss.SSS"));
        BTraceUtils.println("Scheduler thread printDDLOutOfLimit 60s " + BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss.SSS"));
        Thread.sleep(300000L);
        BTraceUtils.println("--------------- " + BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss.SSS"));
    }

}