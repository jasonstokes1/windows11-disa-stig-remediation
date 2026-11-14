# Exceptions and Manual-Review Items

Final audit: Scan 16, November 14, 2026, 15:20 UTC. Tenable compliance audit "DISA Microsoft Windows 11 STIG V2R11". Of 257 rules, 233 passed, **13 failed** and **11 need manual review**.

This document explains every rule that did not pass automatically. The standard I held myself to: **a rule is only marked fixed when the control really exists.** I did not write registry values to satisfy a check when the feature behind it was absent.

---

## Part 1: The 13 Remaining Failures

### Specific to Department of Defense networks (5)

| Rule | CAT | Requirement | Why it fails here | Production fix |
|---|---|---|---|---|
| WN11-PK-000005 | II | DoD Root CA certificates installed | The audit found 0 DoD root certificates. This VM is not on a DoD network and has no reason to trust DoD certificate authorities. | Install the DoD certificates with DISA's InstallRoot tool or Group Policy |
| WN11-PK-000010 | II | External Root CA certificates installed | Same as above | Same as above |
| WN11-PK-000015 | II | DoD Interoperability cross-certificates in the Untrusted store | Same as above | Same as above |
| WN11-PK-000020 | II | CCEB Interoperability cross-certificates in the Untrusted store | Same as above | Same as above |
| WN11-00-000260 | III | Time synchronized with an authorized DoD time source | The Windows Time service uses a local NTP setting. The rule expects the domain time hierarchy or a DoD time server. | Join the domain, or point the time service at the organization's authorized source |

### Needs a domain or device-management service (3)

| Rule | CAT | Requirement | Why it fails here | Production fix |
|---|---|---|---|---|
| WN11-CC-000063 | II | STIG settings enforced by Group Policy or an approved MDM product | The VM is standalone: no domain Group Policy applies and no device-management service is installed. Settings were applied by script. | Join a domain and deploy the settings by Group Policy, or enroll in Intune |
| WN11-SO-000280 | II | Local administrator passwords changed at least every 180 days | The password age itself is within the limit. The audit also requires a Windows LAPS policy (password age, length, complexity), and none is configured. | Deploy Windows LAPS through Active Directory or Entra ID |
| WN11-SO-000245 | II | Admin Approval Mode for the built-in Administrator | The only administrator on this lab VM is the built-in account (renamed). Enabling this setting filters that account's remote administrative token, which would break the authenticated Tenable scans the whole project depends on. | Create separate named administrator accounts, disable the built-in account, then enable the setting |

### Not possible on a cloud virtual machine (3)

| Rule | CAT | Requirement | Why it fails here | Production fix |
|---|---|---|---|---|
| WN11-00-000031 | I | BitLocker PIN for pre-boot authentication | A pre-boot PIN must be typed before Windows starts. This VM is reached only through Azure Bastion after Windows is running, so there is no way to enter it. | On physical workstations: BitLocker with TPM and PIN |
| WN11-00-000032 | II | BitLocker PIN of at least six digits | Depends on the rule above | Same as above |
| WN11-00-000210 | II | Bluetooth turned off unless approved | The VM has no Bluetooth radio: no Bluetooth devices exist and the Bluetooth service is stopped (screenshot 80). The audit expects an Intune policy value. I did not create fake device-management registry values to satisfy it. | Intune policy "Allow Bluetooth" set to disallow |

Compensating control for the BitLocker rules: Azure encrypts managed disks at rest by default on the storage platform, using platform-managed keys. This protects the stored disk, but it is not the same control as BitLocker with a pre-boot PIN, which protects a physical device from someone who has it in hand.

### Requires a Windows Enterprise license (1)

**WN11-CC-000075 (CAT I): Credential Guard must be running.**

- **Finding.** The image is Windows 11 Pro. Microsoft licenses Credential Guard for Windows Enterprise and Education only.
- **What I tested.** I enabled Credential Guard without the firmware lock and restarted. Boot events reported it starting, but the interface the audit reads listed only memory integrity as running, not Credential Guard (screenshots 72 to 76).
- **Why I stopped.** The rule requires the firmware-locked setting, which cannot be removed from Windows afterwards. It would still have failed the "running" half of the check. An irreversible change with no benefit is not a fix.
- **Action.** Rolled back and confirmed the original state (screenshots 77 and 78).
- **Compensating controls in place.** The credential process (LSASS) runs as a protected process. WDigest plain-text credential caching is disabled. Virtualization-based security and memory integrity are running.
- **Production fix.** Windows 11 Enterprise license, then enable Credential Guard with the lock.

### Conflicts with a lab rule (1)

**WN11-00-000135 (CAT II): A host-based firewall must be enabled.**

- **Finding.** Windows Firewall is off on all three profiles (screenshot 02).
- **Reason.** The training range requires the firewall to be off so its scan engine can reach lab VMs.
- **Compensating control.** The VM has no public IP address. It is reachable only from the range's private networks and through Azure Bastion.
- **Production fix.** Enable the firewall and add an inbound rule for the scan engine's address only.

---

## Part 2: The 11 Manual-Review Items

Tenable marks these as Warning (10) or Error (1) because a scanner cannot decide them. Each needs a person to look. None of them is counted as passed in the project's compliance percentage.

### Compliant by inspection (6)

| Rule | CAT | Requirement | What I checked | Evidence |
|---|---|---|---|---|
| WN11-00-000065 | III | Unused accounts disabled after 35 days | The only enabled account is the administrator, used the same day. Guest and the other built-in accounts are disabled. (Tenable returned an error because it had no logon timestamps to evaluate.) | 81 |
| WN11-00-000070 | I | Only administrators in the Administrators group | The group has one member: the built-in administrator account. | 82 |
| WN11-00-000060 | II | Non-system file shares restricted | Only the default administrative shares exist (ADMIN$, C$, IPC$). | 83 |
| WN11-00-000055 | II | No alternate operating systems | Boot entries: Windows 11 and the Windows Recovery Environment, which is part of Windows. | 84 |
| WN11-00-000130 | II | No software certificate installation files | A recursive search of the system drive found no .p12 or .pfx files. | Not captured |
| WN11-00-000190 | II | No orphaned SIDs in user rights | Exported user rights and translated every SID to a name. None was orphaned. | 86 |

### Not applicable (2)

| Rule | CAT | Requirement | Reason |
|---|---|---|---|
| WN11-00-000230 | II | Notify the user when a Bluetooth device connects | No Bluetooth radio (see WN11-00-000210) |
| WN11-00-000140 | II | Firewall inbound exceptions on domain workstations | Not domain-joined; firewall covered by the WN11-00-000135 exception |

### Exceptions (2)

| Rule | CAT | Requirement | Finding | Production fix |
|---|---|---|---|---|
| WN11-00-000030 | I | BitLocker on all disks | BitLocker protection is off on the system drive. Linked to the pre-boot PIN exception above. Azure platform encryption at rest applies as a compensating control. | BitLocker on physical workstations |
| WN11-00-000035 | II | Deny-all, permit-by-exception application policy | No application control policy is configured. | App Control for Business (WDAC), or AppLocker with the appropriate license, deployed centrally |

### Procedural (1)

| Rule | CAT | Requirement | Note |
|---|---|---|---|
| WN11-00-000240 | I | Administrative accounts not used for internet applications | This lab VM has a single administrator account used only for the hardening work. In production: a separate standard account for browsing and email. |

---

## Summary

| Category | Count |
|---|---|
| Failed: DoD-network specific | 5 |
| Failed: needs domain or device management | 3 |
| Failed: not possible on a cloud VM | 3 |
| Failed: license | 1 |
| Failed: lab rule | 1 |
| **Total failed** | **13** |
| Manual review: compliant by inspection | 6 |
| Manual review: not applicable | 2 |
| Manual review: exception | 2 |
| Manual review: procedural | 1 |
| **Total manual review** | **11** |

Screenshot numbers refer to files in [../screenshots/](../screenshots/).
