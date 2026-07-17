# Assignment 6 — Build an AI-Assisted Linux Health Check (AI-Assisted Linux Incident Triage)

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will build a read-only Bash triage script that checks the health of your Ubuntu server and Nginx application, connect it to Claude Code as a reusable `/linux-triage` skill, simulate a controlled Nginx incident, use the skill to gather and analyze evidence, recover the service manually, and verify recovery. The workflow follows the Agentic Loop: Gather → Analyze → Human Act → Verify.

---

# Task 1 — Confirm the Healthy Baseline and Create the Workspace

## Goal

Confirm that Nginx and the React application are healthy before building the automation.

### Evidence

#### Screenshot 1 — Output of `systemctl is-active nginx`, `ss -ltn | grep ':80'`, and `curl -I http://localhost`

![Assignment 6](screenshots/ass6/1.png)

---

#### Screenshot 2 — Output of `pwd` and `find . -maxdepth 4 -type d | sort` showing the workspace folder structure

![Assignment 6](screenshots/ass6/2.png)

---

### Notes

Answer the following in your own words:

**1. What proves that Nginx is running?**

I used systemctl is-active nginx. It showed active, which means Nginx is running.

---

**2. What proves that the server is listening for HTTP traffic?**

ss -ltn | grep ':80'. It showed port 80 is listening, which means the server can accept HTTP requests.

---

**3. Why must you capture a healthy baseline before simulating an incident?**

A healthy baseline shows that everything is working before testing. It helps compare the system before and after the incident and makes it easier to check if the fix worked.

---

# Task 2 — Create Project Context and Safety Rules in CLAUDE.md

## Goal

Tell Claude exactly what this project does and what it is not allowed to do.

### Evidence

#### Screenshot 3 — CLAUDE.md open in VS Code showing all four sections (Project Overview, Incident Workflow, Safety Rules, Output Rules)

![Assignment 6](screenshots/ass6/t2.png)


---

### Notes

Answer the following in your own words:

**1. Why should Claude receive project-specific operational rules?**

It help Claude follow the correct steps and give safe answers.

---

**2. Why is the human required to execute the recovery command?**

Because restarting or changing the system should be done by a person to avoid mistakes.

---

**3. Which rule prevents Claude from making an unsupported diagnosis?**

Claude can only use the Bash report as evidence. It should not guess the cause without proof.

---

# Task 3 — Use Agentic AI to Plan Before Writing the Script

## Goal

Use Claude Code to inspect the environment and produce a read-only plan before creating any Bash code.

### Evidence

#### Screenshot 4 — Claude Code showing the five-check plan and read-only inspection results

![Assignment 6](screenshots/ass6/t3.png)

---

### Notes

Answer the following in your own words:

**1. Which part of this task represents the Gather phase?**

Gather phase is where Claude checks the server and collects information.

---

**2. Did Claude follow the instruction not to create files? How did you verify this?**

Yes. Claude only checked the server and did not create or change any files.

---

**3. Why is planning before coding useful in DevOps automation?**

Planning helps avoid mistakes and makes the script easier to write.

---

# Task 4 — Build the Linux Triage Bash Script

## Goal

Create one Bash script that gathers consistent Linux and Nginx health evidence.

### Evidence

#### Screenshot 5 — Top section of `linux-triage.sh` showing variables, thresholds, and the checks array

![Assignment 6](screenshots/ass6/t4.png)

---

#### Screenshot 6 — Middle section showing check functions and conditionals

![Assignment 6](screenshots/ass6/t4..png)

---

#### Screenshot 7 — Bottom section showing the loop, summary function, and exit behavior

![Assignment 6](screenshots/ass6/t4...png)

---

#### Screenshot 8 — Output of `bash -n scripts/linux-triage.sh` (no syntax errors) and `ls -l scripts/linux-triage.sh` showing executable permission

![Assignment 6](screenshots/ass6/t4....png)

---

### Notes

Answer the following in your own words:

**1. What is stored in the checks array?**

The checks array stores the names of the health check functions.

---

**2. How does the `for` loop use that array?**

The loop runs each health check one by one.

---

**3. Why are the health checks separated into functions?**

It keeps the script clean and makes it easier to use again.

---

**4. What is the purpose of `$(...)` in this script?**

It runs a command and saves its output.

---

**5. Why does the script use different exit codes for HEALTHY, WARN, and FAIL?**

Different exit codes show if the system is healthy, has a warning, or has a failure.

---

# Task 5 — Run and Understand the Healthy-State Report

## Goal

Run the Bash script against the healthy server and verify that it creates a report.

### Evidence

#### Screenshot 9 — Output of `./scripts/linux-triage.sh` showing your Full Name and all five check results

![Assignment 6](screenshots/ass6/t5.png)

---

#### Screenshot 10 — Output showing the captured exit code and final summary

![Assignment 6](screenshots/ass6/t5..png)

---

### Notes

Answer the following in your own words:

**1. What is the overall status of your healthy baseline?**

The system was healthy and everything was working normally.

---

**2. Which exact Linux evidence proves the application is serving traffic?**

curl -I http://localhost command returned HTTP 200 OK.

---

**3. Did your script return exit code 0 or 1? Explain why.**

It returned 0 because the system was healthy.

---

**4. What is the difference between a warning and a failure in this script?**

A warning means there may be a small issue. A failure means something is broken.

---

# Task 6 — Create and Run the /linux-triage Skill

## Goal

Turn the Bash script into a reusable, manually invoked Agentic AI workflow.

### Evidence

#### Screenshot 11 — `SKILL.md` showing the frontmatter, allowed tool restrictions, and safety rules

![Assignment 6](screenshots/ass6/t6.png)

---

#### Screenshot 12 — `/linux-triage` output for the healthy server

![Assignment 6](screenshots/ass6/t6..png)

---

### Notes

Answer the following in your own words:

**1. Why does this skill have Bash, Read, and Grep, but not Write?**

Because it only checks the system and does not change anything.

---

**2. Why is `disable-model-invocation: true` useful for this skill?**

It makes sure the skill follows the given steps correctly.

---

**3. What part is performed by Bash, and what part is performed by Claude?**

Bash collects the information, and Claude reads it and explains the results.

---

**4. Why is this better than asking Claude "Is my server healthy?" without giving it evidence?**

Because Claude uses real system information instead of guessing.

---

# Task 7 — Simulate an Nginx Incident and Let the Skill Diagnose It

## Goal

Create a controlled service failure, gather evidence through Bash, and let Claude analyze the evidence without taking recovery action.

### Evidence

#### Screenshot 13 — Output showing Nginx is inactive and the HTTP request fails

![Assignment 6](screenshots/ass6/t7.png)

---

#### Screenshot 14 — `/linux-triage` output showing failed evidence, most likely cause, and a suggested recovery command

![Assignment 6](screenshots/ass6/t7..png)

---

#### Screenshot 15 — `incident-failure-report.txt` showing the failed checks and your Full Name

![Assignment 6](screenshots/ass6/t7...png)

---

### Notes

Answer the following in your own words:

**1. Which three checks failed?**

The Nginx service check, port 80 check, and HTTP check failed.

---

**2. What evidence supports the conclusion that Nginx is unavailable?**

Nginx was inactive, port 80 was not listening, and the HTTP request failed.

---

**3. Did Claude execute the recovery command? Why is that important?**

No. Claude only suggested the command. I ran it manually to keep the system safe.

---

**4. Which phase of the Agentic Loop is represented by the Bash report?**

The Bash report is the Gather phase because it collects system information.

---

**5. Which phase is represented by Claude's explanation?**

Claude's explanation is the Analyze phase because it explains the problem.

---

# Task 8 — Recover Manually, Verify Again, and Write the Incident Summary

## Goal

Recover the service as the human operator and prove that the system is healthy again.

### Evidence

#### Screenshot 16 — Output showing Nginx is active and `curl -I http://localhost` returns 200 OK

![Assignment 6](screenshots/ass6/t8.png)

---

#### Screenshot 17 — Second `/linux-triage` output showing successful recovery with no FAIL results

![Assignment 6](screenshots/ass6/t8..png)

---

#### Screenshot 18 — Output of `ls -lah reports` showing both `incident-failure-report.txt` and `recovery-report.txt`

![Assignment 6](screenshots/ass6/t8...png)

---

#### Screenshot 19 — `incident-summary.md` showing all required sections and your Full Name

![Assignment 6](screenshots/ass6/t8....png)

---

### Notes

Answer the following in your own words:

**1. What action did you execute manually?**

I manually ran the command to start Nginx.

---

**2. What evidence proves that the service recovered?**

Nginx became active, the website returned HTTP 200 OK, and all health checks passed.

---

**3. Why is the second triage run necessary?**

It checks that the problem is fixed and everything is working again.

---

**4. What could go wrong if an AI agent automatically restarted every failed service?**

It could restart the wrong service or cause more problems.

---

**5. In one sentence, explain the difference between using AI as a chatbot and using AI in this agentic workflow.**

A chatbot answers questions, but an agentic AI checks the system and helps find problems using real data.

---

# Incident Summary

Fill in all seven sections below in your own words.

**Full Name:** Abhinav T

**Date:** 17/07/2026

---

**1. Reported Symptom**

Nginx was not running, so the website was not working

---

**2. Evidence Collected**

Nginx service was inactive.
Port 80 was not listening.
HTTP check returned 000.
Logs showed Nginx was stopped successfully.

---

**3. Most Likely Cause**

Nginx was stopped, so the website could not respond.

---

**4. Human-Approved Recovery Action**

sudo systemctl start nginx

---

**5. Verification**

Nginx became active.
curl http://localhost returned HTTP 200 OK.
Health report showed PASS: 5, FAIL: 0.

---

**6. Safety Decision**

 The AI only found the problem. I started Nginx myself because only a person should make system changes

---

**7. Agentic Loop Mapping**

Gather -> Checked the system.
Analyze -> Found that Nginx was stopped.
Human Act -> I started Nginx.
Verify -> Checked again and everything was working.

---

# LinkedIn Post (Required)

## Evidence

#### LinkedIn Post URL

https://www.linkedin.com/posts/abhinav-t-210682296_linux-bash-devops-ugcPost-7483896016275136513-hq0b/?utm_source=share&utm_medium=member_desktop&rcm=ACoAAEelfqwBrAEfQ03WBMjV0-o9bvqgBIe7vGM

---

#### Screenshot — Published LinkedIn post

![Assignment 6](screenshots/ass6/0.png)


---

# GitHub Repository URL

https://github.com/abhinavleo/Ultimate-Agentic-DevOps-with-Claude-Code.git
---

# Submission Instructions

- Add all required screenshots in your submission
- Full Name must be visible in required screenshots and the Bash report
- All written answers must be in your own words
- Do not expose sensitive information (keys, passwords, AWS account IDs, tokens)
- GitHub URL must be included in this document

---

# Completion Checklist

- [ ] Task 1: Healthy baseline confirmed, workspace created (Screenshots 1–2, Notes answered)
- [ ] Task 2: CLAUDE.md created with all four sections (Screenshot 3, Notes answered)
- [ ] Task 3: Five-check plan produced by Claude using read-only tools (Screenshot 4, Notes answered)
- [ ] Task 4: `linux-triage.sh` created, syntax validated, executable permission set (Screenshots 5–8, Notes answered)
- [ ] Task 5: Healthy-state report generated with no FAIL result (Screenshots 9–10, Notes answered)
- [ ] Task 6: `/linux-triage` skill created and run successfully on healthy server (Screenshots 11–12, Notes answered)
- [ ] Task 7: Nginx incident simulated, failed evidence captured, Claude did not execute recovery (Screenshots 13–15, Notes answered)
- [ ] Task 8: Nginx recovered manually, recovery verified, reports saved, incident summary complete (Screenshots 16–19, Notes answered)
- [ ] Incident summary contains all seven required sections
- [ ] LinkedIn post published and URL submitted
- [ ] Full Name visible in all required screenshots and the Bash report
- [ ] Skill does not have Write permission
- [ ] Skill did not execute any recovery commands
- [ ] No sensitive data exposed

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://pravinmishra.com/dmi  
- 🎓 DevOps for Beginners (Udemy): https://www.udemy.com/course/devops-for-beginners-docker-k8s-cloud-cicd-4-projects/  
- 🎓 Agentic AI DevOps with Claude Code: https://www.udemy.com/course/ultimate-agentic-ai-devops-with-claude-code/  
- 🎓 DevOps with Claude Code: Terraform, EKS, ArgoCD & Helm: https://www.udemy.com/course/devops-with-claude-code-terraform-eks-argocd-helm/  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*