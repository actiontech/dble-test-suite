package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;

@BTrace(unsafe = true)
public final class GetSpecialNodeTablesHandlerFinished{
    private GetSpecialNodeTablesHandlerFinished(){

    }

    @OnMethod(
            clazz = "com.actiontech.dble.meta.table.GetSpecialNodeTablesHandler",
            method = "handleFinished"
    )
    public static void getSpecialNodeTablesHandlerFinished(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.print("get into getSpecialNodeTablesHandlerFinished ");
        BTraceUtils.print("for order __________________________ ");
        Thread.sleep(30000L);
    }

}