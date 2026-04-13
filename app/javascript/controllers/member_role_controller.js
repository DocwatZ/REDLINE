import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { roomSlug: String }

  async setRole(event) {
    const btn = event.currentTarget
    const userId = btn.dataset.userId
    const newRole = btn.dataset.role
    if (!userId || !newRole) return

    const csrf = document.querySelector('meta[name="csrf-token"]')?.content
    try {
      const resp = await fetch(`/rooms/${this.roomSlugValue}/room_memberships/${userId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": csrf ?? ""
        },
        body: JSON.stringify({ role: newRole })
      })
      if (resp.ok) {
        const data = await resp.json()
        const li = btn.closest("li")
        if (li) {
          const badge = li.querySelector(".member-role-badge")
          if (badge) badge.textContent = newRole === "admin" ? "★" : newRole === "moderator" ? "◆" : ""
        }
      } else {
        const err = await resp.json()
        alert(err.error || "Failed to change role")
      }
    } catch (err) {
      console.error("Role change error:", err)
    }
  }
}
