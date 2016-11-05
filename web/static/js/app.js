// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import {Socket, Presence} from "phoenix"

let socket = new Socket("/socket", { params: { username: window.username } })

socket.connect()

let presences = {}
let $users = document.getElementById("users")
let $input = document.getElementById("input")
let $messages = document.getElementById("messages")
let room = socket.channel("room:lobby", {})

let listBy = (username, { metas: [first, ...rest] }) => {
  return {
    name: username,
    count: rest.length + 1
  }
}

let render = (presences) => {
  $users.innerHTML = Presence.list(presences, listBy)
    .map(user => `<li>${user.name} (${user.count})</li>`)
    .join("")
}

let messageTemplate = ({time, username, body}) => {
  return `
  <p class="msg">
    <span class="time">${time}</span>
    <strong class="username">${username}</strong>
    ${body}
  </p>`
}

room.on("presence_state", state => {
  presences = Presence.syncState(presences, state)
  render(presences)
})

room.on("presence_diff", diff => {
  presences = Presence.syncDiff(presences, diff)
  render(presences)
})

room.on("new_msg", msg => {
  $messages.innerHTML += messageTemplate(msg)
  if (msg.username == window.username) {
    $messages.scrollTop = $messages.scrollHeight
  }
})

$input.addEventListener("keypress", e => {
  if (e.keyCode == 13) {
    room.push("new_msg", { username: window.username, body: $input.value })
    $input.value = ""
  }
})

room.join()
