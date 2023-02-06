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
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Test redis6 command
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL redis6 
    else 
        APT_INSTALL redis6 
    fi
    systemctl start redis
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    systemctl status redis | grep running
    CHECK_RESULT $?
    redis-cli -r 3 ping | grep "PONG"
    CHECK_RESULT $?
    redis-cli -r 3 -i 1 ping | grep "PONG"
    CHECK_RESULT $?
    echo "test" | redis-cli -x set hello | grep "OK"
    CHECK_RESULT $?
    redis-cli --version | grep "redis-cli"
    CHECK_RESULT $?
    expect -c "
    set timeout 10
    log_file testlog
    spawn redis-cli -h 127.0.0.1 -p 6379
    expect {
        \"127.0.0.1:6379>\" { send \"bgsave\r\"
	expect \"127.0.0.1:6379>\" {send \"exit\r\"}
}
}
expect eof
"
    grep -iE "error|failed" testlog
    CHECK_RESULT $? 1
    test -f /var/lib/redis/dump.rdb
    CHECK_RESULT $?
    redis-check-rdb /var/lib/redis/dump.rdb | grep "OK"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    rm -rf testlog
    systemctl stop redis
    APT_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
