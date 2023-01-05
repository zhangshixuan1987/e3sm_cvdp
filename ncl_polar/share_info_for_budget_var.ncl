;;;;;;declare the 3D variables;;;;;;;;;;;;
  process                               = (/"Dycore",   "DeepCu",   "MG2",    "CLUBB",          "Radiation"        /)
  modvars                               = (/"CLOUD",                "T",                    "Q",         "CLDLIQ",        "CLDICE"/)
  facmod                                = (/      1,                  1,                    1e3,              1e3,             1e6/)
  factnd                                = (/      1,        24.0*3600.0,            24.0*3600.0,      24.0*3600.0,     24.0*3600.0/)
  varunt                                = (/"fraction",             "K",         "g kg~S~-1~N~",   "g kg~S~-1~N~", "mg kg~S~-1~N~"/)
  tndunt                                = varunt+ " day~S~-1~N~"
  cpair                                 = 1004.0
  grav                                  = 9.80665
  panelstr1  = tname + " ("+tttag+")"
  
