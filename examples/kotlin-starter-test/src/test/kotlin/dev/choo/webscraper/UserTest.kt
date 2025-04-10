/*
 * Copyright (C) 2025 Steven Choo <info@stevenchoo.nl>
 *
 * MIT License. See the LICENSE file in the root directory or <http://www.opensource.org/licenses/mit-license.php>
 */

package dev.choo.webscraper

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class UserTest {
    @Test
    fun canCreateUser() {
        val user = User(id = "id", name = "name", email = "email")
        assertThat(user.id).isEqualTo("id")
        assertThat(user.name).isEqualTo("name")
        assertThat(user.email).isEqualTo("email")
    }
}
