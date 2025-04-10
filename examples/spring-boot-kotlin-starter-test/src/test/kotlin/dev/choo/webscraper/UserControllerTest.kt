/*
 * Copyright (C) 2025 Steven Choo <info@stevenchoo.nl>
 *
 * MIT License. See the LICENSE file in the root directory or <http://www.opensource.org/licenses/mit-license.php>
 */

package dev.choo.webscraper

import org.hamcrest.Matchers.`is`
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@WebMvcTest(UserController::class)
class UserControllerTest {
    @Autowired
    private lateinit var mockMvc: MockMvc

    @Test
    fun `should return user`() {
        mockMvc
            .perform(get("/api/user"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.id", `is`("123")))
            .andExpect(jsonPath("$.name", `is`("John Doe")))
            .andExpect(jsonPath("$.email", `is`("john.doe@example.com")))
    }
}
