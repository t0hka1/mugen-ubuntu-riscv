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
# @Author    :   duanxuemin
# @Contact   :   duanxuemin@163.com
# @Date      :   2020-06-09
# @License   :   Mulan PSL v2
# @Desc      :   Copy between container and host
# ############################################

source ../common/prepare_isulad.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_isulad_env
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    run_isulad_container

    test -d testdir || mkdir testdir
    touch testdir/mytest.txt
    isula cp testdir ${containerId}:/tmp
    CHECK_RESULT $?
    isula exec -it ${containerId} /bin/sh -c "ls /tmp/testdir" | grep mytest.txt
    CHECK_RESULT $?

    isula cp ${containerId}:/tmp .
    CHECK_RESULT $?
    test -f tmp/testdir/mytest.txt
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf testdir tmp
    clean_isulad_env
    APT_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
