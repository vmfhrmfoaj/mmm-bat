TEST_FILES=$(wildcard test-*.sh)
all: test
test: $(patsubst %.sh,%,$(TEST_FILES))
%: %.sh
	@bash $<
install:
	@echo "'Install' is not yet supported."
