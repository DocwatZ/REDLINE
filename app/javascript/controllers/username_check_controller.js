import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status"]

  connect() {
    this._timer = null
  }

  disconnect() {
    clearTimeout(this._timer)
  }

  check(event) {
    clearTimeout(this._timer)
    const value = event.target.value.trim()
    if (value.length < 3) {
      this._setStatus("", "")
      return
    }
    this._timer = setTimeout(() => this._checkAvailability(value), 400)
  }

  async _checkAvailability(username) {
    try {
      const csrf = document.querySelector('meta[name="csrf-token"]')?.content
      const resp = await fetch(`/users/username_check?username=${encodeURIComponent(username)}`, {
        headers: { "X-CSRF-Token": csrf ?? "" }
      })
      if (!resp.ok) return
      const data = await resp.json()
      if (data.available) {
        this._setStatus("✓", "color:var(--rl-accent)")
      } else {
        this._setStatus("✗ taken", "color:var(--rl-danger)")
      }
    } catch { /* ignore */ }
  }

  _setStatus(text, style) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = text
      this.statusTarget.setAttribute("style", `position:absolute;right:.75rem;top:50%;transform:translateY(-50%);font-size:.75rem;${style}`)
    }
  }
}
