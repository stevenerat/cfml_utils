<!--- 
@name:			ImageMetadata.cfc
@author:		Steven Erat
@created:		March 2011
@lastModified	April 2026
@version: 		1.1
@contact:		stevenerat@gmail.com
@purpose:		Get and Set image XMP metadata including EXIF and IPTC.
				Improves upon the image metadata accessors built into ColdFusion 8 & 9, and adds new image metadata mutator (sets metadata) since none exist in those versions of ColdFusion.
				Extends ImageGetIPTCMetadata() & ImageGetEXIFMetadata(), and provides access to additional XMP tags.
				Confirmed working on ColdFusion 2025 on Mac (Apple Silicon) with ExifTool installed via Homebrew.
@requires: 		Install ExifTool on the ColdFusion server, then set the exifTool path below. See https://exiftool.org/ for details and documentation.
				Windows: Download exiftool(-k).exe, rename to exiftool.exe, and place in C:\Windows\ (or any directory on your PATH).
				Mac (Homebrew): brew install exiftool  — installs to /opt/homebrew/bin/exiftool (Apple Silicon) or /usr/local/bin/exiftool (Intel).
				Mac/Linux (manual): Place exiftool on your PATH, e.g. /usr/local/bin/exiftool.
@usage:			create+init 1a) <cfset imgMetadata = createObject("component","com.stevenerat.util.ImageMetadata").init()>
				create+init 1b) <cfset imgMetadata = createObject("component","com.stevenerat.util.ImageMetadata").init("/opt/homebrew/bin/exiftool")>
				get all tags)   <cfset metadataAll = imgMetadata.getImageMetadata("#imageFilePath#")>
				get one tag)    <cfset metadataTag = imgMetadata.getImageMetadataTag("#imageFilePath#","description")>
				set tags)       <cfset tags = {}>
				   		        <cfset tags['headline'] = "A NEW HEADLINE">
				   		        <cfset tags['description'] = "A NEW DESCRIPTION">
				   		        <cfset imgMetadata.setImageMetadata(imageFilePath="#imageFilePath#",tags=tags)>
@support:		Originally tested on Windows 7 and Mac OS X with ColdFusion 8.01 and ColdFusion 9.01 using Image::ExifTool 8.48.
				Confirmed working on macOS (Apple Silicon) with ColdFusion 2025 using ExifTool 12.x installed via Homebrew.
@license:		MIT — see LICENSE file for details.
@disclaimer:	This software is provided "as is", without warranty of any kind, express or implied. The author makes no guarantees regarding correctness, fitness for a particular purpose, 
				or data integrity. Use at your own risk. The author accepts no responsibility or liability for any loss, damage, or unintended consequences arising from the use of this software. This includes but is not limited to: corrupted images, missing metadata, your girlfriend leaving you, or your dog eating your hard drive.
@notes:			The tag 'keyword' is complicated.  Using [-xmp:keyword=foo, bar, baz] will actually set //pdf:Keywords, but neither ExifTool nor ColdFusion will give you //pdf:Keywords.
				If, however, you use tag 'subject' [-xmp:subject=foo, bar, baz], then in Photoshop the IPTC 'keyword' field will show the change. In raw XMP, this corresponds to //dc:subject/rdf:Bag/rdf:li.
				So the lesson is that when you want to set the image keywords, use the tag 'subject'.
				Also, tag 'headline' exists in 2 different namespaces.  ColdFusion sees one namespace, ExifTool sees another.
				Use the exifToolWinsConflict flag to set which one wins.  See below & demo.
 --->

<cfcomponent displayname="Image Metadata Utility" output="false"
			 hint="Custom enhancement for ColdFusion's built-in EXIF and IPTC metadata functions. Wrapper for ExifTool command-line utility. Can read AND write all XMP metadata.">
	
	<cfproperty name="variables.exifTool" type="string" default="">
	
	<cffunction name="init" access="public" returntype="ImageMetadata" output="false" hint="Initialize CFC by setting path to ExifTool.">
		<cfargument name="exifToolPath" required="false" type="string" default="" hint="Optional full path to the ExifTool executable. If omitted, the default path for the current platform is used.">
		<cfset setExifTool(arguments.exifToolPath)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setExifTool" access="public" returntype="void" output="false" hint="Set the path to ExifTool. If no path is provided, auto-detects the default installation location for the current platform.">
		<cfargument name="exifToolPath" required="false" type="string" default="" hint="Optional full path to the ExifTool executable. If omitted, the default path for the current platform is used.">
		<cfif arguments.exifToolPath NEQ "">
			<cfset variables.exifTool = arguments.exifToolPath>
		<cfelseif server.os.name contains "Windows">
			<!--- Standard Windows install: rename exiftool(-k).exe to exiftool.exe and place in C:\Windows\ --->
			<cfset variables.exifTool = "C:\Windows\exiftool.exe">
		<cfelse>
			<!--- Homebrew on Apple Silicon installs to /opt/homebrew/bin/; Intel Mac and Linux typically use /usr/local/bin/ --->
			<cfset variables.exifTool = "/opt/homebrew/bin/exiftool">
		</cfif>
		<cfif NOT fileExists(variables.exifTool)>
			<cfthrow type="Custom" message="ExifTool Not Found" detail="Expected to find #variables.exifTool# but it does not exist or cannot be accessed by the server">
		</cfif>
	</cffunction>
	
	<cffunction name="getImageMetadata" access="public"
				returntype="struct" output="false"
				hint="Returns all XMP metadata for EXIF and IPTC types. Supplies a merge of metadata from the ColdFusion built-in functions and that from ExifTool.">
		<cfargument name="imageFilePath" required="true" type="string" hint="Absolute file path to the image file.">
		<cfargument name="exifToolWinsConflict" required="false" type="boolean" default="true" hint="ColdFusion may see a tag name in a different namespace having a different value than the ExifTool tag namespace. Default is ExifTool wins a conflict. Set to false for ColdFusion to win.">
		<cfset var local = {}>
		<cfset local.result = {}>
		<cfif fileExists(arguments.imageFilePath)>
		<cflock name="ImageMetadataAccessLock#hash(imageFilePath)#" type="exclusive" timeout="60" throwontimeout="true">
			<cfexecute name="#variables.exifTool#" arguments="-xmp:all #arguments.imageFilePath#" variable="local.exifToolResult" timeout="30"/> 
		</cflock>
		<!--- Optional Logging for Debugging --->
		<!---
		<cflog file="ImageMetadataUtil" text="GET-LOCK: ImageMetadataAccessLock#hash(imageFilePath)#">
		<cflog file="ImageMetadataUtil" text="GET-COMMAND: #variables.exifTool# -xmp:all #arguments.imageFilePath#">
		<cflog file="ImageMetadataUtil" text="GET-RESULT: #local.exifToolResult#">
		--->
		<cfset local.exifToolResult = listtoarray(local.exifToolResult,chr(10))>
		<cfloop from="1" to="#arraylen(local.exifToolResult)#" index="local.i">
			<cfset local.keyname = listfirst(local.exifToolResult[local.i],":")>
			<cfset local.keyvalue = replace(local.exifToolResult[local.i],"#local.keyname#:","","one")>
			<cfset local.result['#trim(local.keyname)#'] = trim(local.keyvalue)>
		</cfloop>
		<cfelse>
			<cfthrow type="Custom" message="Image Not Found" detail="The image file at #arguments.imageFilePath# does not exist or cannot be accessed by the server">
		</cfif>
		<cfset local.result = mergeExifToolWithCFFuncs(arguments.imageFilePath,local.result,arguments.exifToolWinsConflict)>
		<cfreturn local.result>
	</cffunction>
		
	<cffunction name="getImageMetadataTag" access="public"
				returntype="string" output="false"
				hint="Returns a single XMP metadata tag value for EXIF or IPTC types.">
		<cfargument name="imageFilePath" required="true" type="string" hint="Absolute file path to the image file.">
		<cfargument name="tag" required="true" type="string" hint="XMP tag name to retrieve, e.g. headline, description, subject. Case-insensitive.">
		<cfargument name="exifToolWinsConflict" required="false" type="boolean" default="true" hint="ColdFusion may see a tag name in a different namespace having a different value than the ExifTool tag namespace. Default is ExifTool wins a conflict. Set to false for ColdFusion to win.">
		<cfset var local = {}>
		<cfset local.result = {}>
		<cfset local.exifToolResult = getImageMetadata(imageFilePath=arguments.imageFilePath,exifToolWinsConflict=arguments.exifToolWinsConflict)>
		<cfset local.keyList = structKeyList(local.exifToolResult)>
		<cfif listContainsNoCase(local.keyList,arguments.tag)>
			<cfset local.keyListIndex = listFindNoCase(local.keyList,arguments.tag)>
			<!--- maintain the exact case of the xmp tag name regardless of tag case passed in --->
			<cfset local.result['#listGetAt(local.keyList,local.keyListIndex)#'] = local.exifToolResult['#arguments.tag#']>
		<cfelse>
			<cfthrow type="Custom" message="Metadata Tag Not Found" detail="The image file at #arguments.imageFilePath# does not have the metadata key #arguments.tag#">
		</cfif>
		<cfreturn local.result['#tag#']>
	</cffunction>
	
	<cffunction name="setImageMetadata" access="public" returntype="void" output="false"
				hint="Set the values for XMP metadata tags.">
		<cfargument name="imageFilePath" required="true" type="string" hint="Absolute file path to the image file to modify.">
		<cfargument name="tags" required="true" type="struct" hint="A struct containing the tag names and tag values. Struct may contain 1 or more tag name key/value pairs.">
		<cfset var local = {}>
		<cfif fileexists(arguments.imageFilePath)>
			<cfset local.args = arrayNew(1)>
			<!--- <cfset arrayAppend(local.args,"-q")> ---> <!--- quiet mode --->
			<!--- <cfset arrayAppend(local.args,"-v")> ---> <!--- verbose mode --->
			<cfset arrayAppend(local.args,"-overwrite_original")>
			<cfloop collection="#arguments.tags#" item="local.tag">
				<cfset arrayAppend(local.args,'-xmp:#local.tag#=#arguments.tags["#local.tag#"]#')>
			</cfloop>
			<cfset arrayAppend(local.args,imageFilePath)>
			<cflock name="ImageMetadataAccessLock#hash(imageFilePath)#" type="exclusive" timeout="60" throwontimeout="true">
				<cfexecute name="#variables.exifTool#" arguments="#local.args#" timeout="30" variable="local.exifToolResult"/>
			</cflock>
			<!--- Optional Logging for Debugging --->
			<!---
			<cflog file="ImageMetadataUtil" text="SET-LOCK: ImageMetadataAccessLock#hash(imageFilePath)#">
			<cflog file="ImageMetadataUtil" text="SET-COMMAND: #variables.exifTool# #arrayToList(local.args, " ")#">
			<cflog file="ImageMetadataUtil" text="SET-RESULT: #local.exifToolResult#">
			--->
		<cfelse>	
			<cfthrow type="Custom" message="Image Not Found" detail="The image file at #arguments.imageFilePath# does not exist or cannot be accessed by the server">
		</cfif>
	</cffunction>
	
	<cffunction name="mergeExifToolWithCFFuncs" access="private" output="false" returntype="Struct"
				hint="Merges ExifTool output with ColdFusion's built-in ImageGetEXIFMetaData() and ImageGetIPTCMetaData() results. The two sources do not completely overlap. When both return the same tag name from different XMP namespaces, the exifToolWinsConflict flag determines which value is kept.">
		<cfargument name="imageFilePath" required="true" type="string" hint="Absolute file path to the image file.">
		<cfargument name="exifToolResult" required="true" type="struct" hint="Struct of metadata tags already parsed from ExifTool output.">
		<cfargument name="exifToolWinsConflict" required="false" type="boolean" default="true" hint="ColdFusion may see a tag name in a different namespace having a different value than the ExifTool tag namespace. Default is ExifTool wins a conflict. Set to false for ColdFusion to win.">
		<cfset var local = {}>
		<cfset local.imgObj = ImageNew(arguments.imageFilePath)>
		<cfset local.iptc = ImageGetIPTCMetaData(local.imgObj)>
		<cfset local.exif = ImageGetEXIFMetaData(local.imgObj)>
		<cfloop collection="#local.exif#" item="local.tag">
			<cfif  (NOT structkeyexists(exifToolResult,'#local.tag#') OR exifToolResult['#local.tag#'] IS NOT "")  AND exifToolWinsConflict IS false>
				<cfset exifToolResult['#local.tag#'] = trim(local.exif['#local.tag#'])>
			</cfif>
		</cfloop>
		<cfloop collection="#local.iptc#" item="local.tag">
			<cfif (NOT structkeyexists(exifToolResult,'#local.tag#') OR exifToolResult['#local.tag#'] IS NOT "") AND exifToolWinsConflict IS false>
				<cfset exifToolResult['#local.tag#'] = trim(local.iptc['#local.tag#'])>
			</cfif>
		</cfloop>
		<cfreturn exifToolResult>
	</cffunction>
	
</cfcomponent>