# AWS SRE Mini Project

A small, production-style demo to showcase SRE fundamentals on AWS Free Tier:
- **Compute:** EC2 (Amazon Linux 2023)
- **Networking:** Security Groups
- **Web:** Nginx with a custom landing page
- **Monitoring:** CloudWatch metrics + (optional) alarms via SNS
- **Storage:** S3 (manual bucket for Day 1–3)
- **Repo:** GitHub (CI/CD coming next in Days 4–6)

> Region: **us-east-1 (N. Virginia)**

---

## Repo Structure (current)
aws-sre-mini-project/
├─ terraform/ # (Days 4–6: will codify here)
├─ scripts/ # (Days 7–9: health check & backups)
├─ .github/workflows/ # (CI/CD: GitHub Actions)
├─ docs/screenshots/ # <-- put screenshots here
├─ README.md
└─ postmortem.md


---

## ✅ Days 1–3: What I Built

- Launched **EC2 t2.micro/t3.micro** (Amazon Linux **2023**, Free Tier).
- Created **Security Group**:
  - **HTTP (80)** → `0.0.0.0/0` (public web)
  - **SSH (22)** → **My IP** (or EC2 Instance Connect prefix list)
- Installed **Nginx** and published a UTF-8 landing page.
- Viewed instance metrics in **CloudWatch**.
- (Optional) Created a private **S3** bucket for “Day 1–3 storage.”

### Instance details (example)
- Name: `sre-day1-demo`
- AMI: Amazon Linux 2023 (x86_64, kernel 6.1)
- Type: `t2.micro` (or `t3.micro`)
- Public: `http://<PUBLIC_DNS_OR_IP>/`

---

## How to Reproduce (console only)

### 1) Launch EC2
- EC2 → **Launch instances**
- AMI: **Amazon Linux 2023 (x86_64)**
- Type: **t2.micro** (Free Tier)
- Key pair: **Proceed without key pair** (use **EC2 Instance Connect**)
- Networking:
  - New Security Group:
    - **HTTP** 80 → `0.0.0.0/0`
    - **SSH** 22 → **My IP**
  - Auto-assign public IP: **Enable**

### 2) Connect (browser SSH)
EC2 → select instance → **Connect** → **EC2 Instance Connect** → user `ec2-user`.

### 3) Install Nginx (Amazon Linux 2023)
```bash
sudo dnf update -y
sudo dnf install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

4) Custom landing page (with instance metadata)

TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
IID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
PUBIP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AZ::-1}

cat <<EOF | sudo tee /usr/share/nginx/html/index.html > /dev/null
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Rafael’s SRE Demo on AWS</title>
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
  </style>
</head>
<body>
  <div class="wrap"><div class="card">
    <div class="badge">HTTP 200 • Nginx is running</div>
    <h1>Rafael’s SRE Demo on AWS 🚀</h1>
    <p>Mini environment for IaC, CI/CD, monitoring, and incident drills.</p>

    <div class="grid">
      <div class="tile"><div class="label">Instance ID</div><div class="value">${IID}</div></div>
      <div class="tile"><div class="label">Public IPv4</div><div class="value">${PUBIP}</div></div>
      <div class="tile"><div class="label">Region / AZ</div><div class="value">${REGION} / ${AZ}</div></div>
      <div class="tile"><div class="label">Server</div><div class="value">Amazon Linux 2023 • Nginx</div></div>
    </div>

    <div class="footer">Project: AWS SRE Demo • Built by Rafael Ferreira</div>
  </div></div>
</body>
</html>
EOF

sudo nginx -t && sudo systemctl reload nginx

Open in your browser: http://52.90.228.79/

5) CloudWatch (metrics + optional alarm)

Metrics: EC2 → select instance → Monitoring tab (CPU, Status checks, Network).

Optional alarm: CPUUtilization > 70 (1 datapoint) or StatusCheckFailed ≥ 1, action → SNS topic with email subscription.

6) S3 bucket (optional)

S3 → Create bucket → name like rafael-sre-manual-<random> (private, SSE-S3).

Upload a small test file (e.g., hello.txt) or create a backups/ prefix.

Screenshots (placeholders)

Put images in docs/screenshots/ and keep these filenames so the links render.

Instances list (running, checks passed)


Security Group inbound rules (HTTP 80 open to internet; SSH 22 restricted)


Public landing page (custom Nginx page)


Monitoring chart (CPU or Status checks)


(Optional) S3 bucket overview


Ops Notes / Hardening

Keep SSH (22) restricted to My IP or the EC2 Instance Connect prefix list:
com.amazonaws.us-east-1.ec2-instance-connect

Nginx is enabled to start on boot (systemctl enable nginx).

Costs: stays in Free Tier with t2.micro/t3.micro + basic CloudWatch.

Next Steps

Days 4–6 (Terraform): codify EC2 + SG + S3 + CloudWatch + SNS.

Days 7–9 (Scripting): health_check.sh + s3_backup.py.

Days 10–11 (CI/CD): GitHub Actions to plan/apply/destroy Terraform.

Days 12–13 (SRE): SLI/SLO, error budgets, incident mgmt basics.

Day 14: Simulate incident, capture alert, write postmortem.

Day 15: Jira + Scrum/Kanban + final polish/demo.

Demo Talking Points

IaC mindset: “I started manual, then codified infra via Terraform.”

Ops hygiene: “Least-privilege SG, browser SSH via EC2 Instance Connect, UTF-8 page.”

Observability: “Viewed EC2 metrics; added alarm → SNS email for fast detection.”

Next: “Pipeline will validate/plan/apply; scripts will monitor HTTP + back up to S3.”


If you want, I can also generate the **Terraform (AL2023-compatible) files** next so your pipeline can deploy the same stack automatically.

