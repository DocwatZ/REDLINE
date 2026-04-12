import consumer from "channels/consumer"

function showToast(title, body) {
  let container = document.querySelector(".toast-container")
  if (!container) {
    container = document.createElement("div")
    container.className = "toast-container"
    document.body.appendChild(container)
  }
  const toast = document.createElement("div")
  toast.className = "toast"
  toast.setAttribute("role", "alert")
  toast.innerHTML = `<div class="toast-title">${title}</div><div class="toast-body">${body.substring(0, 100)}</div>`
  container.appendChild(toast)
  setTimeout(() => toast.remove(), 5000)
}

/**
 * Subscribes to the current user's personal notification stream.
 * Updates sidebar DM unread badges in real-time when a new DM arrives.
 * Also handles @mention toasts and DM read receipts.
 */
consumer.subscriptions.create("UserNotificationsChannel", {
  received(data) {
    if (data.type === "new_dm") {
      const senderId = data.sender_id
      const link = document.querySelector(`[data-dm-partner-id="${senderId}"]`)
      if (!link) return

      const pathParts = window.location.pathname.split("/")
      const userIdx = pathParts.indexOf("users")
      const currentPartnerId = userIdx >= 0 ? pathParts[userIdx + 1] : null
      const onDmPage = currentPartnerId === String(senderId) &&
                       pathParts.includes("direct_messages")
      if (onDmPage) return

      let badge = link.querySelector(".dm-unread-badge")
      if (badge) {
        const count = parseInt(badge.textContent || "0", 10) + 1
        badge.textContent = count > 99 ? "99+" : count
      } else {
        badge = document.createElement("span")
        badge.className = "dm-unread-badge"
        badge.setAttribute("aria-label", "unread messages")
        badge.textContent = "1"
        link.appendChild(badge)
      }

      if (document.body.dataset.dmSounds === "true") {
        try {
          const ctx = new (window.AudioContext || window.webkitAudioContext)()
          const osc = ctx.createOscillator()
          const gain = ctx.createGain()
          osc.connect(gain)
          gain.connect(ctx.destination)
          osc.frequency.value = 880
          osc.type = "sine"
          gain.gain.setValueAtTime(0.1, ctx.currentTime)
          gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.08)
          osc.start(ctx.currentTime)
          osc.stop(ctx.currentTime + 0.08)
        } catch (e) { /* AudioContext not available */ }
      }
    } else if (data.type === "channel_unread") {
      const link = document.querySelector(`[data-room-slug="${data.room_slug}"]`)
      if (!link) return
      const pathParts = window.location.pathname.split("/")
      const roomIdx = pathParts.indexOf("rooms")
      const currentRoomSlug = roomIdx >= 0 ? pathParts[roomIdx + 1] : null
      if (currentRoomSlug === data.room_slug) return
      let badge = link.querySelector(".channel-unread-badge")
      if (data.count > 0) {
        if (!badge) {
          badge = document.createElement("span")
          badge.className = "channel-unread-badge"
          badge.setAttribute("aria-label", "unread messages")
          link.appendChild(badge)
        }
        badge.textContent = data.count > 99 ? "99+" : data.count
      } else if (badge) {
        badge.remove()
      }
    } else if (data.type === "mention") {
      if (document.body.dataset.mentionAlerts !== "false") {
        showToast(`Mentioned in #${data.room_name}`, `${data.sender_name}: ${data.body_preview}`)
      }
    } else if (data.type === "dm_read") {
      const dmEl = document.getElementById(`dm-${data.message_id}`)
      if (!dmEl) return
      let receipt = dmEl.querySelector(".dm-read-receipt")
      if (!receipt) {
        receipt = document.createElement("div")
        receipt.className = "dm-read-receipt"
        dmEl.querySelector(".flex-1")?.appendChild(receipt)
      }
      receipt.textContent = "✓✓ Read"
    }
  }
})
