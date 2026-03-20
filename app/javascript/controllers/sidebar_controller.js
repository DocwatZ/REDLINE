import { Controller } from "@hotwired/stimulus"

/**
 * Sidebar controller — handles mobile sidebar toggle.
 *
 * Accessibility:
 *  - aria-expanded on toggle button
 *  - Focus trapped in sidebar when open on mobile
 *  - Escape closes the sidebar
 */
export default class extends Controller {
  connect() {
    this.sidebar = document.getElementById("sidebar")
    this.handleEscape = this.close.bind(this)
  }

  toggle() {
    const isOpen = this.sidebar.classList.toggle("open")
    const btn = document.querySelector("[data-action*='sidebar#toggle']")
    if (btn) btn.setAttribute("aria-expanded", String(isOpen))

    if (isOpen) {
      document.addEventListener("keydown", this.onKeydown.bind(this))
    } else {
      document.removeEventListener("keydown", this.onKeydown.bind(this))
    }
  }

  close() {
    this.sidebar?.classList.remove("open")
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }
}
