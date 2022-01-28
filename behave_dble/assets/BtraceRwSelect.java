package btrace;

import com.sun.btrace.BTraceUtils;
import com.sun.btrace.annotations.BTrace;
import com.sun.btrace.annotations.OnMethod;
import com.sun.btrace.annotations.ProbeClassName;
import com.sun.btrace.annotations.ProbeMethodName;

@BTrace(unsafe = true)
public class BtraceRwSelect{

    @OnMethod(
            clazz = "com.actiontech.dble.backend.datasource.PhysicalDbGroup",
            method = "rwSelect"
    )
    public static void handle(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
       BTraceUtils.println("get into rwSelect");
       BTraceUtils.println("------------------------");
       Thread.sleep(5000L);
       BTraceUtils.println("sleep end ");
       BTraceUtils.println(" __________________________ ");
    }
}