#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
# #############################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/15
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in swig package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL swig 
    else 
        APT_INSTALL swig 
    fi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    swig -java -templatereduce example.i
    CHECK_RESULT $?
    grep -i "type" example_wrap.c
    CHECK_RESULT $?
    swig_version=$(rpm -qa swig | awk -F '-' '{print $2}')
    swig -java -version example.i | grep "${swig_version}"
    CHECK_RESULT $?
    swig -java -Wall example.i
    CHECK_RESULT $?
    grep -i "warn" example_wrap.c
    CHECK_RESULT $?
    swig -java -Wallkw example.i
    CHECK_RESULT $?
    grep -i "silence that warning" example_wrap.c
    CHECK_RESULT $?
    swig -java -Werror example.i
    CHECK_RESULT $?
    grep -i "JavaOutOfMemoryError = 1" example_wrap.c
    CHECK_RESULT $?
    swig -java -Wextra example.i
    CHECK_RESULT $?
    grep -i "erro" example_wrap.c
    CHECK_RESULT $?
    swig -java -w401 example.i
    CHECK_RESULT $?
    grep -i "4505" example_wrap.c
    CHECK_RESULT $?
    swig -java -xmlout outfile1 example.i
    CHECK_RESULT $?
    grep "xml version=" outfile1
    CHECK_RESULT $?
    swig -tcl -itcl example.i
    CHECK_RESULT $?
    test -f example.itcl && rm -rf example.itcl
    CHECK_RESULT $?
    grep "tclrun.swg" example_wrap.c
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf $(ls | grep -vE ".sh|example.i")
    LOG_INFO "End to restore the test environment."
}

main "$@"
