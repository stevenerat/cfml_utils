# ImageMetadata CFC

**Author:** Steven Erat (stevenerat@gmail.com)
**Created:** March 2011
**Last Modified:** April 2026
**Version:** 1.1

A ColdFusion Component (CFC) that extends ColdFusion's built-in image metadata functions to provide comprehensive read **and write** access to XMP, EXIF, and IPTC image metadata. ColdFusion has never included a native way to write image metadata; this utility fills that gap by wrapping Phil Harvey's [ExifTool](https://exiftool.org/) command-line utility.

---

## Features

- Read all XMP metadata tags (EXIF and IPTC) from an image file
- Read a single metadata tag by name
- **Write** one or more XMP metadata tags to an image file
- Merges results from both ExifTool and ColdFusion's native `ImageGetEXIFMetaData()` / `ImageGetIPTCMetaData()` for maximum tag coverage
- Handles XMP namespace conflicts between ExifTool and ColdFusion with a configurable resolution strategy
- Concurrency-safe: uses named exclusive locks keyed per image file path
- Cross-platform: auto-detects ExifTool path for Windows and Mac

---

## Requirements

- ColdFusion 8 or later (tested on CF 8.01, CF 9.01, and CF 2025)
- [ExifTool](https://exiftool.org/) installed on the ColdFusion server host OS

### Installing ExifTool

**Mac (Homebrew — recommended):**
```bash
brew install exiftool
```
Installs to `/opt/homebrew/bin/exiftool` on Apple Silicon, or `/usr/local/bin/exiftool` on Intel.

**Windows:**
1. Download `exiftool(-k).exe` from [https://exiftool.org/](https://exiftool.org/)
2. Rename it to `exiftool.exe`
3. Place it in `C:\Windows\` (or any directory on your system PATH)

**Mac/Linux (manual):**
Place the `exiftool` executable on your PATH, e.g. `/usr/local/bin/exiftool`.

---

## Installation

1. Copy the contents of `src/` into your ColdFusion webroot, preserving the full package path:
   ```
   {webroot}/com/stevenerat/util/ImageMetadata.cfc
   ```

2. Optionally copy the contents of `demo/` to a directory in your webroot to run the included demo.

---

## Usage

### Initialize the CFC

The `init()` method auto-detects the ExifTool path for the current platform:
```cfml
<cfset imgMetadata = createObject("component", "com.stevenerat.util.ImageMetadata").init()>
```

Or specify the ExifTool path explicitly:
```cfml
<cfset imgMetadata = createObject("component", "com.stevenerat.util.ImageMetadata").init("/opt/homebrew/bin/exiftool")>
```

### Read All Metadata Tags

Returns a struct containing all XMP, EXIF, and IPTC metadata tags found in the image:
```cfml
<cfset metadata = imgMetadata.getImageMetadata("/path/to/image.jpg")>
<cfdump var="#metadata#">
```

### Read a Single Tag

Returns the string value of a single named tag. Tag name is case-insensitive:
```cfml
<cfset headline = imgMetadata.getImageMetadataTag("/path/to/image.jpg", "headline")>
```

### Write Metadata Tags

Pass a struct of one or more tag name/value pairs to write to the image:
```cfml
<cfset tags = {}>
<cfset tags["headline"] = "A New Headline">
<cfset tags["description"] = "A new description">
<cfset imgMetadata.setImageMetadata(imageFilePath="/path/to/image.jpg", tags=tags)>
```

---

## API Reference

See `Component_ImageMetadata_doc.html` in the `ImageMetadata/` directory for the full auto-generated API documentation.

### Public Methods

| Method | Returns | Description |
|---|---|---|
| `init([exifToolPath])` | `ImageMetadata` | Initialize the CFC. Auto-detects ExifTool path if not provided. |
| `setExifTool([exifToolPath])` | `void` | Set or change the ExifTool path after initialization. |
| `getImageMetadata(imageFilePath, [exifToolWinsConflict])` | `struct` | Returns all XMP/EXIF/IPTC metadata tags as a struct. |
| `getImageMetadataTag(imageFilePath, tag, [exifToolWinsConflict])` | `string` | Returns the value of a single named metadata tag. |
| `setImageMetadata(imageFilePath, tags)` | `void` | Writes one or more XMP metadata tag values to the image file. |

### The `exifToolWinsConflict` Parameter

Some tag names (e.g. `headline`) exist in multiple XMP namespaces. ColdFusion's built-in functions may resolve a tag to a different namespace — and therefore a different value — than ExifTool does. The `exifToolWinsConflict` boolean parameter (default `true`) controls which value wins when both sources return different values for the same tag name.

- `true` (default) — ExifTool's value is kept. Use this when writing metadata with `setImageMetadata`, as ExifTool is the write engine.
- `false` — ColdFusion's value is kept.

---

## Known Quirks

### Keywords vs. Subject

Setting `-xmp:keyword` writes to `//pdf:Keywords`, which is not surfaced by either ExifTool or ColdFusion under that name. To set what Photoshop and most tools display as IPTC "Keywords" (stored as `//dc:subject/rdf:Bag/rdf:li` in raw XMP), use the tag name **`subject`** instead:

```cfml
<cfset tags["subject"] = "nature, landscape, mountains">
```

### Headline Namespace Conflict

`headline` is a known tag with a namespace conflict between ExifTool and ColdFusion. After writing `headline` with `setImageMetadata`, use `exifToolWinsConflict=true` (the default) when reading it back to get the value ExifTool wrote.

---

## Compatibility

| Environment | Status |
|---|---|
| ColdFusion 8.01 / 9.01, Windows 7, Mac OS X | Originally tested and confirmed working |
| ColdFusion 2025, macOS (Apple Silicon), ExifTool 12.x via Homebrew | Confirmed working |

---

## Repository Structure

```
ImageMetadata/
  README.md                         This file
  Component_ImageMetadata_doc.html  Auto-generated API documentation
  src/
    com/stevenerat/util/
      ImageMetadata.cfc             The CFC component (deploy preserving this package path)
  demo/
    demo_test_ImageMetadata.cfm     Demo: reads and dumps all metadata; includes commented-out read/write test block
    demo_test_image.jpg             Sample image with embedded metadata for testing
    demo_compare_metadata_output.htm  Pre-captured demo output for reference
```

---

## License

This project is licensed under the MIT License. See the [LICENSE](../LICENSE) file for details.

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied. The author makes no guarantees regarding correctness, fitness for a particular purpose, or data integrity. Use at your own risk. The author accepts no responsibility or liability for any loss, damage, or unintended consequences arising from the use of this software. This includes but is not limited to: corrupted images, missing metadata, your girlfriend leaving you, or your dog eating your hard drive.
