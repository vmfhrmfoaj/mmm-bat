#!/bin/bash

# test-mmm-bat.sh, Copyright (C) 2013-2014 Jinseop Kim(vmfhrmfoaj@yahoo.com)
# test-mmm-bat.sh comes with ABSOLUTELY NO WARRANTY; for details
# type LICENSE file.  This is free software, and you are welcome
# to redistribute it under certain conditions; type LICENSE
# for details.
# If the LICENSE file does not exist,
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

. test-mmm-bat.inc
. mmm-bat.sh
. mock-mmm-bat.sh

function oneTimeSetUp() {
  mkdir -p build
  touch build/envsetup.sh
}

function oneTimeTearDown() {
  rm -rf build
}

function testIfThereAreNotEnoughParms() {
  # set up
  local dir=`pwd`

  # exercise
  local is_valid=$(checkParams ${dir})

  # verify
  assertEquals "INVALID" ${is_valid}
}

function testBadParam() {
  # set up
  local dir="bad-dir"
  local product_name="test"

  # exercise
  local is_valid=$(checkParams ${dir} ${product_name})

  # verify
  assertEquals "INVALID" ${is_valid}
}

function testNormalParam() {
  # set up
  local dir=`pwd`
  local product_name="test"

  # exercise
  local is_valid=$(checkParams ${dir} ${product_name})

  # verify
  assertEquals "VALID" ${is_valid}
}

function testCheckBuildErrorWithNoErrorLog() {
  # set up
  local temp_no_error_log_file="temp-no-error-log-file"
  echo "${no_error_log}" > ${temp_no_error_log_file}

  # exercise
  local is_error=$(isError ${temp_no_error_log_file})

  # verify
  assertEquals "NO" ${is_error}

  # tear down
  rm -rf ${temp_no_error_log_file}
}

function testCheckBuildErrorWithErrorLog() {
  # set up
  local temp_error_log_file="temp-error-log-file"
  echo "${error_log}" > ${temp_error_log_file}

  # exercise
  local is_error=$(isError ${temp_error_log_file})

  # verify
  assertEquals "YES" ${is_error}

  # tear down
  rm -rf ${temp_error_log_file}
}

function testGeneratePushScript() {
  # set up
  local temp_install_log_file="temp-install-log-file"
  echo "${install_log}" > ${temp_install_log_file}

  # exercise
  local push_script=$(genPushScript ${temp_install_log_file})

  # verify
  local diff=$(diff -c <(echo "${push_script_for_install_log}") \
                       <(echo "${push_script}"))

  assertTrue "${diff}" \
    "[ \"${push_script_for_install_log}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${temp_install_log_file}
}

function testGeneratePushScriptWithError() {
  # set up
  local temp_error_log_file="temp-error-log-file"
  echo "${error_log}" > ${temp_error_log_file}

  # exercise
  local push_script=$(genPushScript ${temp_error_log_file})

  # verify
  local diff=$(diff -c <(echo "${push_script_for_error_log}" ) \
                       <(echo "${push_script}"))
  assertTrue "${diff}" \
    "[ \"${push_script_for_error_log}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${temp_error_log_file}
}

function testJoinPushScript() {
  # exercise
  local push_script=$(joinPushScript "${push_script_for_install_log}" \
                                     "${push_script_for_no_error_log}")

  # verify
  local diff=$(diff -c <(echo "${append_push_script}") <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${append_push_script}\" == \"${push_script}\" ]"
}

function testJoinPushScriptWithFiles_1() {
  # set up
  local input_1="temp_1"
  local input_2="temp_2"
  local output="temp_1"

  echo "${push_script_for_install_log}" > ${input_1}
  echo "${push_script_for_no_error_log}" > ${input_2}

  # exercise
  joinPushScript "$(cat ${input_1})" "$(cat ${input_2})" > ${output}

  # verify
  local push_script=$(cat ${output})
  local diff=$(diff -c <(echo "${append_push_script}") <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${append_push_script}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${input_1}
  rm -rf ${input_2}
  rm -rf ${output}
}

function testJoinPushScriptWithFiles_2() {
  # set up
  local input_1="temp_1"
  local input_2="temp_2"
  local output="temp_2"

  echo "${push_script_for_install_log}" > ${input_1}
  echo "${push_script_for_no_error_log}" > ${input_2}

  # exercise
  joinPushScript "$(cat ${input_1})" "$(cat ${input_2})" > ${output}

  # verify
  local push_script=$(cat ${output})
  local diff=$(diff -c <(echo "${append_push_script}") <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${append_push_script}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${input_1}
  rm -rf ${input_2}
  rm -rf ${output}
}

function testChangeModeForBinaryFiles() {
  # set up
  local temp_bin_log_file="temp-bin-log-file"
  echo "${binary_log}" > ${temp_bin_log_file}

  # exercise
  local push_script=$(genPushScript ${temp_bin_log_file})

  # verify
  local diff=$(diff -c <(echo "${push_script_for_binary_log}" ) \
                       <(echo "${push_script}"))

  assertTrue "${diff}" \
    "[ \"${push_script_for_binary_log}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${temp_bin_log_file}
}

function testRemoveScriptFileIfEmtpy() {
  # set up
  local temp_script_file1="temp-script-file-1"
  local temp_install_log_file="temp-install-log-file"
  echo "${install_log}" > ${temp_install_log_file}
  genPushScript ${temp_install_log_file} > ${temp_script_file1}

  local temp_script_file2="temp-script-file-2"
  local temp_no_install_log_file="temp-no-install-log-file"
  echo "${no_install_log}" > ${temp_no_install_log_file}
  genPushScript ${temp_no_install_log_file} > ${temp_script_file2}

  # exercise & verify
  removeScriptFileIfEmpty ${temp_script_file1}
  assertTrue "not existing ${temp_script_file1}" \
    "[ -f \"${temp_script_file1}\" ]"

  removeScriptFileIfEmpty ${temp_script_file2}
  assertFalse "existing ${temp_script_file2}" "[ -f \"${temp_script_file2}\" ]"

  # tear down
  rm -rf ${temp_script_file1}
  rm -rf ${temp_script_file2}
  rm -rf ${temp_install_log_file}
  rm -rf ${temp_no_install_log_file}
}

function testShowErrorMessage() {
  # set up
  local temp_error_log_file="temp-error-log-file"
  echo "${error_log}" > ${temp_error_log_file}

  # exercise
  local err_msg=$(showError ${temp_error_log_file})

  # verify
  local diff=$(diff -c <(echo "${err_msg_for_error_log}" ) <(echo "${err_msg}"))
  assertTrue "${diff}" "[ \"${err_msg_for_error_log}\" == \"${err_msg}\" ]"

  # tear down
  rm -rf ${temp_error_log_file}
}

function testShowInstallMessage() {
  # set up
  local temp_error_log_file="temp-error-log-file"
  echo "${error_log}" > ${temp_error_log_file}

  # exercise
  local install_msg=$(showInstalled ${temp_error_log_file})

  # verify
  local diff=$(diff -c <(echo "${install_msg_for_error_log}" ) \
                       <(echo "${install_msg}"))

  assertTrue "${diff}" \
    "[ \"${install_msg_for_error_log}\" == \"${install_msg}\" ]"

  # tear down
  rm -rf ${temp_error_log_file}
}

function testBuild() {
  # set up
  local log_file='temp-log-file'
  local push_file='temp-push-script'
  mmm_log=${install_log}

  # exercise
  build . 'test' ${log_file} ${push_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${push_script_for_install_log}" ) \
                       <(echo "${push_script}"))

  assertTrue "${diff}" \
    "[ \"${push_script_for_install_log}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${log_file}
  rm -rf ${push_file}
}

function testBuildWithError() {
  # set up
  local log_file='temp-error-log-file'
  local push_file='temp-push-script-for-error'
  mmm_log=${error_log}

  # exercise
  build . 'test' ${log_file} ${push_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${push_script_for_error_log}" ) \
                       <(echo "${push_script}"))

  assertTrue "${diff}" \
    "[ \"${push_script_for_error_log}\" == \"${push_script}\" ]"
  assertTrue "not existing ${error_script_file}" \
    "[ -f \"${error_script_file}\" ]"

  # tear down
  rm -rf ${log_file}
  rm -rf ${push_file}
  rm -rf ${error_script_file}
}

function testBuildAfterError() {
  # set up
  local log_file='temp-log-file'
  local push_file='temp-push-script'
  mmm_log=${install_log}

  echo "${push_script_for_error_log}" > ${error_script_file}

  # exercise
  build . 'test' ${log_file} ${push_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${push_script_for_install_error_log}" ) \
                       <(echo "${push_script}"))

  assertTrue "${diff}" \
    "[ \"${push_script_for_install_error_log}\" == \"${push_script}\" ]"
  assertFalse "existing ${error_script_file}" "[ -f \"${error_script_file}\" ]"

  # tear down
  rm -rf ${log_file}
  rm -rf ${push_file}
  rm -rf ${error_script_file}
}

function testBuildWithAppendMode() {
  # set up
  local log_file='temp-log-file'
  local push_file='temp-push-script'
  local append_file='temp-push-spcript'
  mmm_log=${install_log}

  echo "${push_script_for_no_error_log}" > ${append_file}

  # exercise
  build . 'test' ${log_file} ${push_file} ${append_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${append_push_script}") <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${append_push_script}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${log_file}
  rm -rf ${push_file}
  rm -rf ${append_file}
}

function testCustomBuild() {
  # set up
  local log_file='temp-log-file'
  local push_file='temp-push-script'
  local check_param_file='temp-check-param'

  echo "echo \$1 > ${check_param_file}" > ${custom_build_command}
  echo "echo \"${install_log}\"" >> ${custom_build_command}

  # exercise
  build . 'custom' ${log_file} ${push_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${push_script_for_install_log}" ) \
                       <(echo "${push_script}"))

  assertTrue "${diff}" \
    "[ \"${push_script_for_install_log}\" == \"${push_script}\" ]"

  local diff=$(diff -c <(echo ".") "${check_param_file}")
  assertTrue "${diff}" \
    "[ \".\" == \"$(cat ${check_param_file})\" ]"

  # tear down
  rm -rf ${log_file}
  rm -rf ${push_file}
  rm -rf ${custom_build_command}
  rm -rf ${check_param_file}
}

function testGetRootPath() {
  # set up
  local path="/home/user/project/android/a/b/c"
  local expected="/home/user/project/android"

  # exercise
  res=$(getRootPath ${path})

  # verify
  assertEquals ${expected} ${res}

  # set up
  local path="/home/user/project/no-android/a/b/c"
  local expected="BAD-PATH"

  # exercise
  res=$(getRootPath ${path})

  # verify
  assertEquals ${expected} ${res}
}

function testGetTargetPath() {
  # set up
  local path="/home/user/project/android/a/b/c"
  local expected="a/b/c"

  # exercise
  res=$(getTargetPath ${path})

  # verify
  assertEquals ${expected} ${res}

  # set up
  local path="/home/user/project/no-android/a/b/c"
  local expected="BAD-PATH"

  # exercise
  res=$(getTargetPath ${path})

  # verify
  assertEquals ${expected} ${res}
}

function testPredictProductName() {
  # set up
  local build_prop=build.prop
  echo "${build_prop_content}" > ${build_prop}

  # exercise
  product_name=$(predictProductName ${build_prop})

  # verify
  assertEquals "XXX-YYY" ${product_name}

  # tear down
  rm -rf ${build_prop}
}

# run test
. shUnit2/src/shunit2
