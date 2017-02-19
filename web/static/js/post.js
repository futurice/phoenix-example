let Post = {

  init(socket, element) {
    if (!element){ return }
    let postId = element.getAttribute("data-id")
    socket.connect()

    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let submitButton = document.getElementById("msg-submit")
    let postChannel = socket.channel("posts:" + postId)

    postChannel.join()
      .receive("ok", resp => console.log("joined the post channel", resp))
      .receive("error", reason => console.log("join failed", reason))
  },
}

export default Post
