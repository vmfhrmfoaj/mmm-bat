# Makefile, Copyright (C) 2013-2014 Jinseop Kim(vmfhrmfoaj@yahoo.com)
# Makefile comes with ABSOLUTELY NO WARRANTY; for details
# type LICENSE file.  This is free software, and you are welcome
# to redistribute it under certain conditions; type LICENSE
# for details.
# If the LICENSE file does not exist,
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

TEST_FILES=$(wildcard test-*.sh)
all: test
test: $(patsubst %.sh,%,$(TEST_FILES))
%: %.sh
	@bash $<
install:
	@echo "'Install' is not yet supported."
