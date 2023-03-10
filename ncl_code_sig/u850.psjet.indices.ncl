; Calculates a variety of pressure indices, as well as hovmollers, spectra, 
; monthly standard deviations, running standard deviations, and spatial
; composites based on the sam index. 
;
; Variables used: ts, ua, and tas
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: u850.psjet.indices.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")  
  
  nsim = numAsciiRow("namelist_byvar/namelist_u850")
  na = asciiread("namelist_byvar/namelist_u850",(/nsim/),"string")
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

;----------- jet spatial composite coding-------------
  nsim_psl = numAsciiRow("namelist_byvar/namelist_psl")
  na_psl = asciiread("namelist_byvar/namelist_psl",(/nsim/),"string")
  names_psl = new(nsim_psl,"string")
  paths_psl = new(nsim_psl,"string")
  syear_psl = new(nsim_psl,"integer",-999)
  eyear_psl = new(nsim_psl,"integer",-999)
  delim = "|"
     
  do gg = 0,nsim-1
     names_psl(gg) = str_strip(str_get_field(na_psl(gg),1,delim))
     paths_psl(gg) = str_strip(str_get_field(na_psl(gg),2,delim))
     syear_psl(gg) = stringtointeger(str_strip(str_get_field(na_psl(gg),3,delim)))
     eyear_psl(gg) = stringtointeger(str_strip(str_get_field(na_psl(gg),4,delim)))
  end do
  delete(na_psl)
  nyr_psl = eyear_psl-syear_psl+1

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
  wks_psjet_mon = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet_mon.timeseries")  
  wks_psjet_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet_djf.timeseries")
  wks_psjet_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet_mam.timeseries")
  wks_psjet_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet_jja.timeseries")
  wks_psjet_son = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet_son.timeseries")
  wks_psjet_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet_ann.timeseries")
  wks_psjet_ts  = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet_ts.timeseries")

  wks_psjetlat_tlon = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjetlat.hov")

  wks_psjet_p = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet.powspec")
  
  wks_psjet_rst = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet.runstddev")

  wks_psjet_mst = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet.monstddev")
  
  wks_psjetsc = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet.spatialcomp")

  wks_psjetsc_ppt = gsn_open_wks(wks_type,getenv("OUTDIR")+"psjet.spatialcomp.ppt")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_psjet_mon,"ncl_default") 
     gsn_define_colormap(wks_psjet_djf,"ncl_default")
     gsn_define_colormap(wks_psjet_mam,"ncl_default")
     gsn_define_colormap(wks_psjet_jja,"ncl_default")
     gsn_define_colormap(wks_psjet_son,"ncl_default")
     gsn_define_colormap(wks_psjet_ann,"ncl_default")
     gsn_define_colormap(wks_psjet_ts,"ncl_default")
     gsn_define_colormap(wks_psjetlat_tlon,"MPL_terrain")
     gsn_define_colormap(wks_psjet_p,"cb_9step")
     gsn_define_colormap(wks_psjet_rst,"ncl_default")   
     gsn_define_colormap(wks_psjet_mst,"ncl_default")   
     gsn_define_colormap(wks_psjetsc,"cmocean_balance")
     gsn_define_colormap(wks_psjetsc_ppt,"MPL_BrBG")  
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_psjet_mon,"ncl_default")
     gsn_define_colormap(wks_psjet_djf,"ncl_default")
     gsn_define_colormap(wks_psjet_mam,"ncl_default")
     gsn_define_colormap(wks_psjet_jja,"ncl_default")
     gsn_define_colormap(wks_psjet_son,"ncl_default")
     gsn_define_colormap(wks_psjet_ann,"ncl_default")
     gsn_define_colormap(wks_psjet_ts,"ncl_default")
     gsn_define_colormap(wks_psjetlat_tlon,"MPL_rainbow")
     gsn_define_colormap(wks_psjet_p,"cb_9step")
     gsn_define_colormap(wks_psjet_rst,"ncl_default")   
     gsn_define_colormap(wks_psjet_mst,"ncl_default")   
     gsn_define_colormap(wks_psjetsc,"BlueDarkRed18")   
     gsn_define_colormap(wks_psjetsc_ppt,"BrownBlue12")    
  end if

  xyn0  = new((/500,nsim/),"graphic")
  xyn1  = new((/500,nsim/),"graphic")
  xyn2  = new((/500,nsim/),"graphic")
  xyn3  = new((/500,nsim/),"graphic")
  xyn4  = new((/500,nsim/),"graphic")
  xyn5  = new((/500,nsim/),"graphic")
  xyn6  = new(nsim,"graphic")  
  xyn7  = new(nsim,"graphic")  
  xyn8 = new(nsim,"graphic")  
  
  plot_jetlat = new(nsim,"graphic")  
  
  map_psjetsc_jja0 = new(nsim,"graphic")  
  map_psjetsc_son0 = new(nsim,"graphic")  
  map_psjetsc_djf1 = new(nsim,"graphic")  
  map_psjetsc_mam1 = new(nsim,"graphic")  

  map_psjetsc_ppt_jja0 = new(nsim,"graphic")  
  map_psjetsc_ppt_son0 = new(nsim,"graphic")  
  map_psjetsc_ppt_djf1 = new(nsim,"graphic")  
  map_psjetsc_ppt_mam1 = new(nsim,"graphic")  

  xypsjet_rst = new(nsim,"graphic")  
  xypsjet_mst = new(nsim,"graphic")  
  xypsjet_ac = new(nsim,"graphic") 
  plot_wave34 = new(nsim,"graphic")  

  pspec = new(nsim,"graphic")
  if (isfilepresent2("obs_ts")) then
     pspec_obs = new(nsim,"graphic")
     xypsjet_ac_obs = new(nsim,"graphic")
  end if

  wgt = (/1.,2.,1./)   
  wgt = wgt/sum(wgt)
  pi=4.*atan(1.0)
  rad=(pi/180.)

  do ee = 0,nsim-1
     ua = data_read_in(paths(ee),"U850",syear(ee),eyear(ee))    ; read in data, orient lats/lons correctly, set time coordinate variable up
     
     if (isatt(ua,"is_all_missing")) then
        delete(ua)
        continue
     end if
 
     ;calcualte jet info with raw ua field  
     llats = -70. ; SH jet region 
     llatn = -20.
     llonw = 0.
     llone = 360.
     finjet = calculate_jet_info(ua,llats,llatn,llonw,llone)

     if (OPT_CLIMO.eq."Full") then
        ua = rmMonAnnCycTLL(ua)
     else
        check_custom_climo(names(ee),syear(ee),eyear(ee),CLIMO_SYEAR,CLIMO_EYEAR)
        temp_arr = ua
        delete(temp_arr&time)
        temp_arr&time = cd_calendar(ua&time,-1)
        if (CLIMO_SYEAR.lt.0) then
           climo = clmMonTLL(temp_arr({(eyear(ee)+CLIMO_SYEAR)*100+1:(eyear(ee)+CLIMO_EYEAR)*100+12},:,:))
        else
           climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))
        end if
        delete(temp_arr)
        ua   = calcMonAnomTLL(ua,climo)
        delete(climo)
     end if

     coswgt=cos(rad*ua&lat)
     coswgt!0 = "lat" 
     coswgt&lat= ua&lat  

     psjetins_mon               = finjet(0,:)
     psjetins_mon@comment_cvdp  = "domain ("+llatn+":"+llats+"S, "+llonw+":"+llone+"E)"
     psjetins_mon@units         = "m s~S~-1~N~"
     psjetins_mon@long_name     = "Polar jet (SH) intensity timeseries (monthly)"

     psjetloc_mon               = finjet(1,:)
     psjetloc_mon@comment_cvdp  = "domain ("+llatn+":"+llats+"S, "+llonw+":"+llone+"E)"
     psjetloc_mon@units         = "degree south"
     psjetloc_mon@long_name     = "Polar jet (SH) latitude timeseries (monthly)"

     psjetind_mon               = finjet(2,:) 
     psjetind_mon@comment_cvdp  = "domain ("+llats+":"+llatn+"S, "+llonw+":"+llone+"E)"
     psjetind_mon@units         = "1"
     psjetind_mon@long_name     = "Polar jet (SH) position index timeseries (monthly)"

     psjetisd_mon               = finjet(3,:)  
     psjetisd_mon@comment_cvdp  = "domain ("+llats+":"+llatn+"S, "+llonw+":"+llone+"E)"
     psjetisd_mon@units         = "1"
     psjetisd_mon@long_name     = "Polar jet (SH) intensity index timeseries (monthly)" 

     delete([/finjet/])
;---------------------------------------------------------------------------------------------
     ;create temporay array for plotting section
     seas  = (/"mon","djf","mam","jja","son","ann"/)
     iname = (/"psjetins","psjetloc"/)
     metric_nam        = new((/dimsizes(iname)/),string)
     jetind_mon        = new((/dimsizes(psjetloc_mon),dimsizes(iname)/),typeof(psjetloc_mon))
     jetind_mon!0      = "time"
     jetind_mon!1      = "x"
     jetind_mon&x      = ispan(0,dimsizes(iname)-1,1)
     jetind_mon&time   = psjetloc_mon&time
     jetind_mon@unit1  = "m/s"
     jetind_mon@unit2  = "degree"

     do ff = 0,dimsizes(iname)-1
       if(iname(ff).eq."psjetins") then
         jetind_mon(:,ff)  = (/psjetins_mon/)
         metric_nam(ff)    = "Polar jet intensity (SH)"
       end if
       if(iname(ff).eq."psjetloc") then
         jetind_mon(:,ff)  = (/psjetloc_mon/)
         metric_nam(ff)    = "Polar jet position (SH)"
       end if
     end do
     jetind_ra_seas      = runave_n_Wrap(jetind_mon,3,0,0)
     jetind_ra_seas(0,:) = (/dim_avg_n(jetind_mon(:1,:),0)/)
     jetind_ra_seas(dimsizes(psjetloc_mon)-1,:) = (/ dim_avg_n(jetind_mon(dimsizes(psjetloc_mon)-2:,:),0) /)
     jetind_ra_ann    = runave_n_Wrap(jetind_mon,12,0,0)
     jetind_djf       = (/jetind_ra_seas(0::12,:)/)
     jetind_mam       = (/jetind_ra_seas(3::12,:)/)
     jetind_jja       = (/jetind_ra_seas(6::12,:)/)
     jetind_son       = (/jetind_ra_seas(9::12,:)/)
     jetind_ann       = (/jetind_ra_ann(5::12,:) /)

     jetind_djf!0    = "TIME"
     jetind_djf&TIME = ispan(syear(ee),eyear(ee),1)
     jetind_djf&TIME@units = "YYYY"
     jetind_djf&TIME@long_name = "time"
     copy_VarMeta(jetind_djf,jetind_mam)
     copy_VarMeta(jetind_djf,jetind_jja)
     copy_VarMeta(jetind_djf,jetind_son)
     copy_VarMeta(jetind_djf,jetind_ann)
     delete([/jetind_ra_seas,jetind_ra_ann/])
;---------------------------------------------------------------------------------------------     
     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.u850.psjet.indices."+syear(ee)+"-"+eyear(ee)+".nc"
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
           date = cd_calendar(psjetind_mon&time,-1)
           date@long_name = "current date (YYYYMM)"
           delete(date@calendar)
           date!0 = "time"
           date&time = psjetind_mon&time
           date@units = "1"
           z->date = date
           delete(date)
        else
           z = addfile(fn,"w")
        end if
        do ff = 0,dimsizes(seas)-1
          do hh = 0,dimsizes(iname)-1
            sea  = str_upper(seas(ff))
            if(seas(ff).eq."mon") then
              vout = jetind_mon(:,hh)
              sea  = "monthly"
            else if (seas(ff).eq."djf") then
              vout = jetind_djf(:,hh)
            else if (seas(ff).eq."mam") then
              vout = jetind_mam(:,hh)
            else if (seas(ff).eq."jja") then
              vout = jetind_jja(:,hh)
            else if (seas(ff).eq."son") then
              vout = jetind_son(:,hh)
            else if (seas(ff).eq."ann") then
              vout = jetind_ann(:,hh)
            else
              print("season does not exist")
            end if
            end if
            end if
            end if
            end if
            end if
            vout@comment_cvdp = "domain(20-70S)"
            if(isStrSubset(iname(hh),"ins")) then
               vout@units  = ua@units
            else
               vout@units  = "degree"
            end if
            vout@long_name = metric_nam(hh) + " timeseries (" +sea+")"
            vonm = iname(hh)+"_" + seas(ff)
            z->$vonm$  = set_varAtts(vout,"","","")
            delete([/vonm,vout,sea/])
          end do
        end do

        z->psjetind_mon   = set_varAtts(psjetind_mon,"","","")
        z->psjetisd_mon   = set_varAtts(psjetisd_mon,"","","")
        delete([/modname,fn/])
     end if

;---------------------------------------------------------------------------------------------
     if (nyr(ee).ge.15) then   ; 15+ years needed for this metric
        finua              = ua(:,0,:)
        finua              = ua@_FillValue 
        finua@long_name    = "Polar Jet Latitude Position"
        finua@units        = "degree"
        finua_mave         = finua(lon|0:2,time|:) 
        finua_tave         = finua(time|0:2,lon|:) 
        finua@comment_cvdp      = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
        finua_mave@comment_cvdp = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"
        finua_tave@comment_cvdp = "domain ("+llats+":"+llatn+"N, "+llonw+":"+llone+"E)"

        do gg = 30,dimsizes(psjetind_mon)-31
          mocntr1 = gg - 30  
          mocntr2 = gg + 30
          vsec = ua(0,{llats:llatn},:)
          vsec = (/escovc(psjetind_mon(time|mocntr1:mocntr2), ua({lat|llats:llatn},{lon|:},time|mocntr1:mocntr2))/)
          ;Polar Jet latitude is search as location with smallest absolute covariance (Paul Wachter et al., 2020)
          vsec = abs(vsec) 
          vsec = where(ismissing(vsec),1e8,vsec)
          do hh = 0,dimsizes(vsec(0,:))-1
            imin = local_min_1d(vsec(:,hh),False, 0, 1)
            if (.not.all(ismissing(imin))) then
              if(dimsizes(imin).gt.1) then
                imin0 = dim_minind(vsec(imin,hh),0)
                finua(gg,hh) = tofloat(vsec&lat(imin(imin0)))
                delete([/imin0/]) 
              else
                finua(gg,hh) = tofloat(vsec&lat(imin))
              end if 
            else  
              imin0 = dim_minind(vsec(:,hh),0)
              finua(gg,hh) = tofloat(vsec&lat(imin0))
              delete([/imin0/])
            end if
            delete([/imin/])
          end do
          delete([/vsec,mocntr1,mocntr2/])
        end do

       ;apply a smoothing to reduce noise  
        finua_sm = smth9(finua, 0.50,  0.25, True)
        finua_sm = where(abs(finua_sm).ge.89,finua,finua_sm)
        finua    = (/finua_sm/) 
        delete([/finua_sm/])

        ;calculate the zonal and time  average and varibility 
        finua_mave(0,:) = dim_avg_n(finua,1)
        finua_mave(1,:) = dim_min_n(finua,1)
        finua_mave(2,:) = dim_max_n(finua,1)
        finua_tave(0,:) = dim_avg_n(finua,0)
        finua_tave(1,:) = dim_min_n(finua,0)
        finua_tave(2,:) = dim_max_n(finua,0)
        
        if (OUTPUT_DATA.eq."True") then 
           time_mon0           = cd_calendar(ua&time,1) 
           time_mon0!0         = "time_mon0"
           time_mon0&time_mon0 = time_mon0
           time_mon0@long_name = "Time"
           time_mon0@calendar  = "standard"
           time_mon0@standard_name = "time"
           lon0                = finua&lon
           lon0@standard_name  = "longitude"
           hov_all             = (/ finua /)
           hov_all!0           = "time_mon0"
           hov_all&time_mon0   = time_mon0
           hov_all!1           = "lon0"
           hov_all&lon0        = lon0
           hov_all@units       = "degree"
           hov_all@_FillValue  = finua@_FillValue 
           hov_mave            = (/ finua_mave /)
           hov_mave!0          = "nx"
           hov_mave!1          = "time_mon0"
           hov_mave&time_mon0  = hov_all&time_mon0
           hov_mave@units      = "degree"
           hov_tave            = (/ finua_tave /)
           hov_tave!0          = "nx"
           hov_tave!1          = "lon0"
           hov_tave&lon0       = hov_all&lon0
           hov_tave@units      = "degree"
           z->jetlat_hov_all  = set_varAtts(hov_all, "Polar Jet Position hovmoller (time-lon)","","")
           z->jetlat_hov_mave = set_varAtts(hov_mave,"Polar Jet Position time series (lon mean)","","")
           z->jetlat_hov_tave = set_varAtts(hov_tave,"Polar Jet Position meridional series (time mean)","","")
           delete([/hov_mave,hov_tave,hov_all,time_mon0,lon0/])
        end if
     end if     

;- - - - - -psjet spatial composite section- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     psjetT         = wgt_runave(psjetloc_mon,wgt,1)        ; for use in Polar Jet composites / running standard deviations
     psjet_jja      = psjetT(6:dimsizes(psjetT)-13:12)  ; cannot count last 1yr as spatial composite uses +1yrs data betond JAS..
     psjet_jja      = dim_standardize(psjet_jja,0)
     psjet_jja!0    = "time"
     psjet_jja&time = ispan(syear(ee),eyear(ee)-1,1)
     psjet_jja      = dtrend_msg(ispan(0,dimsizes(psjet_jja&time)-1,1),psjet_jja,True,False)

     cntr_hi         = 0
     cntr_lo         = 0
     cntr_mid        = 0
     cntr_lo@_FillValue = default_fillvalue(typeof(cntr_lo))
     cntr_mid@_FillValue = default_fillvalue(typeof(cntr_mid))
     cntr_hi@_FillValue = default_fillvalue(typeof(cntr_hi))
     do gg = 0,dimsizes(psjet_jja)-1
        if (.not.ismissing(psjet_jja(gg))) then    
           if (psjet_jja(gg).ge.1.0) then
              cntr_hi = cntr_hi+1
           end if
           if (psjet_jja(gg).ge.-0.5.and.psjet_jja(gg).le.0.5) then
              cntr_mid = cntr_mid+1
           end if 
           if (psjet_jja(gg).le.-1.0) then
              cntr_lo = cntr_lo+1
           end if 
        end if
     end do

     if (any(ismissing((/syear(ee),syear_trefht(ee),syear_psl(ee),syear_ts(ee),eyear(ee),eyear_trefht(ee),eyear_psl(ee),eyear_ts(ee)/)))) then
        tassstreg_plot_flag = 1
     else
        if (syear(ee).eq.syear_trefht(ee).and.syear(ee).eq.syear_psl(ee).and.syear(ee).eq.syear_ts(ee)) then     ; check that the start and end years match for ts, trefht, and psl
           if (eyear(ee).eq.eyear_trefht(ee).and.eyear(ee).eq.eyear_psl(ee).and.eyear(ee).eq.eyear_ts(ee)) then
              tassstreg_plot_flag = 0
           else
              tassstreg_plot_flag = 1
           end if
        else
           tassstreg_plot_flag = 1
        end if
     end if

     if (tassstreg_plot_flag.eq.0) then

       psl = data_read_in(paths_psl(ee),"PSL",syear_psl(ee),eyear_psl(ee)) 
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
       yyyymm = cd_calendar(psl&time,-1)  ; convert tas, ts, and ua from CF-conforming time to YYYYMM for coding below
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

       if (isatt(psl,"is_all_missing").or.isatt(tas,"is_all_missing").or.isatt(sst,"is_all_missing")) then
          tassstreg_plot_flag = 1
          delete([/tas,sst,psl/])
       end if

       if (nyr(ee).lt.15) then   ; 15+ years needed for composites
          tassstreg_plot_flag = 1
       end if

       if (tassstreg_plot_flag.eq.0) then     ; only continue if all 3 fields are present
          if (OPT_CLIMO.eq."Full") then
             tas = rmMonAnnCycTLL(tas)
             sst = rmMonAnnCycTLL(sst)           
             psl = rmMonAnnCycTLL(psl)
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

             check_custom_climo(names_psl(ee),syear_psl(ee),eyear_psl(ee),CLIMO_SYEAR,CLIMO_EYEAR)
             temp_arr = psl
             delete(temp_arr&time)
             temp_arr&time = cd_calendar(psl&time,-1)
             if (CLIMO_SYEAR.lt.0) then
               climo = clmMonTLL(temp_arr({(eyear_psl(ee)+CLIMO_SYEAR)*100+1:(eyear_psl(ee)+CLIMO_EYEAR)*100+12},:,:))
             else
               climo = clmMonTLL(temp_arr({CLIMO_SYEAR*100+1:CLIMO_EYEAR*100+12},:,:))
             end if
             delete(temp_arr)
             psl   = calcMonAnomTLL(psl,climo)
             delete(climo)

          end if

          psl = (/ dtrend_msg_n(ispan(0,dimsizes(psl&time)-1,1),psl,False,False,0) /)
          tas = (/ dtrend_msg_n(ispan(0,dimsizes(tas&time)-1,1),tas,False,False,0) /)     
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
          hiyr = new(dimsizes(psjet_jja&time),integer)
          loyr = hiyr

          do hh = 0,dimsizes(psjet_jja)-1
             if (.not.ismissing(psjet_jja(hh))) then
                if (psjet_jja(hh).ge.1.0) then
                   hiyr(hicntr) = psjet_jja&time(hh)
                   hicntr = hicntr+1
                end if
                if (psjet_jja(hh).le.-1.0) then
                   loyr(locntr) = psjet_jja&time(hh)
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
             print("For "+names(ee)+", 1 or less (normalized) psjet value greater than one standard deviation found, setting psjet spatial composites to missing")  ; sc_*_hi arrays left to _FillValue
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
             print("For "+names(ee)+", 1 or less (normalized) psjet value less than -1 standard deviation found, setting psjet spatial composites to missing")   ; sc_*_lo arrays left to _FillValue
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
          
          psjetsc_psl = sc_psl_hi
          psjetsc_psl = (/ sc_psl_hi - sc_psl_lo /)
          psjetsc_sst = sc_sst_hi
          psjetsc_sst = (/ sc_sst_hi - sc_sst_lo /)
          psjetsc_tas = sc_tas_hi
          psjetsc_tas = (/ sc_tas_hi - sc_tas_lo /)
          delete([/sc_psl_hi,sc_psl_lo,sc_sst_hi,sc_sst_lo,sc_tas_hi,sc_tas_lo/])
          delete(ua&time)
          ua&time = TIME    
          delete(TIME)       
                     
          if (OUTPUT_DATA.eq."True") then
             psjetsc_psl&lat@standard_name = "latitude"
             psjetsc_psl&lon@standard_name = "longitude"
             z->psjet_spacomp_psl_jja0 = set_varAtts(psjetsc_psl(6,:,:),"psjet psl spatial composite (JJA+0)","","")
             z->psjet_spacomp_psl_son0 = set_varAtts(psjetsc_psl(9,:,:),"psjet psl spatial composite (SON+0)","","")
             z->psjet_spacomp_psl_djf1 = set_varAtts(psjetsc_psl(12,:,:),"psjet psl spatial composite (DJF+1)","","")
             z->psjet_spacomp_psl_mam1 = set_varAtts(psjetsc_psl(15,:,:),"psjet psl spatial composite (MAM+1)","","")

             modname = str_sub_str(names_trefht(ee)," ","_")
             bc = (/"/","'","(",")"/)
             do gg = 0,dimsizes(bc)-1
                modname = str_sub_str(modname,bc(gg),"_")
             end do
             fn = getenv("OUTDIR")+modname+".cvdp_data.u850.u850.psjet.indices.tas."+syear_trefht(ee)+"-"+eyear_trefht(ee)+".nc"
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
             z_tas->psjet_spacomp_tas_jja0 = set_varAtts(psjetsc_tas(6,:,:),"psjet tas spatial composite (JJA+0)","","")   
             z_tas->psjet_spacomp_tas_son0 = set_varAtts(psjetsc_tas(9,:,:),"psjet tas spatial composite (SON+0)","","") 
             z_tas->psjet_spacomp_tas_djf1 = set_varAtts(psjetsc_tas(12,:,:),"psjet tas spatial composite (DJF+1)","","") 
             z_tas->psjet_spacomp_tas_mam1 = set_varAtts(psjetsc_tas(15,:,:),"psjet tas spatial composite (MAM+1)","","") 
             delete(z_tas)
             delete(modname)
             
             modname = str_sub_str(names_ts(ee)," ","_")
             bc = (/"/","'","(",")"/)
             do gg = 0,dimsizes(bc)-1
                modname = str_sub_str(modname,bc(gg),"_")
             end do
             fn = getenv("OUTDIR")+modname+".cvdp_data.u850.psjet.indices.sst."+syear_trefht(ee)+"-"+eyear_trefht(ee)+".nc"
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
             z_sst->psjet_spacomp_sst_jja0 = set_varAtts(psjetsc_sst(6,:,:),"psjet sst spatial composite (JJA+0)","","")   
             z_sst->psjet_spacomp_sst_son0 = set_varAtts(psjetsc_sst(9,:,:),"psjet sst spatial composite (SON+0)","","")   
             z_sst->psjet_spacomp_sst_djf1 = set_varAtts(psjetsc_sst(12,:,:),"psjet sst spatial composite (DJF+1)","","")   
             z_sst->psjet_spacomp_sst_mam1 = set_varAtts(psjetsc_sst(15,:,:),"psjet sst spatial composite (MAM+1)","","")   
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
     if (isvar("psl")) then
        delete(psl)
     end if
;-------------psjet composite (precipitation)-----------------------------------------------------
     if (any(ismissing((/syear(ee),syear_prect(ee),eyear(ee),eyear_prect(ee)/)))) then
        pptreg_plot_flag = 1
     else
        if (syear(ee).eq.syear_prect(ee)) then     ; check that the start and end years match for ts, trefht, and ua
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
         ;  tas = mask(tas,conform(tas,lsm,(/1,2/)).eq.0,False)              ; in the psjet pattern correlations
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
           hiyr = new(dimsizes(psjet_jja&time),integer)
           loyr = hiyr

           do hh = 0,dimsizes(psjet_jja)-1
              if (.not.ismissing(psjet_jja(hh))) then
                 if (psjet_jja(hh).ge.1) then
                    hiyr(hicntr) = psjet_jja&time(hh)
                    hicntr = hicntr+1
                 end if
                 if (psjet_jja(hh).le.-1) then
                    loyr(locntr) = psjet_jja&time(hh)
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
              print("For "+names(ee)+", 1 or less (normalized) psjet value greater than one standard deviation found, setting psjet spatial composites to missing")  ; sc_*_hi arrays left to _FillValue
           else           
              do gg = 0,23
                 tt = gg/12.
                 sc_ppt_hi(gg,:,:) = (/ dim_avg_n(ppt({highyr+tt},:,:),0) /)
              end do
              delete(tt)
           end if
           delete(highyr)
           if (dimsizes(lowyr).le.1) then
              print("For "+names(ee)+", 1 or less (normalized) psjet value less than -1 standard deviation found, setting psjet spatial composites to missing")   ; sc_*_lo arrays left to _FillValue
           else           
              do gg = 0,23
                 tt = gg/12.
                 sc_ppt_lo(gg,:,:) = (/ dim_avg_n(ppt({lowyr+tt},:,:),0) /)
              end do
              delete(tt)
           end if
           delete(lowyr)
           
           psjetsc_ppt = sc_ppt_hi
           psjetsc_ppt = (/ sc_ppt_hi - sc_ppt_lo /)
           delete([/sc_ppt_hi,sc_ppt_lo/])     
                      
           if (OUTPUT_DATA.eq."True") then
              modname = str_sub_str(names_prect(ee)," ","_")
              bc = (/"/","'","(",")"/)
              do gg = 0,dimsizes(bc)-1
                 modname = str_sub_str(modname,bc(gg),"_")
              end do
              fn = getenv("OUTDIR")+modname+".cvdp_data.u850.psjet.indices.ppt."+syear_trefht(ee)+"-"+eyear_trefht(ee)+".nc"
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
              z_ppt->psjet_spacomp_pr_jja0 = set_varAtts(psjetsc_ppt(6,:,:),"psjet pr spatial composite (JJA+0)","","")      
              z_ppt->psjet_spacomp_pr_son0 = set_varAtts(psjetsc_ppt(9,:,:),"psjet pr spatial composite (SON+0)","","")
              z_ppt->psjet_spacomp_pr_djf1 = set_varAtts(psjetsc_ppt(12,:,:),"psjet pr spatial composite (DJF+1)","","")
              z_ppt->psjet_spacomp_pr_mam1 = set_varAtts(psjetsc_ppt(15,:,:),"psjet pr spatial composite (MAM+1)","","")
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
     delete([/ua,psjet_jja/])
;-----------------------------------------------------------------------------------------     
     if (nyr(ee).ge.20) then    ; need a minimum number of years to compute running psjet standard deviations
        psjetT = dtrend_msg(ispan(0,dimsizes(psjetT)-1,1),psjetT,True,False)
        psjetT!0 = "time"
        psjetT&time = psjetloc_mon&time
        sd_run = psjetT
        sd_run = sd_run@_FillValue
        sd_run@units = psjetloc_mon@units
        sd_run@long_name = "Polar jet (SH) position 15yr running standard deviation"
        do gg = 90,dimsizes(psjetT)-90
           sd_run(gg) = (/ dim_stddev(psjetT(gg-90:gg+89)) /)
        end do
        if (OUTPUT_DATA.eq."True") then
           z->psjet_runstddev = set_varAtts(sd_run,"","","")
        end if
     end if
     delete(psjetT)
;-----------------------------------------------------------------------------------------
     iopt = 0                ; psjet power spectra
     jave = max((/3,(7*nyr(ee))/100/))
     val1 = .95
     val2 = .99
     pct = 0.1 
     spectra_mvf = False        ; missing value flag for psjet
     psjetloc_mon_nm = dim_standardize(psjetloc_mon,0)
     if (any(ismissing(psjetloc_mon_nm))) then     ; check for missing data                                                            
        print("Missing data detected for "+names(ee)+", not creating spectra in u850.psjet.indices.ncl") 
        spectra_mvf = True
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           spectra_mvf_obs = True
        end if
     else
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           spectra_mvf_obs = False   ; missing value flag for obs psjet
        end if
        psjet_dt = dtrend_msg(ispan(0,dimsizes(psjetloc_mon_nm)-1,1),psjetloc_mon_nm,True,False) 
    
        sdof = specx_anal(psjet_dt,iopt,jave,pct)
        mval = sum(1/(1.+((sdof@xlag1)^2)-((2*sdof@xlag1)*cos(6.28318*sdof@frq))))
        if (mval.eq.0) then ; check for cyclic data that results in sum of Markov elements = 0.
           spectra_mvf = True
           if (isfilepresent2("obs_ts").and.ee.eq.0) then
              spectra_mvf_obs = True   ; missing value flag for obs psjet
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
              splt1@units = "1/df"
              splt1@comment_cvdp = "(0,:)=spectrum,(1,:)=Markov red noise spectrum, (2,:)="+val1+"% confidence bound for Markhov, (3,:)="+val2+"% confidence bound for Markhov"
              z->psjet_spectra = set_varAtts(splt1,"psjet power spectra","","")
           end if
           if (isfilepresent2("obs_ts").and.ee.eq.0) then
              sdof_obs = sdof
           end if
        end if
        delete([/psjet_dt,psjetloc_mon_nm,iopt,jave,pct,mval/])
     end if
;------------------------------------------------------------------------------------------
     psjet_dt = dtrend_msg(ispan(0,dimsizes(psjetloc_mon&time)-1,1),psjetloc_mon,True,False)
     psjet_mon_sd = new(12,typeof(psjetloc_mon))
     
     do hh = 0,11
        psjet_mon_sd(hh) = (/ dim_stddev(psjet_dt(hh::12)) /)
     end do
     psjet_mon_sd@units = "latitude (degree)"
     if (OUTPUT_DATA.eq."True") then
        time_mon2 = ispan(0,11,1)
        time_mon2@units = "months since 0000-01-01 00:00:00"
        time_mon2@long_name = "Time"
        time_mon2@standard_name = "time"
        time_mon2@calendar = "standard"
        time_mon2!0 = "time_mon2"
        time_mon2&time_mon2 = time_mon2
        psjet_mon_sd!0 = "time_mon2"
        psjet_mon_sd&time_mon2 = time_mon2
        z->psjet_monthly_stddev = set_varAtts(psjet_mon_sd,"psjet monthly standard deviation","","")
        delete(time_mon2)
     end if
;------------------------------------------------------------------------------------------
;    psjet wavelet analysis, autocorrelation

     if (spectra_mvf.eq.False) then
        N       = dimsizes(psjetloc_mon)       
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
        wave34 = wavelet(psjetloc_mon,mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)

        power34            = onedtond(wave34@power,(/jtot,N/))
        power34!0          = "period"                    
        power34&period     = wave34@period
        power34&period@long_name = "wavelet period"
        power34&period@units = "1"
        power34!1          = "time"                     
        power34&time       = psjetloc_mon&time
        power34@units      = psjetloc_mon@units+"^2"

        sig34              = power34                       
        sig34              = power34/conform (power34,wave34@signif,0)
        sig34@long_name    = "wavelet significance"
        sig34@units        = ""
        delete([/N,mother,param,dt,s0,dj,jtot,npad,nadof,noise,siglvl,isigtest/])

        ac34 = esacr(psjet_dt,48)
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
           z->psjet_wavelet_power = set_varAtts(power34,"psjet wavelet power","","")
           z->psjet_wavelet_significance = set_varAtts(sig34,"psjet wavelet significance","","")
           z->psjet_autocorrelation = set_varAtts(ac34,"psjet autocorrelation","","")
        end if
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           ac34_obs = ac34
        end if
     end if
     delete(psjet_dt)    
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
     
     xyres3 = xyres            ; resource list for monthly psjet standard deviations
     xyres3@trXMinF = 0.5
     xyres3@trXMaxF = 12.5
     xyres3@vpWidthF = 0.65
     xyres3@vpHeightF = 0.35
     xyres3@trYMinF = 0.0
     xyres3@trYMaxF = 8.0
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
     
     xyres4 = xyres      ; resource list for psjet autocorrelations
     xyres4@trXMinF = 0.0
     xyres4@trXMaxF = 48.0
     xyres4@trYMinF = -0.55
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
     xyres4@tmYLValues = (/-0.5,0,0.5,1/)
     xyres4@tmYLLabels = (/"-0.5","0","0.5","1"/)
     xyres4@tmYLMinorValues = fspan(-0.5,1,9)
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

     do hh = 0,dimsizes(iname)-1,1
      do ff = 0,dimsizes(seas)-1,1
       if (seas(ff).eq."mon") then
          temp = jetind_mon(:,hh)
       else if (seas(ff).eq."djf") then
          temp = jetind_djf(:,hh)
       else if (seas(ff).eq."mam") then
          temp = jetind_mam(:,hh)
       else if (seas(ff).eq."jja") then
          temp = jetind_jja(:,hh)
       else if (seas(ff).eq."son") then
          temp = jetind_son(:,hh)
       else if (seas(ff).eq."ann") then
          temp = jetind_ann(:,hh)
       else
         print ("decleared wrong season...")
       end if
       end if
       end if
       end if
       end if
       end if

       temp@comment_cvdp = "domain(20S-70S)"
       if(isStrSubset(iname(hh),"ins")) then
          temp@units  = jetind_mon@unit1
       else
          temp@units  = jetind_mon@unit2
       end if
       temp@long_name = metric_nam(hh) + " timeseries (" +str_upper(seas(ff))+")"
       arr = new((/3,dimsizes(temp)/),typeof(temp))
       tttt = dtrend_msg(ispan(0,dimsizes(temp)-1,1),temp,False,True)
       arr(0,:) = (/ temp /)
       arr(1,:) = (/ runave_n(temp, 3, 0, 0) /)
       arr(2,:) = (/ (ispan(0,dimsizes(temp)-1,1)*tttt@slope)+tttt@y_intercept /)
       xyres6@tiYAxisString  = temp@units
       xyres6@tiXAxisString  = ""      ; add an axis title
       xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(temp),2,True)+" "+temp@units+" "+nyr(ee)+"yr~S~-1~N~"
       if (seas(ff).eq."mon") then
          xyn0(hh,ee) = gsn_csm_xy(wks_psjet_mon,fspan(syear(ee),eyear(ee)+.91667,dimsizes(temp)),arr,xyres6)
       else if (seas(ff).eq."djf") then
          xyn1(hh,ee) = gsn_csm_xy(wks_psjet_djf,fspan(syear(ee),eyear(ee)+.91667,dimsizes(temp)),arr,xyres6)
       else if (seas(ff).eq."mam") then
          xyn2(hh,ee) = gsn_csm_xy(wks_psjet_mam,fspan(syear(ee),eyear(ee)+.91667,dimsizes(temp)),arr,xyres6)
       else if (seas(ff).eq."jja") then
          xyn3(hh,ee) = gsn_csm_xy(wks_psjet_jja,fspan(syear(ee),eyear(ee)+.91667,dimsizes(temp)),arr,xyres6)
       else if (seas(ff).eq."son") then
          xyn4(hh,ee) = gsn_csm_xy(wks_psjet_son,fspan(syear(ee),eyear(ee)+.91667,dimsizes(temp)),arr,xyres6)
       else if (seas(ff).eq."ann") then
          xyn5(hh,ee) = gsn_csm_xy(wks_psjet_ann,fspan(syear(ee),eyear(ee)+.91667,dimsizes(temp)),arr,xyres6)
       else
         print ("decleared wrong season...")
       end if
       end if
       end if
       end if
       end if
       end if
       delete([/arr,tttt,temp/])
     end do
     end do

     arr = new((/3,dimsizes(psjetloc_mon)/),typeof(psjetind_mon))
     xyres61 = xyres6
     tttt = dtrend_msg(ispan(0,dimsizes(finua_mave(0,:))-1,1),finua_mave(0,:),False,True)
     arr(0,:) = (/ finua_mave(0,:) /)
     arr(1,:) = (/ runave_n(finua_mave(0,:), 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(finua_mave(0,:))-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres61@trYMinF = -70.0
     xyres61@trYMaxF = -20.0 
     xyres61@tiYAxisString  = "Latitude (degree)"      ; add an axis title
     xyres61@tiXAxisString  = ""      ; add an axis title
     xyres61@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(finua_mave(0,:)),2,True)+" "+finua_mave@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn6(ee) = gsn_csm_xy(wks_psjet_ts,fspan(syear(ee),eyear(ee)+.91667,dimsizes(finua_mave(0,:))),arr,xyres61)
     if(.not.isvar("xdum")) then
        xdum = new(1000,graphic)
     end if
     xyres7@trYMinF = min(finua_mave(:,:))
     xyres7@trYMaxF = max(finua_mave(:,:))
     xdum(ee) = gsn_csm_xy(wks_psjet_ts,fspan(syear(ee),eyear(ee)+.91667,dimsizes(finua_mave(0,:))),finua_mave(1:2,:),xyres7)
     overlay(xyn6(ee),xdum(ee))
     delete([/tttt,xyres61/])

     xyres62   = xyres6
     tttt      = avg(finua_tave(0,:))
     arr0      = new((/3,dimsizes(finua_tave(0,:))/),typeof(finua_tave))
     arr0(0,:) = (/ finua_tave(0,:) /)
     arr0(1,:) = (/ runave_n(finua_tave(0,:), 3, 0, 0) /)
     arr0(2,:) = (/ tttt/)
     xyres62@trYMinF = -70.0
     xyres62@trYMaxF = -20.0
     xyres62@trXMinF = tofloat(min(finua_tave&lon))
     xyres62@trXMaxF = tofloat(max(finua_tave&lon))
     xyres62@tiYAxisString  = "Latitude (degree)"      ; add an axis title
     xyres62@tiXAxisString  = "Longitude (degree)"      ; add an axis title
     xyres62@gsnRightString = "mean: "+ decimalPlaces(tttt,2,True)+finua_tave@units
     xyn7(ee) = gsn_csm_xy(wks_psjet_ts,finua_tave&lon,arr0,xyres62)
     if(.not.isvar("xdum")) then
        xdum = new(1000,graphic)
     end if
     xyres7@trYMinF = min(finua_tave(:,:))
     xyres7@trYMaxF = max(finua_tave(:,:))
     xdum(100+ee) = gsn_csm_xy(wks_psjet_ts,finua_tave&lon,finua_tave(1:2,:),xyres7)
     overlay(xyn7(ee),xdum(100+ee))
     delete([/tttt,xyres62,arr0/])

     ;*********************************
     ;plot the jet position normalized index (also mark positive and negative events) 
     ;*********************************
     tttt = dtrend_msg(ispan(0,dimsizes(psjetind_mon)-1,1),psjetind_mon,False,True)
     arr(0,:) = (/ psjetind_mon /)
     arr(1,:) = (/ runave_n(psjetind_mon, 11, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(psjetind_mon)-1,1)*tttt@slope)+tttt@y_intercept /)
     arr0     = psjetind_mon 
     arr1     = psjetind_mon
     arr2     = psjetind_mon 
     arr0     =  0
     arr1     =  1 
     arr2     = -1
     xyres5@trYMinF = -4.0 
     xyres5@trYMaxF =  4.0
     xyres5@tiYAxisString  = "Polar Jet Position (norm.)"          ; add an axis title
     xyres5@tiXAxisString  = ""      ; add an axis title
     xyres5@gsnRightString = "trend: "+decimalPlaces(tttt@slope*dimsizes(psjetind_mon),2,True)+" "+nyr(ee)+"yr~S~-1~N~"
     xyn8(ee) = gsn_csm_xy(wks_psjet_ts,fspan(syear(ee),eyear(ee)+.91667,dimsizes(psjetind_mon)),arr(0,:),xyres5)
     if(.not.isvar("dum")) then 
        dum = new(1000,graphic)
     end if  
     dum(ee)     = gsn_add_polyline(wks_psjet_ts,xyn8(ee),fspan(syear(ee),eyear(ee)+.91667,dimsizes(psjetind_mon)),arr0,gsLine) 
     dum(ee+100) = gsn_add_polyline(wks_psjet_ts,xyn8(ee),fspan(syear(ee),eyear(ee)+.91667,dimsizes(psjetind_mon)),arr1,gsLin0)
     dum(ee+200) = gsn_add_polyline(wks_psjet_ts,xyn8(ee),fspan(syear(ee),eyear(ee)+.91667,dimsizes(psjetind_mon)),arr2,gsLin1)
     dum(ee+300) = gsn_add_text(wks_psjet_ts,xyn8(ee),"Jet (+) " + num(psjetind_mon.ge.1),syear(ee)+0.2, 2.50, txre0)
     dum(ee+400) = gsn_add_text(wks_psjet_ts,xyn8(ee),"Jet (-) " + num(psjetind_mon.le.-1),syear(ee)+0.2,-2.50, txre1)
     delete([/xyres5,gsLine,gsLin0,gsLin1,txre0,txre1/])
     delete([/arr,tttt,arr0,arr1,arr2/])
 
     xyres2@gsnLeftString = names(ee)
     if (nyr(ee).ge.20) then
        xyres2@gsnRightString = sprintf("%4.2f", min(sd_run))+" / "+sprintf("%4.2f", avg(sd_run))+" / "+sprintf("%4.2f", max(sd_run))+sd_run@units
        xypsjet_rst(ee) = gsn_csm_xy(wks_psjet_rst,fspan(syear(ee),eyear(ee)+.91667,dimsizes(sd_run)),sd_run,xyres2)
     end if
     
     xyres3@gsnRightStringFontHeightF = xyres3@gsnCenterStringFontHeightF
     xyres3@gsnLeftString = syear(ee)+"-"+eyear(ee)
     xyres3@gsnCenterString = names(ee)
     xyres3@gsnRightString = "degree"
     if (max(psjet_mon_sd).gt.xyres3@gsnYRefLine) then
        xypsjet_mst(ee) = gsn_csm_xy(wks_psjet_mst,ispan(1,12,1),psjet_mon_sd,xyres3)
     end if
     title_n0  = "domain(20S-70S)"
     title_n1  = "domain(20S-70S)" 
     title_n2  = "domain(20S-70S)"
     title_n3  = "domain(20S-70S)"

     delete([/psjetind_mon,finua_mave,finua_tave,psjetisd_mon,psjetins_mon,psjetloc_mon/])
     delete([/jetind_djf,jetind_mam,jetind_jja,jetind_son,jetind_ann,jetind_mon/])

     if (spectra_mvf.eq.False) then
        xyres4@gsnCenterString = names(ee)
        xyres4@gsnRightString = syear(ee)+"-"+eyear(ee)
        xypsjet_ac(ee) = gsn_csm_xy(wks_psjet_p,ispan(0,48,1),ac34,xyres4)
        if (ee.ge.1.and.isvar("ac34_obs")) then
           delete([/xyres4@gsnAboveYRefLineColor,xyres4@gsnBelowYRefLineColor/])
           xyres4@xyLineColor = "gray62"
           xyres4@xyCurveDrawOrder = "PreDraw"
           xyres4@gsnCenterString = ""
           xyres4@gsnRightString = ""
           xypsjet_ac_obs(ee) = gsn_csm_xy(wks_psjet_p,ispan(0,48,1),ac34_obs,xyres4)
           overlay(xypsjet_ac(ee),xypsjet_ac_obs(ee)) 
           delete(xyres4@xyCurveDrawOrder)
           delete(ac34)
        end if
     end if
     delete([/xyres,xyres2,xyres3,xyres4,psjet_mon_sd/])
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
     yymm        = yyyymm_time(syear(ee), eyear(ee), "integer")
     yyyyFrac    = yyyymm_to_yyyyfrac(yymm, 0.0)

     res = True
     res@vpHeightF = 0.45
     res@vpWidthF = 0.35
     res@gsnFrame = False
     res@gsnDraw = False 
  
     res@tmYLMode        = "Explicit"
     res@tmYLValues      = yyyyFrac(::60)
     res@tmYLLabels      = yymm(::60) 
     res@tmYLMinorValues = yyyyFrac(::12)

     res@tmYLLabelJust = "CenterCenter"               
     res@tmYLLabelDeltaF = 1.3    ;0.05
     res@cnFillOn = True
    ;res@gsnSpreadColors = True  
    ;res@gsnSpreadColorEnd = 19
     
     res@lbLabelBarOn = False
  
     res@tiMainOn = False
     res@cnInfoLabelOn = False
     res@cnLinesOn = True
     res@cnLevelSelectionMode = "ExplicitLevels"
     res@cnLevels = fspan(-60,-40,11) 
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
        res@cnLineThicknessF = 1.
     else
        res@cnLineThicknessF = 0.5
     end if     
     res@gsnCenterStringOrthogonalPosF = 0.025
     res@gsnRightStringOrthogonalPosF = res@gsnCenterStringOrthogonalPosF
     res@gsnCenterStringFontHeightF = 0.017
     res@gsnLeftStringFontHeightF = 0.017
     res@gsnRightStringFontHeightF = 0.017

     res@gsnLeftString = ""
     res@gsnCenterString= ""
     res@gsnRightString = ""

     if (isfilepresent2("obs_ts").and.ee.eq.0.and.isvar("finua")) then      ; for metrics table
        patcor_hov         = new((/nsim,dimsizes(finua&time),dimsizes(finua&lon)/),typeof(finua))
        patcor_hov!1       = "time"
        patcor_hov&time    = finua&time
        patcor_hov!2       = "lon"
        patcor_hov&lon     = finua&lon
        patcor_hov(ee,:,:) = (/ finua /) 
     end if

     if (isfilepresent2("obs_ts").and.ee.ge.1.and.isvar("patcor_hov_hi").and.isvar("finua_mave")) then    
        dimT = dimsizes(finua_mave&time)
        do hh = 0,dimT-1     ; need to loop over each timestep, using linint1 to interpolate to set longitudes. 
           patcor_hov(ee,hh,:) = (/ totype(linint1(finua&lon,finua(hh,:),False,patcor_hov&lon,0),typeof(patcor_hov)) /)
        end do
     end if

     if (isvar("finua")) then    
        res@gsnCenterString = names(ee)   ;"Polar Jet(+)"
        res@gsnRightString  = "" ;"Polar Jet Latitude Position (Degree)"
        delete(finua&time)
        finua&time         = yyyyFrac
        plot_jetlat(ee)     = gsn_csm_hov(wks_psjetlat_tlon,finua,res)
        delete([/finua/])
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
     wres@trYMinF = 0.1
     wres@trYMaxF = (nyr(ee)/2) - (nyr(ee)*0.05)
     wres@tmYLOn = True
     wres@tmYLMode = "Explicit"
     if (nyr(ee).lt.200) then
        wres@tmYLValues = (/0.1,0.2,0.5,1,2,5,10,20,50,100,150/)
     else
        wres@tmYLValues = (/1,5,10,50,100,200,500,1000,2000,5000,10000/)
     end if
     wres@tmYLLabels = wres@tmYLValues
     wres@cnLevelSelectionMode = "ExplicitLevels"
     wres@cnLevels = ispan(0,60,5)
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
        plot_wave34(ee) = gsn_csm_contour(wks_psjet_p,power34,wres)
        plot_wave34(ee) = ShadeCOI(wks_psjet_p,plot_wave34(ee),wave34,power34&time,wavecoi)
        o0 = gsn_csm_contour(wks_psjet_p,sig34,wsres)
        opt   = True
        opt@gsnShadeFillType = "pattern"
        opt@gsnShadeHigh     = 17
        o0 = gsn_contour_shade(o0,0, 0.8, opt)
        overlay(plot_wave34(ee),o0)
        delete([/o0,opt,power34,sig34,wave34/])
     end if
     delete([/wres,wsres,wavecoi/])
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     pres               = True
     pres@vpWidthF      = 0.7
     pres@vpHeightF     = 0.5
     pres@vpXF          = 0.07
     pres@trYMinF       = 0.1
;    pres@trYMaxF       = 82.
     pres@trYLog        = True
     pres@trXLog        = True
     pres@trXMinF       = 0.01
     pres@trXMaxF       = 0.3  ;maxx ;0.0832
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
     pres@tmXTLabels = (/50, 40, 30, 25, 20, 15, 10, 8, 5, 3, 2, 1, 0.5, 0.2, 0.1/)
                      ;(/    "50",    "10",     "5",     "3",    "2",  "1.5",    "1"/)
     pres@tmXTValues = 1.0 / (12.0*pres@tmXTLabels)
                      ;(/".00167",".00833",".01667",".02778",".0416",".0556",".0832"/)
     pres@tmXBValues = (/.01,   .02,  .03, .05,  .08,  0.12, 0.2, 0.3, 0.4, 0.5/)
                      ;(/    ".0",   ".01",   ".02",   ".03", ".042", ".056", ".083"/)
     pres@tmXBLabels = pres@tmXBValues
     pres@tmXTLabelFontHeightF = 0.018
     pres@tmXBLabelFontHeightF = 0.018
     pres@tmYLLabelFontHeightF = 0.018
     pres@tiYAxisString = "Power (1 / cycles mo~S~-1~N~)"              ; yaxis
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
           pres@trYMaxF         = 75.
           pres@tmYLMode        = "Explicit"
           pres@tmYLValues      = 10^fspan(-4,4,9) ;(/0,50,100,150/)
           pres@tmYLLabels      = 10^fspan(-4,4,9) ;pres@tmYLValues
           pres@tmYLMinorValues = 10^(/-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2/) ;ispan(10,140,10)
        end if
        if (mval.ge.70.and.mval.lt.145) then
           pres@trYMaxF         = 150.
           pres@trYMinF         = 0.05
           pres@tmYLMode        = "Explicit"
           pres@tmYLValues      = 10^fspan(-4,4,9) ;(/0,50,100,150/)
           pres@tmYLLabels      = 10^fspan(-4,4,9) ;pres@tmYLValues
           pres@tmYLMinorValues = 10^(/-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2/) ;ispan(10,140,10)
        end if
        if (mval.ge.145) then
           pres@trYMaxF         = mval+15.
           pres@trYMinF         = 0.05
           pres@tmYLMode        = "Explicit"
           pres@tmYLValues      = 10^fspan(-4,4,9) ;(/0,50,100,150/)
           pres@tmYLLabels      = 10^fspan(-4,4,9) ;pres@tmYLValues
           pres@tmYLMinorValues = 10^(/-3,-2.5,-2,-1.5,-1,-0.5,0,0.5,1,1.5,2/) ;ispan(10,140,10)
        end if
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
        pspec(ee) = gsn_csm_xy(wks_psjet_p,sdof@frq,splt1,pres) 
        if (isfilepresent2("obs_ts").and.ee.ge.1.and.spectra_mvf_obs.eq.False) then
           pres@xyLineColors        = (/"gray70","black","black","black"/)
           pres@xyCurveDrawOrder = "PreDraw"
           pres@gsnCenterString = ""
           pres@gsnRightString = ""
           pspec_obs(ee) = gsn_csm_xy(wks_psjet_p,sdof_obs@frq,sdof_obs@spcx,pres)
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
     scres@cnLevels = (/-3,-2.5,-2,-1.5,-1,-.5,-.25,0,.25,.5,1,1.5,2,2.5,3/)

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
     if (isvar("cntr_hi")) then
        scres@gsnRightString = cntr_hi+"/"+cntr_lo  ; list number of El Nino / La Nina events that formed composites
        delete([/cntr_hi,cntr_lo,cntr_mid/])
     else
        scres@gsnRightString = ""
     end if
     scres@gsnLeftString = ""
     scres@gsnLeftStringFontHeightF = 0.014
     scres@gsnCenterStringFontHeightF = 0.018
     scres@gsnRightStringFontHeightF = 0.014

     scres4 = scres    ; scres4 = ppt composite resources     
     delete(scres4@cnLevels)
     if (COLORMAP.eq.0) then
        scres4@cnLevels = (/-7,-6,-5,-4,-3,-2,-1,-.5,-.25,0,.25,.5,1,2,3,4,5,6,7/)
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
     new_index = NhlNewDashPattern(wks_psjetsc,"$_$_$_$_$_$_$_$_$_")
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
           patcor_tas(ee,:,:) = (/ totype(linint2(psjetsc_tas&lon,psjetsc_tas&lat,psjetsc_tas(6,:,:),True,patcor_tas&lon,patcor_tas&lat,0),typeof(patcor_tas)) /)
           patcor_psl(ee,:,:) = (/ totype(linint2(psjetsc_psl&lon,psjetsc_psl&lat,psjetsc_psl(6,:,:),True,patcor_psl&lon,patcor_psl&lat,0),typeof(patcor_psl)) /)
        else
           if (isfilepresent2("obs_trefht")) then
              patcor_tas = new((/nsim,dimsizes(psjetsc_tas&lat),dimsizes(psjetsc_tas&lon)/),typeof(psjetsc_tas))
              patcor_tas!1 = "lat"
              patcor_tas&lat = psjetsc_tas&lat
              patcor_tas!2 = "lon"
              patcor_tas&lon = psjetsc_tas&lon
              patcor_psl = new((/nsim,dimsizes(psjetsc_psl&lat),dimsizes(psjetsc_psl&lon)/),typeof(psjetsc_psl))
              patcor_psl!1 = "lat"
              patcor_psl&lat = psjetsc_psl&lat
              patcor_psl!2 = "lon"
              patcor_psl&lon = psjetsc_psl&lon
              patcor_tas(ee,:,:) = (/ psjetsc_tas(6,:,:) /)
              patcor_psl(ee,:,:) = (/ psjetsc_psl(6,:,:) /)
           end if
        end if
     
        d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")     ; mask ocean for TAS array
        basemap = d->LSMASK
        lsm = landsea_mask(basemap,psjetsc_tas&lat,psjetsc_tas&lon)
        psjetsc_tas = mask(psjetsc_tas,conform(psjetsc_tas,lsm,(/1,2/)).eq.0,False)
        delete([/lsm,basemap/])
        delete(d)
     
        map_psjetsc_jja0(ee) = gsn_csm_contour_map(wks_psjetsc,psjetsc_sst(6,:,:),scres)    ; 6 = JJA 0    
        o1 = gsn_csm_contour(wks_psjetsc,psjetsc_tas(6,:,:),scres2)  
        o2 = gsn_csm_contour(wks_psjetsc,psjetsc_psl(6,:,:),scres3) 
        overlay(map_psjetsc_jja0(ee),o1)
        overlay(map_psjetsc_jja0(ee),o2)
        delete([/o1,o2/])
        
        map_psjetsc_son0(ee) = gsn_csm_contour_map(wks_psjetsc,psjetsc_sst(9,:,:),scres)    ; 9 = SON 0      
        o3 = gsn_csm_contour(wks_psjetsc,psjetsc_tas(9,:,:),scres2)  
        o4 = gsn_csm_contour(wks_psjetsc,psjetsc_psl(9,:,:),scres3) 
        overlay(map_psjetsc_son0(ee),o3)
        overlay(map_psjetsc_son0(ee),o4)
        delete([/o3,o4/])
        
        
        map_psjetsc_djf1(ee) = gsn_csm_contour_map(wks_psjetsc,psjetsc_sst(12,:,:),scres)    ; 12 = DJF+1      
        o5 = gsn_csm_contour(wks_psjetsc,psjetsc_tas(12,:,:),scres2)  
        o6 = gsn_csm_contour(wks_psjetsc,psjetsc_psl(12,:,:),scres3) 
        overlay(map_psjetsc_djf1(ee),o5)
        overlay(map_psjetsc_djf1(ee),o6)
        delete([/o5,o6/])
        
        map_psjetsc_mam1(ee) = gsn_csm_contour_map(wks_psjetsc,psjetsc_sst(15,:,:),scres)    ; 15 = MAM+1      
        o7 = gsn_csm_contour(wks_psjetsc,psjetsc_tas(15,:,:),scres2)  
        o8 = gsn_csm_contour(wks_psjetsc,psjetsc_psl(15,:,:),scres3) 
        overlay(map_psjetsc_mam1(ee),o7)
        overlay(map_psjetsc_mam1(ee),o8)
        delete([/o7,o8/])       
        delete([/psjetsc_sst,psjetsc_tas,psjetsc_psl/])
     end if
     if (pptreg_plot_flag.eq.0) then     
        map_psjetsc_ppt_jja0(ee) = gsn_csm_contour_map(wks_psjetsc_ppt,psjetsc_ppt(6,:,:),scres4)    ; 6 = JJA 0            
        map_psjetsc_ppt_son0(ee) = gsn_csm_contour_map(wks_psjetsc_ppt,psjetsc_ppt(9,:,:),scres4)    ; 9 = SON 0              
        map_psjetsc_ppt_djf1(ee) = gsn_csm_contour_map(wks_psjetsc_ppt,psjetsc_ppt(12,:,:),scres4)    ; 12 = DJF+1              
        map_psjetsc_ppt_mam1(ee) = gsn_csm_contour_map(wks_psjetsc_ppt,psjetsc_ppt(15,:,:),scres4)    ; 15 = MAM+1      
        delete([/psjetsc_ppt/])
     end if
  end do
  
  if (isvar("patcor_tas")) then    ; for pattern correlation table  
     clat_tas  = cos(0.01745329*patcor_tas&lat)
     clat_psl  = cos(0.01745329*patcor_psl&lat)
     clat_tas!0 = "lat"
     clat_tas&lat = patcor_tas&lat
     clat_psl!0 = "lat"
     clat_psl&lat = patcor_psl&lat
     finpr_tas = "Polar Jet TAS (DJF+1)  "    ; Must be 18 characters long
     finpr_psl = "Polar Jet PSL (DJF+1)  " 
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
           finpr_tas = finpr_tas+sprintf(format2,(pattern_cor(patcor_tas(0,{-70:-20},:),patcor_tas(hh,{-70:-20},:),clat_tas({-70:-20}),0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_tas(0,{-70:-20},:),patcor_tas(hh,{-70:-20},:),clat_tas({-70:-20}),1.0,0)))
        end if
        if (all(ismissing(patcor_psl(hh,{-70:-20},:)))) then
           finpr_psl = finpr_psl+sprintf(format2,9.99)+"/"+sprintf(format3,9.99)
        else
           finpr_psl = finpr_psl+sprintf(format2,(pattern_cor(patcor_psl(0,{-70:-20},:),patcor_psl(hh,{-70:-20},:),clat_psl({-70:-20}),0)))+"/"+sprintf(format3,(wgt_arearmse(patcor_psl(0,{-70:-20},:),patcor_psl(hh,{-70:-20},:),clat_psl({-70:-20}),1.0,0)))
        end if
     end do
     if (dimsizes(tochar(line4)).ge.8190) then   ; system or fortran compiler limit
        print("Metrics table warning: Not creating metrics table as size of comparison results in a invalid ascii row size.")   
     else
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.1.txt","w",[/header/],"%s")
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.1.txt","a",[/line3/],"%s")
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.1.txt","a",[/line4/],"%s")
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.1.txt","a",[/finpr_tas/],"%s")
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.1.txt","a",[/finpr_psl/],"%s")
     end if  
     delete([/finpr_tas,finpr_psl,line3,line4,format2,format3,nchar,ntc,clat_tas,clat_psl,patcor_tas,patcor_psl,dimY,ntb,header/])
  end if

  if (isvar("patcor_hov_hi")) then           ; for pattern correlation table  
     finpr_hi = "Polar Jet(+) Hovmoller "    ; Must be 18 characters long
     finpr_lo = "Polar Jet(-) Hovmoller " 
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
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.2.txt","w",[/header/],"%s")
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.2.txt","a",[/line3/],"%s")
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.2.txt","a",[/line4/],"%s")
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.2.txt","a",[/finpr_hi/],"%s")
        write_table(getenv("OUTDIR")+"metrics.u850.psjet.indices.2.txt","a",[/finpr_lo/],"%s")
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

  if (isvar("title_n0")) then
      do ff = 0,dimsizes(seas)-1
       do gg = 0,dimsizes(iname)-1
        ii = hh * dimsizes(seas) + ff
        if(seas(ff).eq."mon") then
          panres@txString = metric_nam(gg) + " [Monthly, "+title_n0+"]"
        else
          panres@txString = metric_nam(gg) + " ["+str_upper(seas(ff))+", "+title_n0+"]"
        end if
        if (seas(ff).eq."mon") then
           gsn_panel2(wks_psjet_mon,xyn0(gg,:),lp,panres)
        else if (seas(ff).eq."djf") then
           gsn_panel2(wks_psjet_djf,xyn1(gg,:),lp,panres)
        else if (seas(ff).eq."mam") then
           gsn_panel2(wks_psjet_mam,xyn2(gg,:),lp,panres)
        else if (seas(ff).eq."jja") then
           gsn_panel2(wks_psjet_jja,xyn3(gg,:),lp,panres)
        else if (seas(ff).eq."son") then
           gsn_panel2(wks_psjet_son,xyn4(gg,:),lp,panres)
        else if (seas(ff).eq."ann") then
           gsn_panel2(wks_psjet_ann,xyn5(gg,:),lp,panres)
        else
          print ("decleared wrong season...")
        end if
        end if
        end if
        end if
        end if
        end if
       end do
     end do

     panres@txString = "Polar jet (SH) mean latitude variation (Monthly, "+title_n1+")"
     gsn_panel2(wks_psjet_ts,xyn6,lp,panres)

     panres@txString = "Polar jet (SH) latitude variation (Monthly, "+title_n2+")"
     gsn_panel2(wks_psjet_ts,xyn7,lp,panres)

     panres@txString = "Polar jet (SH) position (norm.) (Monthly, "+title_n3+")"
     gsn_panel2(wks_psjet_ts,xyn8,lp,panres)

  end if
  delete([/wks_psjet_mon,wks_psjet_djf,wks_psjet_mam,wks_psjet_jja,wks_psjet_son,wks_psjet_ann,wks_psjet_ts/]) 

  if (all(ismissing(xypsjet_rst))) then
;     print("No valid running standard deviation plots, skipping")
  else
     panres@txString = "Polar jet position 15yr running standard deviation"
     gsn_panel2(wks_psjet_rst,xypsjet_rst,lp,panres) 
     delete(xypsjet_rst)  
  end if
  panres@gsnPanelYWhiteSpacePercent = 0.5
  panres@txString = "Polar jet position standard deviation (Monthly)"
  gsn_panel2(wks_psjet_mst,xypsjet_mst,(/nrow,ncol/),panres)   
  
  panres2 = True
  panres2@gsnMaximize = True
  panres2@gsnPaperOrientation = "portrait"
  panres2@gsnPanelLabelBar = True
  panres2@lbLabelStride = 1
  panres2@pmLabelBarWidthF = 0.4
  panres2@pmLabelBarHeightF = 0.06
  panres2@lbLabelFontHeightF = 0.013
  panres2@pmLabelBarOrthogonalPosF = -0.02
  panres2@txString = ""   
  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres2@txFontHeightF = 0.022
        panres2@gsnPanelBottom = 0.50
        panres2@lbLabelFontHeightF = 0.016
        panres2@lbTitleFontHeightF = 0.016
     else
        panres2@txFontHeightF = 0.0145
        panres2@gsnPanelBottom = 0.50
        panres2@lbLabelFontHeightF = 0.010
        panres2@lbTitleFontHeightF = 0.010
     end if
  else     
     panres2@txFontHeightF = 0.016
     panres2@gsnPanelBottom = 0.05
     panres2@lbLabelFontHeightF = 0.010
     panres2@lbTitleFontHeightF = 0.010
  end if
  panres2@lbTitleOn          = True
  panres2@lbTitlePosition    = "Bottom"
  panres2@lbTitleString      = "Latitude (degree)"
  panres2@txString = "Polar Jet Latitude Position (degree)"
  gsn_panel2(wks_psjetlat_tlon,plot_jetlat,(/nrow,ncol/),panres2)   
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
  panres@txString = "Polar Jet Position (Monthly, detrended)"
  gsn_panel2(wks_psjet_p,pspec,(/nrow,ncol/),panres)  
  panres@txString = "Polar Jet Position Autocorrelation (Monthly)"
  gsn_panel2(wks_psjet_p,xypsjet_ac,(/nrow,ncol/),panres) 
  panres2@txString = "Polar Jet Position Wavelet (Monthly)"
  panres2@gsnPanelYWhiteSpacePercent = 3.0
  panres2@gsnPanelXWhiteSpacePercent = 4.0
  gsn_panel2(wks_psjet_p,plot_wave34,(/nrow,ncol/),panres2)  
  delete(wks_psjet_p)

  delete(panres2@gsnPanelYWhiteSpacePercent)
  panres2@pmLabelBarWidthF = 0.8
  panres2@lbLabelAutoStride = False
  panres2@gsnPanelXWhiteSpacePercent = 8.5
  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres2@lbLabelFontHeightF = 0.018
        panres2@lbTitleFontHeightF = 0.018
     else
        panres2@lbLabelFontHeightF = 0.012
        panres2@lbTitleFontHeightF = 0.012
     end if
  else
     panres2@lbLabelFontHeightF = 0.012
     panres2@lbTitleFontHeightF = 0.012
  end if
  if (any(.not.ismissing(map_psjetsc_jja0))) then
     panres2@lbTitleString = "SST/TAS (C)"
     panres2@pmLabelBarOrthogonalPosF = -0.03
     panres2@txString = "Polar Jet SST,TAS,PSL Spatial Composite (JJA~S~0~N~)"
     gsn_panel2(wks_psjetsc,map_psjetsc_jja0,(/nrow,ncol/),panres2)   
     panres2@txString = "Polar Jet SST,TAS,PSL Spatial Composite (SON~S~0~N~)"
     gsn_panel2(wks_psjetsc,map_psjetsc_son0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Polar Jet SST,TAS,PSL Spatial Composite (DJF~S~+1~N~)"
     gsn_panel2(wks_psjetsc,map_psjetsc_djf1,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Polar Jet SST,TAS,PSL Spatial Composite (MAM~S~+1~N~)"
     gsn_panel2(wks_psjetsc,map_psjetsc_mam1,(/nrow,ncol/),panres2)   
     delete(wks_psjetsc)
     
     delete([/map_psjetsc_djf1,map_psjetsc_jja0,map_psjetsc_son0,map_psjetsc_mam1/])
  end if     
  if (any(.not.ismissing(map_psjetsc_ppt_jja0))) then
     panres2@lbTitleString = "PRECT (mm/day)"
     panres2@txString = "Polar Jet PR Spatial Composite (JJA~S~0~N~)"
     gsn_panel2(wks_psjetsc_ppt,map_psjetsc_ppt_jja0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Polar Jet PR Spatial Composite (SON~S~0~N~)"
     gsn_panel2(wks_psjetsc_ppt,map_psjetsc_ppt_son0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Polar Jet PR Spatial Composite (DJF~S~+1~N~)"
     gsn_panel2(wks_psjetsc_ppt,map_psjetsc_ppt_djf1,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Polar Jet PR Spatial Composite (MAM~S~+1~N~)"
     gsn_panel2(wks_psjetsc_ppt,map_psjetsc_ppt_mam1,(/nrow,ncol/),panres2)   
     delete(wks_psjetsc_ppt)
     
     delete([/map_psjetsc_ppt_djf1,map_psjetsc_ppt_jja0,map_psjetsc_ppt_son0,map_psjetsc_ppt_mam1/])
  end if   

  delete([/xyn0,xyn1,xyn2,xyn3,xyn4,xyn5,xyn6,xyn7,xyn8,plot_jetlat,pspec,pi,rad,wgt,lp/])     

  OUTDIR = getenv("OUTDIR")
  
  if (wks_type.eq."png") then  
     if (isfilepresent2(OUTDIR+"psjet.spatialcomp.000001.png")) then
        system("mv "+OUTDIR+"psjet.spatialcomp.000001.png "+OUTDIR+"psjet.spatialcomp.jja0.png")
        system("mv "+OUTDIR+"psjet.spatialcomp.000002.png "+OUTDIR+"psjet.spatialcomp.son0.png")
        system("mv "+OUTDIR+"psjet.spatialcomp.000003.png "+OUTDIR+"psjet.spatialcomp.djf1.png")
        system("mv "+OUTDIR+"psjet.spatialcomp.000004.png "+OUTDIR+"psjet.spatialcomp.mam1.png")
     end if
     if (isfilepresent2(OUTDIR+"psjet.spatialcomp.ppt.000001.png")) then
        system("mv "+OUTDIR+"psjet.spatialcomp.ppt.000001.png "+OUTDIR+"psjet.spatialcomp.pr.jja0.png")
        system("mv "+OUTDIR+"psjet.spatialcomp.ppt.000002.png "+OUTDIR+"psjet.spatialcomp.pr.son0.png")
        system("mv "+OUTDIR+"psjet.spatialcomp.ppt.000003.png "+OUTDIR+"psjet.spatialcomp.pr.djf1.png")
        system("mv "+OUTDIR+"psjet.spatialcomp.ppt.000004.png "+OUTDIR+"psjet.spatialcomp.pr.mam1.png")
     end if
     if (isfilepresent2(OUTDIR+"psjet_mon.timeseries.000001.png")) then
        system("mv "+OUTDIR+"psjet_mon.timeseries.000001.png "+OUTDIR+"psjetins.timeseries.mon.png")
        system("mv "+OUTDIR+"psjet_mon.timeseries.000002.png "+OUTDIR+"psjetloc.timeseries.mon.png")
     end if
     if (isfilepresent2(OUTDIR+"psjet_djf.timeseries.000001.png")) then
        system("mv "+OUTDIR+"psjet_djf.timeseries.000001.png "+OUTDIR+"psjetins.timeseries.djf.png")
        system("mv "+OUTDIR+"psjet_djf.timeseries.000002.png "+OUTDIR+"psjetloc.timeseries.djf.png")
     end if
     if (isfilepresent2(OUTDIR+"psjet_mam.timeseries.000001.png")) then
        system("mv "+OUTDIR+"psjet_mam.timeseries.000001.png "+OUTDIR+"psjetins.timeseries.mam.png")
        system("mv "+OUTDIR+"psjet_mam.timeseries.000002.png "+OUTDIR+"psjetloc.timeseries.mam.png")
     end if
     if (isfilepresent2(OUTDIR+"psjet_jja.timeseries.000001.png")) then
        system("mv "+OUTDIR+"psjet_jja.timeseries.000001.png "+OUTDIR+"psjetins.timeseries.jja.png")
        system("mv "+OUTDIR+"psjet_jja.timeseries.000002.png "+OUTDIR+"psjetloc.timeseries.jja.png")
     end if
     if (isfilepresent2(OUTDIR+"psjet_son.timeseries.000001.png")) then
        system("mv "+OUTDIR+"psjet_son.timeseries.000001.png "+OUTDIR+"psjetins.timeseries.son.png")
        system("mv "+OUTDIR+"psjet_son.timeseries.000002.png "+OUTDIR+"psjetloc.timeseries.son.png")
     end if
     if (isfilepresent2(OUTDIR+"psjet_ann.timeseries.000001.png")) then
        system("mv "+OUTDIR+"psjet_ann.timeseries.000001.png "+OUTDIR+"psjetins.timeseries.ann.png")
        system("mv "+OUTDIR+"psjet_ann.timeseries.000002.png "+OUTDIR+"psjetloc.timeseries.ann.png")
     end if
     if (isfilepresent2(OUTDIR+"psjet_ts.timeseries.000001.png")) then
        system("mv "+OUTDIR+"psjet_ts.timeseries.000001.png "+OUTDIR+"psjetlat_mave.timeseries.png")
        system("mv "+OUTDIR+"psjet_ts.timeseries.000002.png "+OUTDIR+"psjetlat_tave.timeseries.png")
        system("mv "+OUTDIR+"psjet_ts.timeseries.000003.png "+OUTDIR+"psjet_norm.timeseries.png")
     end if
     if (isfilepresent2(OUTDIR+"psjet.powspec.000001.png")) then
        system("mv "+OUTDIR+"psjet.powspec.000001.png "+OUTDIR+"psjet.powspec.png")
        system("mv "+OUTDIR+"psjet.powspec.000002.png "+OUTDIR+"psjet.autocor.png")
        system("mv "+OUTDIR+"psjet.powspec.000003.png "+OUTDIR+"psjet.wavelet.png")
     end if
  else
     if (isfilepresent2(OUTDIR+"psjet.spatialcomp.ps")) then
        system("psplit "+OUTDIR+"psjet.spatialcomp.ps "+OUTDIR+"psjetua_ind")
        system("mv "+OUTDIR+"psjetua_ind0001.ps "+OUTDIR+"psjet.spatialcomp.jja0.ps")
        system("mv "+OUTDIR+"psjetua_ind0002.ps "+OUTDIR+"psjet.spatialcomp.son0.ps")
        system("mv "+OUTDIR+"psjetua_ind0003.ps "+OUTDIR+"psjet.spatialcomp.djf1.ps")
        system("mv "+OUTDIR+"psjetua_ind0004.ps "+OUTDIR+"psjet.spatialcomp.mam1.ps")
        system("rm "+OUTDIR+"psjet.spatialcomp.ps")
     end if
     if (isfilepresent2(OUTDIR+"psjet.spatialcomp.ppt.ps")) then
        system("psplit "+OUTDIR+"psjet.spatialcomp.ppt.ps "+OUTDIR+"psjetua_ind")
        system("mv "+OUTDIR+"psjetua_ind0001.ps "+OUTDIR+"psjet.spatialcomp.pr.jja0.ps")
        system("mv "+OUTDIR+"psjetua_ind0002.ps "+OUTDIR+"psjet.spatialcomp.pr.son0.ps")
        system("mv "+OUTDIR+"psjetua_ind0003.ps "+OUTDIR+"psjet.spatialcomp.pr.djf1.ps")
        system("mv "+OUTDIR+"psjetua_ind0004.ps "+OUTDIR+"psjet.spatialcomp.pr.mam1.ps")
        system("rm "+OUTDIR+"psjet.spatialcomp.ppt.ps")
     end if
     if (isfilepresent2(OUTDIR+"psjet_mon.timeseries.ps")) then
        system("psplit "+OUTDIR+"psjet_mon.timeseries.ps "+OUTDIR+"psjetu850_ind")
        system("mv "+OUTDIR+"psjetu850_ind0001.ps "+OUTDIR+"psjetins.timeseries.mon.ps")
        system("mv "+OUTDIR+"psjetu850_ind0002.ps "+OUTDIR+"psjetloc.timeseries.mon.ps")
     end if
     if (isfilepresent2(OUTDIR+"psjet_djf.timeseries.ps")) then
        system("psplit "+OUTDIR+"psjet_djf.timeseries.ps "+OUTDIR+"psjetu850_ind")
        system("mv "+OUTDIR+"psjetu850_ind0001.ps "+OUTDIR+"psjetins.timeseries.djf.ps")
        system("mv "+OUTDIR+"psjetu850_ind0002.ps "+OUTDIR+"psjetloc.timeseries.djf.ps")
     end if
     if (isfilepresent2(OUTDIR+"psjet_mam.timeseries.ps")) then
        system("psplit "+OUTDIR+"psjet_mam.timeseries.ps "+OUTDIR+"psjetu850_ind")
        system("mv "+OUTDIR+"psjetu850_ind0001.ps "+OUTDIR+"psjetins.timeseries.mam.ps")
        system("mv "+OUTDIR+"psjetu850_ind0002.ps "+OUTDIR+"psjetloc.timeseries.mam.ps")
     end if
     if (isfilepresent2(OUTDIR+"psjet_jja.timeseries.ps")) then
        system("psplit "+OUTDIR+"psjet_jja.timeseries.ps "+OUTDIR+"psjetu850_ind")
        system("mv "+OUTDIR+"psjetu850_ind0001.ps "+OUTDIR+"psjetins.timeseries.jja.ps")
        system("mv "+OUTDIR+"psjetu850_ind0002.ps "+OUTDIR+"psjetloc.timeseries.jja.ps")
     end if
     if (isfilepresent2(OUTDIR+"psjet_son.timeseries.ps")) then
        system("psplit "+OUTDIR+"psjet_son.timeseries.ps "+OUTDIR+"psjetu850_ind")
        system("mv "+OUTDIR+"psjetu850_ind0001.ps "+OUTDIR+"psjetins.timeseries.son.ps")
        system("mv "+OUTDIR+"psjetu850_ind0002.ps "+OUTDIR+"psjetloc.timeseries.son.ps")
     end if
     if (isfilepresent2(OUTDIR+"psjet_ann.timeseries.ps")) then
        system("psplit "+OUTDIR+"psjet_ann.timeseries.ps "+OUTDIR+"psjetu850_ind")
        system("mv "+OUTDIR+"psjetu850_ind0001.ps "+OUTDIR+"psjetins.timeseries.ann.ps")
        system("mv "+OUTDIR+"psjetu850_ind0002.ps "+OUTDIR+"psjetloc.timeseries.ann.ps")
     end if
     if (isfilepresent2(OUTDIR+"psjet_ts.timeseries.ps")) then
        system("psplit "+OUTDIR+"psjet_ts.timeseries.ps "+OUTDIR+"psjetu850_ind")
        system("mv "+OUTDIR+"psjetu850_ind0001.ps "+OUTDIR+"psjetlat_mave.timeseries.ps")
        system("mv "+OUTDIR+"psjetu850_ind0002.ps "+OUTDIR+"psjetlat_tave.timeseries.ps")
        system("mv "+OUTDIR+"psjetu850_ind0003.ps "+OUTDIR+"psjet_norm.timeseries.ps")
     end if
     if (isfilepresent2(OUTDIR+"psjet.powspec.ps")) then
        system("psplit "+OUTDIR+"psjet.powspec.ps "+OUTDIR+"psjetp")
        system("mv "+OUTDIR+"psjetp0001.ps "+OUTDIR+"psjet.powspec.ps")
        if (isfilepresent2(OUTDIR+"psjetp0002.ps")) then
           system("mv "+OUTDIR+"psjetp0002.ps "+OUTDIR+"psjet.autocor.ps")
           system("mv "+OUTDIR+"psjetp0003.ps "+OUTDIR+"psjet.wavelet.ps")
        end if
     end if
  end if
  print("Finished: u850.psjet.indices.ncl")
end
