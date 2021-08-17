package com.actiontech.dble.assets;

import com.sun.btrace.annotations.*;

import static com.sun.btrace.BTraceUtils.Strings.strcat;
import static com.sun.btrace.BTraceUtils.jstack;
import static com.sun.btrace.BTraceUtils.println;
import static com.sun.btrace.BTraceUtils.str;
import static com.sun.btrace.BTraceUtils.Reflective;
import com.sun.btrace.BTraceUtils;

@BTrace(unsafe = true)
public class BtraceMultiNodeMergeAndOrderHandler {

    @OnMethod(
            clazz="com.actiontech.dble.backend.mysql.nio.handler.query.impl.MultiNodeMergeAndOrderHandler",
            //location=@Location(value=Kind.LINE,line=162) for 2.20.04
            //location=@Location(value=Kind.LINE,line=180) for 3.20.07
            //location=@Location(value=Kind.LINE,line=182) for 3.20.10, 3.21.02
            location=@Location(value=Kind.LINE,line=186)
    )
    public static void ownThread(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception  {
        BTraceUtils.println("get into ownThread");
        BTraceUtils.println("---------------");
        BTraceUtils.Threads.jstack();
        Thread.sleep(1000L);
        BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss") + ", end ownThread");
        BTraceUtils.println("---------------");
    }
}