package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;

import com.sun.btrace.annotations.BTrace;

import com.sun.btrace.annotations.OnMethod;

/*
delay before xa rollback
*/

@BTrace(unsafe = true)

public final class DelayBeforeXaRollback {

    private DelayBeforeXaRollback() {

    }
    @OnMethod(

            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",

            method = "delayBeforeXaRollback"

    )

    public static void delayBeforeXaRollback(String rrnName, String xaId) throws Exception {

        BTraceUtils.println("before xa rollback " + xaId + " in " + rrnName);

        Thread.sleep(10000L);

    }

}