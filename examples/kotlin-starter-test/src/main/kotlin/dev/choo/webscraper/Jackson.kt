/*
 * Copyright (C) 2025 Steven Choo <info@stevenchoo.nl>
 *
 * MIT License. See the LICENSE file in the root directory or <http://www.opensource.org/licenses/mit-license.php>
 */

package dev.choo.webscraper

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.registerKotlinModule

class Jackson {
    private val objectMapper = ObjectMapper().registerKotlinModule()

    fun serialize(): String =
        objectMapper.writeValueAsString(
            User(id = "id", name = "name", email = "email"),
        )
}
