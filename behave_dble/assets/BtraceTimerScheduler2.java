package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;
import java.util.Random;

@BTrace(unsafe = true)
public final class BtraceTimerScheduler2 {
    private BtraceTimerScheduler2() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.statistic.stat.FrontActiveRatioStat",
            method = "compress"
    )
    public static void compress(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("========== get into compress ========== " + BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss.SSS"));
        BTraceUtils.println("Scheduler thread compress 5s " + BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss.SSS"));
        Thread.sleep(300000L);
        BTraceUtils.println("========== " + BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss.SSS"));
    }

}
