; Calculates a variety of pressure indices, as well as hovmollers, spectra, 
; monthly standard deviations, running standard deviations, and spatial
; composites based on the sam index. 
;
; Variables used: ts, psl, and tas
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: psl.indices.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")  
  
  nsim = numAsciiRow("namelist_byvar/namelist_psl")
  na = asciiread("namelist_byvar/namelist_psl",(/nsim/),"string")
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
  delete(na)
  nyr = eyear-syear+1
  nyr_max = max(nyr)
;----------- sam spatial composite coding-------------  
  nsim_ts = numAsciiRow("namelist_byvar/namelist_ts")
  na_ts = asciiread("namelist_byvar/namelist_ts",(/nsim_ts/),"string")
  names_ts = new(nsim_ts,"string")
  paths_ts = new(nsim_ts,"string")
  syear_ts = new(nsim_ts,"integer",-999)
  eyear_ts = new(nsim_ts,"integer",-999)

  do gg = 0,nsim_ts-1
     names_ts(gg) = str_strip(str_get_field(na_ts(gg),1,delim))
     paths_ts(gg) = str_strip(str_get_field(na_ts(gg),2,delim))
     syear_ts(gg) = stringtointeger(str_strip(str_get_field(na_ts(gg),3,delim)))
     eyear_ts(gg) = stringtointeger(str_strip(str_get_field(na_ts(gg),4,delim)))
  end do
  delete(na_ts)
  nyr_ts = eyear_ts-syear_ts+1
    
  nsim_trefht = numAsciiRow("namelist_byvar/namelist_trefht")
  na_trefht = asciiread("namelist_byvar/namelist_trefht",(/nsim_trefht/),"string")
  names_trefht = new(nsim_trefht,"string")
  paths_trefht = new(nsim_trefht,"string")
  syear_trefht = new(nsim_trefht,"integer",-999)
  eyear_trefht = new(nsim_trefht,"integer",-999)

  do gg = 0,nsim_trefht-1
     names_trefht(gg) = str_strip(str_get_field(na_trefht(gg),1,delim))
     paths_trefht(gg) = str_strip(str_get_field(na_trefht(gg),2,delim))
     syear_trefht(gg) = stringtointeger(str_strip(str_get_field(na_trefht(gg),3,delim)))
     eyear_trefht(gg) = stringtointeger(str_strip(str_get_field(na_trefht(gg),4,delim)))
  end do
  delete(na_trefht)
  nyr_trefht = eyear_trefht-syear_trefht+1  

  nsim_prect = numAsciiRow("namelist_byvar/namelist_prect")
  na_prect = asciiread("namelist_byvar/namelist_prect",(/nsim_prect/),"string")
  names_prect = new(nsim_prect,"string")
  paths_prect = new(nsim_prect,"string")
  syear_prect = new(nsim_prect,"integer",-999)
  eyear_prect = new(nsim_prect,"integer",-999)

  do gg = 0,nsim_prect-1
     names_prect(gg) = str_strip(str_get_field(na_prect(gg),1,delim))
     paths_prect(gg) = str_strip(str_get_field(na_prect(gg),2,delim))
     syear_prect(gg) = stringtointeger(str_strip(str_get_field(na_prect(gg),3,delim)))
     eyear_prect(gg) = stringtointeger(str_strip(str_get_field(na_prect(gg),4,delim)))
  end do
  delete(na_prect)
  nyr_prect = eyear_prect-syear_prect+1  
;-------------------------------------------------------------------------------------------------
        
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if
  wks_samind = gsn_open_wks(wks_type,getenv("OUTDIR")+"samind.timeseries")  
  wks_aslind  = gsn_open_wks(wks_type,getenv("OUTDIR")+"aslind.timeseries")

  wks_samlat_tlon = gsn_open_wks(wks_type,getenv("OUTDIR")+"samlat.hov")

  wks_samind_p = gsn_open_wks(wks_type,getenv("OUTDIR")+"samind.powspec")
  
  wks_samind_rst = gsn_open_wks(wks_type,getenv("OUTDIR")+"samind.runstddev")

  wks_samind_mst = gsn_open_wks(wks_type,getenv("OUTDIR")+"samind.monstddev")
  
  wks_samindsc = gsn_open_wks(wks_type,getenv("OUTDIR")+"samind.spatialcomp")

  wks_samindsc_ppt = gsn_open_wks(wks_type,getenv("OUTDIR")+"samind.spatialcomp.ppt")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_samind,"ncl_default") 
     gsn_define_colormap(wks_aslind,"ncl_default")
     gsn_merge_colormaps(wks_samlat_tlon,"cmp_flux",(/"gray30","gray50","gray70"/))
     gsn_define_colormap(wks_samind_p,"cb_9step")
     gsn_define_colormap(wks_samind_rst,"ncl_default")   
     gsn_define_colormap(wks_samind_mst,"ncl_default")   
     gsn_define_colormap(wks_samindsc,"ncl_default")   
     gsn_define_colormap(wks_samindsc_ppt,"MPL_BrBG")  
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_samind,"ncl_default") 
     gsn_define_colormap(wks_aslind,"ncl_default")   
     gsn_merge_colormaps(wks_samlat_tlon,"MPL_rainbow",(/"gray30","gray50","gray70"/))
     gsn_define_colormap(wks_samind_p,"cb_9step")
     gsn_define_colormap(wks_samind_rst,"ncl_default")   
     gsn_define_colormap(wks_samind_mst,"ncl_default")   
     gsn_define_colormap(wks_samindsc,"BlueDarkRed18")   
     gsn_define_colormap(wks_samindsc_ppt,"BrownBlue12")    
  end if

  xysamind = new(nsim,"graphic")
  xyn6  = new(nsim,"graphic")  
  xyn5  = new(nsim,"graphic")  
  xyn4  = new(nsim,"graphic")  
  xyn3  = new(nsim,"graphic")  
  xyn12 = new(nsim,"graphic")  
  xytna = new(nsim,"graphic")  
  xytsa = new(nsim,"graphic") 
  xytio = new(nsim,"graphic")  
  xyiod = new(nsim,"graphic")  
  xysocn = new(nsim,"graphic")  
  xyamm  = new(nsim,"graphic")  
  
  plot_samlat = new(nsim,"graphic")  
  
  map_samindsc_jja0 = new(nsim,"graphic")  
  map_samindsc_son0 = new(nsim,"graphic")  
  map_samindsc_djf1 = new(nsim,"graphic")  
  map_samindsc_mam1 = new(nsim,"graphic")  

  map_samindsc_ppt_jja0 = new(nsim,"graphic")  
  map_samindsc_ppt_son0 = new(nsim,"graphic")  
  map_samindsc_ppt_djf1 = new(nsim,"graphic")  
  map_samindsc_ppt_mam1 = new(nsim,"graphic")  

  xysamind_rst = new(nsim,"graphic")  
  xysamind_mst = new(nsim,"graphic")  
  xysamind_ac = new(nsim,"graphic") 
  plot_wave34 = new(nsim,"graphic")  

  pspec = new(nsim,"graphic")
  if (isfilepresent2("obs_ts")) then
     pspec_obs = new(nsim,"graphic")
     xysamind_ac_obs = new(nsim,"graphic")
  end if

  wgt = (/1.,2.,1./)   
  wgt = wgt/sum(wgt)
  pi=4.*atan(1.0)
  rad=(pi/180.)

  do ee = 0,nsim-1
     psl = data_read_in(paths(ee),"PSL",syear(ee),eyear(ee))    ; read in data, orient lats/lons correctly, set time coordinate variable up
     
     if (isatt(psl,"is_all_missing")) then
        delete(psl)
        continue
     end if
  
     ;;save psl for index calculation   
     psl_org = psl
     d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   ; mask out land
     basemap = d->LSMASK
     lsm = landsea_mask(basemap,psl_org&lat,psl_org&lon)
     pslm = psl_org
     pslm = mask(psl_org,conform(psl_org,lsm,(/1,2/)).ge.1,False)
     delete([/lsm,basemap,d/])

     if (OPT_CLIMO.eq."Full") then
        psl = rmMonAnnCycTLL(psl)
     else
        check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
        temp_arr = psl
        delete(temp_arr&time)
        temp_arr&time = cd_calendar(psl&time,-1)
        if (CLIMO_SYEAR.lt.0) then
           climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))
        else
           climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))
        end if
        delete(temp_arr)
        psl   = calcMonAnomTLL(psl,climo)
        delete(climo)
     end if

     coswgt=cos(rad*pslm&lat)
     coswgt!0 = "lat" 
     coswgt&lat= pslm&lat  

     llats = -65. ; sam index
     llatn = -40.
     llonw = 0.
     llone = 360.

     sam_p40S = wgt_areaave_Wrap(psl_org(:,{llatn:llatn},{llonw:llone}),coswgt({llatn:llatn}),1.0,0)
     sam_p40S@comment_cvdp = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     sam_p40S@units        = psl@units
     sam_p40S@long_name    = "sam psl timeseries at 40S (monthly)"

     sam_p65S= wgt_areaave_Wrap(psl_org(:,{llats:llats},{llonw:llone}),coswgt({llats:llats}),1.0,0)
     sam_p65S@comment_cvdp = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     sam_p65S@units        = psl@units
     sam_p65S@long_name    = "sam psl timeseries at 65S (monthly)"

     samind = dim_standardize(sam_p40S,1) - dim_standardize(sam_p65S,1) 
     copy_VarCoords(sam_p40S,samind)
     samind@comment_cvdp = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     samind@units = "1"
     samind@long_name = "sam (Mashall) index timeseries (monthly)"

     samind_rn = dim_standardize(samind,0)
     copy_VarCoords(samind,samind_rn)
     samind_rn@comment_cvdp = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     samind_rn@units = "1"
     samind_rn@long_name = "Normalized sam (Mashall) index timeseries (monthly)"

     llats = -80.    ; Amundsen Sea Low (ASL) indices,  Hosking et al. [2013] 
     llatn = -60.
     llonw = 170.
     llone = 298.

     asl_rmpsl = wgt_areaave_Wrap(psl(:,{llats:llatn},{llonw:llone}),coswgt({llats:llatn}),1.0,0)
     asl_rmpsl@comment_cvdp  = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     asl_rmpsl@units  = psl@units
     asl_rmpsl@long_name = "Amundsen Sea Low (ASL) region mean pressure timeseries (monthly)"

     asl_clat = asl_rmpsl
     asl_clat@comment_cvdp  = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     asl_clat@units  = "degree"
     asl_clat@long_name = "Amundsen Sea Low (ASL) latitude"

     asl_clon  = asl_rmpsl
     asl_clon@comment_cvdp  = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     asl_clon@units  = "degree"
     asl_clon@long_name = "Amundsen Sea Low (ASL) center longitude"

     asl_cpsl  = asl_rmpsl
     asl_cpsl@comment_cvdp  = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     asl_cpsl@units = psl@units
     asl_cpsl@long_name = "Amundsen Sea Low (ASL) central pressure timeseries (monthly)"

     asl_rcpsl = asl_rmpsl
     asl_rcpsl@comment_cvdp  = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     asl_rcpsl@units = psl@units
     asl_rcpsl@long_name = "Amundsen Sea Low (ASL) relative central pressure timeseries (monthly)"

     aslind = asl_rmpsl
     aslind@comment_cvdp = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
     aslind@units        = "1"
     aslind@long_name    = "Amundsen Sea Low (ASL) central pressure standardized timeseries (monthly)"
    
     ;;loop and calculate the ASL indices 
     do gg = 0,dimsizes(asl_rmpsl&time)-1
       vsec  = smth9_Wrap(pslm(gg,{llats:llatn},{llonw:llone}),0.50, -0.25, False)
       vsec@_FillValue = psl@_FillValue 
       vsec  = vsec - asl_rmpsl(gg)
       vsec  = vsec * -1.0
       lat   = vsec&lat
       lon   = vsec&lon
       lnmin = local_max(vsec,False,0.)
       if(lnmin .gt. 0) then
         lind  = minind(lnmin@maxval)
         ii = lnmin@yi(lind)
         jj = lnmin@xi(lind)
         vv = lnmin@maxval(lind) * -1.0
         asl_clat(gg) = tofloat(lat(ii))
         asl_clon(gg) = tofloat(lon(jj))
         asl_cpsl(gg) = vv + asl_rmpsl(gg)
         delete([/ii,jj,vv,lind/])
       else
         a1D      = ndtooned(vsec)
         dsizes_a = dimsizes(vsec)
         a1D@_FillValue = vsec@_FillValue
         indx  = ind_resolve(maxind(a1D),dsizes_a)
         ii = indx(0,0)
         jj = indx(0,1)
         asl_clat(gg) = tofloat(lat(ii))
         asl_clon(gg) = tofloat(lon(jj))
         asl_cpsl(gg) = -vsec(ii,jj) + asl_rmpsl(gg)
         delete([/ii,jj,a1D,dsizes_a,indx/])
       end if
       delete([/lnmin,vsec,lat,lon/])
     end do
     asl_rcpsl = asl_cpsl - asl_rmpsl 
     aslind    = dim_standardize(asl_cpsl,0)
     delete([/coswgt,psl_org,pslm/])   

;---------------------------------------------------------------------------------------------     
     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.psl.indices."+syear(ee)+"-"+eyear(ee)+".nc"
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
           date = cd_calendar(samind&time,-1)
           date@long_name = "current date (YYYYMM)"
           delete(date@calendar)
           date!0 = "time"
           date&time = samind&time
           date@units = "1"
           z->date = date
           delete(date)
        else
           z = addfile(fn,"w")
        end if
        z->samind    = set_varAtts(samind,"","","")
        z->aslind    = set_varAtts(aslind,"","","")
        z->samind_rn = set_varAtts(samind_rn,"","","")
        z->sam_p40S  = set_varAtts(sam_p40S,"","","")
        z->sam_p65S  = set_varAtts(sam_p65S,"","","")
        z->asl_clat  = set_varAtts(asl_clat,"","","")
        z->asl_clon  = set_varAtts(asl_clon,"","","")
        z->asl_rmpsl = set_varAtts(asl_rmpsl,"","","")
        z->asl_rcpsl = set_varAtts(asl_rcpsl,"","","")
        z->asl_cpsl  = set_varAtts(asl_cpsl,"","","")
        delete([/modname,fn/])
     end if

;---------------------------------------------------------------------------------------------
     if (nyr(ee).ge.15) then   ; 15+ years needed for this metric
        finpsl              = psl(:,0,:)
        finpsl              = psl@_FillValue 
        finpsl@long_name    = "SAM Latitude Position"
        finpsl@units        = "degree"
        finpsl_mave         = finpsl(lon|0:2,time|:) 
        finpsl_tave         = finpsl(time|0:2,lon|:) 

        pslr = psl
        pslr = psl@_FillValue 
        do gg = 30,dimsizes(samind_rn)-31
          mocntr1 = gg - 30  
          mocntr2 = gg + 30
          pslr(gg,:,:) = escovc(samind_rn(time|mocntr1:mocntr2), psl({lat|:},{lon|:},time|mocntr1:mocntr2)) 
          vsec = pslr(gg,{-90:-20},:) 
          vsec = abs(vsec)
          ;SAM latitude is search as location with smallest absolute covariance (Paul Wachter et al., 2020)
          mind = dim_minind(vsec,0)
          do hh = 0,dimsizes(vsec(0,:))-1
            finpsl(gg,hh) =  tofloat(vsec&lat(mind(hh)))
          end do 
          delete([/vsec,mocntr1,mocntr2,mind/])
        end do

        ; apply a smoothing to reduce noise  
        finpsl_sm = smth9(finpsl, 0.50,  0.25, True)
        finpsl_sm = where(abs(finpsl_sm).ge.89,finpsl,finpsl_sm)
        finpsl    = (/finpsl_sm/) 
        delete([/finpsl_sm/])

        ;calculate the zonal and time  average and varibility 
        finpsl_mave(0,:) = dim_avg_n(finpsl,1)
        finpsl_mave(1,:) = dim_min_n(finpsl,1)
        finpsl_mave(2,:) = dim_max_n(finpsl,1)
        finpsl_tave(0,:) = dim_avg_n(finpsl,0)
        finpsl_tave(1,:) = dim_min_n(finpsl,0)
        finpsl_tave(2,:) = dim_max_n(finpsl,0)
        delete([/pslr/])
        
        if (OUTPUT_DATA.eq."True") then 
           hov_all = (/ finpsl /)  
           time_mon1 = cd_calendar(psl&time,1) 
           time_mon1@long_name = "Time"
           time_mon1@standard_name = "time"
           time_mon1@calendar = "standard"
           time_mon1!0 = "time_mon1"
           time_mon1&time_mon1 = time_mon1
           hov_all!0 = "time_mon1"
           hov_all&time_mon1 = time_mon1
           lon1 = finpsl&lon
           lon1@standard_name = "longitude"
           hov_all!1    = "lon1"
           hov_all&lon1 = lon1
           hov_all@_FillValue = finpsl@_FillValue 
           delete([/time_mon1,lon1/])
           hov_mave = (/ finpsl_mave /)  
           hov_tave = (/ finpsl_tave /)
           hov_mave!0 = "nx"
           hov_mave!1 = "time_mon1"
           hov_mave&time_mon1 = hov_all&time_mon1
           hov_tave!0 = "nx"
           hov_mave!1 = "lon1"
           hov_mave&lon1  = hov_all&lon1 
           hov_all@units  = "degree"
           hov_mave@units = "degree"
           hov_tave@units = "degree"
           z->samlat_hov_all  = set_varAtts(hov_all, "SAM latitude Hovmoller (time-lon)","","")
           z->samlat_hov_mave = set_varAtts(hov_mave,"SAM latitude time series (lon mean)","","")
           z->samlat_hov_tave = set_varAtts(hov_tave,"SAM latitude meridional series (time mean)","","")
           delete([/hov_mave,hov_tave,hov_all/])
        end if
     end if     

;- - - - - -samind spatial composite section- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     samindT         = wgt_runave(samind,wgt,1)               ; for use in SAM composites / running standard deviations
     samind_jja      = samindT(6:dimsizes(samindT)-13:12)  ; cannot count last 1yr as spatial composite uses +1yrs data betond JAS..
     samind_jja!0    = "time"
     samind_jja&time = ispan(syear(ee),eyear(ee)-1,1)
     samind_jja      = dtrend_msg(ispan(0,dimsizes(samind_jja&time)-1,1),samind_jja,True,False)
     samind_jja      = dim_standardize(samind_jja,0)

     if (any(ismissing((/syear(ee),syear_trefht(ee),syear_ts(ee),eyear(ee),eyear_trefht(ee),eyear_ts(ee)/)))) then
        tassstreg_plot_flag = 1
     else 
        if (syear(ee).eq.syear_trefht(ee).and.syear(ee).eq.syear_ts(ee)) then     ; check that the start and end years match for ts, trefht, and psl
           if (eyear(ee).eq.eyear_trefht(ee).and.eyear(ee).eq.eyear_ts(ee)) then
              tassstreg_plot_flag = 0
           else
              tassstreg_plot_flag = 1
           end if
        else
           tassstreg_plot_flag = 1
        end if
     end if

     if (tassstreg_plot_flag.eq.0) then
        tas = data_read_in(paths_trefht(ee),"TREFHT",syear_trefht(ee),eyear_trefht(ee))
        sst = data_read_in(paths_ts(ee),"TS",syear_ts(ee),eyear_ts(ee))

        sst = where(sst.le.-1.8,-1.8,sst)    ; set all values below -1.8 to -1.8
        d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   ; mask out land (this is redundant for data that is already masked)
        basemap = d->LSMASK
        lsm = landsea_mask(basemap,sst&lat,sst&lon)
        sst = mask(sst,conform(sst,lsm,(/1,2/)).ge.1,False)
        delete([/lsm,basemap/])
        delete(d)

        TIME = psl&time
        yyyymm = cd_calendar(psl&time,-1)  ; convert tas, ts, and psl from CF-conforming time to YYYYMM for coding below
        delete(psl&time)
        psl&time = yyyymm 
        delete(yyyymm)

        yyyymm = cd_calendar(tas&time,-1)  
        delete(tas&time)
        tas&time = yyyymm 
        delete(yyyymm)

        yyyymm = cd_calendar(sst&time,-1) 
        delete(sst&time)
        sst&time = yyyymm 
        delete(yyyymm)

        if (isatt(tas,"is_all_missing").or.isatt(sst,"is_all_missing")) then
           tassstreg_plot_flag = 1
           delete([/tas,psl/])
        end if
        
        if (nyr(ee).lt.15) then   ; 15+ years needed for composites
           tassstreg_plot_flag = 1
        end if

        if (tassstreg_plot_flag.eq.0) then     ; only continue if all 3 fields are present
           if (OPT_CLIMO.eq."Full") then
              tas = rmMonAnnCycTLL(tas)
              sst = rmMonAnnCycTLL(sst)           
           else
              check_custom_climo(names_trefht(ee),syear_trefht(ee),eyear_trefht(ee),CLIMO_SYEAR,CLIMO_EYEAR)
              if (CLIMO_SYEAR.lt.0) then
                 climo = clmMonTLL(tas({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
              else
                 climo = clmMonTLL(tas({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
              end if            
              tas   = calcMonAnomTLL(tas,climo) 
              delete(climo)
           
              check_custom_climo(names_ts(ee),syear_ts(ee),eyear_ts(ee),CLIMO_SYEAR,CLIMO_EYEAR)
              if (CLIMO_SYEAR.lt.0) then
                 climo = clmMonTLL(sst({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
              else
                 climo = clmMonTLL(sst({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
              end if  
              sst   = calcMonAnomTLL(sst,climo) 
              delete(climo)
           end if
           tas = (/ dtrend_msg_n(ispan(0,dimsizes(tas&time)-1,1),tas,False,False,0) /)     ; psl detrended up above
           sst = (/ dtrend_msg_n(ispan(0,dimsizes(sst&time)-1,1),sst,False,False,0) /)  
        
           ta = dim_avg_n(sst(:1,:,:),0)
           sst = runave_n_Wrap(sst,3,0,0)
           sst(0,:,:) = (/ ta /)
           delete(ta)
        
           ta = dim_avg_n(psl(:1,:,:),0)
           psl = runave_n_Wrap(psl,3,0,0)
           psl(0,:,:) = (/ ta /)
           delete(ta)
        
           ta = dim_avg_n(tas(:1,:,:),0)
           tas = runave_n_Wrap(tas,3,0,0)
           tas(0,:,:) = (/ ta /)
           delete(ta)
        
           hicntr = 0
           locntr = 0
           hiyr = new(dimsizes(samind_jja&time),integer)
           loyr = hiyr

           do hh = 0,dimsizes(samind_jja)-1
              if (.not.ismissing(samind_jja(hh))) then
                 if (samind_jja(hh).ge.0.75) then
                    hiyr(hicntr) = samind_jja&time(hh)
                    hicntr = hicntr+1
                 end if
                 if (samind_jja(hh).le.-0.75) then
                    loyr(locntr) = samind_jja&time(hh)
                    locntr = locntr+1
                 end if
              end if
           end do
 
           if (hicntr.eq.0) then     ; for simulations with climatological SSTs
              highyr = hiyr(0)
           else
              highyr = hiyr(:hicntr-1)
           end if
           delete([/hiyr,hicntr/])
           if (locntr.eq.0) then
              lowyr = loyr(0)
           else
              lowyr = loyr(:locntr-1)
           end if
           delete([/loyr,locntr/])
        
           dimS = dimsizes(psl&time)    ; change time from YYYYMM->YYYY.frac
           tmin = psl&time(0)/100
           tmax = psl&time(dimS-1)/100
           delete(psl&time)
           psl&time = fspan(tmin*1.,(tmax*1.)+(11/12.),dimS)
           dimS = dimsizes(tas&time)
           tmin = tas&time(0)/100
           tmax = tas&time(dimS-1)/100
           delete(tas&time)
           tas&time = fspan(tmin*1.,(tmax*1.)+(11/12.),dimS)
           dimS = dimsizes(sst&time)
           tmin = sst&time(0)/100
           tmax = sst&time(dimS-1)/100
           delete(sst&time)
           sst&time = fspan(tmin*1.,(tmax*1.)+(11/12.),dimS)
           delete([/dimS,tmin,tmax/])
           ; print(psl&time)
        
           sc_tas_hi = tas(:23,:,:)
           sc_tas_lo = tas(:23,:,:)    
           sc_sst_hi = sst(:23,:,:)
           sc_sst_lo = sst(:23,:,:)  
           sc_psl_hi = psl(:23,:,:)
           sc_psl_lo = psl(:23,:,:)  
           
           sc_tas_hi = sc_tas_hi@_FillValue
           sc_tas_lo = sc_tas_lo@_FillValue
           sc_sst_hi = sc_sst_hi@_FillValue
           sc_sst_lo = sc_sst_lo@_FillValue
           sc_psl_hi = sc_psl_hi@_FillValue
           sc_psl_lo = sc_psl_lo@_FillValue
           
           if (dimsizes(highyr).le.1) then
              print("For "+names(ee)+", 1 or less (normalized) samind value greater than one standard deviation found, setting samind spatial composites to missing")  ; sc_*_hi arrays left to _FillValue
           else           
              do gg = 0,23
                 tt = gg/12.
                 sc_psl_hi(gg,:,:) = (/ dim_avg_n(psl({highyr+tt},:,:),0) /)
                 sc_sst_hi(gg,:,:) = (/ dim_avg_n(sst({highyr+tt},:,:),0) /)    
                 sc_tas_hi(gg,:,:) = (/ dim_avg_n(tas({highyr+tt},:,:),0) /)
              end do
              delete(tt)
           end if
           delete(highyr)
           if (dimsizes(lowyr).le.1) then
              print("For "+names(ee)+", 1 or less (normalized) samind value less than -1 standard deviation found, setting samind spatial composites to missing")   ; sc_*_lo arrays left to _FillValue
           else           
              do gg = 0,23
                 tt = gg/12.
                 sc_psl_lo(gg,:,:) = (/ dim_avg_n(psl({lowyr+tt},:,:),0) /)
                 sc_sst_lo(gg,:,:) = (/ dim_avg_n(sst({lowyr+tt},:,:),0) /)     
                 sc_tas_lo(gg,:,:) = (/ dim_avg_n(tas({lowyr+tt},:,:),0) /)
              end do
              delete(tt)
           end if
           delete(lowyr)
           
           samindsc_psl = sc_psl_hi
           samindsc_psl = (/ sc_psl_hi - sc_psl_lo /)
           samindsc_sst = sc_sst_hi
           samindsc_sst = (/ sc_sst_hi - sc_sst_lo /)
           samindsc_tas = sc_tas_hi
           samindsc_tas = (/ sc_tas_hi - sc_tas_lo /)
           delete([/sc_psl_hi,sc_psl_lo,sc_sst_hi,sc_sst_lo,sc_tas_hi,sc_tas_lo/])
           delete(psl&time)
           psl&time = TIME    
           delete(TIME)       
                      
           if (OUTPUT_DATA.eq."True") then
              samindsc_psl&lat@standard_name = "latitude"
              samindsc_psl&lon@standard_name = "longitude"
              z->samind_spacomp_psl_jja0 = set_varAtts(samindsc_psl(6,:,:),"samind psl spatial composite (JJA+0)","","")
              z->samind_spacomp_psl_son0 = set_varAtts(samindsc_psl(9,:,:),"samind psl spatial composite (SON+0)","","")
              z->samind_spacomp_psl_djf1 = set_varAtts(samindsc_psl(12,:,:),"samind psl spatial composite (DJF+1)","","")
              z->samind_spacomp_psl_mam1 = set_varAtts(samindsc_psl(15,:,:),"samind psl spatial composite (MAM+1)","","")

              modname = str_sub_str(names_trefht(ee)," ","_")
              bc = (/"/","'","(",")"/)
              do gg = 0,dimsizes(bc)-1
                 modname = str_sub_str(modname,bc(gg),"_")
              end do
              fn = getenv("OUTDIR")+modname+".cvdp_data.psl.psl.indices.tas."+syear_trefht(ee)+"-"+eyear_trefht(ee)+".nc"
              if (.not.isfilepresent2(fn)) then
                 z_tas = addfile(fn,"c")
                 z_tas@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
                 z_tas@notes = "Data from "+names_trefht(ee)+" from "+syear_trefht(ee)+"-"+eyear_trefht(ee)
                 if (OPT_CLIMO.eq."Full") then
                    z_tas@climatology = syear_trefht(ee)+"-"+eyear_trefht(ee)+" climatology removed prior to all calculations (other than means)"
                 else
                    if (CLIMO_SYEAR.lt.0) then
                       z_tas@climatology = (eyear(ee)+CLIMO_SYEAR)+"-"+(eyear(ee)+CLIMO_EYEAR)+" climatology removed prior to all calculations (other than means)"
                    else
                       z_tas@climatology = CLIMO_SYEAR+"-"+CLIMO_EYEAR+" climatology removed prior to all calculations (other than means)"
                    end if
                 end if
              else
                 z_tas = addfile(fn,"w")
              end if
              z_tas->samind_spacomp_tas_jja0 = set_varAtts(samindsc_tas(6,:,:),"samind tas spatial composite (JJA+0)","","")   
              z_tas->samind_spacomp_tas_son0 = set_varAtts(samindsc_tas(9,:,:),"samind tas spatial composite (SON+0)","","") 
              z_tas->samind_spacomp_tas_djf1 = set_varAtts(samindsc_tas(12,:,:),"samind tas spatial composite (DJF+1)","","") 
              z_tas->samind_spacomp_tas_mam1 = set_varAtts(samindsc_tas(15,:,:),"samind tas spatial composite (MAM+1)","","") 
              delete(z_tas)
              delete(modname)
              
              modname = str_sub_str(names_ts(ee)," ","_")
              bc = (/"/","'","(",")"/)
              do gg = 0,dimsizes(bc)-1
                 modname = str_sub_str(modname,bc(gg),"_")
              end do
              fn = getenv("OUTDIR")+modname+".cvdp_data.psl.indices.sst."+syear_trefht(ee)+"-"+eyear_trefht(ee)+".nc"
              if (.not.isfilepresent2(fn)) then
                 z_sst = addfile(fn,"c")
                 z_sst@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
                 z_sst@notes = "Data from "+names_trefht(ee)+" from "+syear_trefht(ee)+"-"+eyear_trefht(ee)
                 if (OPT_CLIMO.eq."Full") then
                    z_sst@climatology = syear_trefht(ee)+"-"+eyear_trefht(ee)+" climatology removed prior to all calculations (other than means)"
                 else
                    if (CLIMO_SYEAR.lt.0) then
                       z_sst@climatology = (eyear(ee)+CLIMO_SYEAR)+"-"+(eyear(ee)+CLIMO_EYEAR)+" climatology removed prior to all calculations (other than means)"
                    else
                       z_sst@climatology = CLIMO_SYEAR+"-"+CLIMO_EYEAR+" climatology removed prior to all calculations (other than means)"
                    end if
                 end if
                 z@Conventions = "CF-1.6"
              else
                 z_sst = addfile(fn,"w")
              end if
              z_sst->samind_spacomp_sst_jja0 = set_varAtts(samindsc_sst(6,:,:),"samind sst spatial composite (JJA+0)","","")   
              z_sst->samind_spacomp_sst_son0 = set_varAtts(samindsc_sst(9,:,:),"samind sst spatial composite (SON+0)","","")   
              z_sst->samind_spacomp_sst_djf1 = set_varAtts(samindsc_sst(12,:,:),"samind sst spatial composite (DJF+1)","","")   
              z_sst->samind_spacomp_sst_mam1 = set_varAtts(samindsc_sst(15,:,:),"samind sst spatial composite (MAM+1)","","")   
              delete(z_sst)
              delete(modname)
           end if
        end if
     end if
     if (isvar("TIME")) then
        delete(TIME)
     end if
     if (isvar("sst")) then
        delete(sst)
     end if
     if (isvar("tas")) then
        delete(tas)
     end if
;-------------samind composite (precipitation)-----------------------------------------------------
     if (any(ismissing((/syear(ee),syear_prect(ee),eyear(ee),eyear_prect(ee)/)))) then
        pptreg_plot_flag = 1
     else
        if (syear(ee).eq.syear_prect(ee)) then     ; check that the start and end years match for ts, trefht, and psl
           if (eyear(ee).eq.eyear_prect(ee)) then
              pptreg_plot_flag = 0
           else
              pptreg_plot_flag = 1
           end if
        else
           pptreg_plot_flag = 1
        end if
     end if

     if (pptreg_plot_flag.eq.0) then
        ppt = data_read_in(paths_prect(ee),"PRECT",syear_prect(ee),eyear_prect(ee))

        yyyymm = cd_calendar(ppt&time,-1) ; convert ppt from CF-conforming time to YYYYMM for coding below
        delete(ppt&time)
        ppt&time = yyyymm 
        delete(yyyymm)

        if (isatt(ppt,"is_all_missing")) then
           pptreg_plot_flag = 1
           delete(ppt)
        end if
        
        if (nyr(ee).lt.15) then   ; 15+ years needed for composites
           pptreg_plot_flag = 1
        end if

        if (pptreg_plot_flag.eq.0) then     ; only continue if all 3 fields are present
         ;  d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")     ; mask ocean for TAS array
         ;  basemap = d->LSMASK                                              ; This is now done right before plotting.
         ;  lsm = landsea_mask(basemap,tas&lat,tas&lon)                      ; so that the entire TAS array is used
         ;  tas = mask(tas,conform(tas,lsm,(/1,2/)).eq.0,False)              ; in the samind pattern correlations
         ;  delete([/lsm,basemap/])                                          ; (Even if the land portion of TAS is the
         ;  delete(d)                                                        ; only portion plotted as SST shown over oceans.)

           if (OPT_CLIMO.eq."Full") then
              ppt = rmMonAnnCycTLL(ppt)           
           else
              check_custom_climo(names_prect(ee),syear_prect(ee),eyear_prect(ee),CLIMO_SYEAR,CLIMO_EYEAR)
              if (CLIMO_SYEAR.lt.0) then
                 climo = clmMonTLL(ppt({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))       
              else
                 climo = clmMonTLL(ppt({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))                 
              end if  
              ppt   = calcMonAnomTLL(ppt,climo) 
              delete(climo)
           end if
           ppt = (/ dtrend_msg_n(ispan(0,dimsizes(ppt&time)-1,1),ppt,False,False,0) /)  

           ta = dim_avg_n(ppt(:1,:,:),0)
           ppt = runave_n_Wrap(ppt,3,0,0)
           ppt(0,:,:) = (/ ta /)
           delete(ta)
        
           hicntr = 0
           locntr = 0
           hiyr = new(dimsizes(samind_jja&time),integer)
           loyr = hiyr

           do hh = 0,dimsizes(samind_jja)-1
              if (.not.ismissing(samind_jja(hh))) then
                 if (samind_jja(hh).ge.1) then
                    hiyr(hicntr) = samind_jja&time(hh)
                    hicntr = hicntr+1
                 end if
                 if (samind_jja(hh).le.-1) then
                    loyr(locntr) = samind_jja&time(hh)
                    locntr = locntr+1
                 end if
              end if
           end do
 
           if (hicntr.eq.0) then     ; for simulations with climatological SSTs
              highyr = hiyr(0)
           else
              highyr = hiyr(:hicntr-1)
           end if
           delete([/hiyr,hicntr/])
           if (locntr.eq.0) then
              lowyr = loyr(0)
           else
              lowyr = loyr(:locntr-1)
           end if
           delete([/loyr,locntr/])
        
           dimS = dimsizes(ppt&time)    ; change time from YYYYMM->YYYY.frac
           tmin = ppt&time(0)/100
           tmax = ppt&time(dimS-1)/100
           delete(ppt&time)
           ppt&time = fspan(tmin*1.,(tmax*1.)+(11/12.),dimS)
           delete([/dimS,tmin,tmax/])
        
           sc_ppt_hi = ppt(:23,:,:)
           sc_ppt_lo = ppt(:23,:,:)  
        
           sc_ppt_hi = sc_ppt_hi@_FillValue
           sc_ppt_lo = sc_ppt_lo@_FillValue
           
           if (dimsizes(highyr).le.1) then
              print("For "+names(ee)+", 1 or less (normalized) samind value greater than one standard deviation found, setting samind spatial composites to missing")  ; sc_*_hi arrays left to _FillValue
           else           
              do gg = 0,23
                 tt = gg/12.
                 sc_ppt_hi(gg,:,:) = (/ dim_avg_n(ppt({highyr+tt},:,:),0) /)
              end do
              delete(tt)
           end if
           delete(highyr)
           if (dimsizes(lowyr).le.1) then
              print("For "+names(ee)+", 1 or less (normalized) samind value less than -1 standard deviation found, setting samind spatial composites to missing")   ; sc_*_lo arrays left to _FillValue
           else           
              do gg = 0,23
                 tt = gg/12.
                 sc_ppt_lo(gg,:,:) = (/ dim_avg_n(ppt({lowyr+tt},:,:),0) /)
              end do
              delete(tt)
           end if
           delete(lowyr)
           
           samindsc_ppt = sc_ppt_hi
           samindsc_ppt = (/ sc_ppt_hi - sc_ppt_lo /)
           delete([/sc_ppt_hi,sc_ppt_lo/])     
                      
           if (OUTPUT_DATA.eq."True") then
              modname = str_sub_str(names_prect(ee)," ","_")
              bc = (/"/","'","(",")"/)
              do gg = 0,dimsizes(bc)-1
                 modname = str_sub_str(modname,bc(gg),"_")
              end do
              fn = getenv("OUTDIR")+modname+".cvdp_data.psl.indices.ppt."+syear_trefht(ee)+"-"+eyear_trefht(ee)+".nc"
              if (.not.isfilepresent2(fn)) then
                 z_ppt = addfile(fn,"c")
                 z_ppt@source = "NCAR Climate Analysis Section's Climate Variability Diagnostics Package v"+getenv("VERSION")
                 z_ppt@notes = "Data from "+names_trefht(ee)+" from "+syear_trefht(ee)+"-"+eyear_trefht(ee)
                 if (OPT_CLIMO.eq."Full") then
                    z_ppt@climatology = syear_trefht(ee)+"-"+eyear_trefht(ee)+" climatology removed prior to all calculations (other than means)"
                 else
                    if (CLIMO_SYEAR.lt.0) then
                       z_ppt@climatology = (eyear(ee)+CLIMO_SYEAR)+"-"+(eyear(ee)+CLIMO_EYEAR)+" climatology removed prior to all calculations (other than means)"
                    else
                       z_ppt@climatology = CLIMO_SYEAR+"-"+CLIMO_EYEAR+" climatology removed prior to all calculations (other than means)"
                    end if
                 end if
                 z@Conventions = "CF-1.6"
              else
                 z_ppt = addfile(fn,"w")
              end if
              z_ppt->samind_spacomp_pr_jja0 = set_varAtts(samindsc_ppt(6,:,:),"samind pr spatial composite (JJA+0)","","")      
              z_ppt->samind_spacomp_pr_son0 = set_varAtts(samindsc_ppt(9,:,:),"samind pr spatial composite (SON+0)","","")
              z_ppt->samind_spacomp_pr_djf1 = set_varAtts(samindsc_ppt(12,:,:),"samind pr spatial composite (DJF+1)","","")
              z_ppt->samind_spacomp_pr_mam1 = set_varAtts(samindsc_ppt(15,:,:),"samind pr spatial composite (MAM+1)","","")
              delete(z_ppt)
              delete(modname)
           end if
        end if
     end if
     if (isvar("TIME")) then
        delete(TIME)
     end if
     if (isvar("ppt")) then
        delete(ppt)
     end if
     delete([/psl,samind_jja/])
;-----------------------------------------------------------------------------------------     
     if (nyr(ee).ge.20) then    ; need a minimum number of years to compute running samind standard deviations
        samindT = dtrend_msg(ispan(0,dimsizes(samindT)-1,1),samindT,True,False)
        samindT!0 = "time"
        samindT&time = samind&time
        sd_run = samindT
        sd_run = sd_run@_FillValue
        sd_run@units = samind@units
        sd_run@long_name = "samind 15yr running standard deviation"
        do gg = 90,dimsizes(samindT)-90
           sd_run(gg) = (/ dim_stddev(samindT(gg-90:gg+89)) /)
        end do
        if (OUTPUT_DATA.eq."True") then
           z->samind_runstddev = set_varAtts(sd_run,"","","")
        end if
     end if
     delete(samindT)
;-----------------------------------------------------------------------------------------
     iopt = 0                ; samind power spectra
     jave = (7*nyr(ee))/100
     val1 = .95
     val2 = .99
     pct = 0.1 
     spectra_mvf = False        ; missing value flag for samind
     if (any(ismissing(samind))) then     ; check for missing data                                                            
        print("Missing data detected for "+names(ee)+", not creating spectra in psl.indices.ncl") 
        spectra_mvf = True
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           spectra_mvf_obs = True
        end if
     else
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           spectra_mvf_obs = False   ; missing value flag for obs samind
        end if
        samind_dt = dtrend_msg(ispan(0,dimsizes(samind)-1,1),samind,True,False) 
    
        sdof = specx_anal(samind_dt,iopt,jave,pct)
        mval = sum(1/(1.+((sdof@xlag1)^2)-((2*sdof@xlag1)*cos(6.28318*sdof@frq))))
        if (mval.eq.0) then ; check for cyclic data that results in sum of Markov elements = 0.
           spectra_mvf = True
           if (isfilepresent2("obs_ts").and.ee.eq.0) then
              spectra_mvf_obs = True   ; missing value flag for obs samind
           end if
        else
           splt1 = specx_ci(sdof,val1,val2)
           if (OUTPUT_DATA.eq."True") then
              splt1!0 = "ncurves"
              splt1&ncurves = ispan(0,3,1)
              splt1&ncurves@long_name = "power spectra curves"
              splt1&ncurves@units = "1"
              splt1!1 = "frequency"
              splt1&frequency = sdof@frq
              splt1&frequency@long_name = "power spectra frequency"
              splt1&frequency@units = "1"
              splt1@units_info = "df refers to frequency interval"
              splt1@units = "hPa^2/df"
              splt1@comment_cvdp = "(0,:)=spectrum,(1,:)=Markov red noise spectrum, (2,:)="+val1+"% confidence bound for Markhov, (3,:)="+val2+"% confidence bound for Markhov"
              z->samind_spectra = set_varAtts(splt1,"samind power spectra","","")
           end if
           if (isfilepresent2("obs_ts").and.ee.eq.0) then
              sdof_obs = sdof
           end if
        end if
        delete([/samind_dt,iopt,jave,pct,mval/])
     end if
;------------------------------------------------------------------------------------------
     samind_dt = dtrend_msg(ispan(0,dimsizes(samind&time)-1,1),samind,True,False)
     samind_mon_sd = new(12,typeof(samind))
     
     do hh = 0,11
        samind_mon_sd(hh) = (/ dim_stddev(samind_dt(hh::12)) /)
     end do
     samind_mon_sd@units = "C"
     if (OUTPUT_DATA.eq."True") then
        time_mon2 = ispan(0,11,1)
        time_mon2@units = "months since 0000-01-01 00:00:00"
        time_mon2@long_name = "Time"
        time_mon2@standard_name = "time"
        time_mon2@calendar = "standard"
        time_mon2!0 = "time_mon2"
        time_mon2&time_mon2 = time_mon2
        samind_mon_sd!0 = "time_mon2"
        samind_mon_sd&time_mon2 = time_mon2
        z->samind_monthly_stddev = set_varAtts(samind_mon_sd,"samind monthly standard deviation","","")
        delete(time_mon2)
     end if
;------------------------------------------------------------------------------------------
;    samind wavelet analysis, autocorrelation

     if (spectra_mvf.eq.False) then
        N       = dimsizes(samind)       
        mother  = 0
        param   = 6.0
        dt      = 1./12.            
        s0      = dt
        dj      = 1./12.
        jtot    = 1+floattointeger(((log10(N*dt/s0))/dj)/log10(2.))
        npad    = N
        nadof   = 0
        noise   = 1 
        siglvl  = .05
        isigtest= 0
        wave34 = wavelet(samind,mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)

        power34            = onedtond(wave34@power,(/jtot,N/))
        power34!0          = "period"                    
        power34&period     = wave34@period
        power34&period@long_name = "wavelet period"
        power34&period@units = "1"
        power34!1          = "time"                     
        power34&time       = samind&time
        power34@units      = samind@units+"^2"

        sig34              = power34                       
        sig34              = power34/conform (power34,wave34@signif,0)
        sig34@long_name    = "wavelet significance"
        sig34@units        = ""
        delete([/N,mother,param,dt,s0,dj,jtot,npad,nadof,noise,siglvl,isigtest/])

        ac34 = esacr(samind_dt,48)
        time_mon3 = ispan(0,48,1)
        time_mon3@units = "months since 0000-01-01 00:00:00"
        time_mon3@long_name = "Time"
        time_mon3@standard_name = "time"
        time_mon3@calendar = "standard"
        time_mon3!0 = "time_mon3"
        time_mon3&time_mon3 = time_mon3
        ac34!0 = "time_mon3"
        ac34&time_mon3 = time_mon3
        ac34@units = "1"
        if (OUTPUT_DATA.eq."True") then
           z->samind_wavelet_power = set_varAtts(power34,"samind wavelet power","","")
           z->samind_wavelet_significance = set_varAtts(sig34,"samind wavelet significance","","")
           z->samind_autocorrelation = set_varAtts(ac34,"samind autocorrelation","","")
        end if
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           ac34_obs = ac34
        end if
     end if
     delete(samind_dt)    
     if (isvar("z")) then
        delete(z)
     end if
;==========================================================================================
     xyres = True
     xyres@gsnDraw = False
     xyres@gsnFrame = False
     xyres@gsnRightString = ""
     xyres@gsnLeftString = ""
     xyres@gsnYRefLine      := 0.0
     xyres@gsnYRefLineColor := "gray42"
     xyres@xyLineColor := "Black" ;"gray62"
     if (wks_type.eq."png") then
        xyres@xyLineThicknessF := .75  * 3.0 
     else
        xyres@xyLineThicknessF := .5   * 3.0
     end if   
     xyres@tiYAxisString   = ""
     xyres@tiXAxisString  = "Time"      ; add an axis title

     if (nsim.le.5) then
        xyres@tmXBLabelFontHeightF = 0.0125
        xyres@tmYLLabelFontHeightF = 0.0125
        xyres@gsnLeftStringFontHeightF = 0.017
        xyres@gsnCenterStringFontHeightF = 0.017
        xyres@gsnRightStringFontHeightF = 0.013         
        xyres@tiXAxisFontHeightF = 0.013
        xyres@tiYAxisFontHeightF = 0.013
     else
        xyres@tmXBLabelFontHeightF = 0.018
        xyres@tmYLLabelFontHeightF = 0.018
        xyres@gsnLeftStringFontHeightF = 0.024
        xyres@gsnCenterStringFontHeightF = 0.024
        xyres@gsnRightStringFontHeightF = 0.020    
        xyres@tiXAxisFontHeightF = 0.018
        xyres@tiYAxisFontHeightF = 0.018
     end if
;     xyres@vpXF = 0.05
     xyres@vpHeightF = 0.3
     if (SCALE_TIMESERIES.eq."True") then
        xyres@vpWidthF = 0.9*((nyr(ee)*1.)/nyr_max)
     else
        xyres@vpWidthF = 0.9
     end if    
     xyres@gsnCenterString = ""
     
     xyres@trXMinF = syear(ee)-.5
     xyres@trXMaxF = eyear(ee)+1.5
     xyres@tiMainOn = False
     xyres@gsnLeftStringOrthogonalPosF = 0.025
     xyres@gsnCenterStringOrthogonalPosF = xyres@gsnLeftStringOrthogonalPosF
     xyres@gsnRightStringOrthogonalPosF = xyres@gsnLeftStringOrthogonalPosF

     xyres2 = xyres
     xyres2@vpHeightF = 0.15
     xyres2@gsnXYBarChart = False

     xyres2@xyLineColor = "royalblue"
     xyres2@trYMinF = 0.15    ; hard wire YMinF and YMaxF for running stddev plots
     xyres2@trYMaxF = 1.95       
     if (wks_type.eq."png") then
        xyres2@xyLineThicknessF = 3.5
     else
        xyres2@xyLineThicknessF = 1.75
     end if
     delete(xyres2@gsnYRefLine)
     xyres2@gsnYRefLine = (/.3,.6,0.9,1.2,1.5,1.8/)
     xyres2@gsnYRefLineColor = "gray85"
     
     xyres3 = xyres            ; resource list for monthly samind standard deviations
     xyres3@trXMinF = 0.5
     xyres3@trXMaxF = 12.5
     xyres3@vpWidthF = 0.65
     xyres3@vpHeightF = 0.35
     xyres3@trYMinF = 0.2
     xyres3@trYMaxF = 2.0
     xyres3@gsnAboveYRefLineColor = "gray50"
     xyres3@xyLineColor = "black"
     if (wks_type.eq."png") then
        xyres3@xyLineThicknessF = 3.5
     else
        xyres3@xyLineThicknessF = 1.75
     end if
     xyres3@gsnXYBarChart = True
     xyres3@gsnXYBarChartBarWidth = 0.75
     xyres3@tmXBMode    = "Explicit"        ; explicit labels
     xyres3@tmXBValues     = ispan(1,12,1)
     xyres3@tmXBLabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
     xyres3@tmXTOn = False
     
     xyres4 = xyres      ; resource list for samind autocorrelations
     xyres4@trXMinF = 0.0
     xyres4@trXMaxF = 48.0
     xyres4@trYMinF = -1.05
     xyres4@trYMaxF = 1.05
     xyres4@vpHeightF = 0.3
     xyres4@vpWidthF = 0.3
     if (wks_type.eq."png") then
        xyres4@xyLineThicknessF = 3.5
     else
        xyres4@xyLineThicknessF = 1.75
     end if
     xyres4@xyLineColor = "black"
     xyres4@gsnAboveYRefLineColor = "firebrick2"
     xyres4@gsnBelowYRefLineColor = "dodgerblue3"
     xyres4@tmYLMode = "Explicit"
     xyres4@tmYLValues = (/-1,0,1/)
     xyres4@tmYLLabels = (/"-1","0","1"/)
     xyres4@tmYLMinorValues = fspan(-1,1,9)
     xyres4@tmXBMode = "Explicit"
     xyres4@tmXBValues = (/0,12,24,36,48/)
     xyres4@tmXBLabels = (/"0","12","24","36","48"/)
     if (nsim.le.5) then
        xyres4@tmXBLabelFontHeightF = 0.0105
        xyres4@tmYLLabelFontHeightF = 0.0105
        xyres4@gsnLeftStringFontHeightF = 0.015
        xyres4@gsnCenterStringFontHeightF = 0.015
        xyres4@gsnRightStringFontHeightF = 0.012         
     else
        xyres4@tmXBLabelFontHeightF = 0.015
        xyres4@tmYLLabelFontHeightF = 0.015
        xyres4@gsnLeftStringFontHeightF = 0.021
        xyres4@gsnCenterStringFontHeightF = 0.021
        xyres4@gsnRightStringFontHeightF = 0.016    
     end if
     xyres4@gsnRightStringOrthogonalPosF = -0.115
     xyres4@gsnRightStringParallelPosF = 0.96
     xyres4@gsnCenterStringOrthogonalPosF = 0.025

     xyres5 = xyres
     xyres5@gsnYRefLine             := (/-0.5,0,0.5/) ; create a reference line   
     xyres5@gsnBelowYRefLineColor   := (/ "blue", "transparent", "transparent"/)
     xyres5@gsnAboveYRefLineColor   := (/ "transparent", "transparent", "red"/)
     xyres5@gsnYRefLineColors       := (/ "blue", "transparent", "red"/)
     xyres5@gsnYRefLineThicknesses  := (/1.0,1.0,1.0/)
     xyres5@gsnYRefLineDashPatterns := (/2,2,2/)

     gsLine = True 
     gsLine@gsLineThicknessF  = 2.0
     gsLin0 = gsLine
     gsLin0@gsLineColor       = "red"       ; Set polyline color
     gsLin1 = gsLine
     gsLin1@gsLineColor       = "blue"

     txres =  True
     txres@txFontHeightF    = 0.015
     txres@txFontThicknessF = 2.0
     txres@txJust           = "CenterLeft"
     txre0 = txres
     txre0@txFontColor      = "red"
     txre1 = txres
     txre1@txFontColor      = "blue"

     xyres6 = xyres
     xyres6@xyLineColors      := (/"gray62","blue","red"/)  ; line colors
     if (wks_type.eq."png") then
       xyres6@xyLineThicknesses := (/1,3,2/)*2.0  ; line thicknesses
     else
       xyres6@xyLineThicknesses := (/1,3,2/)      ; line thicknesses
     end if 
     xyres6@xyDashPatterns    := (/0,0,2/)        ; line patterns

     xyres7 = xyres
     xyres7@gsnXYFillColors = "LightBlue"
     xyres7@xyLineColor     = -1    

     xyres@gsnLeftString = names(ee)
     xyres5@gsnLeftString = names(ee)
     xyres6@gsnLeftString = names(ee)

     arr = new((/3,dimsizes(samind)/),typeof(samind))
   
     tttt = dtrend_msg(ispan(0,dimsizes(samind)-1,1),samind,False,True)
     arr(0,:) = (/ samind /)
     arr(1,:) = (/ runave_n(samind, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(samind)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = ""      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(samind),2,True)+samind@units+" "+nyr(ee)+"yr~S~-1~N~"
     xysamind(ee) = gsn_csm_xy(wks_samind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(samind)),arr,xyres6) 
     delete(tttt)
 
     tttt = dtrend_msg(ispan(0,dimsizes(sam_p40S)-1,1),sam_p40S,False,True)
     arr(0,:) = (/ sam_p40S /)
     arr(1,:) = (/ runave_n(sam_p40S, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(sam_p40S)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = sam_p40S@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(sam_p40S),2,True)+sam_p40S@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn3(ee) = gsn_csm_xy(wks_samind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(sam_p40S)),arr,xyres6) 
     delete(tttt)
     
     tttt = dtrend_msg(ispan(0,dimsizes(sam_p65S)-1,1),sam_p65S,False,True)
     arr(0,:) = (/ sam_p65S /)
     arr(1,:) = (/ runave_n(sam_p65S, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(sam_p65S)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = sam_p65S@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(sam_p65S),2,True)+sam_p65S@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn4(ee) = gsn_csm_xy(wks_samind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(sam_p65S)),arr,xyres6)
     delete(tttt)

     xyres61 = xyres6
     tttt = dtrend_msg(ispan(0,dimsizes(finpsl_mave(0,:))-1,1),finpsl_mave(0,:),False,True)
     arr(0,:) = (/ finpsl_mave(0,:) /)
     arr(1,:) = (/ runave_n(finpsl_mave(0,:), 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(finpsl_mave(0,:))-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres61@trYMinF = -70.0
     xyres61@trYMaxF = -20.0 
     xyres61@tiYAxisString  = "Latitude (degree)"      ; add an axis title
     xyres61@tiXAxisString  = "Time"      ; add an axis title
     xyres61@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(finpsl_mave(0,:)),2,True)+finpsl_mave@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn5(ee) = gsn_csm_xy(wks_samind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(finpsl_mave(0,:))),arr,xyres61)
     if(.not.isvar("xdum")) then
        xdum = new(1000,graphic)
     end if
     xyres7@trYMinF = min(finpsl_mave(:,:))
     xyres7@trYMaxF = max(finpsl_mave(:,:))
     xdum(ee) = gsn_csm_xy(wks_samind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(finpsl_mave(0,:))),finpsl_mave(1:2,:),xyres7)
     overlay(xyn5(ee),xdum(ee))
     delete([/tttt,xyres61/])

     xyres62 = xyres6
     tttt = avg(finpsl_tave(0,:))
     arr(0,:) = (/ finpsl_tave(0,:) /)
     arr(1,:) = (/ runave_n(finpsl_tave(0,:), 11, 0, 0) /)
     arr(2,:) = (/ tttt/)
     xyres62@trYMinF = -70.0 
     xyres62@trYMaxF = -20.0 
     xyres62@trXMinF = tofloat(min(finpsl_tave&lon))
     xyres62@trXMaxF = tofloat(max(finpsl_tave&lon))
     xyres62@tiYAxisString  = "Latitude (degree)"      ; add an axis title    
     xyres62@tiXAxisString  = "Longitude (degree)"      ; add an axis title
     xyres62@gsnRightString = "mean: "+ decimalPlaces(tttt,2,True)+finpsl_mave@units
     xyn6(ee) = gsn_csm_xy(wks_samind,finpsl_tave&lon,arr,xyres62)
     if(.not.isvar("xdum")) then
        xdum = new(1000,graphic)
     end if
     xyres7@trYMinF = min(finpsl_tave(:,:))
     xyres7@trYMaxF = max(finpsl_tave(:,:))
     xdum(100+ee) = gsn_csm_xy(wks_samind,finpsl_tave&lon,finpsl_tave(1:2,:),xyres7)
     overlay(xyn6(ee),xdum(100+ee))
     delete([/tttt,xyres62/])

     tttt = dtrend_msg(ispan(0,dimsizes(aslind)-1,1),aslind,False,True)
     arr(0,:) = (/ aslind /)
     arr(1,:) = (/ runave_n(aslind, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(aslind)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = ""      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(aslind),2,True)+aslind@units+" "+nyr(ee)+"yr~S~-1~N~"
     xytna(ee) = gsn_csm_xy(wks_aslind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(aslind)),arr,xyres6)
     delete(tttt)
     
     tttt = dtrend_msg(ispan(0,dimsizes(asl_clat)-1,1),asl_clat,False,True)
     arr(0,:) = (/ asl_clat/)
     arr(1,:) = (/ runave_n(asl_clat, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(asl_clat)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = "Latitude (degree)"  ;  add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(asl_clat),2,True)+asl_clat@units+" "+nyr(ee)+"yr~S~-1~N~"
     xytsa(ee) = gsn_csm_xy(wks_aslind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(asl_clat)),arr,xyres6)
     delete(tttt)
     
     tttt = dtrend_msg(ispan(0,dimsizes(asl_clon)-1,1),asl_clon,False,True)
     arr(0,:) = (/ asl_clon /)
     arr(1,:) = (/ runave_n(asl_clon, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(asl_clon)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = "Longitude (degree)"      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+decimalPlaces(tttt@slope*dimsizes(asl_clon),2,True)+asl_clon@units+" "+nyr(ee)+"yr~S~-1~N~"
     xytio(ee) = gsn_csm_xy(wks_aslind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(asl_clon)),arr,xyres6)
     delete(tttt)
     
     tttt = dtrend_msg(ispan(0,dimsizes(asl_cpsl)-1,1),asl_cpsl,False,True)
     arr(0,:) = (/ asl_cpsl /)
     arr(1,:) = (/ runave_n(asl_cpsl, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(asl_cpsl)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = asl_cpsl@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+decimalPlaces(tttt@slope*dimsizes(asl_cpsl),2,True)+asl_cpsl@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyiod(ee) = gsn_csm_xy(wks_aslind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(asl_cpsl)),arr,xyres6)
     delete([/tttt/])

     tttt = dtrend_msg(ispan(0,dimsizes(asl_rmpsl)-1,1),asl_rmpsl,False,True)
     arr(0,:) = (/ asl_rmpsl /)
     arr(1,:) = (/ runave_n(asl_rmpsl, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(asl_rmpsl)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = asl_rmpsl@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+decimalPlaces(tttt@slope*dimsizes(asl_rmpsl),2,True)+asl_rmpsl@units+" "+nyr(ee)+"yr~S~-1~N~"
     xysocn(ee) = gsn_csm_xy(wks_aslind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(asl_rmpsl)),arr,xyres6)
     delete([/tttt/])

     tttt = dtrend_msg(ispan(0,dimsizes(asl_rcpsl)-1,1),asl_rcpsl,False,True)
     arr(0,:) = (/ asl_rcpsl /)
     arr(1,:) = (/ runave_n(asl_rcpsl, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(asl_rcpsl)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = asl_rcpsl@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+decimalPlaces(tttt@slope*dimsizes(asl_rcpsl),2,True)+asl_rcpsl@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyamm(ee) = gsn_csm_xy(wks_aslind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(asl_rcpsl)),arr,xyres6)
     delete([/tttt/])

     ;*********************************
     ;plot the sam index (also mark positive and negative events) 
     ;*********************************
     ;ElStr = ind(samind_rn.ge. 2.0)
     ;ElMod = ind(samind_rn.gt. 1.0 .and. samind_rn.lt. 2.0)
     ;LaMod = ind(samind_rn.gt.-2.0 .and. samind_rn.lt.-1.0)
     ;LaStr = ind(samind_rn.le.-2.0)
     ;yyyymm = yyyymm_time(syear(ee),eyear(ee), "integer")
     ;yrfrac = yyyymm_to_yyyyfrac(yyyymm, 0.0)   ; used for graphics
     ;print("SAM (+):   Strong: "+ElStr+"  "+sprintf("%7.2f", yrfrac(ElStr))+"   "+yyyymm(ElStr)+"  "+samind_rn(ElStr))
     ;print("---")
     ;print("SAM (+): Moderate: "+ElMod+"  "+sprintf("%7.2f", yrfrac(ElMod))+"   "+yyyymm(ElMod)+"  "+samind_rn(ElMod))
     ;print("---")
     ;print("SAM (-): Moderate: "+LaMod+"  "+sprintf("%7.2f", yrfrac(LaMod))+"   "+yyyymm(LaMod)+"  "+samind_rn(LaMod))
     ;print("---")
     ;print("SAM (-):   Strong: "+LaStr+"  "+sprintf("%7.2f", yrfrac(LaStr))+"   "+yyyymm(LaStr)+"  "+samind_rn(LaStr))
     ;print("---")
     tttt = dtrend_msg(ispan(0,dimsizes(samind_rn)-1,1),samind_rn,False,True)
     arr(0,:) = (/ samind_rn /)
     arr(1,:) = (/ runave_n(samind_rn, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(samind_rn)-1,1)*tttt@slope)+tttt@y_intercept /)
     arr0     = samind_rn 
     arr1     = samind_rn
     arr2     = samind_rn 
     arr0     =  0
     arr1     =  1 
     arr2     = -1
     xyres5@trYMinF = -3.0 
     xyres5@trYMaxF =  3.0
     xyres5@tiYAxisString  = ""          ; add an axis title
     xyres5@tiXAxisString  = "Time"      ; add an axis title
     xyres5@gsnRightString = "trend: "+decimalPlaces(tttt@slope*dimsizes(samind_rn),2,True)+samind_rn@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn12(ee) = gsn_csm_xy(wks_samind,fspan(syear(ee),eyear(ee)+.91667,dimsizes(samind_rn)),arr(0,:),xyres5)
     if(.not.isvar("dum")) then 
        dum = new(1000,graphic)
     end if  
     dum(ee)     = gsn_add_polyline(wks_samind,xyn12(ee),fspan(syear(ee),eyear(ee)+.91667,dimsizes(samind_rn)),arr0,gsLine) 
     dum(ee+100) = gsn_add_polyline(wks_samind,xyn12(ee),fspan(syear(ee),eyear(ee)+.91667,dimsizes(samind_rn)),arr1,gsLin0)
     dum(ee+200) = gsn_add_polyline(wks_samind,xyn12(ee),fspan(syear(ee),eyear(ee)+.91667,dimsizes(samind_rn)),arr2,gsLin1)
     dum(ee+300) = gsn_add_text(wks_samind,xyn12(ee),"SAM (+)",syear(ee)+0.2, 2.50, txre0)
     dum(ee+400) = gsn_add_text(wks_samind,xyn12(ee),"SAM (-)",syear(ee)+0.2,-2.50, txre1)
     delete([/xyres5,gsLine,gsLin0,gsLin1,txre0,txre1/])
     delete([/arr,tttt,arr0,arr1,arr2/])
 
     xyres2@gsnLeftString = names(ee)
     if (nyr(ee).ge.20) then
        xyres2@gsnRightString = sprintf("%4.2f", min(sd_run))+" / "+sprintf("%4.2f", avg(sd_run))+" / "+sprintf("%4.2f", max(sd_run))+sd_run@units
        xysamind_rst(ee) = gsn_csm_xy(wks_samind_rst,fspan(syear(ee),eyear(ee)+.91667,dimsizes(sd_run)),sd_run,xyres2)
     end if
     
     xyres3@gsnRightStringFontHeightF = xyres3@gsnCenterStringFontHeightF
     xyres3@gsnLeftString = syear(ee)+"-"+eyear(ee)
     xyres3@gsnCenterString = names(ee)
     xyres3@gsnRightString = "C"
     if (max(samind_mon_sd).gt.xyres3@gsnYRefLine) then
        xysamind_mst(ee) = gsn_csm_xy(wks_samind_mst,ispan(1,12,1),samind_mon_sd,xyres3)
     end if
     title_samind = samind@comment_cvdp
     title_n6     = samind@comment_cvdp 
     title_n5     = samind@comment_cvdp 
     title_n4     = sam_p65S@comment_cvdp
     title_n3     = sam_p40S@comment_cvdp
     title_n12    = samind_rn@comment_cvdp

     title_tna  = aslind@comment_cvdp
     title_tsa  = asl_clat@comment_cvdp
     title_tio  = asl_clon@comment_cvdp
     title_iod  = asl_cpsl@comment_cvdp
     title_socn = asl_rmpsl@comment_cvdp
     title_amm  = asl_rcpsl@comment_cvdp

     delete([/samind,sam_p40S,sam_p65S,samind_rn,aslind,asl_clat,asl_clon,asl_cpsl,asl_rmpsl,asl_rcpsl/])

     if (spectra_mvf.eq.False) then
        xyres4@gsnCenterString = names(ee)
        xyres4@gsnRightString = syear(ee)+"-"+eyear(ee)
        xysamind_ac(ee) = gsn_csm_xy(wks_samind_p,ispan(0,48,1),ac34,xyres4)
        if (ee.ge.1.and.isvar("ac34_obs")) then
           delete([/xyres4@gsnAboveYRefLineColor,xyres4@gsnBelowYRefLineColor/])
           xyres4@xyLineColor = "gray62"
           xyres4@xyCurveDrawOrder = "PreDraw"
           xyres4@gsnCenterString = ""
           xyres4@gsnRightString = ""
           xysamind_ac_obs(ee) = gsn_csm_xy(wks_samind_p,ispan(0,48,1),ac34_obs,xyres4)
           overlay(xysamind_ac(ee),xysamind_ac_obs(ee)) 
           delete(xyres4@xyCurveDrawOrder)
           delete(ac34)
        end if
     end if
     delete([/xyres,xyres2,xyres3,xyres4,samind_mon_sd/])
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
     yymm        = yyyymm_time(syear(ee), eyear(ee), "integer")
     yyyyFrac    = yyyymm_to_yyyyfrac(yymm, 0.0)

     res = True
     res@vpHeightF = 0.45
     res@vpWidthF = 0.35
     res@gsnFrame = False
     res@gsnDraw = False 
  

     res@tmYLMode = "Explicit"
;     res@tmYLValues = ispan(0,72,6)
;     res@tmYLLabels = (/"Jan~S~-2~N~","Jul~S~-2~N~","Jan~S~-1~N~","Jul~S~-1~N~", \
;                     "Jan~S~0~N~","Jul~S~0~N~","Jan~S~+1~N~","Jul~S~+1~N~", \
;                     "Jan~S~+2~N~","Jul~S~+2~N~","Jan~S~+3~N~","Jul~S~+3~N~","Jan~S~+4~N~"/)
;     res@trYMinF = 24
;     res@trYMaxF = 52  
;     res@tmYLValues = ispan(24,52,4)
;     res@tmYLLabels = (/"Jan~S~0~N~","May~S~0~N~","Sep~S~0~N~","Jan~S~+1~N~", \
;                     "May~S~+1~N~","Sep~S~+1~N~","Jan~S~+2~N~","May~S~+2~N~"/)    
;     res@tmYLMinorValues = ispan(24,52,2)               

     ;res@trYMinF         = toint(syear(ee)+"01")
     ;res@trYMaxF         = toint(eyear(ee)+"12") 
     ;print(finpsl&time_mon1(::12))
     ;exit

     res@tmYLValues      = yyyyFrac(::60)
     res@tmYLLabels      = yymm(::60) 
     res@tmYLMinorValues = yyyyFrac(::12)

     res@tmYLLabelJust = "CenterCenter"               
     res@tmYLLabelDeltaF = 1.3    ;0.05
     res@cnFillOn = True
     res@gsnSpreadColors = True  
     res@gsnSpreadColorEnd = 19
     
     res@lbLabelBarOn = False
  
     res@tiMainOn = False
     res@cnInfoLabelOn = False
     res@cnLinesOn = True
     res@cnLevelSelectionMode = "ExplicitLevels"
     res@cnLevels = fspan(-70,-20,11) 
     carr = new(dimsizes(res@cnLevels),"string")
     carr = "transparent"
     carr(8) = "gray50"
     res@cnMonoLineColor = False
     res@cnLineColors = carr
     res@cnLineLabelsOn = False
     res@tmYLLabelFontHeightF = 0.014
     res@tmXBLabelFontHeightF = 0.014
     res@gsnMajorLonSpacing = 90.
     res@gsnMinorLonSpacing = 60.
     res@tiYAxisOn = False
     
     if (wks_type.eq."png") then
        res@cnLineThicknessF = 2.  
     else
        res@cnLineThicknessF = 1.  
     end if
     res@gsnCenterStringOrthogonalPosF = 0.025
     res@gsnRightStringOrthogonalPosF = res@gsnCenterStringOrthogonalPosF
     res@gsnCenterStringFontHeightF = 0.017
     res@gsnLeftStringFontHeightF = 0.017
     res@gsnRightStringFontHeightF = 0.017

     res@gsnLeftString = ""
     res@gsnCenterString= ""
     res@gsnRightString = ""

     if (isfilepresent2("obs_ts").and.ee.eq.0.and.isvar("finpsl")) then      ; for metrics table
        patcor_hov         = new((/nsim,dimsizes(finpsl&time),dimsizes(finpsl&lon)/),typeof(finpsl))
        patcor_hov!1       = "time"
        patcor_hov&time    = finpsl&time
        patcor_hov!2       = "lon"
        patcor_hov&lon     = finpsl&lon
        patcor_hov(ee,:,:) = (/ finpsl /) 
     end if

     if (isfilepresent2("obs_ts").and.ee.ge.1.and.isvar("patcor_hov_hi").and.isvar("finpsl_mave")) then    
        dimT = dimsizes(finpsl_mave&time)
        do hh = 0,dimT-1     ; need to loop over each timestep, using linint1 to interpolate to set longitudes. 
           patcor_hov(ee,hh,:) = (/ totype(linint1(finpsl&lon,finpsl(hh,:),False,patcor_hov&lon,0),typeof(patcor_hov)) /)
        end do
     end if

     if (isvar("finpsl")) then    
        res@gsnCenterString = names(ee)   ;"SAM(+)"
        res@gsnRightString  = "" ;"SAM Latitude Position (Degree)"
        delete(finpsl&time)
        finpsl&time         = yyyyFrac
        plot_samlat(ee)     = gsn_csm_hov(wks_samlat_tlon,finpsl,res)
        delete([/finpsl/])
     end if
     delete([/res,yymm,yyyyFrac/])

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     wres = True
     wres@gsnDraw = False
     wres@gsnFrame = False
     wres@vpWidthF = 0.7
     wres@vpHeightF = 0.3
     wres@cnFillOn = True
     wres@cnLinesOn = False
     wres@cnLineLabelsOn = False
     wres@cnInfoLabelOn = False
     wres@trYReverse = True
     wres@trYMinF = 1.0
     wres@trYMaxF = (nyr(ee)/2) - (nyr(ee)*0.05)
     wres@tmYLOn = True
     wres@tmYLMode = "Explicit"
     if (nyr(ee).lt.200) then
        wres@tmYLValues = (/1,2,3,5,10,20,50,100,150/)
     else
        wres@tmYLValues = (/1,5,10,50,100,200,500,1000,2000,5000,10000/)
     end if
     wres@tmYLLabels = wres@tmYLValues
     wres@cnLevelSelectionMode = "ExplicitLevels"
     wres@cnLevels = ispan(0,40,5)
     if (COLORMAP.eq.0) then
        wres@cnFillPalette = "precip3_16lev"
     else
        wres@cnFillPalette = "cb_rainbow"
     end if
     wres@tmXTLabelFontHeightF = 0.018
     wres@tmXBLabelFontHeightF = 0.018
     wres@tmYLLabelFontHeightF = 0.018
     wres@tiYAxisString = "Period (years)"
     wres@tiXAxisOn = False
     wres@lbLabelBarOn = False
     wres@gsnLeftString = ""
     wres@gsnCenterString = ""
     wres@gsnRightString = ""
     wres@gsnCenterStringOrthogonalPosF = 0.025

     wsres = True                            ; res2 probability plots
     wsres@trYReverse          = True
     wsres@tmYLMode = "Explicit"
     wsres@tmYLValues = wres@tmYLValues 
     wsres@tmYLLabels = wres@tmYLLabels
     wsres@gsnDraw             = False       ; Do not draw plot
     wsres@gsnFrame            = False       ; Do not advance frome
     wsres@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
     wsres@cnMinLevelValF      = 0.00        ; set min contour level
     wsres@cnMaxLevelValF      = 2.00        ; set max contour level
     wsres@cnLevelSpacingF     = 1.00        ; set contour spacing
     wsres@cnInfoLabelOn       = False
     wsres@cnLinesOn           = False       ; do not draw contour lines
     wsres@cnLineLabelsOn      = False       ; do not draw contour labels
     wsres@cnFillScaleF   = 0.5         ; add extra density
     wsres@cnFillDotSizeF = .0015
     wsres@gsnLeftString = ""
     wsres@gsnCenterString = ""
     wsres@gsnRightString = ""    

     wavecoi = True
     wavecoi@gsEdgeColor = "gray40"
     wavecoi@gsFillColor = wavecoi@gsEdgeColor
;     wavecoi@gsFillOpacityF = 0.15
     if (wks_type.eq."png") then
        wavecoi@gsFillLineThicknessF = 2.0
        wavecoi@gsEdgeThicknessF = 2.0
     else
        wavecoi@gsFillLineThicknessF = 1.25
        wavecoi@gsEdgeThicknessF = 1.25
     end if
     wavecoi@gsFillIndex = 3
     wavecoi@gsFillScaleF = .65


     if (spectra_mvf.eq.False) then
        wres@gsnLeftString = ""
        wres@gsnCenterString = names(ee)
        delete(power34&time)
        power34&time = fspan(syear(ee),eyear(ee)+.91667,nyr(ee)*12)
        delete(sig34&time)
        sig34&time = power34&time
        plot_wave34(ee) = gsn_csm_contour(wks_samind_p,power34,wres)
        plot_wave34(ee) = ShadeCOI(wks_samind_p,plot_wave34(ee),wave34,power34&time,wavecoi)
        o0 = gsn_csm_contour(wks_samind_p,sig34,wsres)
        opt   = True
        opt@gsnShadeFillType = "pattern"
        opt@gsnShadeHigh     = 17
        o0 = gsn_contour_shade(o0,0, 0.8, opt)
        overlay(plot_wave34(ee),o0)
        delete([/o0,opt,power34,sig34,wave34/])
     end if
     delete([/wres,wsres,wavecoi/])
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     pres = True
     pres@vpXF = 0.07
     pres@trYMinF = 0.
     pres@trXMinF = 0.0
;     pres@trYMaxF = 82.
     pres@trXMaxF = 0.0832
     pres@tiYAxisString = "Power"              ; yaxis
     pres@xyLineColor   =  "black"         
     pres@gsnFrame      = False
     pres@gsnDraw       = False
  
     pres@tmXBLabelDeltaF = -.8
     pres@tmXTLabelDeltaF = -.8
     pres@pmLegendDisplayMode    = "Never"
     if (wks_type.eq."png") then
        pres@xyLineThicknesses   = (/3.5,2.,1.,1./) 
     else
        pres@xyLineThicknesses   = (/2.5,1.5,1.,1./) 
     end if
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
     pres@tiYAxisString = "Power (hPa~S~2~N~ / cycles mo~S~-1~N~)"              ; yaxis
     pres@tiXAxisString = "Frequency (cycles mo~S~-1~N~)"
     pres@tiMainString = ""
     pres@txFontHeightF = 0.015
     pres@xyLineLabelFontHeightF = 0.022
     pres@tiXAxisFontHeightF = 0.025
     pres@tiYAxisFontHeightF = 0.025
     pres@tiMainFontHeightF = 0.03
     pres@gsnRightStringOrthogonalPosF = -0.115
     
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
        if (mval.lt.70) then
           pres@trYMaxF = 75.
           pres@tmYLMode = "Explicit"
           pres@tmYLValues = (/0,25,50,75/)
           pres@tmYLLabels = pres@tmYLValues
           pres@tmYLMinorValues = ispan(5,70,5)
        end if
        if (mval.ge.70.and.mval.lt.145) then
           pres@trYMaxF = 150.
           pres@tmYLMode = "Explicit"
           pres@tmYLValues = (/0,50,100,150/)
           pres@tmYLLabels = pres@tmYLValues
           pres@tmYLMinorValues = ispan(10,140,10)
        end if
        if (mval.ge.145) then
           pres@trYMaxF = mval+15.
        end if
        pres@trYMaxF = 100. 
        delete(mval)
     end if
     
     pres@tiMainOn = False
     pres@gsnCenterString = "Period (years)"
     pres@gsnCenterStringFontHeightF =    pres@tiYAxisFontHeightF
     pres@gsnRightStringFontHeightF =    pres@tiYAxisFontHeightF - 0.005
     pres@gsnRightString = syear(ee)+"-"+eyear(ee)+"  "
     pres@gsnLeftString = "" 
     pres@gsnCenterString = names(ee)
     if (spectra_mvf.eq.False) then
        pspec(ee) = gsn_csm_xy(wks_samind_p,sdof@frq,splt1,pres) 
        if (isfilepresent2("obs_ts").and.ee.ge.1.and.spectra_mvf_obs.eq.False) then
           pres@xyLineColors        = (/"gray70","black","black","black"/)
           pres@xyCurveDrawOrder = "PreDraw"
           pres@gsnCenterString = ""
           pres@gsnRightString = ""
           pspec_obs(ee) = gsn_csm_xy(wks_samind_p,sdof_obs@frq,sdof_obs@spcx,pres)
           overlay(pspec(ee),pspec_obs(ee)) 
           delete(pres@xyCurveDrawOrder)
        end if
        delete([/sdof,splt1/])
     end if     
     delete([/val1,val2,pres/])
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -       
     if (nyr(ee).ge.20) then
        delete(sd_run)
     end if
     
     scres = True    ; scres = spatial composite res
     scres@mpProjection = "WinkelTripel"
     scres@mpGeophysicalLineColor = "black" ;"gray42"
     
     scres@mpPerimOn    = False
     scres@mpGridLatSpacingF =  90            ; change latitude  line spacing
     scres@mpGridLonSpacingF = 180.           ; change longitude line spacing
     scres@mpGridLineColor   = "transparent"  ; trick ncl into drawing perimeter
     scres@mpGridAndLimbOn   = True           ; turn on lat/lon lines  
     scres@mpFillOn = False
     scres@mpCenterLonF = 210.
     scres@mpOutlineOn = True  
     scres@gsnDraw      = False
     scres@gsnFrame     = False
     
     scres@cnLevelSelectionMode = "ExplicitLevels"
     scres@cnLevels = (/-4,-3,-2,-1.5,-1,-.5,-.25,0,.25,.5,1,1.5,2,3.,4/)

     scres@cnLineLabelsOn = False
     scres@cnFillOn        = True
     scres@cnLinesOn       = False
;    scres@mpOutlineDrawOrder = "PostDraw"
;    scres@cnFillMode = "RasterFill"
     scres@mpOutlineDrawOrder = "PostDraw"
     scres@cnFillMode = "AreaFill"   
     scres@lbLabelBarOn    = False
     scres@cnInfoLabelOn = False
     scres@gsnAddCyclic = True
     
     scres@gsnLeftStringOrthogonalPosF = -0.05
     scres@gsnLeftStringParallelPosF = .005
     scres@gsnRightStringOrthogonalPosF = -0.05
     scres@gsnRightStringParallelPosF = 0.96
     scres@gsnRightString = ""
     scres@gsnLeftString = ""
     scres@gsnLeftStringFontHeightF = 0.014
     scres@gsnCenterStringFontHeightF = 0.018
     scres@gsnRightStringFontHeightF = 0.014

     scres4 = scres    ; scres4 = ppt composite resources     
     delete(scres4@cnLevels)
     if (COLORMAP.eq.0) then
        scres4@cnLevels = (/-10,-8,-6,-4,-3,-2,-1,-.5,-.25,0,.25,.5,1,2,3,4,6,8,10/)     
     else
        scres4@cnLevels = (/-5,-3,-2,-1,-.5,0,.5,1,2,3,5/)     
     end if

     scres2 = True
     scres2@gsnDraw      = False
     scres2@gsnFrame     = False
     scres2@cnLevelSelectionMode = "ExplicitLevels"
     scres2@cnLevels = scres@cnLevels

     scres2@cnLineLabelsOn = False
     scres2@cnFillOn        = True
     scres2@cnLinesOn       = False
     scres2@cnFillMode = "AreaFill"
     scres2@lbLabelBarOn    = False
     scres2@cnInfoLabelOn = False
     scres2@gsnRightString = ""
     scres2@gsnLeftString = "" 
     scres2@gsnCenterString = ""   
     scres2@gsnAddCyclic = True

     
     scres3 = True          ; PSL resources
     scres3@cnLineColor = "black"
     scres3@cnLineLabelsOn = False  
     scres3@cnLevelSelectionMode = "ExplicitLevels"
     scres3@cnInfoLabelOn = False
     scres3@tiMainOn = False      
     new_index = NhlNewDashPattern(wks_samindsc,"$_$_$_$_$_$_$_$_$_")
     scres3@gsnContourNegLineDashPattern  = new_index
     scres3@cnLineDashSegLenF = 0.08
     scres3@gsnDraw = False
     scres3@gsnFrame = False
     scres3@gsnLeftString = ""
     scres3@gsnRightString = ""
     scres3@gsnCenterString = ""
     scres3@cnLevels = ispan(-16,16,1)

     scres4@gsnLeftString = syear_prect(ee)+"-"+eyear_prect(ee)
     scres4@gsnCenterString = names_prect(ee)     

     scres@gsnLeftString = syear(ee)+"-"+eyear(ee) 
     if (names(ee).eq.names_trefht(ee).and.names(ee).eq.names_ts(ee)) then
        scres@gsnCenterString = names(ee)     
     else
        scres@gsnCenterString = names(ee)+" / "+names_trefht(ee)+" / "+names_ts(ee)
     end if
  
     if (wks_type.eq."png") then
        scres3@cnLineThicknessF = 3.
        scres@mpGeophysicalLineThicknessF = 2. 
        scres4@mpGeophysicalLineThicknessF = 2.  
     else
        scres3@cnLineThicknessF = 1.25
        scres@mpGeophysicalLineThicknessF = 1.  
        scres4@mpGeophysicalLineThicknessF = 1.  
     end if

     if (tassstreg_plot_flag.eq.0) then
        if (isvar("patcor_tas")) then    ; for metrics table
           patcor_tas(ee,:,:) = (/ totype(linint2(samindsc_tas&lon,samindsc_tas&lat,samindsc_tas(12,:,:),True,patcor_tas&lon,patcor_tas&lat,0),typeof(patcor_tas)) /)
           patcor_psl(ee,:,:) = (/ totype(linint2(samindsc_psl&lon,samindsc_psl&lat,samindsc_psl(12,:,:),True,patcor_psl&lon,patcor_psl&lat,0),typeof(patcor_psl)) /)
        else
           if (isfilepresent2("obs_trefht")) then
              patcor_tas = new((/nsim,dimsizes(samindsc_tas&lat),dimsizes(samindsc_tas&lon)/),typeof(samindsc_tas))
              patcor_tas!1 = "lat"
              patcor_tas&lat = samindsc_tas&lat
              patcor_tas!2 = "lon"
              patcor_tas&lon = samindsc_tas&lon
              patcor_psl = new((/nsim,dimsizes(samindsc_psl&lat),dimsizes(samindsc_psl&lon)/),typeof(samindsc_psl))
              patcor_psl!1 = "lat"
              patcor_psl&lat = samindsc_psl&lat
              patcor_psl!2 = "lon"
              patcor_psl&lon = samindsc_psl&lon
              patcor_tas(ee,:,:) = (/ samindsc_tas(12,:,:) /)
              patcor_psl(ee,:,:) = (/ samindsc_psl(12,:,:) /)
           end if
        end if
     
        d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")     ; mask ocean for TAS array
        basemap = d->LSMASK
        lsm = landsea_mask(basemap,samindsc_tas&lat,samindsc_tas&lon)
        samindsc_tas = mask(samindsc_tas,conform(samindsc_tas,lsm,(/1,2/)).eq.0,False)
        delete([/lsm,basemap/])
        delete(d)
     
        map_samindsc_jja0(ee) = gsn_csm_contour_map(wks_samindsc,samindsc_sst(6,:,:),scres)    ; 6 = JJA 0    
        o1 = gsn_csm_contour(wks_samindsc,samindsc_tas(6,:,:),scres2)  
        o2 = gsn_csm_contour(wks_samindsc,samindsc_psl(6,:,:),scres3) 
        overlay(map_samindsc_jja0(ee),o1)
        overlay(map_samindsc_jja0(ee),o2)
        delete([/o1,o2/])
        
        map_samindsc_son0(ee) = gsn_csm_contour_map(wks_samindsc,samindsc_sst(9,:,:),scres)    ; 9 = SON 0      
        o3 = gsn_csm_contour(wks_samindsc,samindsc_tas(9,:,:),scres2)  
        o4 = gsn_csm_contour(wks_samindsc,samindsc_psl(9,:,:),scres3) 
        overlay(map_samindsc_son0(ee),o3)
        overlay(map_samindsc_son0(ee),o4)
        delete([/o3,o4/])
        
        
        map_samindsc_djf1(ee) = gsn_csm_contour_map(wks_samindsc,samindsc_sst(12,:,:),scres)    ; 12 = DJF+1      
        o5 = gsn_csm_contour(wks_samindsc,samindsc_tas(12,:,:),scres2)  
        o6 = gsn_csm_contour(wks_samindsc,samindsc_psl(12,:,:),scres3) 
        overlay(map_samindsc_djf1(ee),o5)
        overlay(map_samindsc_djf1(ee),o6)
        delete([/o5,o6/])
        
        map_samindsc_mam1(ee) = gsn_csm_contour_map(wks_samindsc,samindsc_sst(15,:,:),scres)    ; 15 = MAM+1      
        o7 = gsn_csm_contour(wks_samindsc,samindsc_tas(15,:,:),scres2)  
        o8 = gsn_csm_contour(wks_samindsc,samindsc_psl(15,:,:),scres3) 
        overlay(map_samindsc_mam1(ee),o7)
        overlay(map_samindsc_mam1(ee),o8)
        delete([/o7,o8/])       
        delete([/samindsc_sst,samindsc_tas,samindsc_psl/])
     end if
     if (pptreg_plot_flag.eq.0) then     
        map_samindsc_ppt_jja0(ee) = gsn_csm_contour_map(wks_samindsc_ppt,samindsc_ppt(6,:,:),scres4)    ; 6 = JJA 0            
        map_samindsc_ppt_son0(ee) = gsn_csm_contour_map(wks_samindsc_ppt,samindsc_ppt(9,:,:),scres4)    ; 9 = SON 0              
        map_samindsc_ppt_djf1(ee) = gsn_csm_contour_map(wks_samindsc_ppt,samindsc_ppt(12,:,:),scres4)    ; 12 = DJF+1              
        map_samindsc_ppt_mam1(ee) = gsn_csm_contour_map(wks_samindsc_ppt,samindsc_ppt(15,:,:),scres4)    ; 15 = MAM+1      
        delete([/samindsc_ppt/])
     end if
  end do
  
  if (isvar("patcor_tas")) then    ; for pattern correlation table  
     clat_tas = cos(0.01745329*patcor_tas&lat)
     clat_psl = cos(0.01745329*patcor_psl&lat)
     finpr_tas = "SAM TAS (DJF+1)  "    ; Must be 18 characters long
     finpr_psl = "SAM PSL (DJF+1)  " 
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
        if (all(ismissing(patcor_tas(hh,:,:)))) then
           finpr_tas = finpr_tas+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
        else
           finpr_tas = finpr_tas+sprintf(format2,(pattern_cor(patcor_tas(0,:,:),patcor_tas(hh,:,:),clat_tas,0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_tas(0,:,:),patcor_tas(hh,:,:),clat_tas,1.0,0)))
        end if
        if (all(ismissing(patcor_psl(hh,:,:)))) then
           finpr_psl = finpr_psl+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
        else
           finpr_psl = finpr_psl+sprintf(format2,(pattern_cor(patcor_psl(0,:,:),patcor_psl(hh,:,:),clat_psl,0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_psl(0,:,:),patcor_psl(hh,:,:),clat_psl,1.0,0)))
        end if
     end do
     if (dimsizes(tochar(line4)).ge.8190) then   ; system or fortran compiler limit
        print("Metrics table warning: Not creating metrics table as size of comparison results in a invalid ascii row size.")   
     else
        write_table(getenv("OUTDIR")+"metrics.psl.indices.1.txt","w",[/header/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.indices.1.txt","a",[/line3/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.indices.1.txt","a",[/line4/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.indices.1.txt","a",[/finpr_tas/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.indices.1.txt","a",[/finpr_psl/],"%s")
     end if  
     delete([/finpr_tas,finpr_psl,line3,line4,format2,format3,nchar,ntc,clat_tas,clat_psl,patcor_tas,patcor_psl,dimY,ntb,header/])
  end if

  if (isvar("patcor_hov_hi")) then           ; for pattern correlation table  
     finpr_hi = "SAM(+) Hovmoller "    ; Must be 18 characters long
     finpr_lo = "SAM(-) Hovmoller " 
     line3   = "                  "    ; Must be 18 characters long                                 patcor_hov_hi
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
        if (all(ismissing(patcor_hov_hi(hh,0:28,:)))) then                ; 0:28 refers to Jan+0->May+2, which is the range shown in the hovmoller plots.
           finpr_hi = finpr_hi+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
        else
           finpr_hi = finpr_hi+sprintf(format2,(pattern_cor(patcor_hov_hi(0,0:28,:),patcor_hov_hi(hh,0:28,:),1.0,0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_hov_hi(0,0:28,:),patcor_hov_hi(hh,0:28,:),1.0,1.0,0)))
        end if
        if (all(ismissing(patcor_hov_lo(hh,0:28,:)))) then
           finpr_lo = finpr_lo+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
        else
           finpr_lo = finpr_lo+sprintf(format2,(pattern_cor(patcor_hov_lo(0,0:28,:),patcor_hov_lo(hh,0:28,:),1.0,0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_hov_lo(0,0:28,:),patcor_hov_lo(hh,0:28,:),1.0,1.0,0)))
        end if
     end do
     if (dimsizes(tochar(line4)).ge.8190) then   ; system or fortran compiler limit
        print("Metrics table warning: Not creating metrics table as size of comparison results in a invalid ascii row size.")   
     else
        write_table(getenv("OUTDIR")+"metrics.psl.indices.2.txt","w",[/header/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.indices.2.txt","a",[/line3/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.indices.2.txt","a",[/line4/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.indices.2.txt","a",[/finpr_hi/],"%s")
        write_table(getenv("OUTDIR")+"metrics.psl.indices.2.txt","a",[/finpr_lo/],"%s")
     end if
     delete([/finpr_hi,finpr_lo,line3,line4,format2,format3,nchar,ntc,patcor_hov_hi,patcor_hov_lo,dimY,ntb,header/])  
  end if
  
  ncol = floattointeger(sqrt(nsim))
  nrow = (nsim/ncol)+mod(nsim,ncol) 
  
  panres = True
  panres@gsnMaximize = True
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelYWhiteSpacePercent = 3.0
  if (nsim.le.10) then
     panres@txFontHeightF = 0.016
  else
     panres@txFontHeightF = 0.012
  end if

  if (SCALE_TIMESERIES.eq."True") then
     tt = ind(nyr.eq.nyr_max)
     panres@gsnPanelScalePlotIndex = tt(0)
     delete(tt)
  end if

  if (nsim.le.3) then
    nrow = nsim
    ncol = 1
  else 
    ncol = floattointeger(sqrt(nsim))
    nrow = (nsim/ncol)+mod(nsim,ncol)
  end if 
  lp = (/nrow,ncol/)

  if (isvar("title_samind")) then
     panres@txString = "SAM (Marshall) index (Monthly, "+title_samind+")"
     gsn_panel2(wks_samind,xysamind,lp,panres)    

     panres@txString = "SAM (Marshall) Pressure at 40S (Monthly, "+title_n3+")"
     gsn_panel2(wks_samind,xyn3,lp,panres)

     panres@txString = "SAM (Marshall) Pressure at 65S (Monthly, "+title_n4+")"
     gsn_panel2(wks_samind,xyn4,lp,panres)

     panres@txString = "SAM Mean Latitude Variation (Monthly, "+title_n5+")"
     gsn_panel2(wks_samind,xyn5,lp,panres)

     panres@txString = "SAM Mean Latitude Variation (Monthly, "+title_n6+")"
     gsn_panel2(wks_samind,xyn6,lp,panres)

     panres@txString = "Normalized SAM (Marshall) index (Monthly, "+title_n12+")"
     gsn_panel2(wks_samind,xyn12,lp,panres)

     panres@txString = "Amundsen Sea Low (ASL) index (Monthly, "+title_tna+")"
     gsn_panel2(wks_aslind,xytna,lp,panres)  

     panres@txString = "ASL Central Latitude (Monthly, "+title_tsa+")"
     gsn_panel2(wks_aslind,xytsa,lp,panres)       

     panres@txString = "ASL Central Longitude (Monthly, "+title_tio+")"
     gsn_panel2(wks_aslind,xytio,lp,panres)       
   
     panres@txString = "ASL Central Pressure (Monthly, "+title_iod+")"
     gsn_panel2(wks_aslind,xyiod,lp,panres)
  
     panres@txString = "ASL Sector Mean Pressure (Monthly, "+title_socn+")"
     gsn_panel2(wks_aslind,xysocn,lp,panres)

     panres@txString = "ASL Relative Central Pressure (Monthly, "+title_amm+")"
     gsn_panel2(wks_aslind,xyamm,lp,panres)

  end if
  delete([/wks_samind,wks_aslind/]) 

  if (all(ismissing(xysamind_rst))) then
;     print("No valid running standard deviation plots, skipping")
  else
     panres@txString = "SAM (Marshall) index 15yr running standard deviation"
     gsn_panel2(wks_samind_rst,xysamind_rst,lp,panres) 
     delete(xysamind_rst)  
  end if
  panres@gsnPanelYWhiteSpacePercent = 0.5
  panres@txString = "SAM (Marshall) index standard deviation (Monthly)"
  gsn_panel2(wks_samind_mst,xysamind_mst,(/nrow,ncol/),panres)   
  
  panres2 = True
  panres2@gsnMaximize = True
  panres2@gsnPaperOrientation = "portrait"
  panres2@gsnPanelLabelBar = True
  panres2@lbLabelStride = 1
  panres2@pmLabelBarWidthF = 0.4
  panres2@pmLabelBarHeightF = 0.06
  panres2@lbLabelFontHeightF = 0.013
  panres2@txString = ""   

  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres2@txFontHeightF = 0.022
        panres2@gsnPanelBottom = 0.50
     else
        panres2@txFontHeightF = 0.0145
        panres2@gsnPanelBottom = 0.50
     end if
  else
     panres2@txFontHeightF = 0.016
     panres2@gsnPanelBottom = 0.05
  end if
  panres2@lbTitleOn = True
  panres2@lbTitlePosition = "Bottom"
  panres2@lbTitleFontHeightF = panres2@lbLabelFontHeightF - 0.002

  panres2@lbTitleString = "Latitude (degree)"
  panres2@txString = "SAM Latitude Position (degree)"
  gsn_panel2(wks_samlat_tlon,plot_samlat,(/nrow,ncol/),panres2)   
  delete([/panres2@lbTitleOn,panres2@lbTitlePosition,panres2@lbTitleFontHeightF,panres2@lbTitleString/])

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
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@txString = "SAM (Marshall) index (Monthly, detrended)"
  gsn_panel2(wks_samind_p,pspec,(/nrow,ncol/),panres)  
  panres@txString = "SAM (Marshall) index Autocorrelation (Monthly)"
  gsn_panel2(wks_samind_p,xysamind_ac,(/nrow,ncol/),panres) 
  panres2@txString = "SAM (Marshall) index Wavelet (Monthly)"
  panres2@gsnPanelYWhiteSpacePercent = 3.0
  panres2@gsnPanelXWhiteSpacePercent = 4.0
  gsn_panel2(wks_samind_p,plot_wave34,(/nrow,ncol/),panres2)  
  delete(wks_samind_p)

  delete(panres2@gsnPanelYWhiteSpacePercent)
  panres2@pmLabelBarWidthF = 0.8
  panres2@lbLabelAutoStride = False
  panres2@gsnPanelXWhiteSpacePercent = 8.5
  if (any(.not.ismissing(map_samindsc_jja0))) then
     panres2@lbTitleString = "SST/TAS (C)"
     panres2@pmLabelBarOrthogonalPosF = -0.05
     panres2@txString = "SAM (Marshall) SST,TAS,PSL Spatial Composite (JJA~S~0~N~)"
     gsn_panel2(wks_samindsc,map_samindsc_jja0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "SAM (Marshall) SST,TAS,PSL Spatial Composite (SON~S~0~N~)"
     gsn_panel2(wks_samindsc,map_samindsc_son0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "SAM (Marshall) SST,TAS,PSL Spatial Composite (DJF~S~+1~N~)"
     gsn_panel2(wks_samindsc,map_samindsc_djf1,(/nrow,ncol/),panres2)   
  
     panres2@txString = "SAM (Marshall) SST,TAS,PSL Spatial Composite (MAM~S~+1~N~)"
     gsn_panel2(wks_samindsc,map_samindsc_mam1,(/nrow,ncol/),panres2)   
     delete(wks_samindsc)
     
     delete([/map_samindsc_djf1,map_samindsc_jja0,map_samindsc_son0,map_samindsc_mam1/])
  end if     
  if (any(.not.ismissing(map_samindsc_ppt_jja0))) then
     panres2@txString = "SAM (Marshall) PR Spatial Composite (JJA~S~0~N~)"
     gsn_panel2(wks_samindsc_ppt,map_samindsc_ppt_jja0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "SAM (Marshall) PR Spatial Composite (SON~S~0~N~)"
     gsn_panel2(wks_samindsc_ppt,map_samindsc_ppt_son0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "SAM (Marshall) PR Spatial Composite (DJF~S~+1~N~)"
     gsn_panel2(wks_samindsc_ppt,map_samindsc_ppt_djf1,(/nrow,ncol/),panres2)   
  
     panres2@txString = "SAM (Marshall) PR Spatial Composite (MAM~S~+1~N~)"
     gsn_panel2(wks_samindsc_ppt,map_samindsc_ppt_mam1,(/nrow,ncol/),panres2)   
     delete(wks_samindsc_ppt)
     
     delete([/map_samindsc_ppt_djf1,map_samindsc_ppt_jja0,map_samindsc_ppt_son0,map_samindsc_ppt_mam1/])
  end if   

  delete([/xysamind,xyn6,xyn5,xyn4,xyn3,xyn12,xytna,xytsa,xytio,xyiod,plot_samlat,pspec,pi,rad,wgt,lp/])     

  OUTDIR = getenv("OUTDIR")
  
  if (wks_type.eq."png") then  
     if (isfilepresent2(OUTDIR+"samind.spatialcomp.000001.png")) then
        system("mv "+OUTDIR+"samind.spatialcomp.000001.png "+OUTDIR+"samind.spatialcomp.jja0.png")
        system("mv "+OUTDIR+"samind.spatialcomp.000002.png "+OUTDIR+"samind.spatialcomp.son0.png")
        system("mv "+OUTDIR+"samind.spatialcomp.000003.png "+OUTDIR+"samind.spatialcomp.djf1.png")
        system("mv "+OUTDIR+"samind.spatialcomp.000004.png "+OUTDIR+"samind.spatialcomp.mam1.png")
     end if
     if (isfilepresent2(OUTDIR+"samind.spatialcomp.ppt.000001.png")) then
        system("mv "+OUTDIR+"samind.spatialcomp.ppt.000001.png "+OUTDIR+"samind.spatialcomp.pr.jja0.png")
        system("mv "+OUTDIR+"samind.spatialcomp.ppt.000002.png "+OUTDIR+"samind.spatialcomp.pr.son0.png")
        system("mv "+OUTDIR+"samind.spatialcomp.ppt.000003.png "+OUTDIR+"samind.spatialcomp.pr.djf1.png")
        system("mv "+OUTDIR+"samind.spatialcomp.ppt.000004.png "+OUTDIR+"samind.spatialcomp.pr.mam1.png")
     end if
     if (isfilepresent2(OUTDIR+"samind.timeseries.000001.png")) then
        system("mv "+OUTDIR+"samind.timeseries.000001.png "+OUTDIR+"samind.timeseries.png")
        system("mv "+OUTDIR+"samind.timeseries.000002.png "+OUTDIR+"sam_p40S.timeseries.png")
        system("mv "+OUTDIR+"samind.timeseries.000003.png "+OUTDIR+"sam_p65S.timeseries.png")
        system("mv "+OUTDIR+"samind.timeseries.000004.png "+OUTDIR+"samlat_mave.timeseries.png")
        system("mv "+OUTDIR+"samind.timeseries.000005.png "+OUTDIR+"samlat_tave.timeseries.png")
        system("mv "+OUTDIR+"samind.timeseries.000006.png "+OUTDIR+"samind_norm.timeseries.png")
     end if
     if (isfilepresent2(OUTDIR+"aslind.timeseries.000001.png")) then
        system("mv "+OUTDIR+"aslind.timeseries.000001.png "+OUTDIR+"aslind.timeseries.png")
        system("mv "+OUTDIR+"aslind.timeseries.000002.png "+OUTDIR+"asl_clat.timeseries.png")
        system("mv "+OUTDIR+"aslind.timeseries.000003.png "+OUTDIR+"asl_clon.timeseries.png")
        system("mv "+OUTDIR+"aslind.timeseries.000004.png "+OUTDIR+"asl_cpsl.timeseries.png")
        system("mv "+OUTDIR+"aslind.timeseries.000005.png "+OUTDIR+"asl_rmpsl.timeseries.png")
        system("mv "+OUTDIR+"aslind.timeseries.000006.png "+OUTDIR+"asl_rcpsl.timeseries.png")
     end if
     if (isfilepresent2(OUTDIR+"samind.powspec.000001.png")) then
        system("mv "+OUTDIR+"samind.powspec.000001.png "+OUTDIR+"samind.powspec.png")
        system("mv "+OUTDIR+"samind.powspec.000002.png "+OUTDIR+"samind.autocor.png")
        system("mv "+OUTDIR+"samind.powspec.000003.png "+OUTDIR+"samind.wavelet.png")
     end if
  else
     if (isfilepresent2(OUTDIR+"samind.spatialcomp.ps")) then
        system("psplit "+OUTDIR+"samind.spatialcomp.ps "+OUTDIR+"psl_ind")
        system("mv "+OUTDIR+"psl_ind0001.ps "+OUTDIR+"samind.spatialcomp.jja0.ps")
        system("mv "+OUTDIR+"psl_ind0002.ps "+OUTDIR+"samind.spatialcomp.son0.ps")
        system("mv "+OUTDIR+"psl_ind0003.ps "+OUTDIR+"samind.spatialcomp.djf1.ps")
        system("mv "+OUTDIR+"psl_ind0004.ps "+OUTDIR+"samind.spatialcomp.mam1.ps")
        system("rm "+OUTDIR+"samind.spatialcomp.ps")
     end if
     if (isfilepresent2(OUTDIR+"samind.spatialcomp.ppt.ps")) then
        system("psplit "+OUTDIR+"samind.spatialcomp.ppt.ps "+OUTDIR+"psl_ind")
        system("mv "+OUTDIR+"psl_ind0001.ps "+OUTDIR+"samind.spatialcomp.pr.jja0.ps")
        system("mv "+OUTDIR+"psl_ind0002.ps "+OUTDIR+"samind.spatialcomp.pr.son0.ps")
        system("mv "+OUTDIR+"psl_ind0003.ps "+OUTDIR+"samind.spatialcomp.pr.djf1.ps")
        system("mv "+OUTDIR+"psl_ind0004.ps "+OUTDIR+"samind.spatialcomp.pr.mam1.ps")
        system("rm "+OUTDIR+"samind.spatialcomp.ppt.ps")
     end if
     if (isfilepresent2(OUTDIR+"samind.timeseries.ps")) then
        system("psplit "+OUTDIR+"samind.timeseries.ps "+OUTDIR+"sampsl_ind")
        system("mv "+OUTDIR+"sampsl_ind0001.ps "+OUTDIR+"samind.timeseries.ps")
        system("mv "+OUTDIR+"sampsl_ind0002.ps "+OUTDIR+"sam_p40S.timeseries.ps")
        system("mv "+OUTDIR+"sampsl_ind0003.ps "+OUTDIR+"sam_p65S.timeseries.ps")
        system("mv "+OUTDIR+"sampsl_ind0004.ps "+OUTDIR+"samlat_mave.timeseries.ps")
        system("mv "+OUTDIR+"sampsl_ind0005.ps "+OUTDIR+"samlat_tave.timeseries.ps")
        system("mv "+OUTDIR+"sampsl_ind0006.ps "+OUTDIR+"samind_norm.timeseries.ps")
     end if
     if (isfilepresent2(OUTDIR+"aslind.timeseries.ps")) then
        system("psplit "+OUTDIR+"aslind.timeseries.ps "+OUTDIR+"aslpsl_ind")
        system("mv "+OUTDIR+"aslpsl_ind0001.ps "+OUTDIR+"aslind.timeseries.ps")
        system("mv "+OUTDIR+"aslpsl_ind0002.ps "+OUTDIR+"asl_clat.timeseries.ps")
        system("mv "+OUTDIR+"aslpsl_ind0003.ps "+OUTDIR+"asl_clon.timeseries.ps")
        system("mv "+OUTDIR+"aslpsl_ind0004.ps "+OUTDIR+"asl_cpsl.timeseries.ps")
        system("mv "+OUTDIR+"aslpsl_ind0005.ps "+OUTDIR+"asl_rmpsl.timeseries.ps")
        system("mv "+OUTDIR+"aslpsl_ind0006.ps "+OUTDIR+"asl_rcpsl.timeseries.ps")
     end if
     if (isfilepresent2(OUTDIR+"samind.powspec.ps")) then
        system("psplit "+OUTDIR+"samind.powspec.ps "+OUTDIR+"samindp")
        system("mv "+OUTDIR+"samindp0001.ps "+OUTDIR+"samind.powspec.ps")
        if (isfilepresent2(OUTDIR+"samindp0002.ps")) then
           system("mv "+OUTDIR+"samindp0002.ps "+OUTDIR+"samind.autocor.ps")
           system("mv "+OUTDIR+"samindp0003.ps "+OUTDIR+"samind.wavelet.ps")
        end if
     end if
  end if
  print("Finished: psl.indices.ncl")
end
