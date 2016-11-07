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
    "location": "api.html#EarthOrientation.getdx-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdx",
    "category": "Method",
    "text": "getdx(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the celestial pole x-coordinate correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdx_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdx_err",
    "category": "Method",
    "text": "getdx_err(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the error in celestial pole x-coordinate correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdy-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdy",
    "category": "Method",
    "text": "getdy(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the celestial pole y-coordinate correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdy_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdy_err",
    "category": "Method",
    "text": "getdy_err(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the error in celestial pole y-coordinate correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdψ-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdψ",
    "category": "Method",
    "text": "getdψ(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the ecliptic nutation correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdψ_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdψ_err",
    "category": "Method",
    "text": "getdψ_err(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the error in the ecliptic nutation correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdϵ-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdϵ",
    "category": "Method",
    "text": "getdϵ(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the ecliptic obliquity correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdϵ_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdϵ_err",
    "category": "Method",
    "text": "getdϵ_err(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the error in the ecliptic obliquity correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getlod-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getlod",
    "category": "Method",
    "text": "getlod(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the excess length of day for a certain date in milliseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getlod_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getlod_err",
    "category": "Method",
    "text": "getlod_err(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the error in the excess length of day for a certain date in milliseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getxp-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getxp",
    "category": "Method",
    "text": "getxp(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the x-coordinate of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getxp_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getxp_err",
    "category": "Method",
    "text": "getxp_err(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the error for the x-coordinate of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getyp-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getyp",
    "category": "Method",
    "text": "getyp(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the y-coordinate of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getyp_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getyp_err",
    "category": "Method",
    "text": "getyp_err(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the error for the y-coordinate of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getΔUT1-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getΔUT1",
    "category": "Method",
    "text": "getΔUT1(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the difference between UTC and UT1 for a certain date in seconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getΔUT1_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getΔUT1_err",
    "category": "Method",
    "text": "getΔUT1_err(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the error in the difference between UTC and UT1 for a certain date in seconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.polarmotion-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.polarmotion",
    "category": "Method",
    "text": "polarmotion(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the coordinates of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.precession_nutation00-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.precession_nutation00",
    "category": "Method",
    "text": "precession_nutation00(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the celestial pole coordinate corrections for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.precession_nutation80-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.precession_nutation80",
    "category": "Method",
    "text": "precession_nutation80(eop::EOParameters, date; extrapolate=true, warnings=true)\n\nGet the ecliptic corrections for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
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
