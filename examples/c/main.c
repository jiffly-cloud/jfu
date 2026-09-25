/* SPDX-FileCopyrightText: 2026 Jiffly */
/* SPDX-License-Identifier: MIT OR Apache-2.0 */

#include "hello.h"
#include <stdio.h>

int main(void) { return puts(jiffly_hello()) == EOF ? 1 : 0; }
