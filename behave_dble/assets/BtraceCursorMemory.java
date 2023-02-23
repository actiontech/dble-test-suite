package com.actiontech.dble.assets;

import com.sun.btrace.annotations.*;

import static com.sun.btrace.BTraceUtils.Strings.strcat;
import static com.sun.btrace.BTraceUtils.jstack;
import static com.sun.btrace.BTraceUtils.println;
import static com.sun.btrace.BTraceUtils.str;
import static com.sun.btrace.BTraceUtils.Reflective;
import com.sun.btrace.BTraceUtils;

@BTrace(unsafe = true)
public class BtraceCursorMemory {

    @OnMethod(
            clazz="com.actiontech.dble.backend.mysql.store.CursorCacheForGeneral",
            method="add"
    )
    public static void func(@Self Object self) throws Exception {
        BTraceUtils.println("get into CursorCacheForGeneral.add");
        BTraceUtils.println("---------------");
        BTraceUtils.Threads.jstack();
        BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss"));
        Object localResult =Reflective.get("localResult",self);
        // currentMemory
        BTraceUtils.printFields(localResult);
        Thread.sleep(10L);
        BTraceUtils.println("sleep end ");
        BTraceUtils.println("---------------");
    }
}
