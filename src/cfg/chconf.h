#ifndef CHCONF_H
#define CHCONF_H

/* Kernel system options */
#define CH_CFG_USE_SEMAPHORES              FALSE
#define CH_CFG_USE_SEMAPHORES_PRIORITY     FALSE
#define CH_CFG_USE_MUTEXES                 FALSE
#define CH_CFG_USE_MUTEXES_RECURSIVE       FALSE
#define CH_CFG_USE_CONDVARS                FALSE
#define CH_CFG_USE_CONDVARS_TIMEOUT        FALSE
#define CH_CFG_USE_EVENTS                   FALSE
#define CH_CFG_USE_EVENTS_TIMEOUT           FALSE
#define CH_CFG_USE_MESSAGES                 FALSE
#define CH_CFG_USE_MESSAGES_PRIORITY        FALSE
#define CH_CFG_USE_DYNAMIC                  FALSE
#define CH_CFG_USE_WAITEXIT                 FALSE
#define CH_CFG_USE_OLD_POLICY               FALSE

/* Debug options */
#define CH_DBG_STATISTICS                   FALSE
#define CH_DBG_SYSTEM_STATE_CHECK           FALSE
#define CH_DBG_ENABLE_CHECKS                FALSE
#define CH_DBG_ENABLE_ASSERTS               FALSE
#define CH_DBG_TRACE_MASK                   0
#define CH_DBG_TRACE_BUFFER_SIZE            0
#define CH_DBG_ENABLE_STACK_CHECK           FALSE
#define CH_DBG_FILL_THREADS                 FALSE
#define CH_DBG_THREADS_PROFILING            FALSE

/* Mandatory hooks */
#define CH_CFG_THREAD_EXTRA_FIELDS          0
#define CH_CFG_THREAD_INIT_HOOK             NULL
#define CH_CFG_THREAD_EXIT_HOOK             NULL
#define CH_CFG_CONTEXT_SWITCH_HOOK          NULL
#define CH_CFG_IRQ_PROLOGUE_HOOK            NULL
#define CH_CFG_IRQ_EPILOGUE_HOOK            NULL
#define CH_CFG_IDLE_ENTER_HOOK              NULL
#define CH_CFG_IDLE_LEAVE_HOOK              NULL
#define CH_CFG_IDLE_LOOP_HOOK               NULL
#define CH_CFG_SYSTEM_TICK_HOOK             NULL
#define CH_CFG_SYSTEM_HALT_HOOK             NULL
#define CH_CFG_TRACE_HOOK                    NULL
#define CH_CFG_RUNTIME_FAULTS_HOOK          NULL

/* System extra fields */
#define CH_CFG_SYSTEM_EXTRA_FIELDS          0
#define CH_CFG_SYSTEM_INIT_HOOK             NULL
#define CH_CFG_OS_INSTANCE_INIT_HOOK        NULL
#define CH_CFG_OS_INSTANCE_EXTRA_FIELDS     0

#endif
