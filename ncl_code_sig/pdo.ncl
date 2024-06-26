; Calculates the PDO pattern, timeseries, and spectra.
;
; Variables used: ts
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: pdo.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")  
  
  nsim = numAsciiRow("namelist_byvar/namelist_ts")
  na = asciiread("namelist_byvar/namelist_ts",(/nsim/),"string")
  names = new(nsim,"string")
  paths = new(nsim,"string")
  syear = new(nsim,"integer",-999)
  eyear = new(nsim,"integer",-999)
  delim = "|"

  do gg = 0,nsim-1
     names(gg) = str_strip(str_get_field(na(gg),1,delim))
     paths(gg) = str_strip(str_get_field(na(gg),2,delim))
     syear(gg) = stringtointeger(str_strip(str_get_field(na(gg),3,delim)))
     eyear(gg) = stringtointeger(str_strip(str_get_field(na(gg),4,delim)))
  end do
  nyr = eyear-syear+1
  nyr_max = max(nyr)

  pi=4.*atan(1.0)
  rad=(pi/180.)
;---------TAS Regressions coding-------------------------------------------------
  nsim_tas = numAsciiRow("namelist_byvar/namelist_trefht")
  na_tas = asciiread("namelist_byvar/namelist_trefht",(/nsim_tas/),"string")
  names_tas = new(nsim_tas,"string")
  paths_tas = new(nsim_tas,"string")
  syear_tas = new(nsim_tas,"integer",-999)
  eyear_tas = new(nsim_tas,"integer",-999)

  do gg = 0,nsim_tas-1
     names_tas(gg) = str_strip(str_get_field(na_tas(gg),1,delim))
     paths_tas(gg) = str_strip(str_get_field(na_tas(gg),2,delim))
     syear_tas(gg) = stringtointeger(str_strip(str_get_field(na_tas(gg),3,delim)))
     eyear_tas(gg) = stringtointeger(str_strip(str_get_field(na_tas(gg),4,delim)))
  end do
  delete(na_tas)
  nyr_tas = eyear_tas-syear_tas+1  
;---------PR Regressions coding-------------------------------------------------
  nsim_pr = numAsciiRow("namelist_byvar/namelist_prect")
  na_pr = asciiread("namelist_byvar/namelist_prect",(/nsim_pr/),"string")
  names_pr = new(nsim_pr,"string")
  paths_pr = new(nsim_pr,"string")
  syear_pr = new(nsim_pr,"integer",-999)
  eyear_pr = new(nsim_pr,"integer",-999)

  do gg = 0,nsim_pr-1
     names_pr(gg) = str_strip(str_get_field(na_pr(gg),1,delim))
     paths_pr(gg) = str_strip(str_get_field(na_pr(gg),2,delim))
     syear_pr(gg) = stringtointeger(str_strip(str_get_field(na_pr(gg),3,delim)))
     eyear_pr(gg) = stringtointeger(str_strip(str_get_field(na_pr(gg),4,delim)))
  end do
  delete(na_pr)
  nyr_pr = eyear_pr-syear_pr+1  
;-------------------------------------------------------------------------------------------------                
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if
  wks = gsn_open_wks(wks_type,getenv("OUTDIR")+"pdo")
  wks4 = gsn_open_wks(wks_type,getenv("OUTDIR")+"pdo.prreg")
  wks2 = gsn_open_wks(wks_type,getenv("OUTDIR")+"pdo.powspec")
  wks3 = gsn_open_wks(wks_type,getenv("OUTDIR")+"pdo.timeseries")  

  if (COLORMAP.eq."0") then
     gsn_define_colormap(wks,"cmp_b2r")   
     gsn_define_colormap(wks2,"cb_9step")
     gsn_define_colormap(wks3,"ncl_default")
     gsn_define_colormap(wks4,"MPL_BrBG")  
  end if
  if (COLORMAP.eq."1") then
     gsn_define_colormap(wks,"BlueDarkRed18")   
     gsn_define_colormap(wks2,"cb_9step")
     gsn_define_colormap(wks3,"ncl_default")
     gsn_define_colormap(wks4,"BrownBlue12")     
  end if
  map = new(nsim,"graphic")  
  map_sst = new(nsim,"graphic")
  map_tasreg = new(nsim,"graphic")  
  map_prreg = new(nsim,"graphic")  
  pspec = new(nsim,"graphic")
  xyplot = new(nsim,"graphic")
  xyplot2 = new(nsim,"graphic")
  if (isfilepresent2("obs_ts")) then
     pspec_obs = new(nsim,"graphic")
  end if

  tasreg_frame = 1    ; *reg_frame = flag to create regressions .ps/.png files. Created/used instead of *reg_plot_flag
                      ; so that if {tas,pr} regressions are not created for the last simulation listed that .ps/png files are created
  prreg_frame  = 1
  do ee = 0,nsim-1
     sst = data_read_in(paths(ee),"TS",syear(ee),eyear(ee))    ; read in data, orient lats/lons correctly, set time coordinate variable up
     if (isatt(sst,"is_all_missing").or.nyr(ee).lt.15) then
        delete(sst)
        continue
     end if
     sst = where(sst.le.-1.8,-1.8,sst)    ; set all values below -1.8 to -1.8
     d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   ; mask out land (this is redundant for data that is already masked)
     basemap = d->LSMASK
     lsm = landsea_mask(basemap,sst&lat,sst&lon)
     sst = mask(sst,conform(sst,lsm,(/1,2/)).ge.1,False)
     delete([/lsm,basemap/])
     delete(d)  
         
     if (OPT_CLIMO.eq."Full") then
        sst = rmMonAnnCycTLL(sst)
     else
        check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
        temp_arr = sst
        delete(temp_arr&time)
        temp_arr&time = cd_calendar(sst&time,-1)
        if (CLIMO_SYEAR.lt.0) then
           climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
        else
           climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
        end if    
        delete(temp_arr)
        sst   = calcMonAnomTLL(sst,climo) 
        delete(climo)
     end if
  
     coswgt=cos(rad*sst&lat)
     coswgt!0 = "lat"
     coswgt&lat= sst&lat
    
     do ff = 0,dimsizes(sst&time)-1
        sst(ff,:,:) = (/ sst(ff,:,:) - wgt_areaave(sst(ff,{-60:70},:),coswgt({-60.:70.}),1.0,0) /)
     end do
     delete(coswgt)
     sst2 = sst(lat|:,lon|:,time|:)
     delete(sst)
     sst_CW= SqrtCosWeight(sst2(time|:,lat|:,lon|:))
  
     evecv = eofunc(sst_CW({lat|20:70},{lon|110:260},time|:),2,75)
     delete(sst_CW)
     pcts = eofunc_ts(sst2({20:70},{110:260},:),evecv,False)
     pctsS = dim_standardize(pcts(0,:),0)
     delete([/pcts/])
     finarr = sst2(:,:,0)
     finarr = finarr@_FillValue

     finarr = (/ regCoef(pctsS,sst2) /)
     finarr@syear = syear(ee)
     finarr@eyear = eyear(ee)

     pdo = finarr
     pc1 = pctsS
     pc1!0 = "time"
     pc1&time = sst2&time
     pc1@units = "1"
     sig_pcv = eofunc_north2(evecv@pcvar,dimsizes(pc1),False)
     if (sig_pcv(0)) then    ; if True then significant
        pdo@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%*"
     else
        pdo@pcvar = tofloat(sprintf("%4.1f", evecv@pcvar(0)))+"%"
     end if
     delete([/sig_pcv,evecv/])
 
     if (.not.all(ismissing(pdo({35:39},{198:202})))) then
        if (avg(pdo({35:39},{198:202})).ge.0) then  ; arbitrary attempt to make all plots have the same sign..
           pdo = pdo*-1.
           pc1 = pc1*-1.
        end if
     end if
     delete([/sst2,pctsS,finarr/])
;---------TAS Regressions coding-------------------------------------------------
     if (any(ismissing((/syear(ee),syear_tas(ee),eyear(ee),eyear_tas(ee)/)))) then
        tasreg_plot_flag = 1
     else
        if (syear(ee).eq.syear_tas(ee)) then     ; check that the start and end years match for ts, tas, and psl
           if (eyear(ee).eq.eyear_tas(ee)) then
              tasreg_plot_flag = 0
           else
              tasreg_plot_flag = 1
           end if
        else
           tasreg_plot_flag = 1
        end if
     end if 

     if (tasreg_plot_flag.eq.0) then 
        tas = data_read_in(paths_tas(ee),"TREFHT",syear_tas(ee),eyear_tas(ee))
        if (isatt(tas,"is_all_missing")) then
           tasreg_plot_flag = 1
           delete(tas)
        end if
        
        if (tasreg_plot_flag.eq.0) then     ; only continue if both TAS/SST fields are present
           d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   
           basemap = d->LSMASK
           lsm = landsea_mask(basemap,tas&lat,tas&lon)
           tas = mask(tas,conform(tas,lsm,(/1,2/)).eq.0,False)
           delete(lsm)
           
           if (OPT_CLIMO.eq."Full") then
              tas = rmMonAnnCycTLL(tas)
           else
              check_custom_climo(names_tas(ee),syear_tas(ee),eyear_tas(ee),CLIMO_SYEAR,CLIMO_EYEAR)
              temp_arr = tas
              delete(temp_arr&time)
              temp_arr&time = cd_calendar(tas&time,1)
              if (CLIMO_SYEAR.lt.0) then
                 climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
              else
                 climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
              end if    
              delete(temp_arr)
              tas   = calcMonAnomTLL(tas,climo) 
              delete(climo)
           end if
           finreg_tas = tas(0,:,:)
           finreg_tas = (/ regCoef(pc1,tas(lat|:,lon|:,time|:))  /) 
           delete(tas)
        end if
     end if
;---------PR Regressions coding-------------------------------------------------
     if (any(ismissing((/syear(ee),syear_pr(ee),eyear(ee),eyear_pr(ee)/)))) then
        prreg_plot_flag = 1
     else
        if (syear(ee).eq.syear_pr(ee)) then     ; check that the start and end years match for pr and psl
           if (eyear(ee).eq.eyear_pr(ee)) then
              prreg_plot_flag = 0
           else
              prreg_plot_flag = 1
           end if
        else
           prreg_plot_flag = 1
        end if
     end if 

     if (prreg_plot_flag.eq.0) then 
        pr = data_read_in(paths_pr(ee),"PRECT",syear_pr(ee),eyear_pr(ee))
        if (isatt(pr,"is_all_missing")) then
           prreg_plot_flag = 1
           delete(pr)
        end if
        
        if (prreg_plot_flag.eq.0) then     ; only continue if both SST/PR fields are present
           if (OPT_CLIMO.eq."Full") then
              pr = rmMonAnnCycTLL(pr)
           else
              check_custom_climo(names_pr(ee),syear_pr(ee),eyear_pr(ee),CLIMO_SYEAR,CLIMO_EYEAR)
              temp_arr = pr
              delete(temp_arr&time)
              temp_arr&time = cd_calendar(pr&time,1)
              if (CLIMO_SYEAR.lt.0) then
                 climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
              else
                 climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
              end if    
              delete(temp_arr)
              pr   = calcMonAnomTLL(pr,climo) 
              delete(climo)
           end if
           finreg_pr = pr(0,:,:)
           finreg_pr = (/ regCoef(pc1,pr(lat|:,lon|:,time|:))  /) 
           delete(pr)
        end if
     end if
;---------------------------------------------------------------------------------------------    
     if (tasreg_frame.eq.1.and.tasreg_plot_flag.eq.0) then    ; tasreg_frame = flag to create regressions .ps/.png files 
        tasreg_frame = 0
     end if  
     if (prreg_frame.eq.1.and.prreg_plot_flag.eq.0) then      ; prreg_frame = flag to create regressions .ps/.png files 
        prreg_frame = 0
     end if  
;---------------------------------------------------------------------------------------------     
     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.pdo."+syear(ee)+"-"+eyear(ee)+".nc"
        if (.not.isfilepresent2(fn)) then
           z = addfile(fn,"c")
           z@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
           z@notes = "Data from "+names(ee)+" from "+syear(ee)+"-"+eyear(ee)
           if (OPT_CLIMO.eq."Full") then
              z@climatology = syear(ee)+"-"+eyear(ee)+" climatology removed prior to all calculations (other than means)"
           else
              if (CLIMO_SYEAR.lt.0) then
                 z@climatology = (eyear(ee)+CLIMO_SYEAR)+"-"+(eyear(ee)+CLIMO_EYEAR)+" climatology removed prior to all calculations (other than means)"
              else
                 z@climatology = CLIMO_SYEAR+"-"+CLIMO_EYEAR+" climatology removed prior to all calculations (other than means)"
              end if
           end if
           z@Conventions = "CF-1.6"
        else
           z = addfile(fn,"w")
        end if
        z->pdo_pattern_mon = set_varAtts(pdo,"PDO spatial pattern (monthly)","","")
        z->pdo_timeseries_mon = set_varAtts(pc1,"PDO normalized principal component timeseries (monthly)","1","")
        delete([/modname,fn/])
        if (tasreg_plot_flag.eq.0) then
           modname = str_sub_str(names_tas(ee)," ","_")
           bc = (/"/","'","(",")"/)
           do gg = 0,dimsizes(bc)-1
              modname = str_sub_str(modname,bc(gg),"_")
           end do
           fn = getenv("OUTDIR")+modname+".cvdp_data.pdo.tas."+syear_tas(ee)+"-"+eyear_tas(ee)+".nc"
           if (.not.isfilepresent2(fn)) then
              z_tas = addfile(fn,"c")
              z_tas@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
              z_tas@notes = "Data from "+names_tas(ee)+" from "+syear_tas(ee)+"-"+eyear_tas(ee)
              if (OPT_CLIMO.eq."Full") then
                 z_tas@climatology = syear_tas(ee)+"-"+eyear_tas(ee)+" climatology removed prior to all calculations (other than means)"
              else
                 if (CLIMO_SYEAR.lt.0) then
                    z_tas@climatology = (eyear(ee)+CLIMO_SYEAR)+"-"+(eyear(ee)+CLIMO_EYEAR)+" climatology removed prior to all calculations (other than means)"
                 else
                    z_tas@climatology = CLIMO_SYEAR+"-"+CLIMO_EYEAR+" climatology removed prior to all calculations (other than means)"
                 end if
              end if
              z_tas@Conventions = "CF-1.6"
           else
              z_tas = addfile(fn,"w")
           end if
           z_tas->pdo_tas_regression_mon = set_varAtts(finreg_tas,"tas regression onto PDO timeseries (monthly)","","")    
           delete([/modname,fn,z_tas/])
        end if
        if (prreg_plot_flag.eq.0) then
           modname = str_sub_str(names_pr(ee)," ","_")
           bc = (/"/","'","(",")"/)
           do gg = 0,dimsizes(bc)-1
              modname = str_sub_str(modname,bc(gg),"_")
           end do
           fn = getenv("OUTDIR")+modname+".cvdp_data.pdo.pr."+syear_pr(ee)+"-"+eyear_pr(ee)+".nc"
           if (.not.isfilepresent2(fn)) then
              z_pr = addfile(fn,"c")
              z_pr@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
              z_pr@notes = "Data from "+names_pr(ee)+" from "+syear_pr(ee)+"-"+eyear_pr(ee)
              if (OPT_CLIMO.eq."Full") then
                 z_pr@climatology = syear_pr(ee)+"-"+eyear_pr(ee)+" climatology removed prior to all calculations (other than means)"
              else
                 if (CLIMO_SYEAR.lt.0) then
                    z_pr@climatology = (eyear(ee)+CLIMO_SYEAR)+"-"+(eyear(ee)+CLIMO_EYEAR)+" climatology removed prior to all calculations (other than means)"
                 else
                    z_pr@climatology = CLIMO_SYEAR+"-"+CLIMO_EYEAR+" climatology removed prior to all calculations (other than means)"
                 end if
              end if
              z_pr@Conventions = "CF-1.6"
           else
              z_pr = addfile(fn,"w")
           end if
           z_pr->pdo_pr_regression_mon = set_varAtts(finreg_pr,"pr regression onto PDO timeseries (monthly)","","") 
           delete([/modname,fn,z_pr/])
        end if
     end if              
;------------------------------------------------------------------------
     iopt = 0
     jave = (7*nyr(ee))/100
     val1 = .95
     val2 = .99
     if (jave.eq.0) then
       jave = 1
     end if
     pct = 0.1    
     spectra_mvf = False        ; missing value flag
     if (any(ismissing(pc1))) then  ; check for missing data            
        print("Missing data detected for "+names(ee)+", not creating PDO spectra")
        spectra_mvf = True
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           spectra_mvf_obs = True    ; missing value flag
        end if
     else
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           spectra_mvf_obs = False   ; missing value flag
        end if 
        sdof = specx_anal(pc1,iopt,jave,pct)   ; pc1 is standardized
        splt1 = specx_ci(sdof,val1,val2)
        if (OUTPUT_DATA.eq."True") then
           splt1!0 = "ncurves"
           splt1&ncurves = ispan(0,3,1)
           splt1&ncurves@long_name = "power spectra curves"
           splt1&ncurves@units = "1"
           splt1!1 = "frequency"
           splt1&frequency = sdof@frq
           splt1&frequency@units = "1"
           splt1@units_info = "df refers to frequency interval; data are standardized so there are no physical units"
           splt1@units = "1/df"
           splt1@info = "(0,:)=spectrum,(1,:)=Markov red noise spectrum, (2,:)="+val1+"% confidence bound for Markhov, (3,:)="+val2+"% confidence bound for Markhov"
           z->pdo_spectra = set_varAtts(splt1,"PDO (monthly) power spectra, Markov spectrum and confidence curves","","") 
        end if
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           sdof_obs = sdof
        end if
        delete([/iopt,jave,pct/])
     end if
     if (isvar("z")) then
        delete(z)
     end if
;========================================================================
     res = True
     res@mpProjection = "WinkelTripel"
     res@mpGeophysicalLineColor = "gray42"
     res@mpPerimOn    = False
     res@mpGridLatSpacingF =  90            ; change latitude  line spacing
     res@mpGridLonSpacingF = 180.           ; change longitude line spacing
     res@mpGridLineColor   = "transparent"  ; trick ncl into drawing perimeter
     res@mpGridAndLimbOn   = True           ; turn on lat/lon lines  
     res@mpFillOn = False
     res@mpCenterLonF = 210.
     res@mpOutlineOn = True  
     res@gsnDraw      = False
     res@gsnFrame     = False
     res@vpYF = 0.95
     res@vpHeightF = 0.3
     res@vpXF = 0.2
     res@vpWidthF = 0.6
  
     if (wks_type.eq."png") then
        res@mpGeophysicalLineThicknessF = 2.
     else
        res@mpGeophysicalLineThicknessF = 1.
     end if

;     res@cnFillMode = "RasterFill"
     res@cnLevelSelectionMode = "ExplicitLevels"
     
     if (COLORMAP.eq."0") then
        res@cnLevels = fspan(-.65,.65,27)
     end if
     if (COLORMAP.eq."1") then
        res@cnLevels = fspan(-.8,.8,17)
     end if

     res@cnLineLabelsOn = False
     res@cnFillOn        = True
     res@cnLinesOn       = False
     res@lbLabelBarOn    = False

     res@gsnLeftStringOrthogonalPosF = -0.05
     res@gsnLeftStringParallelPosF = .005
     res@gsnRightStringOrthogonalPosF = -0.05
     res@gsnRightStringParallelPosF = 0.96
     res@gsnRightString = ""
     res@gsnLeftString = ""
     res@gsnLeftStringFontHeightF = 0.014
     res@gsnCenterStringFontHeightF = 0.018
     res@gsnRightStringFontHeightF = 0.014
     res@gsnLeftString = syear(ee)+"-"+eyear(ee)
     res@gsnRightString = pdo@pcvar
     res@gsnCenterString = names(ee)

     res4 = res    ; res4 = pr regression resources 
     delete(res4@cnLevels)    
     if (COLORMAP.eq.0) then
        res4@cnLevels = (/-5,-4,-3,-2,-1,-.75,-.5,-.25,-.1,0,.1,.25,.5,.75,1,2,3,4,5/)     
     else
        res4@cnLevels = (/-3,-2,-1,-.5,-.1,0,.1,.5,1,2,3/)     
     end if

     res2 = True   ; res2 = tas regression resources     
     res2@gsnDraw      = False
     res2@gsnFrame     = False
     res2@cnLevelSelectionMode = "ExplicitLevels"
     res2@cnLevels = res@cnLevels

     res2@cnLineLabelsOn = False
     res2@cnFillOn        = True
     res2@cnLinesOn       = False
     res2@cnFillMode = "AreaFill"
     res2@lbLabelBarOn    = False
     res2@cnInfoLabelOn = False
     res2@gsnRightString = ""
     res2@gsnLeftString = "" 
     res2@gsnCenterString = ""   
     res2@gsnAddCyclic = True

     if (isfilepresent2("obs_ts").and.ee.eq.0) then    ; for pattern correlation table
        patcor = new((/nsim,dimsizes(pdo&lat),dimsizes(pdo&lon)/),typeof(pdo))
        patcor!1 = "lat"
        patcor&lat = pdo&lat
        patcor!2 = "lon"
        patcor&lon = pdo&lon
        patcor(ee,:,:) = (/ pdo /)
     end if
     if (isfilepresent2("obs_ts").and.ee.ge.1.and.isvar("patcor")) then
        patcor(ee,:,:) = (/ totype(linint2(pdo&lon,pdo&lat,pdo,True,patcor&lon,patcor&lat,0),typeof(patcor)) /)
     end if

     map(ee) = gsn_csm_contour_map(wks,pdo,res)
          
     if (tasreg_plot_flag.eq.0) then
        if (names(ee).eq.names_tas(ee)) then
           res@gsnCenterString = names(ee)     
        else
           res@gsnCenterString = names(ee)+" / "+names_tas(ee)
        end if
        map_sst(ee) = gsn_csm_contour_map(wks,pdo,res)
        map_tasreg(ee) = gsn_csm_contour(wks,finreg_tas,res2)
        overlay(map_sst(ee),map_tasreg(ee))
        delete([/finreg_tas/])
     end if
     delete([/pdo/])
     if (prreg_plot_flag.eq.0) then
        res4@gsnCenterString = names_pr(ee)
        map_prreg(ee) = gsn_csm_contour_map(wks4,finreg_pr,res4)
        delete(finreg_pr)
     end if

     pres = True
     pres@vpWidthF      = 0.7
     pres@vpHeightF     = 0.5
     pres@vpXF          = 0.07
     pres@trYMinF       = 0.
     pres@trXMinF       = 0.0
;     pres@trYMaxF      = 82.
     pres@trXMaxF       = 0.0832
     pres@tiYAxisString = "Power"              ; yaxis
     pres@xyLineColor   = "black"         
     pres@gsnFrame      = False
     pres@gsnDraw       = False
  
     pres@tmXBLabelDeltaF = -.8
     pres@tmXTLabelDeltaF = -.8
     pres@pmLegendDisplayMode    = "Never"
     pres@xyDashPatterns      = (/0,0,0,0/)
     pres@xyLineColors        = (/"foreground","red","blue","green"/)      
     pres@xyLabelMode = "custom"
     pres@xyLineLabelFontColors = pres@xyLineColors 
     pres@xyExplicitLabels = (/"","",val1*100+"%",val2*100+"%"/)
     pres@tmXTOn = True
     pres@tmYROn = False
     pres@tmXTLabelsOn = True
     pres@tmXUseBottom = False
     pres@tmXTMode   = "Explicit"  
     pres@tmXBMode   = "Explicit"            
     pres@tmXTValues = (/".00167",".00833",".01667",".02778",".0416",".0556",".0832"/)
     pres@tmXTLabels = (/"50","10","5","3","2","1.5","1"/)           
     pres@tmXBValues = (/".0",".01",".02",".03",".042",".056",".083"/)
     pres@tmXBLabels =     pres@tmXBValues
     pres@tmXTLabelFontHeightF = 0.018
     pres@tmXBLabelFontHeightF = 0.018
     pres@tmYLLabelFontHeightF = 0.018
     pres@tiYAxisString = "Variance" ;"Power (~S~o~N~C~S~2~N~ / cycles mo~S~-1~N~)"              ; yaxis
     pres@tiXAxisString = "Frequency (cycles mo~S~-1~N~)"
     pres@tiMainString = ""
     pres@txFontHeightF = 0.015
     pres@xyLineLabelFontHeightF = 0.022
     pres@tiXAxisFontHeightF = 0.025
     pres@tiYAxisFontHeightF = 0.025
     pres@tiMainFontHeightF = 0.03
     pres@gsnRightStringOrthogonalPosF = -0.135
     
     if (spectra_mvf.eq.False) then
        if (isfilepresent2("obs_ts").and.ee.ge.1.and.spectra_mvf_obs.eq.False) then
           val = new(2,typeof(sdof_obs@spcx))
           val(0) = max(sdof_obs@spcx)
           val(1) = totype(max(splt1(0,:)),typeof(sdof_obs@spcx))
           mval = max(val)
           delete(val)
        else
           mval = max(splt1(0,:))
        end if
        if (mval.lt.40) then
           pres@trYMaxF         := 40.
           pres@tmYLMode        := "Explicit"
           pres@tmYLValues      := (/0,10,20,30,40/)
           pres@tmYLLabels      := pres@tmYLValues
           pres@tmYLMinorValues := ispan(0,40,5)
        else if (mval.lt.80) then
           pres@trYMaxF         := 80.
           pres@tmYLMode        := "Explicit"
           pres@tmYLValues      := (/0,20,40,60,80/)
           pres@tmYLLabels      := pres@tmYLValues
           pres@tmYLMinorValues := ispan(0,80,10)
        else if (mval.lt.150) then
           pres@trYMaxF         := 150.
           pres@tmYLMode        := "Explicit"
           pres@tmYLValues      := (/0,30,60,90,120,150/)
           pres@tmYLLabels      := pres@tmYLValues
           pres@tmYLMinorValues := ispan(0,150,10)
        else
           pres@trYMaxF         := mval+15.
           pres@tmYLMode        := "Explicit"
           pres@tmYLValues      := ispan(0,toint(mval+15),50)
           pres@tmYLLabels      := pres@tmYLValues
           pres@tmYLMinorValues := ispan(0,toint(mval+15),25)
        end if
        end if
        end if
        delete(mval)
     end if

     pres@tiMainOn = False
     pres@gsnCenterString = "Period (years)"
     pres@gsnCenterStringFontHeightF =    pres@tiYAxisFontHeightF
     pres@gsnRightStringFontHeightF  =    pres@tiYAxisFontHeightF - 0.005
     pres@gsnRightString = syear(ee)+"-"+eyear(ee)+"  "
     pres@gsnLeftString = "" 
     if (wks_type.eq."png") then
        pres@xyLineThicknessF   = 3.5
     else
        pres@xyLineThicknessF   = 1.5
     end if
     pres@gsnCenterString = names(ee)
     if (spectra_mvf.eq.False) then
        pspec(ee) = gsn_csm_xy(wks2,sdof@frq,splt1,pres) 
     
        if (isfilepresent2("obs_ts").and.ee.ge.1.and.spectra_mvf_obs.eq.False) then
           pres@xyLineColors        = (/"gray70","black","black","black"/)
           pres@xyCurveDrawOrder = "PreDraw"
           pres@gsnCenterString = ""
           pres@gsnRightString = ""
           pspec_obs(ee) = gsn_csm_xy(wks2,sdof_obs@frq,sdof_obs@spcx,pres)
           overlay(pspec(ee),pspec_obs(ee)) 
           delete(pres@xyCurveDrawOrder)
        end if     
        delete([/sdof,splt1/])
     end if 
     
     xyres = True
     xyres@gsnDraw = False
     xyres@gsnFrame = False
;     xyres@trYMinF = -.65
;     xyres@trYMaxF = .65
;     xyres@tmYLFormat = "f"
;     xyres@tmYLMode = "Explicit"
;     xyres@tmYLValues = (/-0.5,-0.25,0,0.25,0.5/)
;     xyres@tmYLLabels = (/"-0.5","-0.25","0","0.25","0.5"/)
;     xyres@tmYLMinorValues = fspan(-1,1,41)
     xyres@gsnRightString = ""
     xyres@gsnLeftString = ""
     xyres@gsnFrame = False
     xyres@gsnYRefLine = 0.0
     xyres@gsnYRefLineColor = "gray42"
     xyres@gsnXYBarChart = False
     xyres@gsnAboveYRefLineColor = 185
     xyres@gsnBelowYRefLineColor = 35
     xyres@xyLineThicknessF = 0.1
;     xyres@xyLineColors = (/   xyres@gsnAboveYRefLineColor,   xyres@gsnBelowYRefLineColor/)
     xyres@xyLineColor = "gray70"
     xyres@tiYAxisString = ""
     if (nsim.le.5) then
        xyres@tmXBLabelFontHeightF = 0.0125
        xyres@tmYLLabelFontHeightF = 0.0125
        xyres@gsnStringFontHeightF = 0.017     
     else
        xyres@tmXBLabelFontHeightF = 0.018
        xyres@tmYLLabelFontHeightF = 0.018
        xyres@gsnStringFontHeightF = 0.024
     end if
     xyres@gsnCenterStringOrthogonalPosF = 0.025
     xyres@vpXF = 0.05
     xyres@vpHeightF = 0.15
     if (SCALE_TIMESERIES.eq."True") then
        xyres@vpWidthF = 0.9*((nyr(ee)*1.)/nyr_max)
     else
        xyres@vpWidthF = 0.9
     end if
     xyres@gsnCenterString = ""
     
     xyres@trXMinF = syear(ee)-.5
     xyres@trXMaxF = eyear(ee)+1.5

     xyres@trYMinF = -3.0
     xyres@trYMaxF =  3.0
     
     xyres2 =    xyres
     delete(xyres2@gsnXYBarChart)
     delete(xyres2@gsnAboveYRefLineColor)
     delete(xyres2@gsnBelowYRefLineColor)
;     delete(xyres2@xyLineColors)
     xyres2@xyLineColor = "black"
     if (wks_type.eq."png") then
        xyres2@xyLineThicknessF = 3.5
     else
        xyres2@xyLineThicknessF = 2.5
     end if

     xyres@gsnCenterString = names(ee)
     xyplot(ee) = gsn_csm_xy(wks3,fspan(syear(ee),eyear(ee)+.91667,dimsizes(pc1)),pc1,xyres)   ; use standardized timeseries  
     xyplot2(ee) = gsn_csm_xy(wks3,fspan(syear(ee),eyear(ee)+.91667,dimsizes(pc1)),runave(pc1,61,0),xyres2)
     overlay(xyplot(ee),xyplot2(ee))
     
     delete([/val1,val2,pc1,res,pres,xyres,xyres2/])
  end do

  if (isvar("patcor")) then    ; for pattern correlation table  
     clat = cos(0.01745329*patcor&lat)
     finpr   = "PDO (Monthly)     "    ; Must be 18 characters long
     line3   = "                  "    ; Must be 18 characters long
     line4   = line3
     header = (/"","Pattern Correlations/RMS Differences   Observations vs. Model(s)",""/)
     do hh = 1,nsim-1
        dimY = dimsizes(tochar(names(hh)))
        nchar = dimY
        nchar = where(nchar.le.10,10,nchar)
        if (dimY.lt.10) then
           ntb = ""
           do ii = 0,10-dimY-1
              ntb = ntb+" "
           end do
           ntb = ntb+names(hh)
        else
           ntb = names(hh)
        end if
        
        ntc = ""
        do ii = 0,nchar-1
           ntc = ntc+"-"
        end do
        format2 = "%"+(nchar-5+1)+".2f"
        format3 = "%4.2f"
        line3 = line3+" "+ntb   
        line4 = line4+" "+ntc 
        if (all(ismissing(patcor(hh,:,:)))) then
           finpr = finpr+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
        else
           finpr = finpr+sprintf(format2,(pattern_cor(patcor(0,:,:),patcor(hh,:,:),clat,0)))+"/"+sprintf(format3,(wgt_arearmse(patcor(0,:,:),patcor(hh,:,:),clat,1.0,0)))
        end if
     end do
     if (dimsizes(tochar(line4)).ge.8190) then   ; system or fortran compiler limit
        print("Metrics table warning: Not creating metrics table as size of comparison results in a invalid ascii row size.")   
     else        
        write_table(getenv("OUTDIR")+"metrics.pdo.txt","w",[/header/],"%s")
        write_table(getenv("OUTDIR")+"metrics.pdo.txt","a",[/line3/],"%s")
        write_table(getenv("OUTDIR")+"metrics.pdo.txt","a",[/line4/],"%s")
        write_table(getenv("OUTDIR")+"metrics.pdo.txt","a",[/finpr/],"%s")
     end if
     delete([/finpr,line3,line4,format2,format3,nchar,ntc,clat,patcor,dimY,ntb,header/])
  end if

  panres = True
  panres@gsnMaximize = True
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelLabelBar = True
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@pmLabelBarHeightF = 0.05
  panres@pmLabelBarWidthF = 0.55
  panres@lbTitleOn = False
  panres@lbBoxLineColor = "gray70"
  panres@lbLabelFontHeightF = 0.013
  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres@txFontHeightF = 0.022
        panres@gsnPanelBottom = 0.50
     else
        panres@txFontHeightF = 0.0145
        panres@gsnPanelBottom = 0.50
     end if
  else
     panres@txFontHeightF = 0.016
     panres@gsnPanelBottom = 0.05
  end if
  panres@txString = "PDO (Monthly)"
  if (nsim.le.3) then
    ncol = nsim
    nrow = 1
  else if (nsim.le.6) then
    nrow = 2
    ncol = 3
  else
    ncol = floattointeger(sqrt(nsim))
    nrow = (nsim/ncol)+mod(nsim,ncol)
  end if
  end if
  gsn_panel2(wks,map,(/nrow,ncol/),panres)

  if (tasreg_frame.eq.0) then
     panres@txString = "PDO SST/TAS Regressions (Monthly)" 
     gsn_panel2(wks,map_sst,(/nrow,ncol/),panres)
  end if
  delete(wks)

  if (prreg_frame.eq.0) then
     panres@txString = "PDO PR Regressions (Monthly)" 
     gsn_panel2(wks4,map_prreg,(/nrow,ncol/),panres)
  end if
  delete(wks4)


  delete(panres@gsnPanelLabelBar)
  panres@txString = "PDO (Monthly)"
  gsn_panel2(wks2,pspec,(/nrow,ncol/),panres)  
  delete(wks2)
  
  if (SCALE_TIMESERIES.eq."True") then
     tt = ind(nyr.eq.nyr_max)
     panres@gsnPanelScalePlotIndex = tt(0)
     delete(tt)
  end if
  if (nsim.le.12) then
     lp = (/nsim,1/)
  else
     lp = (/nrow,ncol/)  ;(/nsim/2+1,nsim/8+1/)  
  end if
  panres@txString = "PDO (Monthly)"
  gsn_panel2(wks3,xyplot,lp,panres)  
  delete(wks3)
  delete([/map,pspec,syear,eyear,nyr,nyr_max,lp/])
;--------------------------------------------------------------------------------------------------
  OUTDIR = getenv("OUTDIR") 
  if (wks_type.eq."png") then  
     if (tasreg_frame.eq.0) then  
        system("mv "+OUTDIR+"pdo.000001.png "+OUTDIR+"pdo.png") 
        system("mv "+OUTDIR+"pdo.000002.png "+OUTDIR+"pdo.tasreg.png") 
     end if
  else
     if (tasreg_frame.eq.0) then  
        system("psplit "+OUTDIR+"pdo.ps "+OUTDIR+"pdo_nn")
        system("mv "+OUTDIR+"pdo_nn0001.ps "+OUTDIR+"pdo.ps") 
        system("mv "+OUTDIR+"pdo_nn0002.ps "+OUTDIR+"pdo.tasreg.ps") 
     end if
  end if
  print("Finished: pdo.ncl")
end
    
