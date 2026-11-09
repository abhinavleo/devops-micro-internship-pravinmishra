# Assignment 6 — Capstone: Deploy Book Review App (Three-Tier Architecture) on Azure

Part of the DevOps Micro Internship (DMI) with Agentic AI

---

## Purpose

This is the most important assignment of the course. You will deploy the Book Review App in a production-ready, best-practice-compliant three-tier architecture on Azure: separated presentation, application, and database tiers, least-privilege network access, a controlled public entry point, protected secrets, and availability/monitoring evidence.

---

# Task 1 — Design the Azure Three-Tier Architecture

## Goal

Create an architecture diagram and implementation plan identifying the presentation, application, and database components, the chosen Azure services, the public entry point, and the internal traffic paths.

### Evidence

#### Screenshot 1 — Architecture diagram showing the public entry point, three tiers, network boundaries, and traffic flow
![Assignment 6](screenshots/ass6/1.jpg)


---

#### Screenshot 2 — Written architecture assumptions and selected Azure services
![Assignment 6](screenshots/ass6/2.jpg)

---

# Task 2 — Create the Azure Network Foundation

## Goal

Create a dedicated Resource Group and VNet with separate subnets for the web, application, and database tiers, keeping the application and database tiers without direct public access.

### Evidence

#### Screenshot 3 — Resource Group overview showing the assignment resources
![Assignment 6](screenshots/ass6/3.jpg)
---

#### Screenshot 4 — VNet overview showing the address space and all required subnets
![Assignment 6](screenshots/ass6/4.jpg)


---

#### Screenshot 5 — Route-table or Private DNS evidence where applicable
![Assignment 6](screenshots/ass6/5.jpg)


---

# Task 3 — Configure Security and Secret Management

## Goal

Apply least-privilege NSG rules so traffic flows Internet → public entry point → web tier → application tier → database tier, and store credentials in Azure Key Vault or another approved secure mechanism.

### Evidence

#### Screenshot 6 — NSG rules proving least-privilege access between the tiers
![Assignment 6](screenshots/ass6/6.jpg)
![Assignment 6](screenshots/ass6/6b.jpg)

---

#### Screenshot 7 — Key Vault or approved secret-management configuration (without displaying secret values)
![Assignment 6](screenshots/ass6/7.jpg)


---

# Task 4 — Deploy the Presentation (Web) Tier

## Goal

Deploy the Book Review App presentation layer on the approved web-tier compute service, configured to route requests to the internal application-tier endpoint, and not directly exposed except through the public entry service.

### Evidence

#### Screenshot 8 — Web-tier compute overview showing subnet and availability configuration
![Assignment 6](screenshots/ass6/8.jpg)


---

#### Screenshot 9 — Terminal or service output proving the presentation layer is running
![Assignment 6](screenshots/ass6/9.jpg)


---

# Task 5 — Deploy the Business (Application) Tier

## Goal

Deploy the Book Review App backend privately in the application subnet, configured to use the private database endpoint and secured environment values, reachable only through its internal endpoint.

### Evidence

#### Screenshot 10 — Application-tier compute overview showing private subnet placement
![Assignment 6](screenshots/ass6/10.jpg)
---

#### Screenshot 11 — Backend process, service, or listening-port evidence
![Assignment 6](screenshots/ass6/11.jpg)


---

#### Screenshot 12 — Internal health-check or API response (without exposing secrets)
![Assignment 6](screenshots/ass6/12.jpg)


---

# Task 6 — Deploy the Managed Database Tier

## Goal

Create a private Azure managed database (public access disabled), with availability/backup/retention settings, the Book Review App schema imported, and access restricted to the application tier only.

### Evidence

#### Screenshot 13 — Database overview showing private connectivity and public access disabled
![Assignment 6](screenshots/ass6/13.jpg)
---

#### Screenshot 14 — Availability, backup, and retention configuration
![Assignment 6](screenshots/ass6/14.jpg)

---

#### Screenshot 15 — Successful schema or connectivity verification (without exposing credentials)
![Assignment 6](screenshots/ass6/15.jpg)

---

# Task 7 — Configure Traffic Management, Availability, and Monitoring

## Goal

Configure the approved public entry service with health probes and backend pools, internal routing for the application tier where required, and enable Azure Monitor/diagnostics/logs/alerts for the key resources.

### Evidence

#### Screenshot 16 — Public entry service showing listener, frontend endpoint, and healthy web targets
![Assignment 6](screenshots/ass6/16.jpg)


---

#### Screenshot 17 — Internal application-tier load-balancing or routing configuration where applicable
![Assignment 6](screenshots/ass6/17.jpg)


---

#### Screenshot 18 — Azure Monitor, diagnostic settings, logs, metrics, or alert evidence
![Assignment 6](screenshots/ass6/18a.jpg)
![Assignment 6](screenshots/ass6/18b.jpg)
![Assignment 6](screenshots/ass6/18c.jpg)


---

# Task 8 — Validate the Production-Style Deployment

## Goal

Confirm the Book Review App works end to end through the public endpoint, with at least one database read and one write, confirm private tiers are not internet-reachable, and complete a safe availability test.

### Evidence

#### Screenshot 19 — Browser showing the Book Review App through the public endpoint
![Assignment 6](screenshots/ass6/19.jpg)
---

#### Screenshot 20 — Proof of successful database-backed read and write operations
![Assignment 6](screenshots/ass6/20.jpg)
![Assignment 6](screenshots/ass6/20b.jpg)


---

#### Screenshot 21 — Evidence that private tiers are not publicly accessible
![Assignment 6](screenshots/ass6/21.jpg)


---

#### Screenshot 22 — Availability-test and healthy-target evidence
![Assignment 6](screenshots/ass6/22.jpg)
![Assignment 6](screenshots/ass6/22c.jpg)


---

#### Public Endpoint

Paste your public endpoint URL here:

`http://51.141.125.27`

---

### Notes

Summarize what worked, issues encountered and how they were fixed, and the availability/security/secrets/monitoring/backup choices made.

**What worked.** The architecture came up as designed and behaved correctly under test: traffic reaches only the public load balancer, each tier admits exactly one upstream, the database has no public endpoint, and the application survived losing a web VM without interruption. The Key Vault and managed identity design worked first time, which was the part I expected to fight with.

**Issues encountered, and how they were fixed.**

The region moved. Azure Database for MySQL Flexible Server is unavailable in UK South for this subscription, to the point where even a read-only `az mysql flexible-server list-skus --location uksouth` returns `InternalServerError`, while UK West, North Europe and West Europe all answer normally. Private access requires the server and the VNet in the same region, so the deployment went to UK West.

The database was created in the portal rather than the CLI. `az mysql flexible-server create` in CLI 2.90.0 rebuilt an existing VNet twice during Assignment 5, deleting a subnet each time, when given the network by name and again when given a full resource ID. The portal path leaves the network untouched.

The application's frontend could not fetch data. The home page builds `${NEXT_PUBLIC_API_URL}/api/books` while `src/services/api.js` builds `${NEXT_PUBLIC_API_URL}/books`, so no single value satisfies both files. The backend mounts everything under `/api`, which makes `api.js` correct and the home page wrong, and the fix was to bring the home page into line and rebuild. Next.js inlines `NEXT_PUBLIC_*` values at build time, so a restart alone would not have applied it.

The application VM was refused when a load balancer command was run on it by mistake. That was the correct outcome and a useful accident: its managed identity holds read access to two secrets and nothing else.

Three resource providers needed one-time registration before use: `Microsoft.DBforMySQL`, `Microsoft.KeyVault` and `Microsoft.Insights`. None of this is visible until a command fails. Action groups also have to be created with `--location global` even though they live in a regional resource group.

**Availability.** Two web VMs in an availability set behind a Standard load balancer with a five-second health probe. High availability on the database is disabled as a cost decision, with 14-day backup retention as the recovery path.

**Security.** No VM has a public IP. Administrative SSH arrives through load balancer NAT rules restricted to one address, and the application tier is reached by jumping through a web VM. Each tier's NSG pairs an allow with an explicit deny, because Azure's default `AllowVnetInBound` rule would otherwise leave the allow doing nothing. The database user is scoped to the application subnet and to one database, and the application never uses the admin account.

**Secrets.** Azure Key Vault with a system-assigned managed identity and RBAC granted per secret. The application VM holds no stored credential and cannot read the administrator password. The database password was generated randomly and never displayed.

**Monitoring.** Azure Monitor alerts on load balancer probe availability and application tier CPU, routed to an action group. Database slow logs, audit logs and metrics stream to a Log Analytics workspace with 30-day retention. The availability alert fired and resolved during the availability test, so the monitoring is demonstrably working rather than merely configured.

**Backup.** Automated backups with 14-day retention, raised from the default 7. Geo-redundant backup is disabled as a cost decision for a single-region assessment environment.

---

# Submission Instructions

- Add all required screenshots and links in your submission
- Do not expose passwords, keys, connection strings, or subscription IDs

---

# Completion Checklist

- [ ] Task 1: Architecture diagram and assumptions documented (Screenshots 1–2)
- [ ] Task 2: Network foundation created with isolated tiers (Screenshots 3–5)
- [ ] Task 3: Least-privilege security and secret management configured (Screenshots 6–7)
- [ ] Task 4: Presentation tier deployed (Screenshots 8–9)
- [ ] Task 5: Application tier deployed privately (Screenshots 10–12)
- [ ] Task 6: Managed database tier deployed privately (Screenshots 13–15)
- [ ] Task 7: Public entry, internal routing, and monitoring configured (Screenshots 16–18)
- [ ] Task 8: End-to-end validation and availability test completed (Screenshots 19–22, Public Endpoint, Notes)
- [ ] No sensitive data exposed

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme  
- 🎓 University: https://university.pravinmishra.com?utm_source=github&utm_medium=readme  
- 💬 Discord Community: https://discord.pravinmishra.com?utm_source=github&utm_medium=readme  
- 📝 Blog: https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) — Agentic AI Track.*