package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;
import com.sun.btrace.AnyType;

@BTrace(unsafe = true)
public final class BtraceClusterDelayquery {

    private BtraceClusterDelayquery() {

    }
     @OnMethod(
             clazz = "com.actiontech.dble.services.mysqlsharding.MySQLResponseService",
             method = "synAndDoExecute"
     )
     public static void synAndDoExecute(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod, AnyType[] args) throws Exception {
         BTraceUtils.printArray(args);
         BTraceUtils.println("get into query");
         BTraceUtils.println(" __________________________ ");
         Thread.sleep(1L);
    }
}
