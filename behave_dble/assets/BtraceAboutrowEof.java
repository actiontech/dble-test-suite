package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;
import java.util.concurrent.atomic.AtomicBoolean;


@BTrace(unsafe = true)
public class BtraceAboutrowEof {
    public static AtomicBoolean flag = new AtomicBoolean(false);

    public BtraceAboutrowEof() {
    }

    @OnMethod(
            clazz = "com.actiontech.dble.backend.mysql.nio.handler.query.impl.BaseSelectHandler",
            method = "rowEofResponse"
    )
    public static void rowEofResponse(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into way");
        if (flag.compareAndSet(false, true)) {
            Thread.sleep(4000L);
            BTraceUtils.println("get into reRegister1");
            BTraceUtils.println();
        }
        if (flag.compareAndSet(true, false)) {
            Thread.sleep(5000L);
            BTraceUtils.println("get into reRegister2");
            BTraceUtils.println();
        }
    }
}