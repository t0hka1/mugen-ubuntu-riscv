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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2022/04/22
# @License   :   Mulan PSL v2
# @Desc      :   Firewall change default zone
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL httpd 
    else 
        APT_INSTALL httpd 
    fi
    sudo systemctl start httpd
    sudo systemctl start firewalld
    default_zone=$(sudo firewall-cmd --get-default-zone)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    sudo firewall-cmd --add-service=http --zone=home
    CHECK_RESULT $?
    get_zone_interface=$(sudo sudo firewall-cmd --get-zone-of-interface="$NODE1_NIC")
    if [ ! -z "$get_zone_interface" ]; then
        sudo firewall-cmd --zone="$get_zone_interface" --remove-interface="$NODE1_NIC"
    fi
    sudo firewall-cmd --set-default-zone home
    CHECK_RESULT $?
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --set-default-zone "$default_zone"
    if [ ! -z "$get_zone_interface" ]; then
        sudo firewall-cmd --zone="$get_zone_interface" --add-interface="$NODE1_NIC"
    fi
    sudo firewall-cmd --remove-service=http --zone=home
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    sudo systemctl stop httpd
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
