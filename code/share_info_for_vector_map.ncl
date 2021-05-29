;;;;;;declare the variables for vector  map;;;;;;;;;;;;
  plotvars   = (/ "WIND_STRESS",            "WIND_1000",     "WIND_700",       "WIND_500",       "WIND_200"  /)
  prelev     = (/-9999,                     1000,            700,              500,              200         /)
  facvar     = (/ 1e2,                      1,               1,                1,                1           /)
  varunt     = (/"10~S~-2~N~ N m~S~-2~N~",  "m s~S~-1~N~",   "m s~S~-1~N~",    "m s~S~-1~N~",    "m s~S~-1~N~" /)
  intyp      = 2 ;

  panelstr1  = tname + " ("+tttag+")"
  panelstr2  = cname + " ("+cttag+")"

  if(compare.eq."Model_vs_OBS") then

   if((cname.ne."ERA5").and.(cname.ne."ERA20C")) then
     print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
     print("Error occurs at share_info_for_latlon_map.ncl")
     exit
   end if

  end if 
