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
#@Author    	:   doraemon2020
#@Contact   	:   xcl_job@163.com
#@Date      	:   2020-10-13
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2html5 parameter coverage test of the python-docutils package
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cp -r ../common/testfile.rst ./
    cp -r ../common/template_html.txt ./
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "python-docutils" 
    else 
        APT_INSTALL "python-docutils" 
    fi
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2html5 --language=en-GB testfile.rst test1.html && grep 'lang="en-GB"' test1.html
    CHECK_RESULT $?
    rst2html5 --record-dependencies=recordlist.log testfile.rst test2.html && grep '.css' recordlist.log
    CHECK_RESULT $?
    test "$(rst2html5 -V | awk '{print$3}')" == "$(rpm -qa python3-docutils | awk -F "-" '{print$3}')"
    CHECK_RESULT $?
    rst2html5 -h | grep 'Usage'
    CHECK_RESULT $?
    rst2html5 --template=template_html.txt testfile.rst test5.html
    CHECK_RESULT $?
    grep '<table class="docinfo"' test5.html
    CHECK_RESULT $? 0 1
    rst2html5 --initial-header-level=2 testfile.rst test6.html
    CHECK_RESULT $?
    grep '<h1>' test6.html
    CHECK_RESULT $? 0 1
    rst2html5 --footnote-references=superscript testfile.rst test7.html && grep 'superscript' test7.html
    CHECK_RESULT $?
    rst2html5 --attribution=none testfile.rst test8.html && grep '<p class="attribution">Buckaroo Banzai' test8.html
    CHECK_RESULT $?
    rst2html5 --no-compact-lists testfile.rst test9.html && grep 'arabic' test9.html
    CHECK_RESULT $?
    rst2html5 --table-style=collapse testfile.rst test10.html && grep 'collapse' test10.html
    CHECK_RESULT $?
    rst2html5 --no-xml-declaration testfile.rst test11.html
    CHECK_RESULT $?
    grep 'xml version="1.0"' test11.html
    CHECK_RESULT $? 0 1
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf ./*.html ./*.rst ./*.log ./*.txt
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
