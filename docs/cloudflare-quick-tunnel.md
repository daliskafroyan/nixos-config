# Cloudflare Quick Tunnel

The `cloudflared-quick-tunnel` user service manually exposes the local service at `http://127.0.0.1:3001` through a randomly generated `https://*.trycloudflare.com` URL.

## Start and share

```bash
tunnel-up
tunnel-url
```

Anyone with the generated URL can access the service. Quick Tunnels have no Cloudflare Access policy, no custom hostname, and no stable URL. Use them only for temporary testing or demos.

## Inspect and stop

```bash
tunnel-status
tunnel-down
```

The service does not start automatically at boot or login. The public URL changes whenever the tunnel restarts. Do not use it for a persistent or sensitive service.
