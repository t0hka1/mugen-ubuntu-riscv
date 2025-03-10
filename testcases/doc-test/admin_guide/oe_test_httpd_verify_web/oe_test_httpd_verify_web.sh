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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020.4-9
# @License   :   Mulan PSL v2
# @Desc      :   Verify that the web service is successfully built
# #############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "httpd net-tools firewalld" 
    else 
        APT_INSTALL "httpd net-tools firewalld" 
    fi
    systemctl start httpd
    systemctl start firewalld
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    ifconfig
    CHECK_RESULT $?
    firewall-cmd --add-service=http --permanent | grep success
    CHECK_RESULT $?
    firewall-cmd --reload | grep success
    CHECK_RESULT $?
    python3 -m http.server 8080 &
    SSH_CMD "curl http://${NODE1_IPV4}" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    kill -9 $(pgrep -f http.server)
    APT_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
