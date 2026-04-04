<!---
@Demo:  	This file demonstrates usage of the ImageMetadata.cfc utility by Steven Erat, stevenerat@gmail.com
@Requires: 	Install ExifTool on the ColdFusion server host OS. See https://exiftool.org/ for details and documentation.
			Windows: rename exiftool(-k).exe to exiftool.exe and place in C:\Windows\ (or any directory on your PATH).
			Mac (Homebrew): brew install exiftool  — installs to /opt/homebrew/bin/exiftool (Apple Silicon) or /usr/local/bin/exiftool (Intel).
@license:		MIT — see LICENSE file for details.
@disclaimer:	This software is provided "as is", without warranty of any kind, express or implied. The author makes no guarantees regarding correctness, fitness for a particular purpose, or data integrity. Use at your own risk. The author accepts no responsibility or liability for any loss, damage, or unintended consequences arising from the use of this software. This includes but is not limited to: corrupted images, missing metadata, your girlfriend leaving you, or your dog eating your hard drive.
--->
<style>
	.mainText {font-family:Helvetica; color: blue;}
	.values {font-family: Courier; color: red;}
</style>

<!--- init ImageMetadata.cfc using the default ExifTool path for the current platform:
      Windows: C:\Windows\exiftool.exe  |  Mac (Apple Silicon/Homebrew): /opt/homebrew/bin/exiftool --->
<cfset imageMetaDataUtil = createObject("component","com.stevenerat.util.ImageMetadata").init()>

<!--- Or you can optionally init the ImageMetadata.cfc by specifying the exact path to ExifTool on your system --->
<!---<cfset imageMetaDataUtil = createObject("component","com.stevenerat.util.ImageMetadata").init("C:\Windows\exiftool.exe")>---> <!--- Windows --->
<!---<cfset imageMetaDataUtil = createObject("component","com.stevenerat.util.ImageMetadata").init("/opt/homebrew/bin/exiftool")>---> <!--- Mac Apple Silicon (Homebrew) --->
<!---<cfset imageMetaDataUtil = createObject("component","com.stevenerat.util.ImageMetadata").init("/usr/local/bin/exiftool")>---> <!--- Mac Intel (Homebrew) or Linux --->

<cfset imageFilePath = getDirectoryFromPath(ExpandPath("*.*")) & "demo_test_image.jpg">


<!--- TEST 1: Read and write single metadata fields --->
<!--- Uncomment the following block to test reading and writing individual metadata fields for the test image --->
<!--- 
<div class="mainText">
	<!--- Get a single metadata xmp tag, "headline" --->
	<cfset getTag_Headline = imageMetaDataUtil.getImageMetadataTag("#imageFilePath#","headline",true)>
	<cfoutput>ImageMetadata IPTC tag 'headline' - Before: <span class="values">#getTag_Headline#</span> <br/><br/></cfoutput>
	
	<!--- Change the value of "headline" --->
	<cfset tags = {}> 
	<cfset tags['headline'] = "A NEW HEADLINE (#now()#)">
	<cfset imageMetaDataUtil.setImageMetadata(imageFilePath="#imageFilePath#",tags=tags)>
	Setting image IPTC tag 'headline' to value: <cfoutput><span class="values">#tags['headline']#</span></cfoutput><br/><br/>
	
	<!--- Get the new value for single metadata xmp tag, "headline" --->
	<cfset getTag_Headline = imageMetaDataUtil.getImageMetadataTag("#imageFilePath#","headline",true)>
	<cfoutput>ImageMetadata IPTC tag 'headline' - After: <span class="values">#getTag_Headline#</span> <br/><br/></cfoutput>
	
	<!--- Now use ONLY the ColdFusion built-in functions for a comparison--->
	<cfset imgObj = imageNew(imageFilePath)>
	<cfoutput>ColdFusion's IPTC tag 'headline': <span class="values">#imageGetIPTCTag(imgObj,'headline')#</span> <br/><br/></cfoutput>
	
	<!--- Demonstrate how to let ColdFusion functions win tag namespace conflicts when ExifTool sees a different tag namespace --->
	<!--- A given tag can exist in different locations in the image metadata, but in different namespaces.  CF may see one namespace when ExifTool sees another --->
	<cfset getTag_Headline = imageMetaDataUtil.getImageMetadataTag(imageFilePath="#imageFilePath#",tag="headline",exifToolWinsConflict=false)>
	<cfoutput>ImageMetadata IPTC tag 'headline' - CF Wins Conflict: <span class="values">#getTag_Headline#</span> <br/><br/></cfoutput>
</div>
--->

<!--- TEST 2: Read and dump all metadata tags from test image --->
<!--- Get all metadata tags for EXIF and IPTC information, combining result of ExifTool with CF's built-in functions --->
<!--- If using setImageMetadata, then it is best to let ExifTool win on tag namespace conflicts when reading metadata with getImageMetadata/getImageMetadataTag  --->
<!--- Only some tags have namespace conflicts like this --->
<cfset getresultAll = imageMetaDataUtil.getImageMetadata(imageFilePath=imageFilePath,exifToolWinsConflict=true)>
<cfdump var="#getresultAll#" label="Combined Image Metadata"><br/><br/>
