# Manual Incident Drill – Nginx Outage (2025-08-20)

**Jira:** SRE-8  
**Type:** Drill (simulated manual outage)  
**Service:** EC2 (Nginx)  
**Detection:** Route 53 HTTP health check → CloudWatch Alarm → SNS email  
**Impact:** Landing page unavailable (simulated)

---

## Timeline (UTC)
- 23:01 – Stopped nginx (`systemctl stop nginx`)  
- 23:05 – CloudWatch alarm entered **ALARM** (email received)  
- 23:06 – Started nginx (`systemctl start nginx`)  
- 23:07 – Alarm returned to **OK** (recovery email)  

---

## Root Cause
- Intentional **manual drill**: nginx stopped to validate monitoring & alerting.  

---

## Recovery
- Restarted nginx service.  
- Verified Route 53 health check healthy and CloudWatch alarm back to **OK**.  

---

## Evidence
- Screenshot: browser error (nginx down)  
![alt text](<docs/manual/Browser Down.png>)

- Screenshot: CloudWatch alarm in **ALARM**  
![alt text](<docs/manual/CloudWatch alarm .png>)

- Screenshot: SNS **ALARM** email  
![alt text](<docs/manual/SNS alarm email.png>)

- Screenshot: CloudWatch alarm back to **OK** (+ recovery email)  
![alt text](<docs/manual/OK email.png>)

---

## Lessons Learned
- HTTP-level monitoring (app health) is critical — EC2 host metrics alone would miss this.  
- Route 53 + CloudWatch + SNS chain works as expected.  
- Adding **OK notifications** improves incident visibility.  

---

## Notes
- This was a **controlled manual drill**.  
- No real user/customer impact.
