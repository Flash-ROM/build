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
LOCAL_DISABLE_GRAPHITE :=

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
POLLY :=-mllvm -polly \
	-mllvm -polly-parallel \
	-mllvm -polly-ast-use-context \
	-mllvm -polly-vectorizer=polly \
	-mllvm -polly-opt-fusion=max \
	-mllvm -polly-opt-maximize-bands=yes \
	-mllvm -polly-run-dce \
	-mllvm -polly-dependences-computeout=0 \
	-mllvm -polly-dependences-analysis-type=value-based \
	-mllvm -polly-run-inliner \
	-mllvm -polly-detect-keep-going \
	-mllvm -polly-rtc-max-arrays-per-group=40

# Those are mostly Bluetooth modules
DISABLE_POLLY_O3 := \
	audio.a2dp.default \
	bdAddrLoader \
	bdt \
        bdtest \
	bluetooth.mapsapi \
        bluetooth.default \
        bluetooth.mapsapi \
        libart-compiler \
        libbluetooth_jni \
        libbt% \
        libosi \
        ositests \
	net_bdtool \
        net_hci \
	net_test_btcore \
	net_test_device \
        net_test_osi \
        libxml2

# Disable modules that dont work with Polly. Split up by arch.
DISABLE_POLLY_arm := \
	healthd \
	libcrypto_static \
	libicuuc \
	libinputflinger \
	libjni_snapcammosaic \
	libjpeg_static \
	recovery

DISABLE_POLLY_arm64 := \
	healthd \
	libart \
	libaudioflinger \
	libaudioutils \
	libavcdec \
        libavcenc \
	libbnnmlowp \
	libcrypto \
	libcrypto_static \
	libF77blas \
        libFFTEm \
	libFraunhoferAAC \
	libicuuc \
	libinputflinger \
	libjni_snapcammosaic \
	libjpeg_static \
	libLLVM% \
	libmedia_jni \
	libmpeg2dec \
	libmusicbundle \
	libopus \
	libpdfium% \
	libreverb \
	libRS_internal \
	libRSCpuRef \
	libscrypt_static \
	libskia_static \
	libsonic \
	libstagefright% \
	libsvoxpico \
	libv8 \
	libvpx \
	libwebp-decode \
        libwebp-encode \
	libwebrtc% \
	recovery

# Set DISABLE_POLLY based on arch
LOCAL_DISABLE_POLLY := \
  $(DISABLE_POLLY_$(TARGET_ARCH))) \
  $(DISABLE_POLLY_O3)

# Set POLLY based on DISABLE_POLLY
ifeq (1,$(words $(filter $(LOCAL_DISABLE_POLLY),$(LOCAL_MODULE))))
  POLLY :=
endif

ifeq ($(my_sdclang), true)
    my_cflags += -Qunused-arguments
    my_cppflags += -Wno-unknown-warning
else ifeq ($(my_clang),true)
  ifndef LOCAL_IS_HOST_MODULE
    my_cflags := $(filter-out -g,$(my_cflags))
    # Enable Polly if not blacklisted.
    # Don't show unused warning on Clang and GCC
    my_cflags += $(POLLY) -Qunused-arguments
  endif
endif

ifeq ($(STRICT_ALIASING),true)
  my_cflags := $(filter-out -fno-strict-aliasing,$(my_cflags))
  ifneq (1,$(words $(filter $(LOCAL_DISABLE_STRICT),$(LOCAL_MODULE))))
    ifeq ($(my_clang),true)
      my_cflags += $(STRICT_ALIASING_FLAGS) $(STRICT_GLANG_LEVEL)
    else
      my_cflags += $(STRICT_ALIASING_FLAGS) $(STRICT_GCC_LEVEL)
    endif
  endif
endif

ifeq ($(GRAPHITE_OPTS),true)
  ifneq (1,$(words $(filter $(LOCAL_DISABLE_GRAPHITE),$(LOCAL_MODULE))))
    ifneq ($(my_clang),true)
      my_cflags += $(GRAPHITE_FLAGS)
    endif
  endif
endif

ifeq ($(O3_OPTS),true)
  my_cflags := $(filter-out -Wall -Werror -g -O3 -O2 -Os -O1 -O0 -Og -Oz -Wextra -Weverything,$(my_cflags))
  ifeq (1,$(words $(filter $(DISABLE_POLLY_O3),$(LOCAL_MODULE))))
      my_cflags += -O2
  else
      my_cflags += -O3
  endif
else
  my_cflags := $(filter-out -Wall -Werror -g -O3 -O2 -Os -O1 -O0 -Og -Oz -Wextra -Weverything,$(my_cflags))
  my_cflags += -O2
endif
