package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceAboutFlowControl {
    private BtraceAboutFlowControl() {
    }

    @OnMethod(
        clazz = "com.actiontech.dble.net.impl.nio.NIOSocketWR",
        method = "doNextWriteCheck"
            )
    public static void doNextWriteCheck(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
    BTraceUtils.println("enter next write check");
    BTraceUtils.println("---------------");
    Thread.sleep(10L);
    BTraceUtils.println("sleep end ");
    BTraceUtils.println("---------------");
    }

    @OnMethod(
        clazz = "sun.nio.ch.SocketChannelImpl",
        method = "write"
            )
    public static void delayBeforeClose(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
    BTraceUtils.print("get into close delay ");
    BTraceUtils.print(" for order __________________________ ");
    Thread.sleep(50L);
    }

    @OnMethod(
        clazz = "com.actiontech.dble.backend.mysql.nio.MySQLConnectionHandler",
        method = "handle"
    )
    public static void delayBeforehandle(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
    BTraceUtils.print("get handle ");
    BTraceUtils.print(" for order __________________________ ");
    Thread.sleep(30L);
    }

}