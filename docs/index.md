---
title: cfml_utils
---

# cfml_utils

A collection of standalone ColdFusion utilities written during years of
technical support engineering at Adobe ColdFusion. Each utility solves a
specific, real-world problem — many were originally accompanied by blog posts
at [talkingtree.com](https://www.talkingtree.com/blog/).

These tools were written against **Adobe ColdFusion** and are not intended
for Lucee, Railo, or other CFML runtimes.

## Utilities

| Utility | Description |
|---|---|
| [ImageMetadata CFC](ImageMetadata/) | Read and write XMP, EXIF, and IPTC image metadata via ExifTool — extending ColdFusion's native-but-limited metadata functions |
| [CFAdmin Datasource Password Cracking Utility](DataSource_Crack/) | Recover lost ColdFusion 5 datasource passwords from the Windows registry by brute-force encoding every printable character through CF's own encoder and matching against stored values |

## Source

[github.com/stevenerat/cfml_utils](https://github.com/stevenerat/cfml_utils)