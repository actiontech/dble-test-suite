package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;

import com.sun.btrace.annotations.BTrace;

import com.sun.btrace.annotations.OnMethod;

/*
delay before xa start
*/

@BTrace(unsafe = true)

public final class DelayBeforeXaStart {

    private DelayBeforeXaStart() {

    }

    @OnMethod(

            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",

            method = "delayBeforeXaStart"

    )

    public static void delayBeforeXaStart(String rrnName, String xaId) throws Exception {

        BTraceUtils.println("before xa start " + xaId + " in " + rrnName);

        Thread.sleep(10000L);

    }
}