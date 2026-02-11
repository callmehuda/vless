let vpsSocket = null;

export default {
  async fetch(request) {
    const upgrade = request.headers.get("Upgrade");
    const url = new URL(request.url);

    if (upgrade !== "websocket") {
      return new Response("Reverse VLESS Tunnel Active", { status: 200 });
    }

    // VPS connects here
    if (url.pathname === "/vps") {
      const [client, server] = Object.values(new WebSocketPair());
      server.accept();
      vpsSocket = server;
      return new Response(null, { status: 101, webSocket: client });
    }

    // Client connects here
    if (url.pathname === "/client") {
      if (!vpsSocket) {
        return new Response("VPS not connected", { status: 503 });
      }

      const [client, server] = Object.values(new WebSocketPair());
      server.accept();
      vpsSocket.accept();

      server.addEventListener("message", evt => vpsSocket.send(evt.data));
      vpsSocket.addEventListener("message", evt => server.send(evt.data));

      server.addEventListener("close", () => vpsSocket.close());
      vpsSocket.addEventListener("close", () => server.close());

      return new Response(null, { status: 101, webSocket: client });
    }

    return new Response("Invalid endpoint", { status: 404 });
  }
}
