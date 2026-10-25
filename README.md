# Enterprise Network & IP Reachability Monitoring Toolkit 🌐📡

[![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-5391FE?style=flat&logo=powershell&logoColor=white)](https://microsoft.com/powershell)
[![Platform](https://img.shields.io/badge/Platform-Azure_VNet_%7C_Hybrid_Cloud-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![SLA](https://img.shields.io/badge/Network_Health-Real--Time_Probing-success)](https://github.com/Deenanath486/IP_Monitoring)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Production-grade **PowerShell Network Monitoring & Audit Toolkit** engineered for enterprise network health verification, CIDR subnet sweep discovery, TCP port reachability auditing, and VNet peering / ExpressRoute latency tracking.

---

## 🏗️ Architecture & Monitoring Capabilities

```text
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                      ENTERPRISE NETWORK PROBING ARCHITECTURE                           │
 └────────────────────────────────────────────────────────────────────────────────────────┘
          │
          ├──► 1. Subnet Health Sweep (Test-SubnetReachability.ps1)
          │    └── Pings CIDR blocks (/24), resolves DNS hostnames, exports CSV audit
          │
          ├──► 2. TCP Port & NSG Boundary Audit (Test-AzurePortConnectivity.ps1)
          │    └── Validates firewall rules for SSH (22), HTTPS (443), DB (5432), K8s (6443)
          │
          ├──► 3. VNet & Hybrid Peering Latency Probe (Monitor-VNetLatency.ps1)
          │    └── Measures round-trip time (RTT), jitter, and packet loss % across links
          │
          └──► 4. Automated Incident Alerting (Send-WebhookAlert.ps1)
               └── Posts rich diagnostic alert cards to Microsoft Teams & Slack channels
```

---

## 📁 Repository Structure

```text
.
├── scripts/
│   ├── Test-SubnetReachability.ps1     # Multi-threaded CIDR ping sweep with CSV reporting
│   ├── Test-AzurePortConnectivity.ps1   # TCP socket probing for firewall/NSG auditing
│   ├── Monitor-VNetLatency.ps1         # Real-time VNet peering & ExpressRoute SLA probe
│   └── Send-WebhookAlert.ps1           # Reusable Microsoft Teams & Slack incident webhook
├── .gitignore
└── README.md
```

---

## 🚀 Execution & Usage Guide

### 1. Scan Entire Subnet Range (/24)
Scans active hosts, records latency, and exports findings to a CSV spreadsheet:
```powershell
.\scripts\Test-SubnetReachability.ps1 -SubnetBase "10.10.1" -StartIP 1 -EndIP 254 -ExportCsv ".\vnet-dev-audit.csv"
```

### 2. Audit Security Group & Port Access (NSG Testing)
Tests whether critical ports are open or filtered by Network Security Groups:
```powershell
# Audit Linux Bastion / PostgreSQL VM:
.\scripts\Test-AzurePortConnectivity.ps1 -TargetHost "10.10.1.4" -Ports 22, 80, 443, 5432
```

### 3. Continuous VNet Peering Latency Probe
Monitors round-trip packet latency and packet loss across hybrid or peered Azure VNets:
```powershell
.\scripts\Monitor-VNetLatency.ps1 -TargetIP "10.20.1.10" -Count 20 -ThresholdLatencyMs 40
```

### 4. Dispatch Automated Alert to Microsoft Teams
```powershell
.\scripts\Send-WebhookAlert.ps1 `
  -WebhookUrl "https://outlook.office.com/webhook/..." `
  -Title "High Latency Warning on Hub-Spoke Peering" `
  -Message "VNet peering latency exceeded SLA threshold (avg 82ms > 50ms target)." `
  -Severity "Critical"
```

---

## 👨‍💻 Author

**Deenanath Yadav**  
*DevOps & Azure Cloud Engineer*  
- **LinkedIn**: [linkedin.com/in/deenanath-yadav-495110146](https://www.linkedin.com/in/deenanath-yadav-495110146)  
- **Email**: [deenanathyadav106@gmail.com](mailto:deenanathyadav106@gmail.com)
