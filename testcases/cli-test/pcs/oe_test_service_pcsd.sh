#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wenjun
# @Contact   :   1009065695@qq.com
# @Date      :   2021/12/29
# @License   :   Mulan PSL v2
# @Desc      :   Test pcsd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL pcs 
    else 
        APT_INSTALL pcs 
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    test_execution pcsd.service
    test_reload pcsd.service
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop pcsd.service
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
