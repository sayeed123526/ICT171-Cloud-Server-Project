# ICT171 Cloud Server Project

**Student Name:** Sayeed Bin Akhter  
**Student Number:** 35820304  
**GitHub Repository:** https://github.com/sayeed123526/ICT171-Cloud-Server-Project  
**Live Website:** https://projectofict171.com  
**Global IP Address:** 20.70.130.74  
## Project Overview

This project documents the provisioning and deployment of a cloud-based web server
for ICT171 at Murdoch University, Semester 1 2026. The server hosts a Cybersecurity
Awareness website accessible at https://projectofict171.com. The server was built
using Microsoft Azure as an Infrastructure as a Service (IaaS) platform, with full
SSH access to an Ubuntu 24.04 LTS virtual machine. All software was installed and
configured manually from the command line.

---

## Infrastructure

| Component        | Detail                          |
|------------------|---------------------------------|
| Cloud Provider   | Microsoft Azure (Student)       |
| VM Name          | ict171Sayeed                    |
| Public IP        | 20.70.130.74                    |
| Internal IP      | 10.0.0.4                        |
| Operating System | Ubuntu 24.04.4 LTS              |
| Web Server       | Apache2                         |
| SSL Certificate  | Let's Encrypt (Certbot)         |
| Domain           | projectofict171.com             |

---

## How to Replicate This Server

### 1. Create Azure VM

- Log into https://portal.azure.com
- Create Ubuntu 24.04 LTS VM, region: Australia East
- Download SSH key as `ict171azurekey.pem`
- Add inbound port rules: 22, 80, 443

### 2. Connect via SSH
ssh azureuser@20.70.130.74 -i .\ict171azurekey.pem
```

### 3. Update System
sudo apt update
sudo apt upgrade -y
```

### 4. Install Apache2
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
### 5. Configure Firewall 
sudo ufw allow OpenSSH
sudo ufw allow "Apache Full"
sudo ufw enable
```

### 6. Stop nginx if Running (port conflict fix)

sudo systemctl stop nginx
sudo systemctl disable nginx
sudo systemctl start apache2
### 7. Deploy Website Files

sudo nano /var/www/html/index.html
sudo nano /var/www/html/style.css
sudo chown www-data:www-data /var/www/html/index.html /var/www/html/style.css
sudo chmod 644 /var/www/html/index.html /var/www/html/style.css
### 8. Configure Apache VirtualHost
sudo nano /etc/apache2/sites-available/projectofict171.com.conf
apache
<VirtualHost *:80>
    ServerAdmin admin@projectofict171.com
    ServerName projectofict171.com
    ServerAlias www.projectofict171.com
    DocumentRoot /var/www/html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
sudo a2ensite projectofict171.com.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2
### 9. Set DNS A Records at Registrar

| Type | Host | Value         |
|------|------|---------------|
| A    | @    | 20.70.130.74  |
| A    | www  | 20.70.130.74  |

### 10. Enable HTTPS

sudo apt install certbot python3-certbot-apache -y
sudo certbot --apache -d projectofict171.com -d www.projectofict171.com

### 11. Run Health Check Script
chmod +x healthcheck.sh
sudo bash healthcheck.sh

## Repository Structure

ICT171-Cloud-Server-Project/
├── README.md ← This file
├── index.html ← Main website page
├── style.css ← Website stylesheet
├── healthcheck.sh ← Bash server health check script
└── docs/
└── report.pdf ← Assignment submission document

## Script — healthcheck.sh

This Bash script checks whether Apache2 is running and whether the website
returns a successful HTTP 200 response. It logs each result with a timestamp
to `/var/log/healthcheck.log` and also prints to the terminal.

Output can be independently verified by visiting https://projectofict171.com
and confirming the page loads with a valid HTTPS padlock.

---

## References

[1] Microsoft, "Use SSH keys to connect to Linux VMs," Microsoft Learn, 2024.
    https://learn.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows

[2] Canonical Ltd., "Install and Configure Apache," Ubuntu Tutorials, 2024.
    https://ubuntu.com/tutorials/install-and-configure-apache

[3] DigitalOcean, "How To Set Up Apache Virtual Hosts on Ubuntu," 2022.
    https://www.digitalocean.com/community/tutorials/how-to-set-up-apache-virtual-hosts-on-ubuntu-20-04

[4] Electronic Frontier Foundation, "Certbot: Apache on Ubuntu," 2024.
    https://certbot.eff.org/

[5] Murdoch University Library, "Referencing," 2024.
    http://library.murdoch.edu.au/Students/Referencing/
