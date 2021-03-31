;;;;;;declare the 3D variables;;;;;;;;;;;;
  modvars                                     = (/"U","T","Q","RELHUM","OMEGA"/)
  facmod                                     = (/  1,  1,  1e3,  1, 24.0*3600.0/100.0/)
  varunt                                     = (/"m~S~-1~N~","K","g kg~S~-1~N~","Percent","hPa day~S~-1~N~"/)
  panelstr1                                  = case1name
  panelstr2                                  = case2name

  if((compare.eq."Model_vs_OBS"))then 

   if((case2name.eq."ERA5").or.(case2name.eq."ERA20C")) then

     obsvars                                 = (/"u", "t", "q", "r", "w"/)
     facobs                                  = (/  1,  1,  1e3,  1, 24.0*3600.0/100.0/)
     panelstr2                               = case2name + " ("+obstimtag+")"

   else if (case2name.eq."NOAA20C") then

     obsvars                                 = (/"uwnd","air","shum","rhum","omega"/)
     facobs                                  = (/  1,  1,  1e3,  1, 24.0*3600.0/100.0/)
     panelstr2                               = case2name + " ("+obstimtag+")"

   else

    print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
    exit

   end if
   end if

  end if 
