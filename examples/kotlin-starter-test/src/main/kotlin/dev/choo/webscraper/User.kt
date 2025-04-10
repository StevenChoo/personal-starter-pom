/*
 * Copyright (C) 2025 Steven Choo <info@stevenchoo.nl>
 *
 * MIT License. See the LICENSE file in the root directory or <http://www.opensource.org/licenses/mit-license.php>
 */

package dev.choo.webscraper

import com.fasterxml.jackson.annotation.JsonProperty

data class User(
    @JsonProperty
    val id: String,
    @JsonProperty
    val name: String,
    @JsonProperty
    val email: String,
)
