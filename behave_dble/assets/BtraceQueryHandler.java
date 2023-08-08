package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public final class BtraceQueryHandler {

    private BtraceQueryHandler() {
    }

   /**
    * shardingUser
    */
    @OnMethod(
            clazz = "com.actiontech.dble.server.ServerQueryHandler",
            method = "query"
    )
    public static void shardingQuery(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into shardingQuery");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println("shardingQuery sleep end");
        BTraceUtils.println("---------------");
    }

   /**
    * rwSplitUser
    */
    @OnMethod(
            clazz = "com.actiontech.dble.services.rwsplit.RWSplitQueryHandler",
            method = "query"
    )
    public static void rwSplitQuery(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into rwSplitQuery");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println("rwSplitQuery sleep end");
        BTraceUtils.println("---------------");
    }

   /**
    * managerUser
    */
    @OnMethod(
            clazz = "com.actiontech.dble.services.manager.ManagerQueryHandler",
            method = "query"
    )
    public static void managerQuery(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into managerQuery");
        BTraceUtils.println("---------------");
        Thread.sleep(1L);
        BTraceUtils.println("managerQuery sleep end");
        BTraceUtils.println("---------------");
    }
}