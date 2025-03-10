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
# @Date      :   2020/11/9
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlopt.opt under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL ocaml 
    else 
        APT_INSTALL ocaml 
    fi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlopt.opt -depend -map /usr/lib64/ocaml/filename.ml /usr/lib64/ocaml/filename.mli | grep -c "cmi" | grep 1
    CHECK_RESULT $?
    ocamlopt.opt -depend -modules /usr/lib64/ocaml/filename.ml | grep "Printf Random String Sys"
    CHECK_RESULT $?
    ocamlopt.opt -depend -native /usr/lib64/ocaml/filename.ml | grep -E ".cmo"
    CHECK_RESULT $? 1
    ocamlopt.opt -depend -bytecode /usr/lib64/ocaml/filename.ml | grep -E ".cmx"
    CHECK_RESULT $? 1
    ocamlopt.opt -depend -open Printf /usr/lib64/ocaml/filename.ml | grep -E ".cmi|.cmo|.cmx"
    CHECK_RESULT $?
    ocamlopt.opt -depend -shared /usr/lib64/ocaml/filename.ml | grep "cmxs"
    CHECK_RESULT $?
    ocamlopt.opt -depend -sort /usr/lib64/ocaml/filename.ml /usr/lib64/ocaml/filename.mli | grep "/usr/lib64/ocaml/filename.mli /usr/lib64/ocaml/filename.ml"
    CHECK_RESULT $?
    ocaml_version=$(rpm -qa ocaml | awk -F '-' '{print $2}')
    ocamlopt.opt -depend -version example.ml | grep -E "ocamldep|$ocaml_version"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
