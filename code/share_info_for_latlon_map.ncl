;;;;;;declare the variables for lat-lon map;;;;;;;;;;;;

  modvars  = (/"CLDTOT",   "CLDLOW",   "CLDHGH",     "TGCLDLWP",     "TGCLDIWP",  \
               "PRECC",    "PRECL",    "PRECT",      "PRECST",                    \
               "LWCF",     "SWCF",     "NETCF",      "LHFLX",        "SHFLX",     \
               "LWCF_SRF", "SWCF_SRF", "NETCF_SRF",  "NET_FLUX_SRF",              \
               "FLUT",     "FSUTOA",   "FSUTOAC",    "FLNT",         "FLUTC",     \
               "FSNTOA",   "FSNTOAC",  "FLNS",       "FLNSC",        "FLDS",      \
               "FLUS",     "FLDSC",    "FSNS",       "FSNSC",        "FSDS",      \
               "FSUS",     "FSUSC",    "FSDSC",      "RESTOM",       "RESTOA",    \
               "TS",       "U10",      "PSL",        "TREFHT",       "TMQ",       \
               "TAUX",     "TAUY",     "ALBEDO",     "ALBEDOC",      "ALBEDO_SRF" /)

  facmod   = (/ 1,              1,            1,            1e3,          1e3,   \
                1000*24*3600,   1000*24*3600, 1000*24*3600, 1000*24*3600,        \
                1,              1,            1,            1,            1,     \
                1,              1,            1,            1,                   \
                1,              1,            1,            1,            1,     \
                1,              1,            1,            1,            1,     \
                1,              1,            1,            1,            1,     \
                1,              1,            1,            1,            1,     \
                1,              1,            1e-2,         1,            1,     \
               -1e2,         -1e2,            1,            1,            1      /)

  varunt   = (/"fraction",                "fraction",               "fraction",         "g kg~S~-1~N~",     "g kg~S~-1~N~",\
               "mm day~S~-1~N~",          "mm day~S~-1~N~",         "mm day~S~-1~N~",   "mm day~S~-1~N~",                \
               "W m~S~-2~N~",             "W m~S~-2~N~",            "W m~S~-2~N~",      "W m~S~-2~N~",      "W m~S~-2~N~", \
               "W m~S~-2~N~",             "W m~S~-2~N~",            "W m~S~-2~N~",      "W m~S~-2~N~",                   \
               "W m~S~-2~N~",             "W m~S~-2~N~",            "W m~S~-2~N~",      "W m~S~-2~N~",      "W m~S~-2~N~", \
               "W m~S~-2~N~",             "W m~S~-2~N~",            "W m~S~-2~N~",      "W m~S~-2~N~",      "W m~S~-2~N~", \
               "W m~S~-2~N~",             "W m~S~-2~N~",            "W m~S~-2~N~",      "W m~S~-2~N~",      "W m~S~-2~N~", \
               "W m~S~-2~N~",             "W m~S~-2~N~",            "W m~S~-2~N~",      "W m~S~-2~N~",      "W m~S~-2~N~", \
               "K",                       "m~S~-1~N~",              "hPa",              "K",                "kg m~S~-2~N~",\
               "10~S~-2~N~ N m~S~-2~N~",  "10~S~-2~N~ N m~S~-2~N~", "unitless",         "unitless",         "unitless"    /)
  panelstr1  = case1name
  panelstr2  = case2name

  if((compare.eq."Model_vs_OBS").and.(case2name.eq."ERA5").or.(case2name.eq."ERA20C")) then

     obsvars = (/  "tcc",     "lcc",      "hcc",        "tclw",         "tciw",      \
                   "mcpr",    "mlspr",    "mtpr",       "sf",                        \
                   "LWCF",    "SWCF",     "NETCF",      "slhf",         "sshf",     \
                   "LWCF_SRF","SWCF_SRF", "NETCF_SRF",  "NET_FLUX_SRF",              \
                   "FLUT",    "FSUTOA",   "FSUTOAC",    "FLNT",         "FLUTC",     \
                   "FSNTOA",  "FSNTOAC",  "FLNS",       "FLNSC",        "FLDS",      \
                   "FLUS",    "FLDSC",    "FSNS",       "FSNSC",        "FSDS",      \
                   "FSUS",    "FSUSC",    "FSDSC",      "RESTOM",       "RESTOA",    \
                   "skt",     "si10",     "msl",        "t2m",          "tcwv",      \
                   "mntss",   "metss",    "ALBEDO",     "ALBEDOC",      "ALBEDO_SRF" /)

     facobs  = (/  1,              1,             1,            1e3,          1e3,      \
                   24*3600,        24*3600,       24*3600,      24*3600,                \
                   1/86400.0,      1/86400.0,     1/86400.0,    1/86400.0,    1/86400.0,\
                   1/86400.0,      1/86400.0,     1/86400.0,    1/86400.0,              \
                   1/86400.0,      1/86400.0,     1/86400.0,    1/86400.0,    1/86400.0,\
                   1/86400.0,      1/86400.0,     1/86400.0,    1/86400.0,    1/86400.0,\
                   1/86400.0,      1/86400.0,     1/86400.0,    1/86400.0,    1/86400.0,\
                   1/86400.0,      1/86400.0,     1/86400.0,    1/86400.0,    1/86400.0,\
                   1,              1,             1e-2,         1,            1,        \
                   -1e2,           -1e2,          1,            1,            1         /)

     panelstr2 = case2name + " ("+obstimtag+")"

  else if (case2name.eq."NOAA20C") then

      obsvars = (/ "tcc",     "lcc",      "hcc",        "tclw",          "tciw",      \
                   "pcpr",    "plspr",    "prate",      "PRECST",                     \
                   "LWCF",    "SWCF",     "NETCF",      "lhtfl",        "shtfl",      \
                   "LWCF_SRF", "SWCF_SRF",  "NETCF_SRF",  "NET_FLUX_SRF",              \
                   "FLUT",    "FSUTOA",   "FSUTOAC",    "FLNT",         "FLUTC",     \
                   "FSNTOA",  "FSNTOAC",  "FLNS",       "FLNSC",        "FLDS",      \
                   "FLUS",    "FLDSC",    "FSNS",       "FSNSC",        "FSDS",      \
                   "FSUS",    "FSUSC",    "FSDSC",      "RESTOM",       "RESTOA",    \
                   "skt",     "si10",     "prmsl",      "t2m",          "pr_wtr",      \
                   "mntss",   "metss",    "ALBEDO",     "ALBEDOC",      "ALBEDO_SRF" /)

      facobs  = (/1e-2,           1e-2,         1e-2,         1e3,          1e3,      \
                  24*3600,        24*3600,      24*3600,      24*3600,             \
                  1,              1,            1,            1,            1,     \
                  1,              1,            1,            1,                   \
                  1,              1,            1,            1,            1,     \
                  1,              1,            1,            1,            1,     \
                  1,              1,            1,            1,            1,     \
                  1,              1,            1,            1,            1,     \
                  1,              1,            1e-2,         1,            1,     \
               -1e2,           -1e2,            1,            1,            1      /)

     panelstr2   = case2name + " ("+obstimtag+")"

  else

    print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
    print("Error occurs at share_info_for_latlon_map.ncl")
    exit

  end if
  end if


