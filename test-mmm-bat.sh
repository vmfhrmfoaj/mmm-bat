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
  # exercise & verify
  assertEquals ${INVALID} $(checkParams $(pwd))
}

function testNonExistingTargetDirectory() {
  # exercise & verify
  assertEquals ${INVALID} $(checkParams "DIR" "PRODUCT")
}

function testInvalidProductName() {
  # exercise & verify
  assertEquals ${INVALID} $(checkParams $(pwd) ${INVALID})
}

function testParam() {
  # exercise & verify
  assertEquals ${VALID} $(checkParams $(pwd) "test")
}

function testCheckBuildErrorWithNoErrorLog() {
  # set up
  local temp_file="temp-no-error-log-file"
  echo "${no_error_log}" > ${temp_file}

  # exercise & verify
  assertEquals ${NO} $(isError ${temp_file})

  # tear down
  rm -rf ${temp_file}
}

function testCheckBuildErrorWithErrorLog() {
  # set up
  local temp_file="temp-error-log-file"
  echo "${error_log}" > ${temp_file}

  # exercise & verify
  assertEquals ${YES} $(isError ${temp_file})

  # tear down
  rm -rf ${temp_file}
}

function testGeneratePushScript() {
  # set up
  local temp_file="temp-install-log-file"
  echo "${normal_log}" > ${temp_file}

  # exercise
  local push_script=$(genPushScript ${temp_file})

  # verify
  local diff=$(diff -c <(echo "${normal_log_sh}") <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${normal_log_sh}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${temp_file}
}

function testGeneratePushScriptWithError() {
  # set up
  local temp_file="temp-error-log-file"
  echo "${error_log}" > ${temp_file}

  # exercise
  local push_script=$(genPushScript ${temp_file})

  # verify
  local diff=$(diff -c <(echo "${error_log_sh}" ) <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${error_log_sh}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${temp_file}
}

function testJoinPushScript() {
  # exercise
  local push_script=$(joinPushScript "${normal_log_sh}" "${no_error_log_sh}")

  # verify
  local diff=$(diff -c <(echo "${joined_sh}") <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${joined_sh}\" == \"${push_script}\" ]"
}

function testJoinPushScriptWithFiles_1() {
  # exercise
  local push_script=$(joinPushScript "${normal_log_sh}" "${no_error_log_sh}")

  # verify
  local diff=$(diff -c <(echo "${joined_sh}") <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${joined_sh}\" == \"${push_script}\" ]"
}

function testJoinPushScriptWithFiles_2() {
  # exercise
  local push_script=$(joinPushScript "${normal_log_sh}" "${no_error_log_sh}")

  # verify
  local diff=$(diff -c <(echo "${joined_sh}") <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${joined_sh}\" == \"${push_script}\" ]"
}

function testChangeModeForBinaryFiles() {
  # set up
  local temp_file="temp-bin-log-file"
  echo "${binary_log}" > ${temp_file}

  # exercise
  local push_script=$(genPushScript ${temp_file})

  # verify
  local diff=$(diff -c <(echo "${binary_log_sh}" ) <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${binary_log_sh}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${temp_file}
}

function testRemoveScriptFileIfEmtpy() {
  # set up
  local temp_file_1="temp-install-log-file"
  local temp_file_2="temp-script-file-1"
  echo "${normal_log}" > ${temp_file_1}
  genPushScript ${temp_file_1} > ${temp_file_2}

  local temp_file_3="temp-no-install-log-file"
  local temp_file_4="temp-script-file-2"
  echo "${no_install_log}" > ${temp_file_3}
  genPushScript ${temp_file_3} > ${temp_file_4}

  # exercise & verify
  removeScriptFileIfEmpty ${temp_file_2}
  assertTrue "not existing ${temp_file_2}" "[ -f \"${temp_file_2}\" ]"

  removeScriptFileIfEmpty ${temp_file_4}
  assertFalse "existing ${temp_file_4}" "[ -f \"${temp_file_4}\" ]"

  # tear down
  rm -rf ${temp_file_1}
  rm -rf ${temp_file_2}
  rm -rf ${temp_file_3}
  rm -rf ${temp_file_4}
}

function testShowErrorMessage() {
  # set up
  local temp_file="temp-error-log-file"
  echo "${error_log}" > ${temp_file}

  # exercise
  local err_msg=$(showError ${temp_file})

  # verify
  local diff=$(diff -c <(echo "${error_log_err_msg}" ) <(echo "${err_msg}"))
  assertTrue "${diff}" "[ \"${error_log_err_msg}\" == \"${err_msg}\" ]"

  # tear down
  rm -rf ${temp_file}
}

function testShowInstallMessage() {
  # set up
  local temp_file="temp-error-log-file"
  echo "${error_log}" > ${temp_file}

  # exercise
  local install_msg=$(showInstalled ${temp_file})

  # verify
  local diff=$(diff -c <(echo "${error_log_install_msg}" ) \
                       <(echo "${install_msg}"))

  assertTrue "${diff}" "[ \"${error_log_install_msg}\" == \"${install_msg}\" ]"

  # tear down
  rm -rf ${temp_file}
}

function testBuild() {
  # set up
  local log_file='temp-log-file'
  local push_file='temp-push-script'
  local mmm_log=${normal_log}

  # exercise
  build . 'test' ${log_file} ${push_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${normal_log_sh}" ) <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${normal_log_sh}\" == \"${push_script}\" ]"

  # tear down
  rm -rf ${log_file}
  rm -rf ${push_file}
}

function testBuildWithError() {
  # set up
  local log_file='temp-error-log-file'
  local push_file='temp-push-script-for-error'
  local mmm_log=${error_log}

  # exercise
  build . 'test' ${log_file} ${push_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${error_log_sh}" ) <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${error_log_sh}\" == \"${push_script}\" ]"
  assertTrue "not existing ${ERROR_SCRIPT}" "[ -f \"${ERROR_SCRIPT}\" ]"

  # tear down
  rm -rf ${log_file}
  rm -rf ${push_file}
  rm -rf ${ERROR_SCRIPT}
}

function testBuildAfterError() {
  # set up
  local log_file='temp-log-file'
  local push_file='temp-push-script'
  local mmm_log=${normal_log}

  echo "${error_log_sh}" > ${ERROR_SCRIPT}

  # exercise
  build . 'test' ${log_file} ${push_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${install_error_log_sh}" ) \
                       <(echo "${push_script}"))

  assertTrue "${diff}" "[ \"${install_error_log_sh}\" == \"${push_script}\" ]"
  assertFalse "existing ${ERROR_SCRIPT}" "[ -f \"${ERROR_SCRIPT}\" ]"

  # tear down
  rm -rf ${log_file}
  rm -rf ${push_file}
  rm -rf ${ERROR_SCRIPT}
}

function testBuildWithAppendMode() {
  # set up
  local log_file='temp-log-file'
  local push_file='temp-push-script'
  local append_file='temp-push-spcript'
  local mmm_log=${normal_log}

  echo "${no_error_log_sh}" > ${append_file}

  # exercise
  build . 'test' ${log_file} ${push_file} ${append_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${joined_sh}") <(echo "${push_script}"))
  assertTrue "${diff}" "[ \"${joined_sh}\" == \"${push_script}\" ]"

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

  echo "echo \$1 > ${check_param_file}" > ${CUSTOM_BUILD}
  echo "echo \"${normal_log}\"" >> ${CUSTOM_BUILD}

  # exercise
  build . 'custom' ${log_file} ${push_file} > /dev/null

  # verify
  local push_script=$(cat ${push_file})
  local diff=$(diff -c <(echo "${normal_log_sh}" ) \
                       <(echo "${push_script}"))

  assertTrue "${diff}" \
    "[ \"${normal_log_sh}\" == \"${push_script}\" ]"

  local diff=$(diff -c <(echo ".") "${check_param_file}")
  assertTrue "${diff}" \
    "[ \".\" == \"$(cat ${check_param_file})\" ]"

  # tear down
  rm -rf ${log_file}
  rm -rf ${push_file}
  rm -rf ${CUSTOM_BUILD}
  rm -rf ${check_param_file}
}

function testGetRootPath() {
  # set up
  local path="/home/user/project/android/a/b/c"
  local expected="/home/user/project/android"

  # exercise & verify
  assertEquals ${expected} $(getRootPath ${path})

  # set up
  local path="/home/user/project/no-android/a/b/c"
  local expected=${INVALID}

  # exercise & verify
  assertEquals ${expected} $(getRootPath ${path})
}

function testGetTargetPath() {
  # set up
  local path="/home/user/project/android/a/b/c"
  local expected="a/b/c"

  # exercise & verify
  assertEquals ${expected} $(getTargetPath ${path})

  # set up
  local path="/home/user/project/no-android/a/b/c"
  local expected=${INVALID}

  # verify
  assertEquals ${expected} $(getTargetPath ${path})
}

function testPredictProductName() {
  # set up
  local log=mmm.log
  local log_2=mmm2.log
  local log_3=mmm3.log
  echo "${mmm_log}" > ${log}
  echo "${mmm_log_2}" > ${log_2}
  echo "not-contain-product-name-hint" > ${log_3}

  # exercise & verify
  assertEquals "XXX-YYY" $(predictProductName ${log})
  assertEquals "XXX" $(predictProductName ${log_2})
  assertEquals ${INVALID} $(predictProductName ${log_3})

  # tear down
  rm -rf ${log}
  rm -rf ${log_2}
  rm -rf ${log_3}
}

# run test
. shUnit2/src/shunit2
