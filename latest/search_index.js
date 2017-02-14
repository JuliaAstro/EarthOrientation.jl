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
    "text": "Calculate Earth orientation parameters from IERS tables in Julia."
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
    "text": "EarthOrientation.jl downloads, parses, and interpolates weekly-updated tables from the IERS that contain the following Earth Orientation Parameters (EOP):Polar motion:\nx-coordinate of Earth's north pole: x_p\ny-coordinate of Earth's north pole: y_p\nEarth rotation\nDifference between UT1 and UTC: Delta UT1\nExcess length of day: LOD\nPrecession and nutation based on the 1980 IAU conventions\nCorrection to the nutation of the ecliptic: dpsi\nCorrection to the obliquity of the ecliptic: depsilon\nPrecession and nutation based on the 2000 IAU conventions\nCorrection to the celestial pole's x-coordinate: dx\nCorrection to the celestial pole's y-coordinate: dyThese parameters are required for precise transformations between quasi-inertial and rotating terrestrial reference frames."
},

{
    "location": "tutorial.html#Getting-Earth-Orientation-Data-1",
    "page": "Tutorial",
    "title": "Getting Earth Orientation Data",
    "category": "section",
    "text": "When the package is imported for the first time the required data will be automatically downloaded from the IERS servers. After that the data needs to be updated manually like shown below.using EarthOrientation\nEarthOrientation.update()If the data is older than one week newer EOP data should be available and a warning will be given on import."
},

{
    "location": "tutorial.html#Loading-Earth-Orientation-Data-1",
    "page": "Tutorial",
    "title": "Loading Earth Orientation Data",
    "category": "section",
    "text": "The downloaded data is parsed into an EOParams object:eop = EOParams()By default the files downloaded by EarthOrientation.update() will be used. It is also possible to manually pass the required finals.all and finals2000A.all files in CSV format.eop = EOParams(\"finals.csv\", \"finals2000A.csv\")This is useful if the data should not be managed by EarthOrientation.jl but by a different system instead."
},

{
    "location": "tutorial.html#Interpolating-Earth-Orientation-Data-1",
    "page": "Tutorial",
    "title": "Interpolating Earth Orientation Data",
    "category": "section",
    "text": "Get the current Earth orientation parameters, e.g. for polar motion:xp, yp = polarmotion(eop, now()) # arcsecondsOr the current difference between UT1 and UTC and the associated prediction error:ΔUT1 = getΔUT1(eop, now()) # seconds\nΔUT1_err = getΔUT1_err(eop, now()) # milliseconds"
},

{
    "location": "api.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#EarthOrientation.EOParams",
    "page": "API",
    "title": "EarthOrientation.EOParams",
    "category": "Type",
    "text": "Contains Earth orientation parameters since 1973-01-01 until \n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdx-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdx",
    "category": "Method",
    "text": "getdx(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the celestial pole x-coordinate correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdx_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdx_err",
    "category": "Method",
    "text": "getdx_err(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the error in celestial pole x-coordinate correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdy-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdy",
    "category": "Method",
    "text": "getdy(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the celestial pole y-coordinate correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdy_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdy_err",
    "category": "Method",
    "text": "getdy_err(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the error in celestial pole y-coordinate correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdψ-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdψ",
    "category": "Method",
    "text": "getdψ(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the ecliptic nutation correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdψ_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdψ_err",
    "category": "Method",
    "text": "getdψ_err(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the error in the ecliptic nutation correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdϵ-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdϵ",
    "category": "Method",
    "text": "getdϵ(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the ecliptic obliquity correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getdϵ_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getdϵ_err",
    "category": "Method",
    "text": "getdϵ_err(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the error in the ecliptic obliquity correction for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getlod-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getlod",
    "category": "Method",
    "text": "getlod(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the excess length of day for a certain date in milliseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getlod_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getlod_err",
    "category": "Method",
    "text": "getlod_err(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the error in the excess length of day for a certain date in milliseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getxp-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getxp",
    "category": "Method",
    "text": "getxp(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the x-coordinate of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getxp_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getxp_err",
    "category": "Method",
    "text": "getxp_err(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the error for the x-coordinate of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getyp-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getyp",
    "category": "Method",
    "text": "getyp(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the y-coordinate of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getyp_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getyp_err",
    "category": "Method",
    "text": "getyp_err(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the error for the y-coordinate of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getΔUT1-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getΔUT1",
    "category": "Method",
    "text": "getΔUT1(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the difference between UTC and UT1 for a certain date in seconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.getΔUT1_err-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.getΔUT1_err",
    "category": "Method",
    "text": "getΔUT1_err(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the error in the difference between UTC and UT1 for a certain date in seconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.polarmotion-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.polarmotion",
    "category": "Method",
    "text": "polarmotion(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the coordinates of Earth's north pole w.r.t. the CIO for a certain date in arcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.precession_nutation00-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.precession_nutation00",
    "category": "Method",
    "text": "precession_nutation00(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the celestial pole coordinate corrections for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
},

{
    "location": "api.html#EarthOrientation.precession_nutation80-Tuple{Any,Any}",
    "page": "API",
    "title": "EarthOrientation.precession_nutation80",
    "category": "Method",
    "text": "precession_nutation80(eop::EOParams, date; extrapolate=true, warnings=true)\n\nGet the ecliptic corrections for a certain date in milliarcseconds.\n\ndate can either be a DateTime object or a Julian date represented by a Float64. If extrapolate is false an exception will be thrown if date is beyond the range of the table contained in eop. If warnings is true the user will be warned if the result is extrapolated.\n\n\n\n"
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
