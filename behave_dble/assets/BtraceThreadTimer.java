package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;
import java.util.Random;

@BTrace(unsafe = true)
public final class BtraceThreadTimer {
    private BtraceThreadTimer() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.singleton.XASessionCheck",
            method = "checkSessions"
    )
    public static void checkXaSessions(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("---------- get into checkXaSessions ---------- " + BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss.SSS"));
        BTraceUtils.println("---------- Timer thread checkXaSessions 1s ---------- " + BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss.SSS"));
        Thread.sleep(600000L);
        BTraceUtils.println("---------------" + BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss.SSS"));
    }
}
