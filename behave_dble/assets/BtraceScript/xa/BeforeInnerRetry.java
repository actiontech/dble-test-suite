package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;

import com.sun.btrace.annotations.BTrace;

import com.sun.btrace.annotations.OnMethod;

/*
before inner retry
*/

@BTrace(unsafe = true)

public final class BeforeInnerRetry {

    private BeforeInnerRetry() {

    }

    @OnMethod(

            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",

            method = "beforeInnerRetry"

    )

    public static void beforeInnerRetry(int count, String xaId) throws Exception {

        BTraceUtils.println("before inner retry " + xaId + " in " + count + " time.");

        Thread.sleep(10000L);

    }
}