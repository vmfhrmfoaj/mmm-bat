#!/bin/bash

# test-mmm-bat.inc, Copyright (C) 2013-2014 Jinseop Kim(vmfhrmfoaj@yahoo.com)
# test-mmm-bat.inc comes with ABSOLUTELY NO WARRANTY; for details
# type LICENSE file.  This is free software, and you are welcome
# to redistribute it under certain conditions; type LICENSE
# for details.
# If the LICENSE file does not exist,
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

normal_log=$(cat <<EOF
Install: dumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: 123/abc/123/system/abc/8910.so
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: 123/abc/123/system/abc/111213.so
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: 123/abc/123/system/abc/do-not-push.so
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: 123/abc/123/system/abc/test_exclude_1.so
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: 123/abc/123/system/abc/test_exclude_2.so
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: 123/abc/123/system/abc/test_exclude_3.so
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
EOF
)

normal_log_sh=$(cat <<EOF
adb wait-for-device
adb remount
adb shell su -c setenforce 0
adb push 123\abc\123\system\abc\8910.so /system/abc
adb push 123\abc\123\system\abc\111213.so /system/abc
adb push 123\abc\123\system\abc\do-not-push.so /system/abc
adb push 123\abc\123\system\abc\test_exclude_1.so /system/abc
adb push 123\abc\123\system\abc\test_exclude_2.so /system/abc
adb push 123\abc\123\system\abc\test_exclude_3.so /system/abc
adb shell sync
adb reboot
EOF
)

no_error_log=$(cat <<EOF
abcdeError: dumydumydumydumyerrordumydumy
abcdeerror: dumydumydumydumyerrordumydumy
error:dumydumydumydumyerrordumydumyErrordumydumydumyerror:
Install: abc/123/system/abc/123.so
abcdeError: dumydumydumydumyerrordumydumy
abcdeerror: dumydumydumydumyerrordumydumy
error:dumydumydumydumyerrordumydumyErrordumydumydumyerror:
Install: abc/123/system/abc/567.so
abcdeError: dumydumydumydumyerrordumydumy
abcdeerror: dumydumydumydumyerrordumydumy
error:dumydumydumydumyerrordumydumyErrordumydumydumyerror:
EOF
)

no_error_log_sh=$(cat <<EOF
adb wait-for-device
adb remount
adb shell su -c setenforce 0
adb push abc\123\system\abc\123.so /system/abc
adb push abc\123\system\abc\567.so /system/abc
adb shell sync
adb reboot
EOF
)

error_log=$(cat <<EOF
abcdeError: dumydumydumydumyerrordumydumy
abcdeerror: dumydumydumydumyerrordumydumy
error:dumydumydumydumyerrordumydumyErrordumydumydumyerror:
Install: abc/123/system/abc/123.so
abcdeError: dumydumydumydumyerrordumydumy
abcdeerror: dumydumydumydumyerrordumydumy
error:dumydumydumydumyerrordumydumyErrordumydumydumyerror:
Install: abc/123/system/abc/567.so
abcdeError: dumydumydumydumyerrordumydumy
abcdeerror: dumydumydumydumyerrordumydumy
error:dumydumydumydumyerrordumydumyErrordumydumydumyerror:
dumydumydumy error: 123.c
dumydumydumy [...] Error 1
EOF
)

error_log_sh=$(cat <<EOF
adb wait-for-device
adb remount
adb shell su -c setenforce 0
adb push abc\123\system\abc\123.so /system/abc
adb push abc\123\system\abc\567.so /system/abc
adb shell sync
adb reboot
EOF
)

install_error_log_sh=$(cat <<EOF
adb wait-for-device
adb remount
adb shell su -c setenforce 0
adb push 123\abc\123\system\abc\8910.so /system/abc
adb push 123\abc\123\system\abc\111213.so /system/abc
adb push 123\abc\123\system\abc\do-not-push.so /system/abc
adb push 123\abc\123\system\abc\test_exclude_1.so /system/abc
adb push 123\abc\123\system\abc\test_exclude_2.so /system/abc
adb push 123\abc\123\system\abc\test_exclude_3.so /system/abc
adb push abc\123\system\abc\123.so /system/abc
adb push abc\123\system\abc\567.so /system/abc
adb shell sync
adb reboot
EOF
)

error_log_err_msg=$(cat <<EOF
!!! error !!!
dumydumydumy error: 123.c
dumydumydumy [...] Error 1
EOF
)

error_log_install_msg=$(cat <<EOF
!!! install !!!
Install: abc/123/system/abc/123.so
Install: abc/123/system/abc/567.so
EOF
)

joined_sh=$(cat <<EOF
adb wait-for-device
adb remount
adb shell su -c setenforce 0
adb push 123\abc\123\system\abc\8910.so /system/abc
adb push 123\abc\123\system\abc\111213.so /system/abc
adb push 123\abc\123\system\abc\do-not-push.so /system/abc
adb push 123\abc\123\system\abc\test_exclude_1.so /system/abc
adb push 123\abc\123\system\abc\test_exclude_2.so /system/abc
adb push 123\abc\123\system\abc\test_exclude_3.so /system/abc
adb push abc\123\system\abc\123.so /system/abc
adb push abc\123\system\abc\567.so /system/abc
adb shell sync
adb reboot
EOF
)

binary_log=$(cat <<EOF
Install: dumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: 123/abc/123/system/abc/8910.so
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: 123/abc/123/system/bin/111213
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
EOF
)

binary_log_sh=$(cat <<EOF
adb wait-for-device
adb remount
adb shell su -c setenforce 0
adb push 123\abc\123\system\abc\8910.so /system/abc
adb push 123\abc\123\system\bin\111213 /system/bin
adb shell chmod 777 /system/bin/111213
adb shell sync
adb reboot
EOF
)

no_install_log=$(cat <<EOF
Install: dumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
Install: DumydumydumydumyinstalldumydumydumydumydumyInstall:
EOF
)

mmm_log=$(cat <<EOF
PRODUCT_TARGET=AAA
TARGET_PRODUCT=XXX
TARGET_BUILD_VARIANT=YYY
TARGET_VARIANT_BUILD=BBB
EOF
)

mmm_log_2=$(cat <<EOF
PRODUCT_TARGET=AAA
TARGET_PRODUCT=XXX
TARGET_VARIANT_BUILD=BBB
EOF
)
