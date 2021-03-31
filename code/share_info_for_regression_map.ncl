;;;;;;declare the variables for regression map;;;;;;;;;;;;
  modregvars     = (/ "PSL",             "TS",           "TREFHT",      "U10",         \
                      "PRECT",           "CLDLOW",       "CLDHGH",      "CLDTOT",      \
                      "SWCF",            "LWCF",         "NETCF",       "SWCF_SRF",    \
                      "LWCF_SRF",         "NETCF_SRF"                                  /)
  facmod         = (/  1.0,              1.0,            1.0,           1.0,           \
                       1000*24*3600,     1.0,            1.0,           1.0,           \
                       1.0,              1.0,            1.0,           1.0,           \
                       1.0,              1.0                                           /)
  varunt         = (/  "hPa",            "K",            "K",           "m~S~-1~N~",   \
                       "mm day~S~-1~N~", "fraction",     "fraction",    "fraction",    \
                       "W m~S~-2~N~",    "W m~S~-2~N~",  "W m~S~-2~N~", "W m~S~-2~N~", \
                       "W m~S~-2~N~",    "W m~S~-2~N~",  "W m~S~-2~N~"                 /)
  panelstr1      = case1name
  panelstr2      = case2name

  if(compare.eq."Model_vs_OBS") then

   if((case2name.eq."ERA5").or.(case2name.eq."ERA20C")) then

     obsregvars  = (/  "msl",            "skt",          "t2m",         "si10",      \
                       "mtpr",           "lcc",          "hcc",         "tcc",       \
                       "SWCF",           "LWCF",         "NETCF",       "SWCF_SRF",  \
                       "LWCF_SRF",       "NETCF_SRF"                                 /)
     facobs      = (/  1.0,              1.0,            1.0,           1.0,         \
                       24*3600,          1.0,            1.0,           1.0,         \
                       1.0/86400.0,      1.0/86400.0,    1.0/86400.0,   1.0/86400.0, \
                       1.0/86400.0,      1.0/86400.0                                 /)
     panelstr2                                 = case2name + " ("+obstimtag+")"

   else if (case2name.eq."NOAA20C")

     obsregvars  = (/  "prmsl",          "skt",          "t2m",         "si10",      \
                       "prate",          "lcc",          "hcc",         "tcc",       \
                       "SWCF",           "LWCF",         "NETCF",       "SWCF_SRF",  \
                       "LWCF_SRF",       "NETCF_SRF"                                 /)
     facobs      = (/  1.0,              1.0,            1.0,           1.0,         \
                       24*3600,          1.0/100.0,      1.0/100.0,     1.0/100.0,   \
                       1.0,              1.0,            1.0,           1.0,         \
                       1.0,              1.0                                         /)
     panelstr2   = case2name + " ("+obstimtag+")"

   else

    print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
    exit

   end if
   end if

  end if 

;;;;;;;range for the plot corresponding to each variable;;;;
  if (l_regress .eq. "l_regress_enso") then 

    maxlev         = 11
    lev_enso1      = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)
    lev_enso2      = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)
    lev_enso3      = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)

  else if (l_regress .eq. "l_regress_z500") then

    maxlev         = 11
    lev_eof1       = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)
    lev_eof2       = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)
    lev_eof3       = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /) 
  
  else if (l_regress .eq. "l_regress_psl") then

    maxlev         = 11
    lev_eof1       = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)
    lev_eof2       = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)
    lev_eof3       = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)
  else if (l_regress .eq. "l_regress_jet_pos") then

    maxlev         = 11
    lev_jet       = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)

  else if (l_regress .eq. "l_regress_jet_ins") then

    maxlev         = 11
    lev_jet       = (/ 100.,  0.5,   0.5,   0.5,  \
                        0.5,   0.01,  0.01,  0.01, \
                        2.,    1.,    1.,    2.,   \
                        1.,    1.                    /)
  else

   print("The source for regression plot is not clear, quit")
   print("Error happend at share_info_for_regression_map.ncl")
   exit

  end if 

  end if 

  end if 

  end if 
  
  end if 

