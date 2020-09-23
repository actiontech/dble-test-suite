package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;

import com.sun.btrace.annotations.BTrace;

import com.sun.btrace.annotations.OnMethod;

/*
delay before  add xa to queue
*/

@BTrace(unsafe = true)

public final class BeforeAddXaToQueue {

    private BeforeAddXaToQueue() {

    }

    @OnMethod(

            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",

            method = "beforeAddXaToQueue"

    )

    public static void beforeAddXaToQueue(int count, String xaId) throws Exception {

        BTraceUtils.println("before add xa " + xaId + " to queue in " + count + " time.");

        Thread.sleep(10000L);

    }
}