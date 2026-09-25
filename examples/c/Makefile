# SPDX-FileCopyrightText: 2026 Jiffly
# SPDX-License-Identifier: MIT OR Apache-2.0

BUILD_DIR ?= ../../target/c-example
FLAGS := -std=c11 -Wall -Wextra -Werror -Wpedantic -Wstrict-prototypes
TESTS := $(wildcard tests/test_*.c)
SOURCES := hello.c main.c $(TESTS)

.PHONY: all test lint
all:
	mkdir -p $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(FLAGS) hello.c main.c $(LDFLAGS) $(LDLIBS) -o $(BUILD_DIR)/hello

test: all
	test -n "$(TESTS)"
	@set -e; for source in $(TESTS); do \
		name=$$(basename "$$source" .c); \
		$(CC) $(CPPFLAGS) $(CFLAGS) $(FLAGS) -UNDEBUG -I. hello.c "$$source" \
			$(LDFLAGS) $(LDLIBS) -o "$(BUILD_DIR)/$$name"; \
		echo "Running $$name"; \
		"$(BUILD_DIR)/$$name"; \
	done

lint:
	clang-format --dry-run --Werror hello.h $(SOURCES)
	clang-tidy $(SOURCES) -- $(CPPFLAGS) $(CFLAGS) $(FLAGS) -UNDEBUG -I.
