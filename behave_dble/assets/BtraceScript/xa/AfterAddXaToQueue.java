package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;

import com.sun.btrace.annotations.BTrace;

import com.sun.btrace.annotations.OnMethod;

/*
delay after add xa to queue
*/

@BTrace(unsafe = true)

public final class AfterAddXaToQueue {

    private AfterAddXaToQueue() {

    }

    @OnMethod(

            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",

            method = "afterAddXaToQueue"

    )

    public static void afterAddXaToQueue(int count, String xaId) throws Exception {

        BTraceUtils.println("after add xa " + xaId + " to queue in " + count + " time.");

        Thread.sleep(10000L);

    }
}