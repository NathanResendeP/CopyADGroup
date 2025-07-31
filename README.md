# CopyADGroups

Tool with a graphical interface developed in PowerShell to copy Active Directory groups from a source user to a destination user, with logging and support for creating a shortcut with silent execution (no console).

---

## 🖼️ Overview

The purpose of **CopyADGroups** is to facilitate the administration of AD groups, allowing groups to be replicated from one user to another with just a few clicks. It is ideal for IT teams carrying out onboarding processes, role changes or temporary user replacements.

---

## 📁 Project Structure
You need to creat the following structure:
```
CopyADGroups/
├── logo/
│ └── (Image used in the interface and the icon (.ico) for the shortcut)
├── logs/
│ └── (Logs files  are generated automatically when running the application)
├── script/
│ └── CopyADGroup.ps1 # Main application script
├── utils/
│ └── CopyGroupShortcut.ps1 # Script to create silent tool shortcut on the desktop
```
---

## 🛠 Features

- Graphical interface (GUI) developed with WinForms
- Validating users in Active Directory
- Automated copying of all the source user's groups
- Confirmation before adding groups
- Complete logging: who did it, when and what was done
- Shortcut execution support (without displaying the PowerShell console)

---

## ⚙ Requirements

- Windows with PowerShell 5.1 or higher
- Active Directory module enabled (`RSAT-AD-PowerShell`)
- Read and modify permissions in AD groups

---

## 🚀 How to use
Download the application files, place it in the desired path (e.g. C:) where you created the structure as above and then run Powershell:

```powershell
cd c:\CopyADGroups\utils
./CopyGroupShortcut.ps1
```
This script creates a shortcut on the desktop so that the tool can be run directly from the graphical interface, without opening the PowerShell console.

After running this script, the application can be used normally every time via the shortcut created on the desktop, without the need for a console.

---

## 🧾 Logs

Os logs de uso são gerados automaticamente em:
  CopyADGroups/logs/log_CopyADGroup.txt

---

##🧑‍💻 Autor

Desenvolvido por Nathan Resende da Silva Pinto
🔗 https://github.com/NathanResendeP

---

##📝 License

This project is licensed under the MIT License.
You can use it, modify it and distribute it freely, as long as you preserve the author's credits.

---
