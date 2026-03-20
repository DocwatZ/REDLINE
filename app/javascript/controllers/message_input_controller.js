import { Controller } from "@hotwired/stimulus"

/**
 * Message input controller — handles:
 *  - Enter to send, Shift+Enter for newline
 *  - Auto-resize textarea
 *  - Minimum 44px touch target preserved
 *
 * Accessibility:
 *  - aria-describedby points to hint about keyboard shortcuts
 *  - Sends message via fetch, CSRF token included
 */
export default class extends Controller {
  static targets = ["field"]

  get roomId() {
    const url = window.location.pathname
    const parts = url.split("/").filter(Boolean)
    const idx = parts.indexOf("rooms")
    return idx >= 0 ? parts[idx + 1] : null
  }

  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.sendMessage()
    }
  }

  autoResize() {
    const field = this.fieldTarget
    field.style.height = "auto"
    field.style.height = Math.min(field.scrollHeight, 192) + "px"
  }

  send(event) {
    event.preventDefault()
    this.sendMessage()
  }

  async sendMessage() {
    const body = this.fieldTarget.value.trim()
    if (!body) return

    const roomSlug = this.roomId
    if (!roomSlug) return

    const csrf = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      const response = await fetch(`/rooms/${roomSlug}/messages`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrf ?? ""
        },
        body: JSON.stringify({ message: { body } })
      })

      if (response.ok) {
        this.fieldTarget.value = ""
        this.fieldTarget.style.height = "auto"
      } else {
        const data = await response.json().catch(() => ({}))
        this.announceError(data.errors?.join(", ") ?? "Failed to send message")
      }
    } catch (err) {
      this.announceError("Network error. Message not sent.")
    }
  }

  announceError(msg) {
    // Use an aria-live region for accessible error feedback
    let region = document.getElementById("message-error-announce")
    if (!region) {
      region = document.createElement("div")
      region.id = "message-error-announce"
      region.setAttribute("role", "alert")
      region.setAttribute("aria-live", "assertive")
      region.className = "sr-only"
      document.body.appendChild(region)
    }
    region.textContent = msg
    setTimeout(() => { region.textContent = "" }, 5000)
  }
}
