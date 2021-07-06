package com.actiontech.dble.assets;

import com.sun.btrace.annotations.*;

import static com.sun.btrace.BTraceUtils.Strings.strcat;
import static com.sun.btrace.BTraceUtils.jstack;
import static com.sun.btrace.BTraceUtils.println;
import static com.sun.btrace.BTraceUtils.str;
import static com.sun.btrace.BTraceUtils.Reflective;
import com.sun.btrace.BTraceUtils;

@BTrace(unsafe = true)
public class BtraceCursorBuffer {

    @OnMethod(
            clazz="com.actiontech.dble.backend.mysql.store.diskbuffer.UnSortedResultDiskBuffer",
            method="next"
    )
    public static void func(@Self Object self) {
        BTraceUtils.println("get into UnSortedResultDiskBuffer.next");
        BTraceUtils.println("---------------");
        BTraceUtils.Threads.jstack();
        BTraceUtils.println(BTraceUtils.Time.timestamp("yyyy-MM-dd HH:mm:ss"));
        Object obj =Reflective.get("mainTape",self);
        BTraceUtils.printFields(obj); //readBuffer => cap
        BTraceUtils.println("---------------");
    }
}
