package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;

import com.sun.btrace.annotations.BTrace;

import com.sun.btrace.annotations.OnMethod;

/*
delay before xa prepare
*/

@BTrace(unsafe = true)

public final class DelayBeforeXaPrepare {

    private DelayBeforeXaPrepare() {

    }

    @OnMethod(

            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",

            method = "delayBeforeXaPrepare"

    )

    public static void delayBeforeXaPrepare(String rrnName, String xaId) throws Exception {

        BTraceUtils.println("before xa prepare " + xaId + " in " + rrnName);

        Thread.sleep(10000L);

    }
}