package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;
import java.util.concurrent.atomic.AtomicBoolean;

@BTrace(unsafe = true)
public class BtracetryExistsCon {
    static AtomicBoolean aBoolean = new AtomicBoolean(false);

     @OnMethod(
             clazz = "com.actiontech.dble.server.NonBlockingSession",
             method = "tryExistsCon",
             location = @Location(value = Kind.RETURN)
   )


    public static void tryExistsCon(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        if (aBoolean.compareAndSet(false, true)) {
            BTraceUtils.println("get into btrace...");
            BTraceUtils.println("prepare sleep ...");
            BTraceUtils.println();
            Thread.sleep(1 * 20 * 1000L);
            BTraceUtils.println("end btrace... ");
            BTraceUtils.println();
        }
    }

}