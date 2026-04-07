---
title: CFAdmin Datasource Password Cracking Utility
---

# CFAdmin Datasource Password Cracking Utility

A ColdFusion utility for recovering lost datasource passwords stored by ColdFusion 5 on Windows.

**Written:** June 12, 2002  
**Compatibility:** ColdFusion 5 and earlier (Windows only)

---

## Background

This utility was written during my time in Technical Support at Allaire Corp (later acquired by Macromedia). A customer's employee had quit, taking with them the only known datasource passwords configured in ColdFusion Administrator. The passwords appeared to be lost.

Investigation revealed that ColdFusion 5 stored datasource passwords in the Windows registry under:

```
HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\DataSources\
```

The passwords were encoded, but the encoding was deterministic and position-dependent. Rather than reverse-engineering the encoding algorithm, I discovered that ColdFusion's own `CF_SetDataSourcePassword()` custom tag could be used as an encoding oracle: feed it known input, read back the encoded output from the registry, and build a complete character lookup table. Decoding any stored password then becomes a straightforward positional character lookup.

---

## How It Works

The utility is a single `.cfm` file with a four-stage workflow:

**1. Initialize** — Iterates over all printable ASCII characters (codes 33–126), encodes each through `CF_SetDataSourcePassword()` into a temporary registry key, and records the character-to-encoded-pair mapping for every password position. The resulting lookup table is stored in the CF session.

**2. List Datasources** — Uses `<CFREGISTRY ACTION="GETALL">` to enumerate all configured ColdFusion datasources and presents them for selection.

**3. Crack** — For each selected datasource, reads the encoded password from the registry, splits it into 2-character units, looks up each unit by position in the session table, and reconstructs the plaintext password.

**4. Display** — Outputs datasource name, username, and recovered plaintext password.

---

## Usage

> **Requires** ColdFusion 5 on Windows with registry access. Will not work on later CF versions or non-Windows platforms.

1. Copy `src/cfadmin_dsn_password_cracker.cfm` to a directory served by your ColdFusion 5 installation.
2. Browse to the file in a web browser.
3. Click **Initialize** to build the encoding lookup table.
4. Click **Retrieve List of ColdFusion Datasources**.
5. Select a datasource (or "All Datasources") and click **Crack That Password**.

---

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied. The author makes no guarantees regarding its fitness for any particular purpose, accuracy, or reliability. Use it at your own risk. No support is provided. The author is not responsible for any damage, data loss, or other consequences arising from its use. It is provided here for historic reference only.

Do not use this on systems you do not own or have explicit authorization to administer.

---

## Source

- [Repository](https://github.com/stevenerat/cfml_utils/tree/main/DataSource_Crack)
- [README](https://github.com/stevenerat/cfml_utils/blob/main/DataSource_Crack/README.md)
