let Post = {

  init(socket, element) {
    if (!element){ return }
    let postId = element.getAttribute("data-id")
    socket.connect()

    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let submitButton = document.getElementById("msg-submit")
    let postChannel = socket.channel("posts:" + postId)
    // TODO: Join the channel
  },
}

export default Post
