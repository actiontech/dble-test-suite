package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;

import com.sun.btrace.annotations.BTrace;

import com.sun.btrace.annotations.OnMethod;

/*
delay before xa end
*/

@BTrace(unsafe = true)

public final class DelayBeforeXaEnd {

    private DelayBeforeXaEnd() {

    }

    @OnMethod(

            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",

            method = "delayBeforeXaEnd"

    )

    public static void delayBeforeXaEnd(String rrnName, String xaId) throws Exception {

        BTraceUtils.println("before xa end " + xaId + " in " + rrnName);

        Thread.sleep(10000L);

    }
}