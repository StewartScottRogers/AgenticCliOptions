# Print the first reachable LM Studio /v1/models endpoint, or nothing.
# Probes 127.0.0.1 first, then each non-loopback / non-link-local
# IPv4 the host currently owns, on the two most common LM Studio
# ports (1234 default, 1235 the typical fallback).
$ips = @('127.0.0.1')
foreach ($n in (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue)) {
    if ($n.IPAddress -notlike '127.*' -and $n.IPAddress -notlike '169.254.*') {
        $ips += $n.IPAddress
    }
}
foreach ($ip in $ips) {
    foreach ($p in 1234, 1235) {
        $u = "http://${ip}:${p}"
        try {
            [void](Invoke-RestMethod "$u/v1/models" -TimeoutSec 1 -ErrorAction Stop)
            $u
            exit
        } catch {}
    }
}
