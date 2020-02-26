package com.actiontech.dble.btrace.script;
    import com.sun.btrace.BTraceUtils;
    import com.sun.btrace.annotations.BTrace;
    import com.sun.btrace.annotations.OnMethod;
    import com.sun.btrace.annotations.ProbeClassName;
    import com.sun.btrace.annotations.ProbeMethodName;
    @BTrace(unsafe = true)
    public final class BtraceDelayAfterDdl {

      private BtraceDelayAfterDdl() {

      }

      @OnMethod(
              clazz = "com.actiontech.dble.btrace.provider.ClusterDelayProvider",
              method = "delayAfterDdlExecuted"
      )
      public static void delayAfterDdlExecuted(@ProbeClassName String probeClass, @ProbeMethodName String probeMethod) throws Exception {
          BTraceUtils.print("get into delayAfterDdlExecuted ");
          BTraceUtils.print(" for order __________________________ ");
          Thread.sleep(60000L);
      }
    }