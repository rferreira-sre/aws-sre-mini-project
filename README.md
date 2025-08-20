# 🚀 SRE/DevOps Project – AWS, Terraform, Monitoring & Incident Drill

A small, production-style demo to showcase SRE fundamentals on AWS Free Tier.
The project intentionally starts with manual setup and then evolves into Infrastructure as Code (Terraform + Azure DevOps/GitHub CI/CD), simulating how real teams migrate from manual ops → automation.


# 🎯 Overall Goal

- Demonstrate Site Reliability Engineering practices end-to-end on AWS.

- Cover infra setup, monitoring, automation, CI/CD, incident response, and postmortems.

- Simulate real-world workflows with Jira (Epics, Tasks, Sprints), GitHub (branches, PRs), and AWS tooling.

# **📌 Roadmap / Steps**


**Manual Phase (completed)**

- Launch EC2 instance (Amazon Linux 2023, Free Tier).

- Configure Security Groups (least privilege).

- Install & serve a custom Nginx landing page.

- Enable CloudWatch metrics (CPU, Status Checks).

- Add alarms via SNS for notifications.

- Perform a manual incident drill: stop Nginx, trigger Route 53 health check → CloudWatch alarm → SNS email.

- Document incident + postmortem in repo and Jira.
 
# **🔜 Next Phases (in progress / planned)**

- Terraform (IaC): codify EC2, SG, S3, CloudWatch alarms, SNS topics.

- CI/CD (Azure Pipelines & GitHub Actions): plan/apply/destroy Terraform infra with gated approvals.

- Scripting: health checks (health_check.sh) and automated S3 backups (s3_backup.py).

- Advanced SRE: SLI/SLOs, error budgets, lessons learned.

- Final polish: Jira traceability + interview-ready documentation.



---

## 📂 Repo Structure

<img width="618" height="394" alt="image" src="https://github.com/user-attachments/assets/e631003f-2709-4b51-bc3e-d2561821f549" />


---

## 🌐 Cloud Setup (Epic E1)

AWS resources created manually first:
- EC2 (Nginx web server)
- Route 53 health checks
- CloudWatch alarms
- SNS notifications

📸 Screenshots:  
<img width="585" height="324" alt="image" src="https://github.com/user-attachments/assets/ddb90144-2518-46f6-99d1-c5713c73e3fa" />

<img width="926" height="113" alt="image" src="https://github.com/user-attachments/assets/f83b5460-e4d9-495d-b6f1-808233790751" />

![Route53 HealthCheck](docs/manual/route53-health.png)  

<img width="886" height="230" alt="image" src="https://github.com/user-attachments/assets/3580d62b-2f49-40a1-83bb-7f5b03e3962f" />


---

## 🛠️ Terraform IaC (Epic E2)

All manual AWS resources migrated to Terraform for repeatability.  
Key modules: `ec2`, `route53`, `cloudwatch`, `sns`.

📸 Screenshots:  
![Terraform Plan](docs/manual/terraform-plan.png)  
![Terraform Apply](docs/manual/terraform-apply.png)  

---

## ⚡ CI/CD Pipeline (Epic E3)

Azure DevOps pipeline builds & deploys Terraform automatically.

📸 Screenshots:  
![Azure Pipeline](docs/manual/azure-pipeline.png)  

---

## 🔔 Monitoring & Incident Drill (Epic E4)

### Incident Drill – Nginx Outage (2025-08-20)

**Jira:** SRE-8  
**Service:** EC2 (Nginx)  
**Detection:** Route 53 HTTP health check → CloudWatch Alarm → SNS email  
**Impact:** Landing page unavailable from the internet  

### Timeline (UTC)
- 02:37 – Stopped nginx (`systemctl stop nginx`)  
- 02:40 – CloudWatch alarm entered **ALARM** (SNS email received)  
- 02:45 – Started nginx (`systemctl start nginx`)  
- 02:47 – Alarm returned to **OK** (recovery email)  

### Root Cause
This was a **manual drill**, not a real outage. We intentionally stopped nginx to validate monitoring & alerting.  

### Recovery
Restarted nginx. Verified Route 53 health check healthy and CloudWatch alarm back to **OK**.  

### Evidence
<img width="675" height="419" alt="image" src="https://github.com/user-attachments/assets/0b63bf66-ce69-4270-8d28-a80f03772c42" />

<img width="1418" height="230" alt="image" src="https://github.com/user-attachments/assets/8a7bcae4-51fc-4674-9e5c-21a32969080a" />

<img width="1404" height="589" alt="image" src="https://github.com/user-attachments/assets/35f0b237-af1b-400f-a1f6-965155ee2b27" />

<img width="1387" height="534" alt="image" src="https://github.com/user-attachments/assets/223db00c-aac4-4963-86c6-92d53ef5bf0d" />
 

📄 Full report: [docs/incidents/2025-08-20-nginx-drill.md](docs/incidents/2025-08-20-nginx-drill.md)  

---

## 📊 Jira Documentation (Epic E5)

Project fully tracked in **Jira** with Epics → Tasks → Sprints.

- **Epic E1:** Cloud Setup  
- **Epic E2:** Terraform  
- **Epic E3:** CI/CD  
- **Epic E4:** Monitoring & Incidents  
- **Epic E5:** Docs & Interview Prep  

Example:  
- **Task SRE-8:** Manual Incident Drill – Stop Nginx & Validate Alarm  
  - Subtasks: stop service, verify alert, recover service, document incident  
  - Linked PR: `feature/SRE-8-incident-drill`  
  - Evidence: screenshots + SNS emails  

📸 Jira Screenshots:  
<img width="1725" height="716" alt="image" src="https://github.com/user-attachments/assets/d532397c-7150-4488-aecb-6e81a1a9d763" />


<img width="1641" height="833" alt="image" src="https://github.com/user-attachments/assets/c60ad5ca-c537-43fc-8897-b5205bf385f6" />


---

## ✅ Lessons Learned
- App-level monitoring is required; EC2 host metrics alone won’t catch app failures.  
- Route 53 + CloudWatch + SNS = simple but effective lightweight monitoring.  
- Terraform migration ensures infra is reproducible.  
- Jira provides full visibility into tasks, drills, and outcomes.  

---

## 🏁 Next Steps
- Convert Route 53 + CloudWatch alarms into Terraform (SRE-6).  
- Integrate alarm notifications with Slack or MS Teams.  
- Expand CI/CD pipelines with automated test stages.  

---

