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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-06-08
# @License   :   Mulan PSL v2
# @Desc      :   Background run container (run in background after creation)
# ############################################

source ../common/prepare_docker.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_docker_env
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    containers_id=$(docker run -d ${Images_name} /bin/sh -c "while true;do echo hello world;sleep 1;done")
    CHECK_RESULT $?
    docker inspect -f {{.State.Status}} ${containers_id} | grep running
    CHECK_RESULT $?
    
    docker logs ${containers_id} | grep "hello world"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    clean_docker_env
    APT_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
