#!/bin/bash

# mock-mmm-bat.sh v0.2, Copyright (C) 2013-2014 Jinseop Kim(vmfhrmfoaj@yahoo.com)
# mock-mmm-bat.sh comes with ABSOLUTELY NO WARRANTY; for details
# type LICENSE file.  This is free software, and you are welcome
# to redistribute it under certain conditions; type LICENSE
# for details.
# If the LICENSE file does not exist,
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# mock writeLog
function writeLog() {
  echo -n
}

# mock build_command
function build_command() {
  local path=$1
  local product_name=$2
  echo ${mock_build_command_log}
}
