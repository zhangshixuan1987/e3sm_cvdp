;;;;;;declare the 3D variables;;;;;;;;;;;;
  modvars                                     = (/"U","V","OMEGA","T","FLUT"/)
  facmod                                     = (/   1,  1,    100,  1,  1/)
  varunt                                     = (/"m~S~-1~N~","m~S~-1~N~","hPa s~S~-1~N~","K","W m~S~-2~N~"/)

  panelstr1  = tname + " ("+tttag+")"
  panelstr2  = cname + " ("+cttag+")"

  if(compare.eq."Model_vs_OBS")then 

   if((cname.eq."ERA5").or.(cname.eq."ERA20C")) then

     obsvars                                 = (/"u", "v", "w","t","ttr"/)
     facobs                                  = (/  1,  1,  100,1,-1/86400.0/)

   else if (cname.eq."NOAA20C") then

     obsvars                                 = (/"uwnd","vwnd","omega","air","rlut"/)
     facobs                                  = (/  1,      1,   100,     1,   1/)

   else

    print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
    exit

   end if
   end if

  end if 
