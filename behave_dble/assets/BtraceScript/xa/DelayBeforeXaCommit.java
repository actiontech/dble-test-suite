package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;

import com.sun.btrace.annotations.BTrace;

import com.sun.btrace.annotations.OnMethod;

/*
delay before xa commit
*/

@BTrace(unsafe = true)

public final class DelayBeforeXaCommit {

    private DelayBeforeXaCommit() {

    }
    @OnMethod(

            clazz = "com.actiontech.dble.btrace.provider.XaDelayProvider",

            method = "delayBeforeXaCommit"

    )

    public static void delayBeforeXaCommit(String rrnName, String xaId) throws Exception {

        BTraceUtils.println("before xa commit " + xaId + " in " + rrnName);

        Thread.sleep(10000L);

    }

}