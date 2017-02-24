APPLY_A53_ERRATA_FIXES :=
arch_variant_cflags :=

ifneq ($(filter kryo,$(TARGET_2ND_CPU_VARIANT)),)
	arch_variant_cflags := -mcpu=cortex-a57
endif

ifneq ($(filter cortex-a53,$(TARGET_2ND_CPU_VARIANT)),)
	arch_variant_cflags := -mcpu=cortex-a53
	APPLY_A53_ERRATA_FIXES := true
endif

ifneq ($(filter cortex-a53.a57,$(TARGET_2ND_CPU_VARIANT)),)
        arch_variant_cflags := -mcpu=cortex-a57
        APPLY_A53_ERRATA_FIXES := true
endif

ifneq ($(strip $(TARGET_IS_CORTEX-A53)),)
	APPLY_A53_ERRATA_FIXES := $(TARGET_IS_CORTEX-A53)
endif

ifeq ($(APPLY_A53_ERRATA_FIXES),true)
	arch_variant_cflags  += -mfix-cortex-a53-835769
	arch_variant_ldflags := -Wl,--fix-cortex-a53-843419
	arch_variant_ldflags += -Wl,--fix-cortex-a53-835769
else
	arch_variant_cflags  += -mno-fix-cortex-a53-835769
	arch_variant_ldflags := -Wl,--no-fix-cortex-a53-843419
	arch_variant_ldflags += -Wl,--no-fix-cortex-a53-835769
	RS_DISABLE_A53_WORKAROUND := true
endif

APPLY_A53_ERRATA_FIXES :=
