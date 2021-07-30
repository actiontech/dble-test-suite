package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.*;


@BTrace(unsafe = true)
public class BtraceLineDelay{
    @OnMethod(
            clazz="com.actiontech.dble.sqlengine.MultiTablesMetaJob",
            location=@Location(value=Kind.LINE,line=157)
    )
    public static void args(@Self Object self, @ProbeMethodName String pmn, int line) throws Exception {
        BTraceUtils.println("delay for NP test");
        BTraceUtils.println("for print order ...................");
        Thread.sleep(10000L);
    }
}