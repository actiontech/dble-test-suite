package com.actiontech.dble.btrace.script;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;
/*
 the vars1 about hreatbeat
 purpose:sleep after send "select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only" to mysql
 usage:always  use together with SelectGlobalVars2
 1. First use SelectGlobalVars1.java
 2. After the stub in step 1 works (for example, after printing two lines of logs), start the second breakpoint SelectGlobalVars2.java
 3. Kill the connection after seeing the "select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only" connection in the mysql node
*/
@BTrace(unsafe = true)
public final class SelectGlobalVars1 {

    private SelectGlobalVars1() {

    }

    @OnMethod(
            clazz = "com.actiontech.dble.config.helper.GetAndSyncDbInstanceKeyVariables",
            method = "call"
    )
    public static void call(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
        BTraceUtils.println("get into call");
        BTraceUtils.print(" sleep __________________________ ");
        Thread.sleep(3000L);
    }

}