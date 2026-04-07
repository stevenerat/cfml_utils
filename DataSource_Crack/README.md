# CFAdmin Datasource Password Cracking Utility

A ColdFusion (CFML) utility for recovering lost datasource passwords stored by ColdFusion 5 on Windows.

**Author:** Steven Erat  
**Created:** June 12, 2002  
**Compatibility:** ColdFusion 5 and earlier (Windows only)

---

## Background

This utility was written during my time in Technical Support at Allaire Corp (later acquired by Macromedia). A customer's employee had quit, taking with them the only known datasource passwords configured in ColdFusion Administrator. The passwords appeared to be lost.

Investigation revealed that ColdFusion 5 stored datasource passwords in the Windows registry under:

```
HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\DataSources\
```

The passwords were encoded, but the encoding was deterministic and reversible — the same plaintext character always produced the same encoded output at a given position in the string. Rather than reverse-engineering the encoding algorithm, I discovered that ColdFusion's own `CF_SetDataSourcePassword()` custom tag could be used as an encoding oracle: feed it known input, read back the encoded output from the registry, and build a complete lookup table for all printable ASCII characters.

With that lookup table in hand, decoding any stored password becomes a straightforward character-by-character lookup.

---

## How It Works

The utility runs as a single `.cfm` file with a four-stage workflow driven by a `form.action` switch:

### Stage 1 — Initialize (Build Lookup Table)

- Iterates over all printable ASCII characters (codes 33–126)
- For each character, uses `CF_SetDataSourcePassword()` to encode a repeated string of that character through ColdFusion's own encoder, writing it to a temporary registry key (`MMPasswdTempCracker`)
- Reads back the encoded result and records the character-to-encoded-pair mapping for every password position
- Stores the resulting 3D lookup array in the CF session
- Deletes the temporary registry key when done

The encoding is **position-dependent**: the same character encodes differently depending on its position in the password. The lookup table accounts for this by storing encoded values per position.

### Stage 2 — List Datasources

- Uses `<CFREGISTRY ACTION="GETALL">` to enumerate all configured ColdFusion datasources
- Presents a form to select a specific datasource or crack all at once

### Stage 3 — Crack

- Reads the encoded password and username from the registry for each selected datasource
- Chops the encoded password string into 2-character units
- For each position, scans the lookup table for a matching encoded pair and maps it back to the plaintext character
- Reconstructs and displays the plaintext password alongside the datasource name and username

---

## Usage

> **Important:** This utility requires ColdFusion 5 on Windows with access to the Windows registry. It will not work on later versions of ColdFusion or on non-Windows platforms.

1. Copy `src/cfadmin_dsn_password_cracker.cfm` to a directory served by your ColdFusion 5 installation.
2. Browse to the file in a web browser.
3. Click **Initialize** to build the character encoding lookup table.
4. Click **Retrieve List of ColdFusion Datasources**.
5. Select a datasource (or "All Datasources") and click **Crack That Password**.

The recovered username and plaintext password are displayed for each datasource.

---

## File Structure

```
DataSource_Crack/
└── src/
    └── cfadmin_dsn_password_cracker.cfm
```

---

## Security Note

This utility was developed for legitimate system recovery by authorized personnel. The vulnerability it exploits — plaintext-equivalent encoding of passwords stored in the Windows registry — was addressed in later versions of ColdFusion. Do not use this on systems you do not own or have explicit authorization to administer.

---

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied. The author makes no guarantees regarding its fitness for any particular purpose, accuracy, or reliability. Use it at your own risk. No support is provided. The author is not responsible for any damage, data loss, or other consequences arising from its use.  It is provided here for historic reference only.

---

