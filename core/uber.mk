# Copyright (C) 2014-2015 UBER
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

###################
# Strict Aliasing #
###################
LOCAL_DISABLE_STRICT := \
	libpdfiumfpdfapi \
	mdnsd

STRICT_ALIASING_FLAGS := \
	-fstrict-aliasing \
	-Werror=strict-aliasing

STRICT_GCC_LEVEL := \
	-Wstrict-aliasing=3

STRICT_CLANG_LEVEL := \
	-Wstrict-aliasing=2

############
# GRAPHITE #
############

LOCAL_DISABLE_GRAPHITE := \
	libfec_rs \
	libfec_rs_host \

GRAPHITE_FLAGS := \
	-fgraphite \
	-fgraphite-identity \
	-floop-flatten \
	-floop-parallelize-all \
	-ftree-loop-linear \
	-floop-interchange \
	-floop-strip-mine \
	-floop-block

#########
# POLLY #
#########

# Polly flags for use with Clang
POLLY := \
	-mllvm -polly \
	-mllvm -polly-parallel -lgomp \
	-mllvm -polly-run-inliner \
	-mllvm -polly-opt-fusion=max \
	-mllvm -polly-ast-use-context \
	-mllvm -polly-opt-maximize-bands=yes \
	-mllvm -polly-run-dce \
	-mllvm -polly-opt-simplify-deps=no \
	-mllvm -polly-position=after-loopopt

# Those are mostly Bluetooth modules
DISABLE_POLLY_O3 := \
	audio.a2dp.default \
	bdAddrLoader \
	bdt \
	bdtest \
	bluetooth.mapsapi \
	bluetooth.default \
	bluetooth.mapsapi \
	libbluetooth_jni \
	libbt% \
	libosi \
	ositests \
	net_bdtool \
	net_hci \
	net_test_btcore \
	net_test_device \
	net_test_osi

# Disable modules that dont work with Polly. Split up by arch.
DISABLE_POLLY_arm := \
	libandroid \
	libcrypto \
	libcrypto_static \
	libFraunhoferAAC \
	libjpeg_static \
	libLLVM% \
	libopus \
	libpdfium% \
	libskia_static \
	libstagefright%

DISABLE_POLLY_arm64 := \
	$(DISABLE_POLLY_arm) \
	libaudioutils \
	libmedia_jni \
	libRSCpuRef \
	libscrypt_static \
	libsvoxpico

# Set DISABLE_POLLY based on arch
LOCAL_DISABLE_POLLY := \
	$(DISABLE_POLLY_$(TARGET_ARCH))) \
	$(DISABLE_POLLY_O3)

# We just don't want these flags
my_cflags := $(filter-out -Wall -Werror -g -Wextra -Weverything,$(my_cflags))
my_cppflags := $(filter-out -Wall -Werror -g -Wextra -Weverything,$(my_cppflags))
my_conlyflags := $(filter-out -Wall -Werror -g -Wextra -Weverything,$(my_conlyflags))

ifneq (1,$(words $(filter $(DISABLE_POLLY_O3),$(LOCAL_MODULE))))
  # Remove all other "O" flags to set O3
  my_cflags := $(filter-out -O3 -O2 -Os -O1 -O0 -Og -Oz,$(my_cflags))
  my_cflags += -O3
else
  my_cflags += -O2
endif

ifeq ($(my_sdclang), true)
  # Do not enable POLLY on libraries
  ifndef LOCAL_IS_HOST_MODULE
    # Enable POLLY if not blacklisted
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_POLLY),$(LOCAL_MODULE))))
      # Enable POLLY only on clang
      ifneq ($(LOCAL_CLANG),false)
        my_cflags += $(POLLY) -Qunused-arguments -fuse-ld=gold
        my_ldflags += -fuse-ld=gold
      endif
    endif
  endif
endif

ifeq ($(LOCAL_CLANG),false)
  my_cflags += -Wno-unknown-warning
endif

ifeq ($(STRICT_ALIASING),true)
  # Remove the no-strict-aliasing flags
  my_cflags := $(filter-out -fno-strict-aliasing,$(my_cflags))
  ifneq (1,$(words $(filter $(LOCAL_DISABLE_STRICT),$(LOCAL_MODULE))))
    ifneq ($(LOCAL_CLANG),false)
      my_cflags += $(STRICT_ALIASING_FLAGS) $(STRICT_GLANG_LEVEL)
    else
      my_cflags += $(STRICT_ALIASING_FLAGS) $(STRICT_GCC_LEVEL)
    endif
  endif
endif

ifeq ($(GRAPHITE_OPTS),true)
  # Enable graphite only on GCC
  ifneq ($(LOCAL_CLANG),false)
    my_cflags += $(GRAPHITE_FLAGS)
  endif
endif
