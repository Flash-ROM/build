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
	libc% \
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

CUSTOM_FLAGS := -O3 -g0 -DNDEBUG
O_FLAGS := -O3 -O2 -Os -O1 -O0 -Og -Oz

# Remove all flags we don't want use high level of optimization
my_cflags := $(filter-out -Wall -Werror -g -Wextra -Weverything $(O_FLAGS),$(my_cflags)) $(CUSTOM_FLAGS)
my_cppflags := $(filter-out -Wall -Werror -g -Wextra -Weverything $(O_FLAGS),$(my_cppflags)) $(CUSTOM_FLAGS)
my_conlyflags := $(filter-out -Wall -Werror -g -Wextra -Weverything $(O_FLAGS),$(my_conlyflags)) $(CUSTOM_FLAGS)

# IPA
ifndef LOCAL_IS_HOST_MODULE
  ifeq (,$(filter true,$(my_clang)))
    my_cflags += -fipa-sra -fipa-pta -fipa-cp -fipa-cp-clone
  else
    my_cflags += -analyze -analyzer-purge
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

ifndef LOCAL_IS_HOST_MODULE
  ifeq ($(GRAPHITE_OPTS),true)
    # Enable graphite only on GCC
    ifneq ($(LOCAL_CLANG),true)
      my_cflags += $(GRAPHITE_FLAGS)
    endif
  endif
endif
