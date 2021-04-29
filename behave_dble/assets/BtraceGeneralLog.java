package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;

@BTrace(unsafe = true)
public final class BtraceGeneralLog {

    private BtraceGeneralLog() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.GeneralProvider",
            method = "getGeneralLogQueueSize"
    )
    public static void getGeneralLogQueueSize(int queueSize) throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into getGeneralLogQueueSize");
        BTraceUtils.println("------- get into getGeneralLogQueueSize -------, generalLogQueueSize is : " + queueSize);
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into getGeneralLogQueueSize");
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.GeneralProvider",
            method = "onOffGeneralLog"
    )
    public static void onOffGeneralLog() throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into onOffGeneralLog");
        BTraceUtils.println("------- get into onOffGeneralLog -------");
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into onOffGeneralLog");
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.GeneralProvider",
            method = "updateGeneralLogFile"
    )
    public static void updateGeneralLogFile() throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into updateGeneralLogFile");
        BTraceUtils.println("------- get into updateGeneralLogFile -------");
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into updateGeneralLogFile");
        BTraceUtils.println();
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.GeneralProvider",
            method = "showGeneralLog"
    )
    public static void showGeneralLog() throws Exception {
        long startTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + startTime + "], start get into showGeneralLog");
        BTraceUtils.println("------- get into showGeneralLog -------");
        Thread.sleep(100L);
        long endTime = System.currentTimeMillis();
        BTraceUtils.println("time[" + endTime + "], end get into showGeneralLog");
        BTraceUtils.println();
    }

}