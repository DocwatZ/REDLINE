import { Controller } from "@hotwired/stimulus"

/**
 * LiveKit controller — manages WebRTC voice/video calls.
 *
 * Flow:
 *  1. User clicks "Join Call"
 *  2. Fetch JWT token from server (room-scoped, user-scoped)
 *  3. Connect to LiveKit server via livekit-client SDK
 *  4. Publish local audio/video tracks
 *  5. Subscribe to remote participant tracks and render tiles
 *
 * Accessibility:
 *  - Call panel uses aria-live="polite" for participant announcements
 *  - Mute button uses aria-pressed
 *  - All participant tiles have accessible labels
 *
 * NOTE: livekit-client is loaded from importmap / CDN.
 *       Set LIVEKIT_URL in your .env for the WebSocket endpoint.
 */
export default class extends Controller {
  static values = { tokenUrl: String }

  connect() {
    this.room = null
    this.localMicMuted = false
  }

  async joinCall() {
    try {
      const { token, url } = await this.fetchToken()
      await this.connectToRoom(token, url)
      document.getElementById("call-panel")?.classList.remove("hidden")
      document.getElementById("join-call-btn")?.setAttribute("aria-disabled", "true")
      this.announce("Joined the voice call")
    } catch (err) {
      console.error("LiveKit join error:", err)
      this.announce("Failed to join call: " + err.message)
    }
  }

  async fetchToken() {
    const csrf = document.querySelector('meta[name="csrf-token"]')?.content
    const resp = await fetch(this.tokenUrlValue, {
      headers: { "X-CSRF-Token": csrf ?? "" }
    })
    if (!resp.ok) throw new Error("Token fetch failed")
    return resp.json()
  }

  async connectToRoom(token, url) {
    // The livekit-client package exports its API via the module namespace
    // When loaded via importmap/ESM it attaches to the module, not window.
    // We dynamically import it to avoid blocking and reference via import.
    let LK
    try {
      LK = await import("livekit-client")
    } catch {
      throw new Error("LiveKit client library not loaded. Check importmap configuration.")
    }

    this._LK = LK

    this.room = new LK.Room({
      adaptiveStream: true,
      dynacast: true
    })

    this.room.on(LK.RoomEvent.ParticipantConnected, (p) => {
      this.announce(`${p.identity} joined the call`)
      this.renderParticipant(p)
    })

    this.room.on(LK.RoomEvent.ParticipantDisconnected, (p) => {
      this.announce(`${p.identity} left the call`)
      document.getElementById(`participant-${p.identity}`)?.remove()
    })

    this.room.on(LK.RoomEvent.TrackSubscribed, (track, _pub, participant) => {
      this.attachTrack(track, participant)
    })

    await this.room.connect(url, token)

    // Publish local mic
    await this.room.localParticipant.setMicrophoneEnabled(true)
    this.renderLocalParticipant()
  }

  renderLocalParticipant() {
    const me = this.room?.localParticipant
    if (!me) return
    const tile = this.createTile(me.identity, me.identity + " (you)")
    document.getElementById("call-participants")?.appendChild(tile)
  }

  renderParticipant(participant) {
    const tile = this.createTile(participant.identity, participant.identity)
    document.getElementById("call-participants")?.appendChild(tile)
  }

  attachTrack(track, participant) {
    const LK = this._LK
    if (!LK) return

    const tile = document.getElementById(`participant-${participant.identity}`)
    if (!tile) return

    if (track.kind === LK.Track.Kind.Video) {
      const video = document.createElement("video")
      video.autoplay = true
      video.playsInline = true
      video.muted = true
      video.setAttribute("aria-label", `${participant.identity}'s video`)
      track.attach(video)
      tile.prepend(video)
    } else if (track.kind === LK.Track.Kind.Audio) {
      const audio = document.createElement("audio")
      audio.autoplay = true
      audio.setAttribute("aria-label", `${participant.identity}'s audio`)
      track.attach(audio)
      tile.appendChild(audio)
    }
  }

  createTile(identity, label) {
    const tile = document.createElement("div")
    tile.id = `participant-${identity}`
    tile.className = "participant-tile"
    tile.setAttribute("role", "listitem")
    tile.setAttribute("aria-label", label)
    tile.innerHTML = `<span class="text-xs text-secondary">${this.escapeHtml(label)}</span>`
    return tile
  }

  toggleMic() {
    if (!this.room) return
    this.localMicMuted = !this.localMicMuted
    this.room.localParticipant.setMicrophoneEnabled(!this.localMicMuted)

    const btn = document.getElementById("toggle-mic")
    if (btn) {
      btn.setAttribute("aria-pressed", String(this.localMicMuted))
      btn.textContent = this.localMicMuted ? "Unmute" : "Mute"
    }
    this.announce(this.localMicMuted ? "Microphone muted" : "Microphone unmuted")
  }

  leaveCall() {
    this.room?.disconnect()
    this.room = null
    document.getElementById("call-panel")?.classList.add("hidden")
    document.getElementById("call-participants").innerHTML = ""
    document.getElementById("join-call-btn")?.removeAttribute("aria-disabled")
    this.announce("Left the voice call")
  }

  announce(msg) {
    let region = document.getElementById("livekit-announce")
    if (!region) {
      region = document.createElement("div")
      region.id = "livekit-announce"
      region.setAttribute("role", "status")
      region.setAttribute("aria-live", "polite")
      region.className = "sr-only"
      document.body.appendChild(region)
    }
    region.textContent = msg
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.appendChild(document.createTextNode(String(str ?? "")))
    return div.innerHTML
  }

  disconnect() {
    this.room?.disconnect()
  }
}
