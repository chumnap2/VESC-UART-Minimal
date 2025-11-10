// Stub chcore.h for minimal compilation
#define PORT_SUPPORTS_RT             1
#define PORT_NATURAL_ALIGN           4
#define PORT_STACK_ALIGN             8
#define PORT_WORKING_AREA_ALIGN      8
#define PORT_ARCHITECTURE_NAME       "ARM Cortex-M4"
#define PORT_CORE_VARIANT_NAME       "Cortex-M4"
#define PORT_INFO                    "Stub ChibiOS port"
#define PORT_IRQ_IS_VALID_PRIORITY(x)   1
#define PORT_IRQ_IS_VALID_KERNEL_PRIORITY(x) 1
#define PORT_SETUP_CONTEXT(tp, pf, arg) ((void)0)
#define PORT_WA_SIZE                    128
#define PORT_IRQ_PROLOGUE()             ((void)0)
#define PORT_IRQ_EPILOGUE()             ((void)0)
#define PORT_IRQ_HANDLER()              ((void)0)
#define PORT_FAST_IRQ_HANDLER()         ((void)0)
