#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin_job@163.com
# @Date      :   2022-04-09
# @License   :   Mulan PSL v2
# @Desc      :   lvm2 command test
# ############################################
source ./common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL lvm2 
    else 
        APT_INSTALL lvm2 
    fi
    check_free_disk
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvcreate -y /dev/${local_disk}
    CHECK_RESULT $?
    pvs | grep "/dev/${local_disk}"
    CHECK_RESULT $?
    vgcreate test /dev/${local_disk}
    CHECK_RESULT $?
    vgrename test test1 | grep "successfully renamed"
    CHECK_RESULT $?
    vgs 2>&1 | grep "test1"
    CHECK_RESULT $?
    UUID=$(vgdisplay | grep "VG UUID" | sed -n 1p | awk {'print$3'})
    CHECK_RESULT $?
    vgrename ${UUID} new
    CHECK_RESULT $?
    vgs 2>&1 | grep "new"
    CHECK_RESULT $?
    vgrename new test --reportformat basic | grep "successfully renamed"
    CHECK_RESULT $?
    vgs 2>&1 | grep "test"
    CHECK_RESULT $?
    vgrename test new --autobackup y | grep "successfully renamed"
    CHECK_RESULT $?
    vgs 2>&1 | grep "new"
    CHECK_RESULT $?
    vgrename --version | grep "LVM version"
    CHECK_RESULT $?
    vgrename --help | grep "Rename a volume group"
    CHECK_RESULT $?
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    vgremove -f new
    pvremove -f /dev/${local_disk}
    APT_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
