#!/usr/bin/env bash
# Usage: ./curl_stats.sh <url> [extra curl args...]

if [ $# -lt 1 ]; then
  echo "Usage: $0 <url> [extra curl args...]" >&2
  exit 1
fi

URL="$1"
shift  # remaining args go to curl

# Run curl in silent mode, discard body, and print only timing & network stats.
curl -s -o /dev/null -w \
"URL:            %{url_effective}
HTTP code:      %{http_code}
Remote IP:      %{remote_ip}
Remote port:    %{remote_port}
Content type:   %{content_type}
Downloaded:     %{size_download} bytes
DNS lookup:     %{time_namelookup} s
TCP connect:    %{time_connect} s
TLS handshake:  %{time_appconnect} s
TTFB:           %{time_starttransfer} s
Total time:     %{time_total} s
" \
"$URL" "$@"