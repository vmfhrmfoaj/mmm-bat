#!/bin/bash

# mmm-bat.sh, Copyright (C) 2013-2014 Jinseop Kim(vmfhrmfoaj@yahoo.com)
# mmm-bat.sh comes with ABSOLUTELY NO WARRANTY; for details
# type LICENSE file.  This is free software, and you are welcome
# to redistribute it under certain conditions; type LICENSE
# for details.
# If the LICENSE file does not exist,
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#
# Variables
#

# predefined return value
YES="YES"
NO="NO"
VALID="VALID"
INVALID="INVALID"

# predefined regular expression
INSTALL_REGX="Install: ([_0-9a-zA-Z]+/)+[-._0-9a-zA-Z]+"
ROOT_REGX="/system.*"
ERROR_REGX="\<error: |\<Error [0-9]+"
BIN_REGX="/bin/?$"
PUSH_REGX="adb push|adb shell chmod"

# predefined files
ERROR_SCRIPT="error.bat"
PUSH_LOG="push.log"
CUSTOM_BUILD='mmm-bat-custom.sh'


#
# Fucntions
#

function helpUsage() {
  echo    "Usage:"
  echo    "    $0 [dir] [product name] [-a]?"
  echo    "    - dir: path for build"
  echo    "           e.g) hardware/qcom/camera"
  echo    "    - product name: product string for mmm-build."
  echo -n "                    If the product name is \"custom\", "
  echo                        "we to execute the \"mmm-bat-custom.sh\" file."
  echo    ""
  echo    "  Optional:"
  echo    "    - append mode(-a): To accumulate a push list."
}

function isError() {
  local log_file=$1
  local is_eorr=$(grep -c -E "${ERROR_REGX}" ${log_file})
  if [ ${is_eorr} == "0" ]; then
    echo ${NO}
  else
    echo ${YES}
  fi
}

function writeLog() {
  local logs=$1
  echo "${logs}"
  echo "${logs}" >> ${PUSH_LOG}
}

function showError() {
  local log_file=$1
  if [ $(isError ${log_file}) == "YES" ]; then
    echo "!!! error !!!"
    grep -E "${ERROR_REGX}" ${log_file}
  fi
}

function showInstalled() {
  local log_file=$1
  echo "!!! install !!!"
  grep -E "${INSTALL_REGX}" ${log_file}
}

function joinPushScript() {
  local script_1=$1
  local script_2=$2
  genPushScriptHeader
  echo "${script_1}" | grep -E "${PUSH_REGX}"
  echo "${script_2}" | grep -E "${PUSH_REGX}"
  genPushScriptTail
}

function genPushScriptTail() {
  echo "adb shell sync"
  echo "adb reboot"
}

function genPushScriptBody() {
  local log_file=$1
  if [ ! -f ${log_file} ]; then
    return
  fi

  local install_files=$(grep -o -E "${INSTALL_REGX}" ${log_file} | awk '{print $2}')
  for file in ${install_files}; do
    local push_path=$(echo ${file} | tr '/' '\\')
    local target_dir=$(dirname $(echo ${file} | grep -o -E ${ROOT_REGX}))
    echo "adb push ${push_path} ${target_dir}"

    # change mode for executable files
    local is_executable_file=$(echo ${target_dir} | grep -c -E ${BIN_REGX})
    if [ ! ${is_executable_file} == "0" ]; then
      local push_file=$(basename $file)
      echo "adb shell chmod 777 ${target_dir%/}/${push_file}"
    fi
  done
}

function genPushScriptHeader() {
  echo "adb wait-for-device"
  echo "adb remount"
  echo "adb shell su -c setenforce 0"
}

function checkParams() {
  local target_path=$1
  local product_name=$2

  if [ $# -lt 2 ] || [ ! -d ${target_path} ] || \
     [ ${product_name} == ${INVALID}  ]; then
    echo ${INVALID}
  else
    echo ${VALID}
  fi
}

function removeScriptFileIfEmpty() {
  local script_file=$1
  local num_push_cmd=$(grep -c -E "adb push" ${script_file})
  if [ ${num_push_cmd} == "0" ]; then
    rm -rf ${script_file}
  fi
}

function createErrorPushScriptIfNeed() {
  local log_file=$1
  local push_file=$2
  if [ $(isError ${log_file}) == "YES" ]; then
    cp ${push_file} ${ERROR_SCRIPT}
  else
    rm -rf ${ERROR_SCRIPT}
  fi
}

function includeErrorPushScriptIfPossible() {
  local push_file=$1
  if [ -f ${ERROR_SCRIPT} ]; then
    local temp_file=".temp-$(date +"%N").bat"
    joinPushScript "$(cat ${push_file})" "$(cat ${ERROR_SCRIPT})" > ${temp_file}
    mv ${temp_file} ${push_file}
  fi
}

function genPushScript() {
  local log_file=$1
  genPushScriptHeader
  genPushScriptBody ${log_file}
  genPushScriptTail
}

function runBuild() {
  local path=$1
  local product_name=$2
  local log_file=$3

  if [ ${product_name} == "custom" ]; then
    bash ${CUSTOM_BUILD} ${path} 2>&1 | tee ${log_file}
  else
    source build/envsetup.sh
    lunch ${product_name}
    mmm ${path} 2>&1 | tee ${log_file}
  fi
}

function exitWhenInvalidParam() {
  local path=$1
  local product_name=$2

  if [ $(checkParams ${path} ${product_name}) == "INVALID" ]; then
    helpUsage
    exit -1
  fi
}

function build() {
  local path=$1
  local product_name=$2
  local log_file=${3:-${BUILD_LOG_FILE}}
  local push_file=${4:-${SCRIPT_FILE}}

  exitWhenInvalidParam ${path} ${product_name}
  runBuild ${path} ${product_name} ${log_file}
  genPushScript ${log_file} > ${push_file}
  includeErrorPushScriptIfPossible ${push_file}
  createErrorPushScriptIfNeed ${log_file} ${push_file}
  removeScriptFileIfEmpty ${push_file}
  writeLog "$(showInstalled ${log_file})"
  writeLog "$(showError ${log_file})"
}

function predictProductName() {
  local log_file=${1:-${BUILD_LOG_FILE}}
  local product_regex="TARGET_PRODUCT="
  local type_regex="TARGET_BUILD_VARIANT="

  product=$(cat ${log_file} | grep ${product_regex} | head -1 | cut -d'=' -f2)
  product=${product:-${INVALID}}
  type=$(cat ${log_file} | grep ${type_regex} | head -1 | cut -d'=' -f2)

  echo -n ${product}
  if [ -n "${type}" ]; then
    echo "-${type}"
  fi
}

function splitPathToRootAndTarget() {
  local path=${1:-$(pwd)}
  if [ $(echo ${path} | grep --count "/android/") -ge "1" ]; then
    local splitted_path=${path//\/android\//\/android:}
    echo ${splitted_path}
  else
    echo ${INVALID}
  fi
}

function getTargetPath() {
  local path=$1
  echo $(splitPathToRootAndTarget ${path}) | cut -d':' -f2
}

function getRootPath() {
  local path=$1
  if [ "$(basename ${path})" == "android" ]; then
    echo ${path}
  else
    echo $(splitPathToRootAndTarget ${path}) | cut -d':' -f1
  fi
}
