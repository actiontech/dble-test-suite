package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutsqlStatistic {
    private BtraceAboutsqlStatistic() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.StatisticProvider",
            method = "updateTableMaxSize"
    )
    public static void updateTableMaxSize(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("reload tablesize");
        BTraceUtils.println("---------------");
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.StatisticProvider",
            method = "getStatisticQueueSize"
    )
    public static void getStatisticQueueSize(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into sleep");
        BTraceUtils.println("---------------");
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }


    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.StatisticProvider",
            method = "onOffStatistic"
    )
    public static void onOffStatistic(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into sleep");
        BTraceUtils.println("---------------");
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }


    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.StatisticProvider",
            method = "showStatistic"
    )
    public static void showStatistic(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into sleep");
        BTraceUtils.println("---------------");
        Thread.sleep(30000L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }

}