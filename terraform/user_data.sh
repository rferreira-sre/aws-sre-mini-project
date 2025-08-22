#!/usr/bin/env bash
set -euo pipefail

dnf -y update
dnf -y install nginx curl

systemctl enable nginx
systemctl start nginx

TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

IID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

PUBIP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AZ::-1}

cat >/usr/share/nginx/html/index.html <<EOF
<!doctype html>
<html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${project_title}</title>
<style>
:root { --bg:#0f172a; --card:#111827; --text:#e5e7eb; --muted:#9ca3af; }
*{box-sizing:border-box} body{margin:0;font-family:system-ui,-apple-system,Segoe UI,Roboto,Ubuntu,sans-serif;background:linear-gradient(135deg,#0f172a,#1f2937)}
.wrap{min-height:100vh;display:flex;align-items:center;justify-content:center;padding:24px}
.card{width:100%;max-width:760px;background:rgba(17,24,39,.85);border:1px solid rgba(255,255,255,.08);border-radius:18px;padding:28px;backdrop-filter:blur(6px);box-shadow:0 10px 30px rgba(0,0,0,.35)}
h1{color:#fff;margin:0 0 8px;font-size:28px} p{color:var(--muted);margin:0 0 16px}
.badge{display:inline-block;padding:6px 10px;border-radius:999px;background:rgba(34,197,94,.12);color:#86efac;font-weight:600;font-size:12px;margin:4px 0 16px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px;margin-top:12px}
.tile{background:#0b1220;border:1px solid rgba(255,255,255,.06);border-radius:14px;padding:14px}
.label{color:#9ca3af;font-size:12px;margin-bottom:6px}.value{color:#e5e7eb;font-weight:600;word-break:break-all}
.footer{margin-top:18px;color:#9ca3af;font-size:12px}
</style></head>
<body><div class="wrap"><div class="card">
<div class="badge">HTTP 200 • Nginx is running</div>
<h1>${project_title}</h1>
<p>Mini environment for IaC, CI/CD, monitoring, and incident drills.</p>
<div class="grid">
  <div class="tile"><div class="label">Instance ID</div><div class="value">${IID}</div></div>
  <div class="tile"><div class="label">Public IPv4</div><div class="value">${PUBIP}</div></div>
  <div class="tile"><div class="label">Region / AZ</div><div class="value">${REGION} / ${AZ}</div></div>
  <div class="tile"><div class="label">Server</div><div class="value">Amazon Linux 2023 • Nginx</div></div>
</div>
<div class="footer">Project: AWS SRE Demo • Built by Rafael Ferreira</div>
</div></div></body></html>
EOF

nginx -t && systemctl reload nginx
