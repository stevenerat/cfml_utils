<!--- 
Author: Steven Erat
Contact: serat@macromedia.com
Creation Date: June 12, 2002
Purpose: Retrieve usernames and passwords for Coldfusion Datasources
Coldfusion Versions:  Works on Coldfusion 5 and lower
 --->
<cfsetting showdebugoutput="No">
<cfapplication name="CFAdminDatasourcePasswordCrackingUtility" sessionmanagement="Yes" sessiontimeout="#CreateTimeSpan(0,0,5,0)#">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>CFAdmin Datasource Password Cracking Utility</title>
</head>
<body>
<STYLE>
	body {font-family: tahoma,arial,geneva,sans-serif;font-size:10pt;color:navy}
	th {font-family: tahoma,arial,geneva,sans-serif;font-size:12pt;color:white}
	td {font-family: tahoma,arial,geneva,sans-serif;font-size:10pt;color:navy}
	.warn {font-family: tahoma,arial,geneva,sans-serif;font-size:8pt;color:red}
</STYLE>
<h2>CFAdmin Datasource Password Cracking Utility</h2>
<HR>
<CFPARAM name="form.action" default="">
<CFSWITCH expression="#form.action#">
	<CFCASE value="init">
		<CFSILENT>
			<CFSET TestDSN = "MMPasswdTempCracker">
			<CFTRY>
				<CFREGISTRY ACTION="SET" BRANCH="HKEY_LOCAL_MACHINE\Software\Allaire\ColdFusion\CurrentVersion\DataSources\" ENTRY="#TestDSN#" TYPE="KEY">
				<CFSET message = "Successfully initialized">
			<CFCATCH><CFSET message = "Failure"></CFCATCH>
			</CFTRY>
			<CFSET ascCharValue = 33 >
			<CFSET maxCharValue = 126 >
			<CFSET charRange = (maxCharValue - ascCharValue) + 1 >
			<CFSET aryCharEncCharPair = ArrayNew(3)>
			<CFLOOP index="i" from="1" to="#charRange#">
				<CFSET inputString = chr(ascCharValue) >
				<CFSET quantalInputString = "">
				<CFLOOP from="1" to="8" index="encryptionUnitRepeatLength">
					<CFSET quantalInputString = quantalInputString & inputString>		
				</CFLOOP>
				<CFLOOP from="1" to="2" index="maxPasswordLengthAsMultiplesOfEncryptionUnitRepeatLength">
					<CFSET quantalInputString = quantalInputString & quantalInputString>		
				</CFLOOP>
				<CFIF CF_SetDataSourcePassword( TestDSN, quantalInputString ) ></CFIF>
				<CFREGISTRY ACTION="GET" VARIABLE="outputEncString" ENTRY="Password" TYPE="STRING" BRANCH ="HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\DataSources\#TestDSN#">
				<CFSET passwordRemainder = outputEncString>
				<CFSET tmpAryEncCharUnit = "">
				<CFSET tmpAryEncCharUnit = ArrayNew(1)>
				<CFLOOP from="1" to="#Len(quantalInputString)#" index="q">
					<CFSET thisEncChar = Left(passwordRemainder,2)>
					<CFSET passwordRemainder = removeChars(passwordRemainder,1,2)>
					<CFSET aryCharEncCharPair[i][1][1] = inputString >
					<CFSET aryCharEncCharPair[i][2][q] = thisEncChar >
				</CFLOOP>
				<CFSET ascCharValue = ascCharValue + 1 >
			</CFLOOP>
			<CFTRY>
				<CFREGISTRY ACTION="DELETE" BRANCH="HKEY_LOCAL_MACHINE\Software\Allaire\ColdFusion\CurrentVersion\DataSources\" ENTRY="#TestDSN#" TYPE="KEY">
			<CFCATCH></CFCATCH>
			</CFTRY>
			<CFLOCK scope="SESSION" type="EXCLUSIVE" timeout="10">
				<CFSET  session.aryCharEncCharPair = variables.aryCharEncCharPair>
			</CFLOCK>
		</CFSILENT>
		<CFOUTPUT>
			<h3>Status:  #message#</h3>
			<FORM action="#cgi.script_name#" method="post">
				<CFIF message CONTAINS "Success"><INPUT type="Hidden" name="action" value="list"></CFIF>
				<INPUT type="Submit" value="Retrieve List of Coldfusion Datasources">
			</FORM>
		</CFOUTPUT>
	</CFCASE>
	
	<CFCASE value="list">
		<CFREGISTRY ACTION="GETALL" NAME="DatasourceName" ENTRY="Password"	TYPE="Key" BRANCH="HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\DataSources\">
		<CFOUTPUT>
			<h3>Datasource List</h3>
			<BLOCKQUOTE>
			<FORM action="#cgi.script_name#" method="post">
				<CFLOOP query="DatasourceName">
					<INPUT type="Radio" name="dsnName" value="#Entry#"> #Entry#<BR>
				</CFLOOP>
				<INPUT type="Radio" name="dsnName" value="ALL" checked> All Datasources<BR>
				<INPUT type="Hidden" name="action" value="crack"><BR><BR>
				<INPUT type="Submit" value="Crack That Password !">
			</FORM>
			</BLOCKQUOTE>
		</CFOUTPUT>
	</CFCASE>
	
	<CFCASE value="crack">	
		<h3>Status:  Working ...</h3>
		<CFOUTPUT>
			<FORM action="#cgi.script_name#" method="post">
				<INPUT type="Hidden" name="action" value="list">
				<INPUT type="Submit" value="Return To List of Coldfusion Datasources">
			</FORM>
		</CFOUTPUT>
		<CFREGISTRY ACTION="GETALL" NAME="DatasourceName" ENTRY="Password"	TYPE="Key" BRANCH="HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\DataSources\">
		<TABLE bgcolor="black" width="750">
		<TR><TH bgcolor="gray" width="250">Datasource Name</TH><TH bgcolor="gray" width="250">Username</TH><TH bgcolor="gray" width="250">Password</TH></TR>
		</TABLE>
		<CFLOOP query="DatasourceName">
			<CFIF Entry EQ "#form.dsnName#" OR  form.dsnName EQ "ALL">
				<CFLOCK scope="SESSION" type="EXCLUSIVE" timeout="10">
					<CFSET bSessionTimer = IsDefined("session.aryCharEncCharPair")>
				</CFLOCK>
				<CFIF bSessionTimer EQ 0>
					<CFLOCATION url="#cgi.script_name#?timeout=1">
				</CFIF>
				<CFLOCK scope="SESSION" type="EXCLUSIVE" timeout="10">
					<CFSET variables.aryCharEncCharPair = session.aryCharEncCharPair>
				</CFLOCK>
				<CFSILENT>
					<CFREGISTRY ACTION="GET" VARIABLE="inputEncString" ENTRY="Password" TYPE="STRING" BRANCH ="HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\DataSources\#Entry#">
					<CFREGISTRY ACTION="GET" VARIABLE="dsnUsername" ENTRY="UserID" TYPE="STRING" BRANCH ="HKEY_LOCAL_MACHINE\SOFTWARE\Allaire\ColdFusion\CurrentVersion\DataSources\#Entry#">
					<CFSET passwordRemainder = "">
					<CFSET passwordRemainder = inputEncString>
					<CFSET intEncPassLen = Len(passwordRemainder)>
					<CFSET intPassLen = (intEncPassLen / 2) >
					<CFSET aryFinalAnswer = ArrayNew(1)>
					<CFLOOP index="i" from="1" to="#arrayLen(aryCharEncCharPair)#">
						<CFLOOP from="1" to="#intPassLen#" index="position">	
							<CFSET thisEncChar = Left(passwordRemainder,2)>
							<CFIF thisEncChar EQ aryCharEncCharPair[i][2][position]>
								<CFSET aryFinalAnswer[position] = aryCharEncCharPair[i][1][1] >  
							</CFIF>
							<CFSET passwordRemainder = removeChars(passwordRemainder,1,2)>
						</CFLOOP>
						<CFSET passwordRemainder = "">
						<CFSET passwordRemainder = inputEncString>
					</CFLOOP>
					<CFSET FinalAnswer = ArrayToList(aryFinalAnswer,"")>
				</CFSILENT>			
				<CFOUTPUT>	
				<TABLE bgcolor="black" width="750">		
				<!--- <CFIF intPassLen GT 8>class="warn"<CFSET warning = 1></CFIF> --->
				<TR><TD bgcolor="white" width="250">#Entry#</TD><TD bgcolor="white"  width="250"><CFTRY><CFIF Len(dsnUsername) GT 0>#dsnUsername#<CFELSE>no username</CFIF><CFCATCH>no username</CFCATCH></CFTRY></TD><TD bgcolor="white" width="250"><CFIF Len(FinalAnswer) GT 0>#FinalAnswer#<CFELSE>no password</CFIF></TD></TR>
				</TABLE>
				</CFOUTPUT>
			</CFIF>
			<CFFLUSH>
		</CFLOOP>
		<h3>Status:  Complete</h3>
		<!--- 		
		<CFIF IsDefined("variables.warning")>
		<BR><font size="2" face="Tahoma,arial" color="red">Passwords that are entirely numerical and greater than 8 characters may not be fully accurate.</font>
		</CFIF> 
		--->
	</CFCASE>
	
	<CFDEFAULTCASE>
		<h3>Status:  Begin</h3>
		<CFOUTPUT>
			<FORM action="#cgi.script_name#" method="post">
				<INPUT type="Hidden" name="action" value="init">
				<INPUT type="Submit" value="Initialize CFAdmin Datasource Password Cracking Utility">
			</FORM>
		<CFIF IsDefined("url.timeout")><span class="warn">Your previous session expired.</span></CFIF>
		</CFOUTPUT>
	</CFDEFAULTCASE>
</CFSWITCH>

</body>
</html>
