;;;;;;declare the 3D variables;;;;;;;;;;;;
  modvars                                     = (/"U","T","Q","RELHUM","OMEGA"/)
  facmod                                     = (/  1,  1,  1e3,  1, 24.0*3600.0/100.0/)
  varunt                                     = (/"m~S~-1~N~","K","g kg~S~-1~N~","Percent","hPa day~S~-1~N~"/)

  panelstr1  = tname + " ("+tttag+")"
  panelstr2  = cname + " ("+cttag+")"

  if(compare.eq."Model_vs_OBS")then 

   if((cname.eq."ERA5").or.(cname.eq."ERA20C")) then

     obsvars                                 = (/"u", "t", "q", "r", "w"/)
     facobs                                  = (/  1,  1,  1e3,  1, 24.0*3600.0/100.0/)

   else if (cname.eq."NOAA20C") then

     obsvars                                 = (/"uwnd","air","shum","rhum","omega"/)
     facobs                                  = (/  1,  1,  1e3,  1, 24.0*3600.0/100.0/)

   else

    print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
    exit

   end if
   end if

  end if 
