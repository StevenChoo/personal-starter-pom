/*
 * Copyright (C) 2025 Steven Choo <info@stevenchoo.nl>
 *
 * MIT License. See the LICENSE file in the root directory or <http://www.opensource.org/licenses/mit-license.php>
 */

package dev.choo.webscraper;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.SneakyThrows;

public class Jackson {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @SneakyThrows
    public String serialize() {
        return objectMapper.writeValueAsString(
                User.builder().id("id").name("name").email("email").build());
    }
}
