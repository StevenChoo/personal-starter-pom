/*
 * Copyright (C) 2025 Steven Choo <info@stevenchoo.nl>
 *
 * MIT License. See the LICENSE file in the root directory or <http://www.opensource.org/licenses/mit-license.php>
 */

package dev.choo.webscraper;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class JacksonTest {

    @Test
    void testJacksonSerialize() {
        assertThat(new Jackson().serialize()).isEqualTo("{\"id\":\"id\",\"name\":\"name\",\"email\":\"email\"}");
    }
}
