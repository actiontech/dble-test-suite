package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;

@BTrace(unsafe = true)
public final class BtraceXaDelay_backgroundRetry {

     private static boolean isFirst = true;

    private BtraceXaDelay_backgroundRetry() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",
            method = "delayBeforeXaPrepare"
    )
    public static void delayBeforeXaPrepare(String rrnName, String xaId) throws Exception {
        BTraceUtils.println("--------------");
        BTraceUtils.println("before xa prepare " + xaId + " in " + rrnName);
        Thread.sleep(100L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",
            method = "delayBeforeXaCommit"
    )

    public static void delayBeforeXaCommit(String rrnName, String xaId) throws Exception {
        if (isFirst) {
            BTraceUtils.println("--------------");
            BTraceUtils.println("before xa commit first:" + xaId + " in " + rrnName);
            BTraceUtils.println("--------------");
            Thread.sleep(100L);
            isFirst=false;
        } else {
            BTraceUtils.println("--------------");
            BTraceUtils.println("before xa commit " + xaId + " in " + rrnName);
        }
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",
            method = "delayBeforeXaRollback"
    )
    public static void delayBeforeXaRollback(String rrnName, String xaId) throws Exception {
        BTraceUtils.println("--------------");
        BTraceUtils.println("before xa rollback " + xaId + " in " + rrnName);
        Thread.sleep(100L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",
            method = "beforeAddXaToQueue"
    )
    public static void beforeAddXaToQueue(int count, String xaId) throws Exception {
        BTraceUtils.println("--------------");
        BTraceUtils.println("before add xa " + xaId + " to queue in " + count + " time.");
        Thread.sleep(100L);
    }

    @OnMethod(
            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",
            method = "afterAddXaToQueue"
    )
    public static void afterAddXaToQueue(int count, String xaId) throws Exception {
        BTraceUtils.println("--------------");
        BTraceUtils.println("after add xa " + xaId + " to queue in " + count + " time.");
        Thread.sleep(100L);
    }

}