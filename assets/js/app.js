// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"
import Drag from './dragHook';

let Hooks = { Drag: Drag }
Hooks.CopyToClipboard = {
    mounted() {
        this.el.addEventListener("click", e => {
            var copyText = document.getElementById("game-link");
            copyText.select();
            copyText.setSelectionRange(0, 99999);
            try {
                document.execCommand("copy");
            } catch (err) {
                alert('Copy to clipboard error. Please select the area to copy and use ctrl + c shortcut keys.')
            }
        })
    }
}

Hooks.ImageContextMenu = {
    mounted() {
        this.el.addEventListener("contextmenu", e => {
            e.preventDefault()
            return false
        })
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket




