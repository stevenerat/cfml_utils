---
title: ImageMetadata CFC
---

# ImageMetadata CFC

A ColdFusion Component (CFC) that extends ColdFusion's built-in image metadata
functions to provide comprehensive read **and write** access to XMP, EXIF, and
IPTC image metadata.

ColdFusion 8 introduced `imageGetIPTCMetadata()` and `imageGetExifMetadata()`,
both built on Drew Noakes' metadata-extractor library. These functions return
only a subset of available metadata and provide no way to write it back.
`ImageMetadata.cfc` fills both gaps by wrapping Phil Harvey's
[ExifTool](https://exiftool.org/) command-line utility.

## What It Does

- Reads all XMP, EXIF, and IPTC metadata tags from an image file
- Reads a single tag by name
- **Writes** one or more XMP tags to an image file — something ColdFusion has
  never supported natively
- Merges results from ExifTool and ColdFusion's native functions for maximum
  tag coverage
- Handles namespace conflicts between ExifTool and ColdFusion with a
  configurable resolution strategy
- Concurrency-safe (named exclusive locks keyed per image file path)
- Cross-platform: auto-detects ExifTool path for Windows and Mac

## Requirements

- Adobe ColdFusion 8 or later. Last tested on Adobe ColdFusion 2025 (mac OS)
- [ExifTool](https://exiftool.org/) installed on the ColdFusion server host OS

## History

Originally developed in March 2011 and published on
[talkingtree.com](https://www.talkingtree.com/blog/). Hosted on RIAForge where
it received 665 downloads and 11,348 views. Updated in 2026 and confirmed
working on ColdFusion 2025 with ExifTool 12.x.

## Source & Documentation

- [Repository](https://github.com/stevenerat/cfml_utils/tree/main/ImageMetadata)
- [README — installation, usage, and API reference](https://github.com/stevenerat/cfml_utils/blob/main/ImageMetadata/README.md)