#!/bin/bash

export KERNEL_ROOT="$(pwd)"

TOOLCHAIN_URL="https://github.com/trantranphi1992/kernel/releases/download/toolchain/toolchain.tar.gz"
TOOLCHAIN_ARCHIVE="${KERNEL_ROOT}/toolchain.tar.gz"
TOOLCHAIN_DST="${KERNEL_ROOT}/kernel_platform"

# Định nghĩa đường dẫn các thư mục cần kiểm tra
# 1. kernel_platform/prebuilts
CHECK_DIR_1="${TOOLCHAIN_DST}/prebuilts"
# 2. prebuilts-master (Giả sử nằm ở thư mục gốc KERNEL_ROOT, bạn hãy sửa lại đường dẫn nếu nó nằm chỗ khác)
CHECK_DIR_2="${TOOLCHAIN_DST}/prebuilts-master"

# Kiểm tra: Nếu cả 2 thư mục ĐÃ tồn tại thì báo Skip
if [ -d "${CHECK_DIR_1}" ] && [ -d "${CHECK_DIR_2}" ]; then
    echo -e "\n[INFO]: Toolchain directories already exist. Skipping download."
else
    # Nếu thiếu một trong hai (hoặc cả hai) thì tiến hành download
    echo -e "\n[INFO]: Toolchain not found or incomplete. Downloading..."
    
    curl -L --fail -o "${TOOLCHAIN_ARCHIVE}" "${TOOLCHAIN_URL}" || exit 1

    echo -e "\n[INFO]: Extracting toolchain into ${TOOLCHAIN_DST} ..."
    mkdir -p "${TOOLCHAIN_DST}" || exit 1
    tar -xzf "${TOOLCHAIN_ARCHIVE}" -C "${TOOLCHAIN_DST}" || exit 1
    
    echo -e "\n[INFO]: Toolchain setup completed."
fi

#1. target config
BUILD_TARGET=b0q_gbl_openx
export MODEL=$(echo ${BUILD_TARGET} | cut -d'_' -f1)
export PROJECT_NAME=${MODEL}
export REGION=$(echo ${BUILD_TARGET} | cut -d'_' -f2)
export CARRIER=$(echo ${BUILD_TARGET} | cut -d'_' -f3)
export TARGET_BUILD_VARIANT= user
                        
#2. Chipset common config
CHIPSET_NAME=waipio
export ANDROID_BUILD_TOP=$(pwd)
export TARGET_PRODUCT=gki
export TARGET_BOARD_PLATFORM=gki

export ANDROID_PRODUCT_OUT=${ANDROID_BUILD_TOP}/out/target/product/${MODEL}
export STRIP_PATH=${ANDROID_BUILD_TOP}/kernel_platform/prebuilts-master/clang/host/linux-x86/clang-r416183b/bin/llvm-strip
export OUT_DIR=${ANDROID_BUILD_TOP}/out/msm-${CHIPSET_NAME}-${CHIPSET_NAME}-${TARGET_PRODUCT}


# for Lcd(techpack) driver build
export KBUILD_EXTRA_SYMBOLS=${ANDROID_BUILD_TOP}/out/vendor/qcom/opensource/mmrm-driver/Module.symvers

# for Audio(techpack) driver build
export MODNAME=audio_dlkm

export KBUILD_EXT_MODULES="../vendor/qcom/opensource/datarmnet/core  ../vendor/qcom/opensource/datarmnet-ext/shs ../vendor/qcom/opensource/dataipa/drivers/platform/msm ../vendor/qcom/opensource/mmrm-driver ../vendor/qcom/opensource/audio-kernel ../vendor/qcom/opensource/camera-kernel ../vendor/qcom/opensource/display-drivers/msm ../vendor/qcom/opensource/video-driver ../vendor/qcom/opensource/eva-kernel ../vendor/qcom/opensource/datarmnet-ext/wlan ../vendor/qcom/opensource/datarmnet-ext/aps ../vendor/qcom/opensource/datarmnet-ext/offload ../vendor/qcom/opensource/datarmnet-ext/perf ../vendor/qcom/opensource/datarmnet-ext/perf_tether ../vendor/qcom/opensource/datarmnet-ext/sch "

#3. build kernel
RECOMPILE_KERNEL=1 ./kernel_platform/build/android/prepare_vendor.sh sec ${TARGET_PRODUCT}

