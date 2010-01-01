<cfcomponent name="jtidy" displayname="jTidy" hint="clean out invalid html">

	<cffunction name="makexHTMLValid" displayname="Tidy parser" hint="Takes a string as an argument and returns parsed and valid xHTML" output="false">
		<cfargument name="strToParse" required="true" type="string" default="" />
		
		<cfset var returnPart = "" /> <!--- // return variable --->
		<cfset parseData = trim(arguments.strToParse) />
		
		<!--- Simply return the sting if its empty --->
		<cfif not len(parseData)>
			<cfreturn parseData />
		</cfif>
		
		<cftry>
		
			<cfscript>
			/**
			* This function reads in a string, checks and corrects any invalid HTML.
			* By Greg Stewart
			*
			* @param strToParse The string to parse (will be written to file).
			* accessible from the web browser
			* @return returnPart
			* @author Greg Stewart (gregs(at)tcias.co.uk)
			* @version 1, August 22, 2004
			
			* @version 1.1, September 09, 2004
			* with the help of Mark Woods this UDF no longer requires temp files and only accepts
			* the string to parse
			
			* @version 1.2, January 01, 2010
			* slightly modified version by Mike Henke
			* added javaloader
			*/
			
			// generic warning
			warning="jTidy is not installed on your server.";
			
			// jtidy-r938.zip from http://sourceforge.net/projects/jtidy/files/
			loadPaths = ArrayNew(1);
			loadPaths[1] = expandPath("lib/jtidy-r938.jar");
     	 	
			javaloader = createObject("component", "javaloader.JavaLoader").init(loadPaths);														
			jTidy = javaloader.create("org.w3c.tidy.Tidy").init();	
			 
			jTidy.setQuiet(false);
			jTidy.setIndentContent(true);
			jTidy.setSmartIndent(true);
			jTidy.setIndentAttributes(true);
			jTidy.setWraplen(1024);
			jTidy.setXHTML(true);
			
			// create the in and out streams for jTidy
			readBuffer = CreateObject("java","java.lang.String").init(parseData).getBytes();
			inP = createobject("java","java.io.ByteArrayInputStream").init(readBuffer);
			
			//ByteArrayOutputStream
			outx = createObject("java", "java.io.ByteArrayOutputStream").init();
			
			// do the parsing
			jTidy.parse(inP,outx);
			
			// close the stream
			// outx.close();
			outstr = outx.toString();
			</cfscript>
			
			// ok now strip all the header/body stuff
			<cfset startPos = REFind("<body>", outstr)+6 />
			<cfset endPos = REFind("</body>", outstr) />
			
			<!--- check if output from jtidy is blank --->
			<cfif outstr eq '' >
				<cfset warning = "output from jtidy empty" />
				<cfthrow />
			</cfif>
			
			<cfset returnPart = Mid(outstr, startPos, endPos-startPos) />
			
			<cfreturn returnPart />
			
			<cfcatch type="any">
				<!--- display and log error message  --->
				<cftrace type="warning" text="jtidy_cfc: #warning#" />
				<!--- displays input data so the application still works --->
				<cfreturn parseData />
			</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>