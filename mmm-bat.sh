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

install_regx="Install: ([_0-9a-zA-Z]+/)+[-._0-9a-zA-Z]+"
root_regx="/system.*"
error_regx="\<error: |\<Error [0-9]+"
bin_regx="/bin/?$"
push_regx="adb push|adb shell chmod"

error_script_file="error.bat"
push_log_file="push.log"
custom_build_command='mmm-bat-custom.sh'

invalid_product_name="INVALID-PRODUCT-NAME"

function splitPathToRootAndTarget() {
  local path=${1:-$(pwd)}
  if [ $(echo ${path} | grep --count "/android/") -ge "1" ]; then
    local splitted_path=${path//\/android\//\/android:}
    echo ${splitted_path}
  else
    echo "BAD-PATH"
  fi
}

function getRootPath() {
  local path=$1
  echo $(echo $(splitPathToRootAndTarget ${path}) | cut -d':' -f1)
}

function getTargetPath() {
  local path=$1
  echo $(echo $(splitPathToRootAndTarget ${path}) | cut -d':' -f2)
}

function predictProductName() {
  local log_file=${1:-${build_log_file}}
  local product_regex="TARGET_PRODUCT="
  local type_regex="TARGET_BUILD_VARIANT="

  product=$(cat ${log_file} | grep ${product_regex} | head -1 | cut -d'=' -f2)
  product=${product:-${invalid_product_name}}
  type=$(cat ${log_file} | grep ${type_regex} | head -1 | cut -d'=' -f2)

  echo -n ${product}
  if [ -n "${type}" ]; then
    echo "-${type}"
  fi
}

function checkParams() {
  local target_path=$1
  local product_name=$2

  if [ $# -lt 2 ] || [ ! -d ${target_path} ] || \
     [ ${product_name} == ${invalid_product_name}  ]; then
    echo "INVALID"
  else
    echo "VALID"
  fi
}

function writeLog() {
  local logs=$1
  echo "${logs}"
  echo "${logs}" >> ${push_log_file}
}

function showError() {
  local log_file=$1
  echo "!!! error !!!"
  grep -E "${error_regx}" ${log_file}
}

function showInstalled() {
  local log_file=$1
  echo "!!! install !!!"
  grep -E "${install_regx}" ${log_file}
}

function isError() {
  local log_file=$1
  local is_eorr=$(grep -c -E "${error_regx}" ${log_file})
  if [ ${is_eorr} == "0" ]; then
    echo "NO"
  else
    echo "YES"
  fi
}

function appendPushScriptHeader() {
  echo "adb wait-for-device"
  echo "adb remount"
  echo "adb shell su -c setenforce 0"
}

function genPushScriptInternal() {
  local log_file=$1
  if [ ! -f ${log_file} ]; then
    return
  fi

  local install_files=$(grep -o -E "${install_regx}" ${log_file} | awk '{print $2}')
  for file in ${install_files}; do
    local push_path=$(echo ${file} | tr '/' '\\')
    local target_dir=$(dirname $(echo ${file} | grep -o -E ${root_regx}))
    echo "adb push ${push_path} ${target_dir}"

    # change mode for executable files
    local is_executable_file=$(echo ${target_dir} | grep -c -E ${bin_regx})
    if [ ! ${is_executable_file} == "0" ]; then
      local push_file=$(basename $file)
      echo "adb shell chmod 777 ${target_dir%/}/${push_file}"
    fi
  done
}

function appendPushScriptTail() {
  echo "adb shell sync"
  echo "adb reboot"
}

function genPushScript() {
  local log_file=$1
  appendPushScriptHeader
  genPushScriptInternal ${log_file}
  appendPushScriptTail
}

function joinPushScript() {
  local script_1=$1
  local script_2=$2
  appendPushScriptHeader
  echo "${script_1}" | grep -E "${push_regx}"
  echo "${script_2}" | grep -E "${push_regx}"
  appendPushScriptTail
}

function removeScriptFileIfEmpty() {
  local script_file=$1
  local num_push_cmd=$(grep -c -E "adb push" ${script_file})
  if [ ${num_push_cmd} == "0" ]; then
    rm -rf ${script_file}
  fi
}

function runBuild() {
  local path=$1
  local product_name=$2
  local log_file=$3

  if [ ${product_name} == "custom" ]; then
    bash ${custom_build_command} ${path} 2>&1 | tee ${log_file}
  else
    source build/envsetup.sh
    lunch ${product_name}
    mmm ${path} 2>&1 | tee ${log_file}
  fi
}

function includeErrorPushScriptIfPossible() {
  local push_file=$1
  if [ -f ${error_script_file} ]; then
    local temp_file=".temp-$(date +"%N").bat"
    joinPushScript "$(cat ${push_file})" \
                   "$(cat ${error_script_file})" > ${temp_file}
    mv ${temp_file} ${push_file}
  fi
}

function createErrorPushScriptIfNeed() {
  local log_file=$1
  local push_file=$2
  local is_error=$(isError ${log_file})
  if [ ${is_error} == "YES" ]; then
    cp ${push_file} ${error_script_file}
    writeLog "$(showError ${log_file})"
  else
    rm -rf ${error_script_file}
  fi
}

function buildInternal() {
  local path=$1
  local product_name=$2
  local log_file=$3
  local push_file=$4

  runBuild ${path} ${product_name} ${log_file}
  genPushScript ${log_file} > ${push_file}
  includeErrorPushScriptIfPossible ${push_file}
  writeLog "$(showInstalled ${log_file})"
  createErrorPushScriptIfNeed ${log_file} ${push_file}
}

function includePushScriptIfPossible() {
  local push_file=$1
  local include_push_file=$2

  if [ ! -z "${include_push_file}" ]; then
    # with append mode
    local temp_push_file=".${log_file}-$(date +"%N").bat"
    mv ${push_file} ${temp_push_file}
    joinPushScript "$(cat ${temp_push_file})" \
                   "$(cat ${include_push_file})" > ${push_file}
    rm -rf ${temp_push_file}
  fi
}

function build() {
  local path=$1
  local product_name=$2
  local log_file=$3
  local push_file=$4
  local include_push_file=$5

  buildInternal ${path} ${product_name} ${log_file} ${push_file}
  includePushScriptIfPossible ${push_file} ${include_push_file}
}
