#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   zhangyili2
#@Contact   	:   yili@isrc.iscas.ac.cn
#@Date      	:   2022-03-03 09:39:43
#@License   	:   Mulan PSL v2
#@Desc      	:   Test Command rootsh
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "rootsh" 
    else 
        APT_INSTALL "rootsh" 
    fi
    useradd testUser
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    ! rootsh -h 2>&1 | grep "invalid option" && rootsh -h 2>&1 | grep "Usage: rootsh"
    CHECK_RESULT $? 0 0 "Failed option: -h"

    ! rootsh -V 2>&1 | grep "invalid option" && rootsh -V 2>&1 | grep "rootsh version"
    CHECK_RESULT $? 0 0 "Failed option: -V"

    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh -i
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
			    catch wait result
			    exit [lindex \$result 3]
		    }
        }  
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: -i"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: -i"
    rm -f /var/log/test.log

    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh -u testUser
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: -u"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: -u"
    rm -f /var/log/test.log

    expect <<EOF
        spawn rootsh -u zhangsan
        expect "*does not exist" {
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
EOF
    CHECK_RESULT $? 1 0 "Failed option: -u"

    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh -f log_test
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: -f"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: -f"
    rm -f /var/log/test.log

    dir=/root/my_log
    if [ ! -d "$dir" ]; then
        mkdir $dir
    fi
    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh -d /root/my_log 
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: -d"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: -d"
    rm -f /var/log/test.log

    expect <<EOF
        spawn rootsh -d /root/others_log
        expect "*No such file or directory" {
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
EOF
    CHECK_RESULT $? 1 0 "Failed option: -d"

    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh --no-logfile
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --no-logfile"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: --no-logfile"
    rm -f /var/log/test.log

    expect <<EOF
        log_file /var/log/test.log
        spawn rootsh --no-syslog
        expect "Welcome*" {
            exec sleep 1
            send "exit\r"
            expect eof {
                catch wait result
			    exit [lindex \$result 3]
            }
        }
        exit 1
EOF
    CHECK_RESULT $? 0 0 "Failed option: --no-syslog"
    cat /var/log/test.log | grep -E "Welcome"
    CHECK_RESULT $? 0 0 "Failed option: --no-syslog"
    rm -f /var/log/test.log

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    userdel testUser
    LOG_INFO "End to restore the test environment."
}

main "$@"
