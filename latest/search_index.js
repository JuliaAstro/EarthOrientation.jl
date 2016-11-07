var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#EarthOrientation.jl-1",
    "page": "Home",
    "title": "EarthOrientation.jl",
    "category": "section",
    "text": "Acquire and interpolate IERS Earth orientation parameters in Julia."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "The package can be installed through Julia's package manager:Pkg.clone(\"https://github.com/helgee/EarthOrientation.jl.git\")\n# As soon as the package has been published in METADATA.jl use:\n# Pkg.add(\"EarthOrientation\")"
},

{
    "location": "index.html#Get-Started-1",
    "page": "Home",
    "title": "Get Started",
    "category": "section",
    "text": "Please follow the Tutorial or refer to the API documentation."
},

{
    "location": "index.html#Contribute-1",
    "page": "Home",
    "title": "Contribute",
    "category": "section",
    "text": "Report issues on the project's issue tracker or fork the project and open a pull request."
},

{
    "location": "tutorial.html#",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "page",
    "text": ""
},

{
    "location": "tutorial.html#Tutorial-1",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "section",
    "text": "Fetch the latest IERS tables:using EarthOrientation\nEarthOrientation.update()Parse the data files into an EOParameters object:eop = EOParameters()By default the files downloaded by EarthOrientation.update() will be used. It is also possible to pass different finals.all and finals2000A.all files in CSV format.eop = EOParameters(\"finals.csv\", \"finals2000A.csv\")Get the current Earth orientation parameters, e.g. for polar motion:xp, yp = polarmotion(eop, now()) # arcsecondsOr the current difference between UT1 and UTC and the associated prediction error:ΔUT1 = getΔUT1(eop, now()) # seconds\nΔUT1_err = getΔUT1_err(eop, now()) # milliseconds"
},

{
    "location": "api.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#EarthOrientation.EOParameters",
    "page": "API",
    "title": "EarthOrientation.EOParameters",
    "category": "Type",
    "text": "Contains Earth orientation parameters since 1973-01-01 until \n\n\n\n"
},

{
    "location": "api.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "Modules = [EarthOrientation]\nPrivate = false"
},

{
    "location": "internals.html#",
    "page": "Internals",
    "title": "Internals",
    "category": "page",
    "text": ""
},

{
    "location": "internals.html#EarthOrientation.getdate-Tuple{Any}",
    "page": "Internals",
    "title": "EarthOrientation.getdate",
    "category": "Method",
    "text": "getdate(data)\n\nDetermine the creation date of an IERS table by finding the last entry which is marked as \"final\".\n\n\n\n"
},

{
    "location": "internals.html#EarthOrientation.isold-Tuple{Any}",
    "page": "Internals",
    "title": "EarthOrientation.isold",
    "category": "Method",
    "text": "isold(file)\n\nCheck whether new EOP data should be available, i.e. if the CSV file is older than a week.\n\n\n\n"
},

{
    "location": "internals.html#EarthOrientation.update-Tuple{}",
    "page": "Internals",
    "title": "EarthOrientation.update",
    "category": "Method",
    "text": "update()\n\nDownload weekly EOP data from the IERS servers if newer files are available or no data has been downloaded previously.\n\n\n\n"
},

{
    "location": "internals.html#Internals-1",
    "page": "Internals",
    "title": "Internals",
    "category": "section",
    "text": "Modules = [EarthOrientation]\nPublic = false"
},

]}
