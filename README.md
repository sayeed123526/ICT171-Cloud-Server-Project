# ICT171 Cloud Server Project

**Student:** Sayeed Bin Akhter
**Student number:** 35820304
**Unit:** ICT171 — Introduction to Server Environments and Architectures

**Live site:** https://projectofict171.com
**Public IP:** 20.70.130.74

---

## About

A public-facing **Cybersecurity Awareness** website running on a Microsoft Azure
virtual machine (Infrastructure as a Service). The server was provisioned and
configured by hand over SSH — Ubuntu Server 24.04 LTS, Apache2, a custom HTML/CSS
website, a registered domain with DNS A records, and HTTPS via Let's Encrypt. The
full, replicable build documentation is in `docs/report.pdf`.

## Stack

| Layer       | Choice                                         |
|-------------|------------------------------------------------|
| Cloud       | Microsoft Azure (Azure for Students)           |
| OS          | Ubuntu Server 24.04 LTS                        |
| Web server  | Apache2                                         |
| TLS         | Let's Encrypt (Certbot)                         |
| Domain/DNS  | projectofict171.com → 20.70.130.74 (A records) |

## Repository structure

```
ICT171-Cloud-Server-Project/
├── README.md          # this file
├── index.html         # website
├── style.css          # website styles
├── healthcheck.sh     # server health-check script
└── docs/
    └── report.pdf     # full build documentation
```

## The website

Plain-English guidance on the three most common online threats — **phishing**,
**weak passwords**, and **malware** — each with practical advice, plus a quick
safety checklist. Content licensed under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## healthcheck.sh

A Bash monitoring script that checks the Apache service (auto-restarting it if it
has stopped), the website's HTTP response, disk and memory usage, and the days
remaining on the SSL certificate, logging each run with a timestamp to
`/var/log/healthcheck.log`. See the script header for usage and cron scheduling.

## Attribution

Build steps were adapted from the official Microsoft Azure, Apache, Certbot and
DigitalOcean documentation, cited in `docs/report.pdf`. The website content and
design, the health-check script, and the documentation are my own work, produced
with some AI assistance which is acknowledged in the report.
