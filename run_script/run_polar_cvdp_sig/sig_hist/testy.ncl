;
; CVDP driver script. To run the CVDP at the command line type: ncl driver.ncl
; To run the CVDP at the command line, put it in background mode, and write the terminal output
; to a file named file.out, type: ncl driver.ncl >&! file.out &
; 
;============================================================================================
  outnam            = "cvdp_v3_vs_obs"
  outdir            = "/global/cfs/cdirs/e3sm/zhan391/diag_out/"+outnam+"/"
  title_lines       = (/"Observation: ERA5,NOAA_NSIDC", "Simulation: E3SM AMIP and Coupled Historical"/)
  user_gen_namelist = "True"              ; use the user-specified method to process namelist file
  namelists_only    = "False"             ; Set to True to only create the variable namelists. Useful
                                          ; upon running the package for the first time to verify that the correct
                                          ; files are being selected by the package. (See files in namelist_byvar/ directory)
                                          ; Set to False to run the entire package.

  obs               = "True"           ; True = analyze and plot observations (specified in namelist_obs), False = do not
  scale_timeseries  = "False"          ; True = scale timeseries so that x-axis length is comparable across timeseries, False = do not
  output_data       = "True"           ; True = output selected calculated data to a netCDF file. Make sure .nc files from previous CVDP
                                          ;        runs are not in outdir or they will get added to or modified.  
  compute_modes_mon = "True"           ; True = compute DJF, MAM, JJA, SON, Annual and Monthly Atmospheric Modes of Variability 
                                          ; False = do not compute the Monthly Atmospheric Modes of Variability  (saves computation time)                               
;- - - - - - - - - - - - - - - - - -   
  opt_climo         = "Full"              ; Full  = remove climatology based on full record of each simulation,
                                          ; Custom = set climatological period using climo_syear (climatological start year) and climo_eyear (climatological end year) 

  if (opt_climo.eq."Custom") then         ; When climo_syear and climo_eyear are positive, remove the climatology/annual cycle based on these years.
     climo_syear    = -30                 ; Both settings should be within the range of years of all specified model runs and observational datasets. 
     climo_eyear    = 0                   ; When climo_syear is negative, remove the climatology/annual cycle relative to the end of each model run
  end if                                  ; or observational dataset. Example: climo_syear = -25, climo_eyear = 0 will result in the climatology
                                          ; being removed from the last 26 years of each model run and observations. 
;- - - - - - - - - - - - - - - - - -   
  colormap          = 0               ; 0 = default colormaps, 1 = colormaps better for color blindness

  output_type       = "png"           ; png = create png files, ps = create postscript files as well as png files (for web viewing).  
  
  png_scale         = 1.5             ; Set the output .png size. Value between .1->5.  Any value > 1 (< 1) increases (decreases) png size. 
                                      ; When output_type = "png" a value of 1 will result in a png sized 1500 (H) x 1500 (W) before automatic cropping of white space
                                      ; When output_type = "ps"  a value of 1 will result in a png density setting of 144 before automatic cropping of white space
  
  tar_output        = "False"               ; True = tar up all output in outdir and remove individual files, False = do not                                      
                                            ; Note: ALL files in outdir will be tarred up and then removed from the outdir directory. 

;---Advanced Options----------------------------------------------------------------------                                             
  zp = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/ncl_code_sig/"    ; directory path of CVDP NCL scripts. (must end in a "/")
                         ; Examples: "ncl_scripts/" if all code is local, or on CGD or CISL systems: "~asphilli/CESM-diagnostics/CVDP/Release/v4.1.0/ncl_scripts/"
                         ; Regardless of this setting the following files should be in one directory: namelist, driver.ncl, and namelist_obs. 
                         ; If pointing to code in ~asphilli make sure the driver script version #s match between this script and the script in ~asphilli.
  
  ncl_exec = "ncl"       ; This can be changed to a different path if a different version of NCL needs to be used, such as "/different/path/to/bin/ncl"                           
                         
  run_style = "parallel" ; parallel = allow simple python-based parallelization to occur. X number of CVDP NCL scripts will be called at once. 
                         ;            X is set via max_num_tasks. Terminal output will be harder to follow.
                         ; serial = call CVDP NCL scripts serially.    

  max_num_tasks = 4      ; Set the number of CVDP NCL scripts that can be called at once. If greater than 1 the scripts will be called in parallel. (If unsure set to 3)     
  
  modular = "True"      ; True = Run only those CVDP scripts specified in modular_list.
                         ; False = Run all CVDP scripts (Default)

  modular_list = "psl.nam_nao,psl.pna_npo,tas.trends_timeseries,"+\
                 "psl.trends,amo,pdo,sst.indices,pr.trends_timeseries,"+\
                 "psl.sam_psa,sst.mean_stddev,psl.mean_stddev,pr.mean_stddev,"+\
                 "sst.trends_timeseries,tas.mean_stddev,ipo,aice.mean_stddev,"+\
                 "aice.trends_timeseries,psl.sam_psa_regpatt,sst.nino34_regpatt,"+\
                 "psl.pna_npo_regpatt,psl.nao_regpatt,psl.nam_regpatt,psl.indices,"+\
                 "u850.psjet.indices,u850.pnjet.indices,"+\
                 "zmsf.hovmoller,zmsf.indices,zmsf.trends,zmsf.mean_stddev"
                ;"amoc,snd.trends,snd.mean_stddev" 
                ; When modular = "True" list the CVDP scripts that will be run.
                ; Example: modular_list = "amoc,amo,pr.trends_timeseries"
                ; For a list of available scripts see complete_list at line 72. 

  machine_casesen = "True"  ; True = Your filesystem is case sensitive  (Default)
                             ; False = Your filesystem is case insensitive                                                          
;========END USER MODIFICATIONS===========================================================
  version = "v0"

  print("Starting: Climate Variability Diagnostics Package ("+systemfunc("date")+")")

  complete_list = "psl.nam_nao,psl.pna_npo,tas.trends_timeseries,snd.trends,psl.trends,amo,pdo,sst.indices,pr.trends_timeseries,"+\
                   "psl.sam_psa,sst.mean_stddev,psl.mean_stddev,pr.mean_stddev,sst.trends_timeseries,amoc,tas.mean_stddev,"+\
                   "snd.mean_stddev,aice.mean_stddev,aice.trends_timeseries,ipo"

  loadscript(zp+"functions.ncl")

  if (isfilepresent2(outdir+"metrics_orig.txt")) then    ; remove metrics_orig.txt file if present
     system("rm "+outdir+"metrics_orig.txt")
  end if

  if (opt_climo.eq."Custom") then
     if (climo_syear.ge.climo_eyear) then
        print("Specified custom climatology start year (climo_syear) cannot be greater than or equal to the specified end year (climo_eyear), exiting CVDP.")
        exit 
     end if
  else
     climo_syear = -999
     climo_eyear = -999
  end if

  if (.not.isfilepresent2(outdir)) then
     system("mkdir -p "+outdir)
  end if
  envvar_str = "   export OUTDIR="+outdir+";   export OBS="+obs+";   export SCALE_TIMESERIES="+scale_timeseries+";   "+\
         "export OUTPUT_DATA="+output_data+";   export VERSION="+version+";   export PNG_SCALE="+png_scale+";   "+\
         "export OPT_CLIMO="+opt_climo+";   export CLIMO_SYEAR="+climo_syear+";   export CLIMO_EYEAR="+climo_eyear+";   "+\
         "export COMPUTE_MODES_MON="+compute_modes_mon+";   export OUTPUT_TYPE="+output_type+";   export MACHINE="+machine_casesen+";   "+\
         "export COLORMAP="+colormap+";   export CVDP_SCRIPTS="+zp+";   export MAX_TASKS="+max_num_tasks+";"  
  ncl_exec = ncl_exec+" -n -Q" 

;-------------------------------
; Create webpages
  webpage_title = ""
  do kk = 0,dimsizes(title_lines)-1
    webpage_title = webpage_title + title_lines(kk) + ";"
  end do 
 
  quote = str_get_dq()
  system("   export OUTDIR="+outdir+";   export VERSION="+version+";   export OUTPUT_DATA="+output_data+";   "+\
         "export OPT_CLIMO="+opt_climo+";   export CLIMO_SYEAR="+climo_syear+";   export CLIMO_EYEAR="+climo_eyear+";   "+\
         "export OBS="+obs+";   export CVDP_SCRIPTS="+zp+"; "+ncl_exec+" 'webtitle="+quote+webpage_title+quote+"' "+zp+"webpage.ncl")
  delete(quote)

print("Finished: Climate Variability Diagnostics Package ("+systemfunc("date")+")")
  
