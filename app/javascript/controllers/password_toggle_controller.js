import { Controller } from "@hotwired/stimulus"

/**
 * Password toggle — show/hide password field.
 *
 * Accessibility:
 *  - Button aria-label updates to reflect current state
 *  - Focus remains on the button after toggle
 *  - Works with any password field via data-password-toggle-target-value
 */
export default class extends Controller {
  static values = { target: String }

  connect() {
    this.button = this.element
  }

  toggle() {
    const fieldId = this.targetValue || this.button.closest("div")
      ?.querySelector("input[type='password'], input[type='text']")?.id

    if (!fieldId) return

    const field = document.getElementById(fieldId)
    if (!field) return

    const isPassword = field.type === "password"
    field.type = isPassword ? "text" : "password"
    this.button.setAttribute("aria-label",
      isPassword ? "Hide password" : "Show password")
  }
}
