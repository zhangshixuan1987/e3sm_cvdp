; Calculates ; Diagnostics for the Hadley cell (HC) following Nguyen et al. (2013): Nguyen, H., Evans, A., Lucas, C., Smith, I., & Timbal, B. (2013). The Hadley Circulation in Reanalyses: Climatology, Variability, and Change, Journal of Climate, 26(10), 3357-3376. Retrieved Feb 16, 2023, from https://journals.ametsoc.org/view/journals/clim/26/10/jcli-d-12-00224.1.xml
; Here, The zonal-mean meridional streamfunction derived from the meridional wind fields is chosen to diagnose the HC. Specifically, The monthly zonal-mean meridional streamfunction is computed from monthly-mean data, the diagnostics includes:
;1. intensity: defined as the vertically averaged maximum value of between 900 and 200 hPa, marking the lower and upper limits of the cell
;2. extent (or edge) of the HCs:  the zero isoline for stream function on the poleward side of these cells, averaged between 400 and 600 hPa
;3. the width of the Hadley circulation as the distance between the first latitudes poleward of the cell centers in which the 700-400-hPa average value of c equals zero, which is the width of both cells together. Here, the width of each cell is defined by the difference between these extents and the intersection between the two cells.
;4. The intersection represents the latitude of zero value of c, averaged between 400 and 600 hPa, near the equator (i.e., when c changes sign as it passes from positive value in the NH cell to negative value in the SH cell), that separates the NH and SH cells.
;5. the intensity is defined as the vertically averaged maximum value of c between 900 and 200 hPa, marking the lower and upper limits of the cell
; Author : Shixuan Zhang
; Date   : Dec 06, 2020
;
; Variables used: ts, ua, and tas
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: zmsf.indices.ncl")
  
  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")  
  OUTPUT_DATA      = getenv("OUTPUT_DATA")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")  
  
  nsim = numAsciiRow("namelist_byvar/namelist_zmsf")
  na = asciiread("namelist_byvar/namelist_zmsf",(/nsim/),"string")
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
  wks_hc = gsn_open_wks(wks_type,getenv("OUTDIR")+"hc.timeseries")  

  wks_hclat_tlon = gsn_open_wks(wks_type,getenv("OUTDIR")+"hcpos.hov")

  wks_hc_p = gsn_open_wks(wks_type,getenv("OUTDIR")+"hc.powspec")
  
  wks_hc_rst = gsn_open_wks(wks_type,getenv("OUTDIR")+"hc.runstddev")

  wks_hc_mst = gsn_open_wks(wks_type,getenv("OUTDIR")+"hc.monstddev")
  
  wks_hcsc = gsn_open_wks(wks_type,getenv("OUTDIR")+"hc.spatialcomp")

  wks_hcsc_ppt = gsn_open_wks(wks_type,getenv("OUTDIR")+"hc.spatialcomp.ppt")
  
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_hc,"ncl_default") 
     gsn_merge_colormaps(wks_hclat_tlon,"cmp_flux",(/"gray30","gray50","gray70"/))
     gsn_define_colormap(wks_hc_p,"cb_9step")
     gsn_define_colormap(wks_hc_rst,"ncl_default")   
     gsn_define_colormap(wks_hc_mst,"ncl_default")   
     gsn_define_colormap(wks_hcsc,"ncl_default")   
     gsn_define_colormap(wks_hcsc_ppt,"MPL_BrBG")  
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_hc,"ncl_default") 
     gsn_merge_colormaps(wks_hclat_tlon,"MPL_rainbow",(/"gray30","gray50","gray70"/))
     gsn_define_colormap(wks_hc_p,"cb_9step")
     gsn_define_colormap(wks_hc_rst,"ncl_default")   
     gsn_define_colormap(wks_hc_mst,"ncl_default")   
     gsn_define_colormap(wks_hcsc,"BlueDarkRed18")   
     gsn_define_colormap(wks_hcsc_ppt,"BrownBlue12")    
  end if

  xyn0  = new(nsim,"graphic")
  xyn1  = new(nsim,"graphic")
  xyn2  = new(nsim,"graphic") 
  xyn3  = new(nsim,"graphic")  
  xyn4  = new(nsim,"graphic")
  xyn5  = new(nsim,"graphic")  
  xyn6  = new(nsim,"graphic")  
  xyn7  = new(nsim,"graphic") 
  xyn8  = new(nsim,"graphic") 
  xyn9  = new(nsim,"graphic") 
  xyn10 = new(nsim,"graphic") 
  xyn11 = new(nsim,"graphic") 

  map_hcsc_jja0 = new(nsim,"graphic")  
  map_hcsc_son0 = new(nsim,"graphic")  
  map_hcsc_djf1 = new(nsim,"graphic")  
  map_hcsc_mam1 = new(nsim,"graphic")  

  map_hcsc_ppt_jja0 = new(nsim,"graphic")  
  map_hcsc_ppt_son0 = new(nsim,"graphic")  
  map_hcsc_ppt_djf1 = new(nsim,"graphic")  
  map_hcsc_ppt_mam1 = new(nsim,"graphic")  

  xyhc_rst = new(nsim,"graphic")  
  xyhc_mst = new(nsim,"graphic")  
  xyhc_ac = new(nsim,"graphic") 
  plot_wave34 = new(nsim,"graphic")  

  pspec = new(nsim,"graphic")
  if (isfilepresent2("obs_ts")) then
     pspec_obs = new(nsim,"graphic")
     xyhc_ac_obs = new(nsim,"graphic")
  end if

  wgt = (/1.,2.,1./)   
  wgt = wgt/sum(wgt)
  pi=4.*atan(1.0)
  rad=(pi/180.)

  do ee = 0,nsim-1
     zmsf = data_read_in(paths(ee),"SF",syear(ee),eyear(ee))
     if (isatt(zmsf,"is_all_missing")) then
        delete(zmsf)
        continue
     end if

     scale_factor = 1.e9
     zmsf         = zmsf / scale_factor
     zmsf@units   = "10~S~9~N~ " + zmsf@units
     lbunit       = zmsf@units
     lat          = zmsf&lat
     lat!0        = "lat"
     lat&lat      =  lat 

     ;dreive layer thickness for vertical average;
     plev       = zmsf&lev 
     plev@units = "hPa"
     plev!0     = "lev"
     plev&lev   = plev 
     dpth = dpres_plevel_Wrap(plev, 1018, 0, 0)
     
     delete(zmsf&lev)
     zmsf&lev = plev 
     hcvm920  = dim_avg_wgt_n_Wrap(zmsf(:,{900:200},:),dpth({900:200}),1,1) ;average betwee 900-200hPa 
     hcvm740  = dim_avg_wgt_n_Wrap(zmsf(:,{900:200},:),dpth({900:200}),1,1) ;average betwee 700-400hPa

     ;calcualte hadley cell info 
     coswgt=cos(rad*zmsf&lat)
     coswgt!0 = "lat"
     coswgt&lat= zmsf&lat
   
     hcin               = zmsf(:,0,0) 
     hcin@comment_cvdp  = "domain (0-40N)"
     hcin@units         = zmsf@units 
     hcin@long_name     = "Hadley cell intensity (NH) (900-200hPa mean) timeseries (monthly)"

     hxcin               = hcin
     hxcin@comment_cvdp  = "domain (0-40N)"
     hxcin@units         = zmsf@units
     hxcin@long_name     = "Hadley cell maximum intensity (NH) timeseries (monthly)" 

     hmcin               = hcin
     hmcin@comment_cvdp  = "domain (0-40N)"
     hmcin@units         = zmsf@units
     hmcin@long_name     = "Hadley cell mean intensity (NH) timeseries (monthly)"

     hcis               = hcin 
     hcis@comment_cvdp  = "domain (40S-0)"
     hcis@units         = zmsf@units 
     hcis@long_name     = "Hadley cell intensity (SH) (900-200hPa mean) timeseries (monthly)"

     hxcis               = hcin
     hxcis@comment_cvdp  = "domain (40S-0)"
     hxcis@units         = zmsf@units
     hxcis@long_name     = "Hadley cell maximum intensity (SH) timeseries (monthly)"

     hmcis               = hcin
     hmcis@comment_cvdp  = "domain (40S-0)"
     hmcis@units         = zmsf@units
     hmcis@long_name     = "Hadley cell mean intensity (SH) timeseries (monthly)"

     hpin               = hcin 
     hpin@comment_cvdp  = "domain (0-40N)"
     hpin@units         = "degree"
     hpin@long_name     = "Hadley cell latitude (NH) (900-200hPa mean) timeseries (monthly)"

     hxpin               = hcin
     hxpin@comment_cvdp  = "domain (0-40S)"
     hxpin@units         = "degree"
     hxpin@long_name     = "Hadley cell column (900-200hPa) maximum intensity latitude (NH) timeseries (monthly)"

     hmpin               = hcin
     hmpin@comment_cvdp  = "domain (0-40S)"
     hmpin@units         = "degree"
     hmpin@long_name     = "Hadley cell maximum column mean (900-200hPa) intensity latitude (NH) timeseries (monthly)"

     hpis               = hcin
     hpis@comment_cvdp  = "domain (40S-0)"
     hpis@units         = "degree"
     hpis@long_name     = "Hadley cell latitude (SH) (900-200hPa mean) timeseries (monthly)"
     
     hxpis               = hcin
     hxpis@comment_cvdp  = "domain (40S-0)"
     hxpis@units         = "degree"
     hxpis@long_name     = "Hadley cell column (900-200hPa) maximum intensity latitude (SH) timeseries (monthly)"

     hmpis               = hcin
     hmpis@comment_cvdp  = "domain (40S-0)"
     hmpis@units         = "degree"
     hmpis@long_name     = "Hadley cell maximum column mean (900-200hPa mean) intensity latitude (SH) timeseries (monthly)"

     hcei               = hcin
     hcei@comment_cvdp  = "domain (40S-40N)"
     hcei@units         = "degree"
     hcei@long_name     = "Hadley cell intersection latitude (zero value of steam function) timeseries (monthly)"

     hcen               = hcin
     hcen@comment_cvdp  = "domain (0-40N)"
     hcen@units         = "degree"
     hcen@long_name     = "Hadley cell poleward extent (NH) (zero value of steam function) timeseries (monthly)"

     hces               = hcin
     hces@comment_cvdp  = "domain (40S-0)"
     hces@units         = "degree"
     hces@long_name     = "Hadley cell poleward extent (NH) (zero value of steam function) timeseries (monthly)"

     hcwn               = hcin
     hcwn@comment_cvdp  = "domain (0-40N)"
     hcwn@units         = "degree"
     hcwn@long_name     = "Hadley cell width (NH) (poleward extent - intersection) timeseries (monthly)"

     hcws               = hcin
     hcws@comment_cvdp  = "domain (40S-0)"
     hcws@units         = "degree"
     hcws@long_name     = "Hadley cell width (SH) (poleward extent - intersection) timeseries (monthly)"

     hcwd               = hcin
     hcwd@comment_cvdp  = "domain (40S-40S)"
     hcwd@units         = "degree"
     hcwd@long_name     = "Hadley cell width (NH poleward extent - SH poleward extent) timeseries (monthly)"

     do kk  = 0, dimsizes(zmsf&time) -1

       ;maximum intensity and location
       tmp1 = hcvm920(kk,{-5:40})
       tmp2 = hcvm920(kk,{-40:5}) 
       lat1 = lat({-5:40})
       lat2 = lat({-40:5})
       imax = dim_maxind(tmp1,0)
       jmax = dim_minind(tmp2,0)
       hmcin(kk) = (/tmp1(imax)/)
       hmcis(kk) = (/tmp2(jmax)/)
       hmpin(kk) = (/tofloat(lat1(imax))/)
       hmpis(kk) = (/tofloat(lat2(jmax))/)
       delete([/imax,jmax,tmp1,tmp2,lat1,lat2/])

       ;;;maximum at each level
       xcin      = zmsf(0,:,0) 
       xcis      = zmsf(0,:,0)  
       xpis      = zmsf(0,:,0) 
       xpin      = zmsf(0,:,0)  
       do jj  = 0, dimsizes(zmsf&lev) -1
         tmp1    = zmsf(kk,jj,{-5:40})
         lat1    = lat({-5:40})
         ind1    = dim_maxind(tmp1,0)
         tmp2    = zmsf(kk,jj,{-40:5})
         lat2    = lat({-40:5})
         ind2    = dim_minind(tmp2,0)
         ;;HC intensity and max/min loction
         xcin(jj) = (/tmp1(ind1)/)
         xcis(jj) = (/tmp2(ind2)/)
         xpin(jj) = (/tofloat(lat1(ind1))/)
         xpis(jj) = (/tofloat(lat2(ind2))/)
         delete([/tmp1,tmp2,lat1,lat2,ind1,ind2/])
       end do
       hcin(kk)   = dim_avg_wgt_n(xcin({900:200}), dpth({900:200}), 1, 0)
       hcis(kk)   = dim_avg_wgt_n(xcis({900:200}), dpth({900:200}), 1, 0)
       hpin(kk)   = dim_avg_wgt_n(xpin({900:200}), dpth({900:200}), 1, 0)
       hpis(kk)   = dim_avg_wgt_n(xpis({900:200}), dpth({900:200}), 1, 0)

       indx1      = dim_maxind(xcin,0)
       indx2      = dim_minind(xcis,0)
       hxcin(kk)  = (/xcin(indx1)/)
       hxcis(kk)  = (/xcis(indx2)/)
       hxpin(kk)  = (/xpin(indx1)/)
       hxpis(kk)  = (/xpis(indx2)/)
       delete([/indx1,indx2,xcin,xcis,xpin,xpis/])

       ;HC intersection and extents
       tmp1 = hcvm740(kk,{-5:40})
       tmp2 = hcvm740(kk,{-40:5})
       lat1 = lat({-5:40})
       lat2 = lat({-40:5})
       imax = dim_maxind(tmp1,0)
       jmax = dim_minind(tmp2,0)
       latx1 = lat1(imax)
       latx2 = lat2(jmax)
       delete([/imax,jmax,tmp1,tmp2,lat1,lat2/])

       ;HC SH extent (edge)
       lats2    = latx2 - 1.0
       latt0    = lat({-90:lats2})
       hctt0    = hcvm740(kk,{-90:lats2})
       ismax    = dim_maxind(hctt0,0)
       latxm    = latt0(ismax)
       xi       = hcvm740(kk,{lats2:latxm})
       yi       = tofloat(lat({lats2:latxm}))
       xi       = xi + random_normal(1e-4,1e-4,dimsizes(xi))
       ist      = dim_pqsort_n(xi,2,0)
       yi       = yi(ist)
       hces(kk) = linint1(xi,yi, False, 0.0, 0) ;ftcurv(xi,yi,0.0)
       delete([/ismax,lats2,latxm,xi,yi,latt0,hctt0,ist/])
       if(.not.ismissing(hces(kk)).and.abs(hces(kk)).gt.50.0) then
         hces(kk) = hces@_FillValue
       end if

       ;HC intersection (zero line closed to equator)
       lats1    = latx1
       lats2    = latx2
       xi       = hcvm740(kk,{lats2:lats1}) 
       yi       = tofloat(lat({lats2:lats1}))
       xi       = xi + random_normal(1e-4,1e-4,dimsizes(xi))
       ist      = dim_pqsort_n(xi,2,0)
       cc       = count_unique_values(xi)
       hcei(kk) = linint1(xi,yi, False, 0.0, 0)
       delete([/lats2,lats1,xi,yi,ist/])
       if(.not.ismissing(hcei(kk)).and.abs(hcei(kk)).gt.30.0) then
         hcei(kk) = hcei@_FillValue
       end if

       ;;HC NH extent (edge)
       lats1    = latx1 +1.0
       latt0    = lat({lats1:90})
       hctt0    = hcvm740(kk,{lats1:90})
       ismax    = dim_minind(hctt0,0)
       latxm    = latt0(ismax)
       xi       = hcvm740(kk,{latxm:lats1})
       yi       = tofloat(lat({latxm:lats1}))
       xi       = xi + random_normal(1e-4,1e-4,dimsizes(xi))
       ist      = dim_pqsort_n(xi,2,0)
       yi       = yi(ist)
       hcen(kk) = linint1(xi,yi, False, 0.0, 0) ; ftcurv(xi,yi,0.0)
       if(.not.ismissing(hcen(kk)).and.hcen(kk).gt.50.0) then
         hcen(kk) = hcen@_FillValue
       end if
       delete([/ismax,lats1,latxm,xi,yi,latt0,hctt0,ist/])

     end do

    ;HC width
     hcwn = hcen - hcei
     hcws = hces - hcei
     hcwd = hcen - hces

     hcind = hcwd
     hcind = dim_standardize(hcwd,0)
     hcind = linmsg(hcind, 0)
     hcind@units        = "1"
     hcind@long_name    = "Hadley cell width index timeseries (monthly)"

     hcisd = hcei
     hcisd = dim_standardize(hcei,0)
     hcisd = linmsg(hcisd, 0)
     hcisd@units        = "1"
     hcisd@long_name    = "Hadley cell intersection index timeseries (monthly)" 

     delete([/hcvm740,hcvm920,dpth,plev,coswgt,lat/])

;---------------------------------------------------------------------------------------------     
     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.zmsf.indices."+syear(ee)+"-"+eyear(ee)+".nc"
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
           date = cd_calendar(zmsf&time,-1)
           date@long_name = "current date (YYYYMM)"
           delete(date@calendar)
           date!0 = "time"
           date&time = zmsf&time
           date@units = "1"
           z->date = date
           delete(date)
        else
           z = addfile(fn,"w")
        end if
        z->hcind = set_varAtts(hcind,"","","")
        z->hcisd = set_varAtts(hcisd,"","","")
        z->hcin  = set_varAtts(hcin,"","","")
        z->hcis  = set_varAtts(hcis,"","","")
        z->hxcin = set_varAtts(hxcin,"","","")
        z->hxcis = set_varAtts(hxcis,"","","")
        z->hmcin = set_varAtts(hmcin,"","","")
        z->hmcis = set_varAtts(hmcis,"","","")
        z->hpin  = set_varAtts(hpin,"","","")
        z->hpis  = set_varAtts(hpis,"","","")
        z->hxpin = set_varAtts(hxpin,"","","")
        z->hxpis = set_varAtts(hxpis,"","","")
        z->hmpin = set_varAtts(hmpin,"","","")
        z->hmpis = set_varAtts(hmpis,"","","")
        z->hcei  = set_varAtts(hcei,"","","")
        z->hces  = set_varAtts(hces,"","","")
        z->hcen  = set_varAtts(hcen,"","","")
        z->hcwn  = set_varAtts(hcwn,"","","")
        z->hcws  = set_varAtts(hcws,"","","")
        z->hcwd  = set_varAtts(hcwd,"","","")
        delete([/modname,fn/])
     end if

;- - - - - -hc spatial composite section- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     hcT         = wgt_runave(hcind,wgt,1)        ; for use in composites / running standard deviations
     hc_ndj      = hcT(11:dimsizes(hcT)-13:12)  ; cannot count last 1yr as spatial composite uses +1yrs data betond JAS..
     hc_ndj!0    = "time"
     hc_ndj&time = ispan(syear(ee),eyear(ee)-1,1)
     hc_ndj      = dtrend_msg(ispan(0,dimsizes(hc_ndj&time)-1,1),hc_ndj,True,False)
     hc_ndj      = dim_standardize(hc_ndj,0)

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
          hiyr = new(dimsizes(hc_ndj&time),integer)
          loyr = hiyr

          do hh = 0,dimsizes(hc_ndj)-1
             if (.not.ismissing(hc_ndj(hh))) then
                if (hc_ndj(hh).ge.1.0) then
                   hiyr(hicntr) = hc_ndj&time(hh)
                   hicntr = hicntr+1
                end if
                if (hc_ndj(hh).le.-1.0) then
                   loyr(locntr) = hc_ndj&time(hh)
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
             print("For "+names(ee)+", 1 or less (normalized) hc value greater than one standard deviation found, setting hc spatial composites to missing")  ; sc_*_hi arrays left to _FillValue
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
             print("For "+names(ee)+", 1 or less (normalized) hc value less than -1 standard deviation found, setting hc spatial composites to missing")   ; sc_*_lo arrays left to _FillValue
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
          
          hcsc_psl = sc_psl_hi
          hcsc_psl = (/ sc_psl_hi - sc_psl_lo /)
          hcsc_sst = sc_sst_hi
          hcsc_sst = (/ sc_sst_hi - sc_sst_lo /)
          hcsc_tas = sc_tas_hi
          hcsc_tas = (/ sc_tas_hi - sc_tas_lo /)
          delete([/sc_psl_hi,sc_psl_lo,sc_sst_hi,sc_sst_lo,sc_tas_hi,sc_tas_lo/])
          delete(zmsf&time)
          zmsf&time = TIME    
          delete(TIME)       
                     
          if (OUTPUT_DATA.eq."True") then
             hcsc_psl&lat@standard_name = "latitude"
             hcsc_psl&lon@standard_name = "longitude"
             z->hc_spacomp_psl_jja0 = set_varAtts(hcsc_psl(6,:,:),"hc psl spatial composite (JJA+0)","","")
             z->hc_spacomp_psl_son0 = set_varAtts(hcsc_psl(9,:,:),"hc psl spatial composite (SON+0)","","")
             z->hc_spacomp_psl_djf1 = set_varAtts(hcsc_psl(12,:,:),"hc psl spatial composite (DJF+1)","","")
             z->hc_spacomp_psl_mam1 = set_varAtts(hcsc_psl(15,:,:),"hc psl spatial composite (MAM+1)","","")

             modname = str_sub_str(names_trefht(ee)," ","_")
             bc = (/"/","'","(",")"/)
             do gg = 0,dimsizes(bc)-1
                modname = str_sub_str(modname,bc(gg),"_")
             end do
             fn = getenv("OUTDIR")+modname+".cvdp_data.zmsf.zmsf.indices.tas."+syear_trefht(ee)+"-"+eyear_trefht(ee)+".nc"
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
             z_tas->hc_spacomp_tas_jja0 = set_varAtts(hcsc_tas(6,:,:),"hc tas spatial composite (JJA+0)","","")   
             z_tas->hc_spacomp_tas_son0 = set_varAtts(hcsc_tas(9,:,:),"hc tas spatial composite (SON+0)","","") 
             z_tas->hc_spacomp_tas_djf1 = set_varAtts(hcsc_tas(12,:,:),"hc tas spatial composite (DJF+1)","","") 
             z_tas->hc_spacomp_tas_mam1 = set_varAtts(hcsc_tas(15,:,:),"hc tas spatial composite (MAM+1)","","") 
             delete(z_tas)
             delete(modname)
             
             modname = str_sub_str(names_ts(ee)," ","_")
             bc = (/"/","'","(",")"/)
             do gg = 0,dimsizes(bc)-1
                modname = str_sub_str(modname,bc(gg),"_")
             end do
             fn = getenv("OUTDIR")+modname+".cvdp_data.zmsf.indices.sst."+syear_trefht(ee)+"-"+eyear_trefht(ee)+".nc"
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
             z_sst->hc_spacomp_sst_jja0 = set_varAtts(hcsc_sst(6,:,:),"hc sst spatial composite (JJA+0)","","")   
             z_sst->hc_spacomp_sst_son0 = set_varAtts(hcsc_sst(9,:,:),"hc sst spatial composite (SON+0)","","")   
             z_sst->hc_spacomp_sst_djf1 = set_varAtts(hcsc_sst(12,:,:),"hc sst spatial composite (DJF+1)","","")   
             z_sst->hc_spacomp_sst_mam1 = set_varAtts(hcsc_sst(15,:,:),"hc sst spatial composite (MAM+1)","","")   
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
;-------------hc composite (precipitation)-----------------------------------------------------
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
         ;  tas = mask(tas,conform(tas,lsm,(/1,2/)).eq.0,False)              ; in the hc pattern correlations
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
           hiyr = new(dimsizes(hc_ndj&time),integer)
           loyr = hiyr

           do hh = 0,dimsizes(hc_ndj)-1
              if (.not.ismissing(hc_ndj(hh))) then
                 if (hc_ndj(hh).ge.1) then
                    hiyr(hicntr) = hc_ndj&time(hh)
                    hicntr = hicntr+1
                 end if
                 if (hc_ndj(hh).le.-1) then
                    loyr(locntr) = hc_ndj&time(hh)
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
              print("For "+names(ee)+", 1 or less (normalized) hc value greater than one standard deviation found, setting hc spatial composites to missing")  ; sc_*_hi arrays left to _FillValue
           else           
              do gg = 0,23
                 tt = gg/12.
                 sc_ppt_hi(gg,:,:) = (/ dim_avg_n(ppt({highyr+tt},:,:),0) /)
              end do
              delete(tt)
           end if
           delete(highyr)
           if (dimsizes(lowyr).le.1) then
              print("For "+names(ee)+", 1 or less (normalized) hc value less than -1 standard deviation found, setting hc spatial composites to missing")   ; sc_*_lo arrays left to _FillValue
           else           
              do gg = 0,23
                 tt = gg/12.
                 sc_ppt_lo(gg,:,:) = (/ dim_avg_n(ppt({lowyr+tt},:,:),0) /)
              end do
              delete(tt)
           end if
           delete(lowyr)
           
           hcsc_ppt = sc_ppt_hi
           hcsc_ppt = (/ sc_ppt_hi - sc_ppt_lo /)
           delete([/sc_ppt_hi,sc_ppt_lo/])     
                      
           if (OUTPUT_DATA.eq."True") then
              modname = str_sub_str(names_prect(ee)," ","_")
              bc = (/"/","'","(",")"/)
              do gg = 0,dimsizes(bc)-1
                 modname = str_sub_str(modname,bc(gg),"_")
              end do
              fn = getenv("OUTDIR")+modname+".cvdp_data.zmsf.indices.ppt."+syear_trefht(ee)+"-"+eyear_trefht(ee)+".nc"
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
              z_ppt->hc_spacomp_pr_jja0 = set_varAtts(hcsc_ppt(6,:,:),"hc pr spatial composite (JJA+0)","","")      
              z_ppt->hc_spacomp_pr_son0 = set_varAtts(hcsc_ppt(9,:,:),"hc pr spatial composite (SON+0)","","")
              z_ppt->hc_spacomp_pr_djf1 = set_varAtts(hcsc_ppt(12,:,:),"hc pr spatial composite (DJF+1)","","")
              z_ppt->hc_spacomp_pr_mam1 = set_varAtts(hcsc_ppt(15,:,:),"hc pr spatial composite (MAM+1)","","")
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
     delete([/zmsf,hc_ndj/])
;-----------------------------------------------------------------------------------------     
     if (nyr(ee).ge.20) then    ; need a minimum number of years to compute running hc standard deviations
        hcT = dtrend_msg(ispan(0,dimsizes(hcT)-1,1),hcT,True,False)
        hcT!0 = "time"
        hcT&time = hcind&time
        sd_run = hcT
        sd_run = sd_run@_FillValue
        sd_run@units = hcind@units
        sd_run@long_name = "hcind 15yr running standard deviation"
        do gg = 90,dimsizes(hcT)-90
           sd_run(gg) = (/ dim_stddev(hcT(gg-90:gg+89)) /)
        end do
        if (OUTPUT_DATA.eq."True") then
           z->hc_runstddev = set_varAtts(sd_run,"","","")
        end if
     end if
     delete(hcT)
;-----------------------------------------------------------------------------------------
     iopt = 0                ; hc power spectra
     jave = (7*nyr(ee))/100
     val1 = .95
     val2 = .99
     pct = 0.1 
     spectra_mvf = False        ; missing value flag for hc
     if (any(ismissing(hcind))) then     ; check for missing data                                                            
        print("Missing data detected for "+names(ee)+", not creating spectra in zmsf.indices.ncl") 
        spectra_mvf = True
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           spectra_mvf_obs = True
        end if
     else
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           spectra_mvf_obs = False   ; missing value flag for obs hc
        end if
        hc_dt = dtrend_msg(ispan(0,dimsizes(hcind)-1,1),hcind,True,False) 
    
        sdof = specx_anal(hc_dt,iopt,jave,pct)
        mval = sum(1/(1.+((sdof@xlag1)^2)-((2*sdof@xlag1)*cos(6.28318*sdof@frq))))
        if (mval.eq.0) then ; check for cyclic data that results in sum of Markov elements = 0.
           spectra_mvf = True
           if (isfilepresent2("obs_ts").and.ee.eq.0) then
              spectra_mvf_obs = True   ; missing value flag for obs hc
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
              z->hc_spectra = set_varAtts(splt1,"hc power spectra","","")
           end if
           if (isfilepresent2("obs_ts").and.ee.eq.0) then
              sdof_obs = sdof
           end if
        end if
        delete([/hc_dt,iopt,jave,pct,mval/])
     end if
;------------------------------------------------------------------------------------------
     hc_dt = dtrend_msg(ispan(0,dimsizes(hcind&time)-1,1),hcind,True,False)
     hc_mon_sd = new(12,typeof(hcind))
     
     do hh = 0,11
        hc_mon_sd(hh) = (/ dim_stddev(hc_dt(hh::12)) /)
     end do
     hc_mon_sd@units = "C"
     if (OUTPUT_DATA.eq."True") then
        time_mon2 = ispan(0,11,1)
        time_mon2@units = "months since 0000-01-01 00:00:00"
        time_mon2@long_name = "Time"
        time_mon2@standard_name = "time"
        time_mon2@calendar = "standard"
        time_mon2!0 = "time_mon2"
        time_mon2&time_mon2 = time_mon2
        hc_mon_sd!0 = "time_mon2"
        hc_mon_sd&time_mon2 = time_mon2
        z->hc_monthly_stddev = set_varAtts(hc_mon_sd,"hc monthly standard deviation","","")
        delete(time_mon2)
     end if
;------------------------------------------------------------------------------------------
;    hc wavelet analysis, autocorrelation

     if (spectra_mvf.eq.False) then
        N       = dimsizes(hcind)       
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
        wave34 = wavelet(hcind,mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)

        power34            = onedtond(wave34@power,(/jtot,N/))
        power34!0          = "period"                    
        power34&period     = wave34@period
        power34&period@long_name = "wavelet period"
        power34&period@units = "1"
        power34!1          = "time"                     
        power34&time       = hcind&time
        power34@units      = hcind@units+"^2"

        sig34              = power34                       
        sig34              = power34/conform (power34,wave34@signif,0)
        sig34@long_name    = "wavelet significance"
        sig34@units        = ""
        delete([/N,mother,param,dt,s0,dj,jtot,npad,nadof,noise,siglvl,isigtest/])

        ac34 = esacr(hc_dt,48)
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
           z->hc_wavelet_power = set_varAtts(power34,"hc wavelet power","","")
           z->hc_wavelet_significance = set_varAtts(sig34,"hc wavelet significance","","")
           z->hc_autocorrelation = set_varAtts(ac34,"hc autocorrelation","","")
        end if
        if (isfilepresent2("obs_ts").and.ee.eq.0) then
           ac34_obs = ac34
        end if
     end if
     delete(hc_dt)    
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
     
     xyres3 = xyres            ; resource list for monthly hc standard deviations
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
     
     xyres4 = xyres      ; resource list for hc autocorrelations
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

     arr = new((/3,dimsizes(hcwd)/),typeof(hcwd))
   
     tttt = dtrend_msg(ispan(0,dimsizes(hcwd)-1,1),hcwd,False,True)
     arr(0,:) = (/ hcwd /)
     arr(1,:) = (/ runave_n(hcwd, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hcwd)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = "Latitude (degree)"      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hcwd),2,True)+hcwd@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn0(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hcwd)),arr,xyres6) 
     delete(tttt)
 
     tttt = dtrend_msg(ispan(0,dimsizes(hcei)-1,1),hcei,False,True)
     arr(0,:) = (/ hcei /)
     arr(1,:) = (/ runave_n(hcei, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hcei)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = "Latitude (degree)"      ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hcei),2,True)+hcei@units+" "+nyr(ee)+"yr~S~-1~N~" 
     xyn1(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hcei)),arr,xyres6)
     delete(tttt)

     tttt = dtrend_msg(ispan(0,dimsizes(hcwn)-1,1),hcwn,False,True)
     arr(0,:) = (/ hcwn /)
     arr(1,:) = (/ runave_n(hcwn, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hcwn)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = "Latitude (degree)"       ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hcwn),2,True)+hcwn@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn2(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hcwn)),arr,xyres6)
     delete(tttt)

     tttt = dtrend_msg(ispan(0,dimsizes(hcws)-1,1),hcws,False,True)
     arr(0,:) = (/ hcws /)
     arr(1,:) = (/ runave_n(hcws, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hcws)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = "Latitude (degree)"       ; add an axis title
     xyres6@tiXAxisString  = "Time"      ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hcws),2,True)+hcws@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn3(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hcws)),arr,xyres6) 
     delete(tttt)
     
     tttt = dtrend_msg(ispan(0,dimsizes(hcin)-1,1),hcin,False,True)
     arr(0,:) = (/ hcin /)
     arr(1,:) = (/ runave_n(hcin, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hcin)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = hcin@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"          ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hcin),2,True)+hcin@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn4(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hcin)),arr,xyres6)
     delete(tttt)

     tttt = dtrend_msg(ispan(0,dimsizes(hcis)-1,1),hcis,False,True)
     arr(0,:) = (/ hcis /)
     arr(1,:) = (/ runave_n(hcis, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hcis)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = hcis@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"          ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hcis),2,True)+hcis@units+" "+nyr(ee)+"yr~S~-1~N~" 
     xyn5(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hcis)),arr,xyres6)
     delete(tttt)  

     tttt = dtrend_msg(ispan(0,dimsizes(hcen)-1,1),hcen,False,True)
     arr(0,:) = (/ hcen /)
     arr(1,:) = (/ runave_n(hcen, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hcen)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = "Latitude (degree)"      ; add an axis title
     xyres6@tiXAxisString  = "Time"          ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hcen),2,True)+hcen@units+" "+nyr(ee)+"yr~S~-1~N~" 
     xyn6(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hcen)),arr,xyres6)
     delete(tttt)  

     tttt = dtrend_msg(ispan(0,dimsizes(hces)-1,1),hces,False,True)
     arr(0,:) = (/ hces /)
     arr(1,:) = (/ runave_n(hces, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hces)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = "Latitude (degree)"      ; add an axis title
     xyres6@tiXAxisString  = "Time"          ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hces),2,True)+hces@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn7(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hces)),arr,xyres6)
     delete(tttt)

     tttt = dtrend_msg(ispan(0,dimsizes(hmcin)-1,1),hmcin,False,True)
     arr(0,:) = (/ hmcin /)
     arr(1,:) = (/ runave_n(hmcin, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hmcin)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = hmcin@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"          ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hmcin),2,True)+hmcin@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn8(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hmcin)),arr,xyres6)
     delete(tttt)

     tttt = dtrend_msg(ispan(0,dimsizes(hmcis)-1,1),hmcis,False,True)
     arr(0,:) = (/ hmcis /)
     arr(1,:) = (/ runave_n(hmcis, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hmcis)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = hmcis@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"          ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hmcis),2,True)+hmcis@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn9(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hmcis)),arr,xyres6)
     delete(tttt)

     tttt = dtrend_msg(ispan(0,dimsizes(hxcin)-1,1),hxcin,False,True)
     arr(0,:) = (/ hxcin /)
     arr(1,:) = (/ runave_n(hxcin, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hxcin)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = hxcin@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"          ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hxcin),2,True)+hxcin@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn10(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hxcin)),arr,xyres6)
     delete(tttt)
     
     tttt = dtrend_msg(ispan(0,dimsizes(hxcis)-1,1),hxcis,False,True)
     arr(0,:) = (/ hxcis /)
     arr(1,:) = (/ runave_n(hxcis, 3, 0, 0) /)
     arr(2,:) = (/ (ispan(0,dimsizes(hxcis)-1,1)*tttt@slope)+tttt@y_intercept /)
     xyres6@tiYAxisString  = hxcis@units      ; add an axis title
     xyres6@tiXAxisString  = "Time"          ; add an axis title
     xyres6@gsnRightString = "trend: "+ decimalPlaces(tttt@slope*dimsizes(hxcis),2,True)+hxcis@units+" "+nyr(ee)+"yr~S~-1~N~"
     xyn11(ee) = gsn_csm_xy(wks_hc,fspan(syear(ee),eyear(ee)+.91667,dimsizes(hxcis)),arr,xyres6)
     delete([/xyres6,arr,tttt/])
 
     xyres2@gsnLeftString = names(ee)
     if (nyr(ee).ge.20) then
        xyres2@gsnRightString = sprintf("%4.2f", min(sd_run))+" / "+sprintf("%4.2f", avg(sd_run))+" / "+sprintf("%4.2f", max(sd_run))+sd_run@units
        xyhc_rst(ee) = gsn_csm_xy(wks_hc_rst,fspan(syear(ee),eyear(ee)+.91667,dimsizes(sd_run)),sd_run,xyres2)
     end if
     
     xyres3@gsnRightStringFontHeightF = xyres3@gsnCenterStringFontHeightF
     xyres3@gsnLeftString = syear(ee)+"-"+eyear(ee)
     xyres3@gsnCenterString = names(ee)
     xyres3@gsnRightString = "C"
     if (max(hc_mon_sd).gt.xyres3@gsnYRefLine) then
        xyhc_mst(ee) = gsn_csm_xy(wks_hc_mst,ispan(1,12,1),hc_mon_sd,xyres3)
     end if
     title_n0  = hcwd@comment_cvdp
     title_n1  = hcei@comment_cvdp 
     title_n2  = hcwn@comment_cvdp 
     title_n3  = hcws@comment_cvdp
     title_n4  = hcen@comment_cvdp
     title_n5  = hces@comment_cvdp
     title_n6  = hcin@comment_cvdp
     title_n7  = hcis@comment_cvdp
     title_n8  = hmcin@comment_cvdp
     title_n9  = hmcis@comment_cvdp
     title_n10 = hxcin@comment_cvdp
     title_n11 = hxcis@comment_cvdp
     delete([/hcwd,hcei,hcwn,hcws,hcen,hces,hcin,hcis,hmcin,hmcis,hxcin,hxcis,hpin,hpis,hmpin,hmpis,hcind,hcisd/])

     if (spectra_mvf.eq.False) then
        xyres4@gsnCenterString = names(ee)
        xyres4@gsnRightString = syear(ee)+"-"+eyear(ee)
        xyhc_ac(ee) = gsn_csm_xy(wks_hc_p,ispan(0,48,1),ac34,xyres4)
        if (ee.ge.1.and.isvar("ac34_obs")) then
           delete([/xyres4@gsnAboveYRefLineColor,xyres4@gsnBelowYRefLineColor/])
           xyres4@xyLineColor = "gray62"
           xyres4@xyCurveDrawOrder = "PreDraw"
           xyres4@gsnCenterString = ""
           xyres4@gsnRightString = ""
           xyhc_ac_obs(ee) = gsn_csm_xy(wks_hc_p,ispan(0,48,1),ac34_obs,xyres4)
           overlay(xyhc_ac(ee),xyhc_ac_obs(ee)) 
           delete(xyres4@xyCurveDrawOrder)
           delete(ac34)
        end if
     end if
     delete([/xyres,xyres2,xyres3,xyres4,hc_mon_sd/])

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
        plot_wave34(ee) = gsn_csm_contour(wks_hc_p,power34,wres)
        plot_wave34(ee) = ShadeCOI(wks_hc_p,plot_wave34(ee),wave34,power34&time,wavecoi)
        o0 = gsn_csm_contour(wks_hc_p,sig34,wsres)
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
        pspec(ee) = gsn_csm_xy(wks_hc_p,sdof@frq,splt1,pres) 
        if (isfilepresent2("obs_ts").and.ee.ge.1.and.spectra_mvf_obs.eq.False) then
           pres@xyLineColors        = (/"gray70","black","black","black"/)
           pres@xyCurveDrawOrder = "PreDraw"
           pres@gsnCenterString = ""
           pres@gsnRightString = ""
           pspec_obs(ee) = gsn_csm_xy(wks_hc_p,sdof_obs@frq,sdof_obs@spcx,pres)
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
     new_index = NhlNewDashPattern(wks_hcsc,"$_$_$_$_$_$_$_$_$_")
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
           patcor_tas(ee,:,:) = (/ totype(linint2(hcsc_tas&lon,hcsc_tas&lat,hcsc_tas(12,:,:),True,patcor_tas&lon,patcor_tas&lat,0),typeof(patcor_tas)) /)
           patcor_psl(ee,:,:) = (/ totype(linint2(hcsc_psl&lon,hcsc_psl&lat,hcsc_psl(12,:,:),True,patcor_psl&lon,patcor_psl&lat,0),typeof(patcor_psl)) /)
        else
           if (isfilepresent2("obs_trefht")) then
              patcor_tas = new((/nsim,dimsizes(hcsc_tas&lat),dimsizes(hcsc_tas&lon)/),typeof(hcsc_tas))
              patcor_tas!1 = "lat"
              patcor_tas&lat = hcsc_tas&lat
              patcor_tas!2 = "lon"
              patcor_tas&lon = hcsc_tas&lon
              patcor_psl = new((/nsim,dimsizes(hcsc_psl&lat),dimsizes(hcsc_psl&lon)/),typeof(hcsc_psl))
              patcor_psl!1 = "lat"
              patcor_psl&lat = hcsc_psl&lat
              patcor_psl!2 = "lon"
              patcor_psl&lon = hcsc_psl&lon
              patcor_tas(ee,:,:) = (/ hcsc_tas(12,:,:) /)
              patcor_psl(ee,:,:) = (/ hcsc_psl(12,:,:) /)
           end if
        end if
     
        d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")     ; mask ocean for TAS array
        basemap = d->LSMASK
        lsm = landsea_mask(basemap,hcsc_tas&lat,hcsc_tas&lon)
        hcsc_tas = mask(hcsc_tas,conform(hcsc_tas,lsm,(/1,2/)).eq.0,False)
        delete([/lsm,basemap/])
        delete(d)
     
        map_hcsc_jja0(ee) = gsn_csm_contour_map(wks_hcsc,hcsc_sst(6,:,:),scres)    ; 6 = JJA 0    
        o1 = gsn_csm_contour(wks_hcsc,hcsc_tas(6,:,:),scres2)  
        o2 = gsn_csm_contour(wks_hcsc,hcsc_psl(6,:,:),scres3) 
        overlay(map_hcsc_jja0(ee),o1)
        overlay(map_hcsc_jja0(ee),o2)
        delete([/o1,o2/])
        
        map_hcsc_son0(ee) = gsn_csm_contour_map(wks_hcsc,hcsc_sst(9,:,:),scres)    ; 9 = SON 0      
        o3 = gsn_csm_contour(wks_hcsc,hcsc_tas(9,:,:),scres2)  
        o4 = gsn_csm_contour(wks_hcsc,hcsc_psl(9,:,:),scres3) 
        overlay(map_hcsc_son0(ee),o3)
        overlay(map_hcsc_son0(ee),o4)
        delete([/o3,o4/])
        
        
        map_hcsc_djf1(ee) = gsn_csm_contour_map(wks_hcsc,hcsc_sst(12,:,:),scres)    ; 12 = DJF+1      
        o5 = gsn_csm_contour(wks_hcsc,hcsc_tas(12,:,:),scres2)  
        o6 = gsn_csm_contour(wks_hcsc,hcsc_psl(12,:,:),scres3) 
        overlay(map_hcsc_djf1(ee),o5)
        overlay(map_hcsc_djf1(ee),o6)
        delete([/o5,o6/])
        
        map_hcsc_mam1(ee) = gsn_csm_contour_map(wks_hcsc,hcsc_sst(15,:,:),scres)    ; 15 = MAM+1      
        o7 = gsn_csm_contour(wks_hcsc,hcsc_tas(15,:,:),scres2)  
        o8 = gsn_csm_contour(wks_hcsc,hcsc_psl(15,:,:),scres3) 
        overlay(map_hcsc_mam1(ee),o7)
        overlay(map_hcsc_mam1(ee),o8)
        delete([/o7,o8/])       
        delete([/hcsc_sst,hcsc_tas,hcsc_psl/])
     end if
     if (pptreg_plot_flag.eq.0) then     
        map_hcsc_ppt_jja0(ee) = gsn_csm_contour_map(wks_hcsc_ppt,hcsc_ppt(6,:,:),scres4)    ; 6 = JJA 0            
        map_hcsc_ppt_son0(ee) = gsn_csm_contour_map(wks_hcsc_ppt,hcsc_ppt(9,:,:),scres4)    ; 9 = SON 0              
        map_hcsc_ppt_djf1(ee) = gsn_csm_contour_map(wks_hcsc_ppt,hcsc_ppt(12,:,:),scres4)    ; 12 = DJF+1              
        map_hcsc_ppt_mam1(ee) = gsn_csm_contour_map(wks_hcsc_ppt,hcsc_ppt(15,:,:),scres4)    ; 15 = MAM+1      
        delete([/hcsc_ppt/])
     end if
  end do
  
  if (isvar("patcor_tas")) then    ; for pattern correlation table  
     clat_tas  = cos(0.01745329*patcor_tas&lat)
     clat_psl  = cos(0.01745329*patcor_psl&lat)
     finpr_tas = "Hadley cell TAS (DJF+1)  "    ; Must be 18 characters long
     finpr_psl = "Hadley cell PSL (DJF+1)  " 
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
        write_table(getenv("OUTDIR")+"metrics.zmsf.indices.1.txt","w",[/header/],"%s")
        write_table(getenv("OUTDIR")+"metrics.zmsf.indices.1.txt","a",[/line3/],"%s")
        write_table(getenv("OUTDIR")+"metrics.zmsf.indices.1.txt","a",[/line4/],"%s")
        write_table(getenv("OUTDIR")+"metrics.zmsf.indices.1.txt","a",[/finpr_tas/],"%s")
        write_table(getenv("OUTDIR")+"metrics.zmsf.indices.1.txt","a",[/finpr_psl/],"%s")
     end if  
     delete([/finpr_tas,finpr_psl,line3,line4,format2,format3,nchar,ntc,clat_tas,clat_psl,patcor_tas,patcor_psl,dimY,ntb,header/])
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
     panres@txString = "Hadley cell width (Monthly, "+title_n0+")"
     gsn_panel2(wks_hc,xyn0,lp,panres)    

     panres@txString = "Hadley cell intersection (Monthly, "+title_n1+")"
     gsn_panel2(wks_hc,xyn1,lp,panres)

     panres@txString = "Hadley cell width (NH branch) (Monthly, "+title_n2+")"
     gsn_panel2(wks_hc,xyn2,lp,panres)

     panres@txString = "Hadley cell width (SH branch) (Monthly, "+title_n3+")"
     gsn_panel2(wks_hc,xyn3,lp,panres)

     panres@txString = "Hadley cell intensity (NH branch) (Monthly, "+title_n4+")"
     gsn_panel2(wks_hc,xyn4,lp,panres)

     panres@txString = "Hadley cell intensity (SH branch) (Monthly, "+title_n5+")"
     gsn_panel2(wks_hc,xyn5,lp,panres)

     panres@txString = "Hadley cell poleward extent (NH branch) (Monthly, "+title_n6+")"
     gsn_panel2(wks_hc,xyn6,lp,panres)

     panres@txString = "Hadley cell poleward extent (SH branch) (Monthly, "+title_n7+")"
     gsn_panel2(wks_hc,xyn7,lp,panres)

     panres@txString = "Hadley cell mean intensity (900-200hPa, NH branch) (Monthly, "+title_n8+")"
     gsn_panel2(wks_hc,xyn8,lp,panres)

     panres@txString = "Hadley cell mean intensity (900-200hPa, SH branch) (Monthly, "+title_n9+")"
     gsn_panel2(wks_hc,xyn9,lp,panres)

     panres@txString = "Hadley cell max. intensity (900-200hPa, NH branch) (Monthly, "+title_n10+")"
     gsn_panel2(wks_hc,xyn10,lp,panres)
     
     panres@txString = "Hadley cell max. intensity (900-200hPa, SH branch) (Monthly, "+title_n11+")"
     gsn_panel2(wks_hc,xyn11,lp,panres)

  end if
  delete([/wks_hc/]) 

  if (all(ismissing(xyhc_rst))) then
;     print("No valid running standard deviation plots, skipping")
  else
     panres@txString = "Hadley Cell index 15yr running standard deviation"
     gsn_panel2(wks_hc_rst,xyhc_rst,lp,panres) 
     delete(xyhc_rst)  
  end if
  panres@gsnPanelYWhiteSpacePercent = 0.5
  panres@txString = "Hadley Cell index standard deviation (Monthly)"
  gsn_panel2(wks_hc_mst,xyhc_mst,(/nrow,ncol/),panres)   
  
  panres2 = True
  panres2@gsnMaximize = True
  panres2@gsnPaperOrientation = "portrait"
  panres2@gsnPanelLabelBar = True
  panres2@lbLabelStride = 1
  panres2@pmLabelBarWidthF = 0.4
  panres2@pmLabelBarHeightF = 0.04
  panres@pmLabelBarOrthogonalPosF = -0.03
  panres2@txString = ""   

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
  panres@txString = "Hadley cell width index (Monthly, detrended)"
  gsn_panel2(wks_hc_p,pspec,(/nrow,ncol/),panres)  
  panres@txString = "Hadley cell width index Autocorrelation (Monthly)"
  gsn_panel2(wks_hc_p,xyhc_ac,(/nrow,ncol/),panres) 
  panres2@txString = "Hadley cell width Wavelet (Monthly)"
  panres2@gsnPanelYWhiteSpacePercent = 3.0
  panres2@gsnPanelXWhiteSpacePercent = 4.0
  gsn_panel2(wks_hc_p,plot_wave34,(/nrow,ncol/),panres2)  
  delete(wks_hc_p)

  delete(panres2@gsnPanelYWhiteSpacePercent)
  panres2@pmLabelBarWidthF = 0.8
  panres2@lbLabelAutoStride = False
  panres2@gsnPanelXWhiteSpacePercent = 8.5
  if (any(.not.ismissing(map_hcsc_jja0))) then
     panres2@lbTitleString = "SST/TAS (C)"
     panres2@pmLabelBarOrthogonalPosF = -0.05
     panres2@txString = "Hadley Cell SST,TAS,PSL Spatial Composite (JJA~S~0~N~)"
     gsn_panel2(wks_hcsc,map_hcsc_jja0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Hadley Cell SST,TAS,PSL Spatial Composite (SON~S~0~N~)"
     gsn_panel2(wks_hcsc,map_hcsc_son0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Hadley Cell SST,TAS,PSL Spatial Composite (DJF~S~+1~N~)"
     gsn_panel2(wks_hcsc,map_hcsc_djf1,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Hadley Cell SST,TAS,PSL Spatial Composite (MAM~S~+1~N~)"
     gsn_panel2(wks_hcsc,map_hcsc_mam1,(/nrow,ncol/),panres2)   
     delete(wks_hcsc)
     
     delete([/map_hcsc_djf1,map_hcsc_jja0,map_hcsc_son0,map_hcsc_mam1/])
  end if     
  if (any(.not.ismissing(map_hcsc_ppt_jja0))) then
     panres2@txString = "Hadley Cell PR Spatial Composite (JJA~S~0~N~)"
     gsn_panel2(wks_hcsc_ppt,map_hcsc_ppt_jja0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Hadley Cell PR Spatial Composite (SON~S~0~N~)"
     gsn_panel2(wks_hcsc_ppt,map_hcsc_ppt_son0,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Hadley Cell PR Spatial Composite (DJF~S~+1~N~)"
     gsn_panel2(wks_hcsc_ppt,map_hcsc_ppt_djf1,(/nrow,ncol/),panres2)   
  
     panres2@txString = "Hadley Cell PR Spatial Composite (MAM~S~+1~N~)"
     gsn_panel2(wks_hcsc_ppt,map_hcsc_ppt_mam1,(/nrow,ncol/),panres2)   
     delete(wks_hcsc_ppt)
     
     delete([/map_hcsc_ppt_djf1,map_hcsc_ppt_jja0,map_hcsc_ppt_son0,map_hcsc_ppt_mam1/])
  end if   

  delete([/xyn0,xyn1,xyn2,xyn3,xyn4,xyn5,xyn6,xyn7,xyn8,xyn9,xyn10,xyn11,pspec,pi,rad,wgt,lp/])     

  OUTDIR = getenv("OUTDIR")
  
  if (wks_type.eq."png") then  
     if (isfilepresent2(OUTDIR+"hc.spatialcomp.000001.png")) then
        system("mv "+OUTDIR+"hc.spatialcomp.000001.png "+OUTDIR+"hc.spatialcomp.jja0.png")
        system("mv "+OUTDIR+"hc.spatialcomp.000002.png "+OUTDIR+"hc.spatialcomp.son0.png")
        system("mv "+OUTDIR+"hc.spatialcomp.000003.png "+OUTDIR+"hc.spatialcomp.djf1.png")
        system("mv "+OUTDIR+"hc.spatialcomp.000004.png "+OUTDIR+"hc.spatialcomp.mam1.png")
     end if
     if (isfilepresent2(OUTDIR+"hc.spatialcomp.ppt.000001.png")) then
        system("mv "+OUTDIR+"hc.spatialcomp.ppt.000001.png "+OUTDIR+"hc.spatialcomp.pr.jja0.png")
        system("mv "+OUTDIR+"hc.spatialcomp.ppt.000002.png "+OUTDIR+"hc.spatialcomp.pr.son0.png")
        system("mv "+OUTDIR+"hc.spatialcomp.ppt.000003.png "+OUTDIR+"hc.spatialcomp.pr.djf1.png")
        system("mv "+OUTDIR+"hc.spatialcomp.ppt.000004.png "+OUTDIR+"hc.spatialcomp.pr.mam1.png")
     end if
     if (isfilepresent2(OUTDIR+"hc.timeseries.000001.png")) then
        system("mv "+OUTDIR+"hc.timeseries.000001.png "+OUTDIR+"hcwd.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000002.png "+OUTDIR+"hcei.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000003.png "+OUTDIR+"hcwn.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000004.png "+OUTDIR+"hcws.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000005.png "+OUTDIR+"hcin.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000006.png "+OUTDIR+"hcis.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000007.png "+OUTDIR+"hcen.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000008.png "+OUTDIR+"hces.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000009.png "+OUTDIR+"hmcin.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000010.png "+OUTDIR+"hmcis.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000011.png "+OUTDIR+"hxcin.timeseries.png")
        system("mv "+OUTDIR+"hc.timeseries.000012.png "+OUTDIR+"hxcis.timeseries.png")
     end if
     if (isfilepresent2(OUTDIR+"hc.powspec.000001.png")) then
        system("mv "+OUTDIR+"hc.powspec.000001.png "+OUTDIR+"hc.powspec.png")
        system("mv "+OUTDIR+"hc.powspec.000002.png "+OUTDIR+"hc.autocor.png")
        system("mv "+OUTDIR+"hc.powspec.000003.png "+OUTDIR+"hc.wavelet.png")
     end if
  else
     if (isfilepresent2(OUTDIR+"hc.spatialcomp.ps")) then
        system("psplit "+OUTDIR+"hc.spatialcomp.ps "+OUTDIR+"ua_ind")
        system("mv "+OUTDIR+"ua_ind0001.ps "+OUTDIR+"hc.spatialcomp.jja0.ps")
        system("mv "+OUTDIR+"ua_ind0002.ps "+OUTDIR+"hc.spatialcomp.son0.ps")
        system("mv "+OUTDIR+"ua_ind0003.ps "+OUTDIR+"hc.spatialcomp.djf1.ps")
        system("mv "+OUTDIR+"ua_ind0004.ps "+OUTDIR+"hc.spatialcomp.mam1.ps")
        system("rm "+OUTDIR+"hc.spatialcomp.ps")
     end if
     if (isfilepresent2(OUTDIR+"hc.spatialcomp.ppt.ps")) then
        system("psplit "+OUTDIR+"hc.spatialcomp.ppt.ps "+OUTDIR+"ua_ind")
        system("mv "+OUTDIR+"ua_ind0001.ps "+OUTDIR+"hc.spatialcomp.pr.jja0.ps")
        system("mv "+OUTDIR+"ua_ind0002.ps "+OUTDIR+"hc.spatialcomp.pr.son0.ps")
        system("mv "+OUTDIR+"ua_ind0003.ps "+OUTDIR+"hc.spatialcomp.pr.djf1.ps")
        system("mv "+OUTDIR+"ua_ind0004.ps "+OUTDIR+"hc.spatialcomp.pr.mam1.ps")
        system("rm "+OUTDIR+"hc.spatialcomp.ppt.ps")
     end if
     if (isfilepresent2(OUTDIR+"hc.timeseries.ps")) then
        system("psplit "+OUTDIR+"hc.timeseries.ps "+OUTDIR+"hczmsf_ind")
        system("mv "+OUTDIR+"hczmsf_ind0001.ps "+OUTDIR+"hcwd.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0002.ps "+OUTDIR+"hcei.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0003.ps "+OUTDIR+"hcwn.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0004.ps "+OUTDIR+"hcws.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0005.ps "+OUTDIR+"hcin.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0006.ps "+OUTDIR+"hcis.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0007.ps "+OUTDIR+"hcen.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0008.ps "+OUTDIR+"hces.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0009.ps "+OUTDIR+"hmcin.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0010.ps "+OUTDIR+"hmcis.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0011.ps "+OUTDIR+"hxcin.timeseries.ps")
        system("mv "+OUTDIR+"hczmsf_ind0012.ps "+OUTDIR+"hxcis.timeseries.ps")
     end if
     if (isfilepresent2(OUTDIR+"hc.powspec.ps")) then
        system("psplit "+OUTDIR+"hc.powspec.ps "+OUTDIR+"hcp")
        system("mv "+OUTDIR+"hcp0001.ps "+OUTDIR+"hc.powspec.ps")
        if (isfilepresent2(OUTDIR+"hcp0002.ps")) then
           system("mv "+OUTDIR+"hcp0002.ps "+OUTDIR+"hc.autocor.ps")
           system("mv "+OUTDIR+"hcp0003.ps "+OUTDIR+"hc.wavelet.ps")
        end if
     end if
  end if
  print("Finished: zmsf.indices.ncl")
end
