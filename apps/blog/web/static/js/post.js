let Post = {

  init(socket, element) {
    if (!element){ return }
    let postId = element.getAttribute("data-id")
    socket.connect()

    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let submitButton = document.getElementById("msg-submit")
    let postChannel = socket.channel("posts:" + postId)

    submitButton.addEventListener("click", e => {
      let payload = {body: msgInput.value}
      postChannel
        .push("new_comment", payload)
        .receive("error", e => console.log(e))
      msgInput.value = ""
    })

    postChannel.on("new_comment", (resp) => {
      postChannel.params.last_seen_id = resp.id
      this.renderComment(msgContainer, resp)
    })

    postChannel.join()
      .receive("ok", ({comments}) => {
        let ids = comments.map(comment => comment.id)
        if (ids.length > 0) {
          postChannel.params.last_seen_id = Math.max(...ids)
        }
        comments.forEach(comment => this.renderComment(msgContainer, comment))
      })
      .receive("error", reason => console.log("join failed", reason))
  },

  esc(str) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },

  renderComment(msgContainer, {user, body}) {
    let template = document.createElement("div")
    template.innerHTML = `
    <b>${this.esc(user.username)}</b>: ${this.esc(body)}
    `

    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  }
}

export default Post
