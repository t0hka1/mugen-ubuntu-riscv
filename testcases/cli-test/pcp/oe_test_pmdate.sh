#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-14
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmdate)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmdate -5y %y%m%d-%H:%M:%S | grep "$(date '+%m')"
    CHECK_RESULT $?
    pmdate +3m %y%m%d-%H:%M:%S | grep "$(date '+%d')"
    CHECK_RESULT $?
    pmdate -5d %y%m%d-%H:%M:%S | grep "$(date '+%H')"
    CHECK_RESULT $?
    pmdate +3H %y%m%d-%H:%M:%S | grep "$(date '+%M')"
    CHECK_RESULT $?
    pmdate -5M %y%m%d-%H:%M:%S | grep "$(date '+%S')"
    CHECK_RESULT $?
    pmdate +3S %y%m%d-%H:%M:%S | grep "$(date '+%y')"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
