/* SPDX-FileCopyrightText: 2026 Jiffly */
/* SPDX-License-Identifier: MIT OR Apache-2.0 */

#include "hello.h"
#include <assert.h>
#include <string.h>

static void test_hello_world(void) {
    const char *greeting = jiffly_hello();

    assert(greeting != NULL);
    assert(strcmp(greeting, "hello jiffly") == 0);
}

int main(void) {
    test_hello_world();
    return 0;
}
