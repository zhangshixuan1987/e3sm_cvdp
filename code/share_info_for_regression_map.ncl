;;;;;;declare the variables for regression map;;;;;;;;;;;;
  modregvars     = (/ "PSL",             "TS",           "TREFHT",      "U10",         \
                      "PRECT",           "CLDLOW",       "CLDHGH",      "CLDTOT",      \
                      "SWCF",            "LWCF",         "NETCF",       "SWCF_SRF",    \
                      "LWCF_SRF",         "NETCF_SRF"                                  /)
  facmod         = (/  1.0,              1.0,            1.0,           1.0,           \
                       1000*24*3600,     1.0,            1.0,           1.0,           \
                       1.0,              1.0,            1.0,           1.0,           \
                       1.0,              1.0                                           /)
  varunt         = (/  "Pa",            "K",            "K",           "m~S~-1~N~",    \
                       "mm day~S~-1~N~", "fraction",     "fraction",    "fraction",    \
                       "W m~S~-2~N~",    "W m~S~-2~N~",  "W m~S~-2~N~", "W m~S~-2~N~", \
                       "W m~S~-2~N~",    "W m~S~-2~N~",  "W m~S~-2~N~"                 /)
  panelstr1  = tname + " ("+tttag+")"
  panelstr2  = cname + " ("+cttag+")"

  if(compare.eq."Model_vs_OBS") then

   if((cname.eq."ERA5").or.(cname.eq."ERA20C").or.(cname.eq."ERA_20C")) then

     obsregvars  = (/  "msl",            "skt",          "t2m",         "si10",      \
                       "mtpr",           "lcc",          "hcc",         "tcc",       \
                       "SWCF",           "LWCF",         "NETCF",       "SWCF_SRF",  \
                       "LWCF_SRF",       "NETCF_SRF"                                 /)
     facobs      = (/  1.0,              1.0,            1.0,           1.0,         \
                       24*3600,          1.0,            1.0,           1.0,         \
                       1.0/86400.0,      1.0/86400.0,    1.0/86400.0,   1.0/86400.0, \
                       1.0/86400.0,      1.0/86400.0                                 /)

   else if ((cname.eq."NOAA20C").or.(cname.eq."NOAA_20C")) then

     obsregvars  = (/  "prmsl",          "skt",          "t2m",         "si10",      \
                       "prate",          "lcc",          "hcc",         "tcc",       \
                       "SWCF",           "LWCF",         "NETCF",       "SWCF_SRF",  \
                       "LWCF_SRF",       "NETCF_SRF"                                 /)
     facobs      = (/  1.0,              1.0,            1.0,           1.0,         \
                       24*3600,          1.0/100.0,      1.0/100.0,     1.0/100.0,   \
                       1.0,              1.0,            1.0,           1.0,         \
                       1.0,              1.0                                         /)

   else

    print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
    exit

   end if
   end if

  end if 

;;;;;;;range for the plot corresponding to each variable;;;;
  if (l_regress .eq. "l_regress_enso") then 

    maxlev         = 11
 
    lev_enso1      = (/ 200.,  0.5,   0.5,   0.5,  \
                        0.5,   0.04,  0.04,  0.04, \
                        8.,    4.,    4.,    8.,   \
                        4.,    4.                    /)
    lev_enso2      = (/ 200.,  0.5,   0.5,   0.5,  \
                        0.5,   0.04,  0.04,  0.04,  \
                        8.,    4.,    4.,    8.,   \
                        4.,    4.                    /)
    lev_enso3      = (/ 200.,  0.5,   0.5,   0.5,  \
                        0.5,   0.04,  0.04,  0.04, \
                        8.,    4.,    4.,    8.,   \
                        4.,    4.                    /)

  else if (l_regress .eq. "l_regress_z500") then

    maxlev         = 11

    lev_eof1       = (/ 200.,  0.5,   0.5,   0.5,  \
                        0.5,   0.04,  0.04,  0.04, \
                        8.,    4.,    4.,    8.,   \
                        4.,    4.                    /)
    lev_eof2       = (/ 200.,  0.5,   0.5,   0.5,  \
                        0.5,   0.04,  0.04,  0.04,  \
                        8.,    4.,    4.,    8.,   \
                        4.,    4.                    /)
    lev_eof3       = (/ 200.,  0.5,   0.5,   0.5,  \
                        0.5,   0.04,  0.04,  0.04, \
                        8.,    4.,    4.,    8.,   \
                        4.,    4.                    /)
  
  else if (l_regress .eq. "l_regress_psl") then

    maxlev         = 11
    lev_eof1       = (/ 200.,  0.5,   0.5,   0.5,  \
                        0.5,   0.04,  0.04,  0.04, \
                        8.,    4.,    4.,    8.,   \
                        4.,    4.                    /)
    lev_eof2       = (/ 200.,  0.5,   0.5,   0.5,  \
                        0.5,   0.04,  0.04,  0.04,  \
                        8.,    4.,    4.,    8.,   \
                        4.,    4.                    /)
    lev_eof3       = (/ 200.,  0.5,   0.5,   0.5,  \
                        0.5,   0.04,  0.04,  0.04, \
                        8.,    4.,    4.,    8.,   \
                        4.,    4.                    /)

  else if (l_regress .eq. "l_regress_jet") then

    maxlev         = 11
    lev_jet        = (/ 100.,  0.3,   0.3,   0.3,  \
                        0.3,   0.02,  0.02,  0.02, \
                        4.,    2.,    2.,    4.,   \
                        2.,    2.                    /)
  else

   print("The source for regression plot is not clear, quit")
   print("Error happend at share_info_for_regression_map.ncl")
   exit

  end if 

  end if 

  end if 
  
  end if 

