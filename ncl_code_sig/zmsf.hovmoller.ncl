; Calculates 2m air temperature global means and standard deviations
;
; Variables used: zmsf
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: zmsf.hovmoller.ncl")
  
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
  nyr = eyear-syear+1
  nyr_max = max(nyr)
  
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if
  wks_hovmoller_djf = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.hovmoller.djf")
  wks_hovmoller_mam = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.hovmoller.mam")
  wks_hovmoller_jja = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.hovmoller.jja")
  wks_hovmoller_son = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.hovmoller.son")
  wks_hovmoller_ann = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.hovmoller.ann")
  wks_hovmoller_mon = gsn_open_wks(wks_type,getenv("OUTDIR")+"zmsf.hovmoller.mon")
 
  if (COLORMAP.eq.0) then
     gsn_define_colormap(wks_hovmoller_djf,"NCV_jaisnd") 
     gsn_define_colormap(wks_hovmoller_mam,"NCV_jaisnd")  
     gsn_define_colormap(wks_hovmoller_jja,"NCV_jaisnd") 
     gsn_define_colormap(wks_hovmoller_son,"NCV_jaisnd")  
     gsn_define_colormap(wks_hovmoller_ann,"NCV_jaisnd")
     gsn_define_colormap(wks_hovmoller_mon,"NCV_jaisnd")
  end if
  if (COLORMAP.eq.1) then
     gsn_define_colormap(wks_hovmoller_djf,"BlueDarkRed18") 
     gsn_define_colormap(wks_hovmoller_mam,"BlueDarkRed18")  
     gsn_define_colormap(wks_hovmoller_jja,"BlueDarkRed18") 
     gsn_define_colormap(wks_hovmoller_son,"BlueDarkRed18")  
     gsn_define_colormap(wks_hovmoller_ann,"BlueDarkRed18")     
     gsn_define_colormap(wks_hovmoller_mon,"BlueDarkRed18")
  end if

  map_djf = new(nsim,"graphic")  
  map_mam = new(nsim,"graphic")  
  map_jja = new(nsim,"graphic")  
  map_son = new(nsim,"graphic")   
  map_ann = new(nsim,"graphic")  
  map_mon = new(nsim,"graphic")

  do ee = 0,nsim-1
     zmsf = data_read_in(paths(ee),"SF",syear(ee),eyear(ee))    ; read in data, orient lats/lons correctly, set time coordinate variable up   
     if (isatt(zmsf,"is_all_missing")) then
        delete(zmsf)
        continue
     end if 

     scale_factor = 1.e9
     zmsf         = zmsf / scale_factor 
     zmsf@units   = "10~S~9~N~ " + zmsf@units
     lbunit       = zmsf@units

     ;dreive layer thickness for vertical average;
     plev       = zmsf&lev
     plev@units = "hPa"
     plev!0     = "lev"
     plev&lev   = plev
     dpth = dpres_plevel_Wrap(plev, 1018, 0, 0)

     delete(zmsf&lev)
     zmsf&lev = plev

     zmsf_seas = runave_n_Wrap(zmsf,3,0,0)
     zmsf_seas(0,:,:) = (/ dim_avg_n(zmsf(:1,:,:),0) /)
     zmsf_seas(dimsizes(zmsf&time)-1,:,:) = (/ dim_avg_n(zmsf(dimsizes(zmsf&time)-2:,:,:),0) /)
     zmsf_ann = runave_n_Wrap(zmsf,12,0,0)
     
     zmsf_920_hovmoller_seas      = zmsf_seas(lev|0:3,lat|:,time|0::12)
     zmsf_920_hovmoller_seas      = zmsf_920_hovmoller_seas@_FillValue
     zmsf_920_hovmoller_seas!1    = "lat"
     zmsf_920_hovmoller_seas&lat  = zmsf_seas&lat
     zmsf_920_hovmoller_seas!2    = "time"
     zmsf_920_hovmoller_seas&time = ispan(syear(ee),eyear(ee),1)
     zmsf_920_hovmoller_ann       = zmsf_920_hovmoller_seas(0,:,:)
     zmsf_920_hovmoller_ann!0     = "lat"
     zmsf_920_hovmoller_ann&lat   = zmsf_seas&lat  
     zmsf_920_hovmoller_ann!1     = "time"
     zmsf_920_hovmoller_ann&time  = ispan(syear(ee),eyear(ee),1)
     zmsf_740_hovmoller_seas      = zmsf_920_hovmoller_seas
     zmsf_740_hovmoller_ann       = zmsf_920_hovmoller_ann 

     do ff = 0,4
        if (ff.le.3) then
           tarr = zmsf_seas(ff*3::12,:,:)
        end if
        if (ff.eq.4) then
           tarr = zmsf_ann(5::12,:,:)
        end if
        if (ff.le.3) then
           zmsf_920_hovmoller_seas(ff,:,:) = (/ dim_avg_wgt_n(tarr({lev|900:200},lat|:,time|:),dpth({900:200}),1,0) /) 
           zmsf_740_hovmoller_seas(ff,:,:) = (/ dim_avg_wgt_n(tarr({lev|700:400},lat|:,time|:),dpth({700:400}),1,0) /)    
        end if
        if (ff.eq.4) then
           zmsf_920_hovmoller_ann = (/ dim_avg_wgt_n(tarr({lev|900:200},lat|:,time|:),dpth({900:200}),1,0) /)
           zmsf_740_hovmoller_ann = (/ dim_avg_wgt_n(tarr({lev|700:400},lat|:,time|:),dpth({700:400}),1,0) /)
        end if
        delete([/tarr/])
     end do
 
     zmsf_920_hc_lat_seas           = new((/2,4,nyr(ee)/),float)
     zmsf_920_hc_lat_seas!2         = "time" 
     zmsf_920_hc_lat_seas&time      = ispan(syear(ee),eyear(ee),1) 
     zmsf_920_hc_lat_seas@units     = "degree"
     zmsf_920_hc_lat_seas@long_name = "Hadley cell poleward extend latitude"
     zmsf_920_hc_lat_ann            = zmsf_920_hc_lat_seas(:,0,:)

     do ff = 0, 4 
        if (ff.le.3) then
           tarr = zmsf_seas(ff*3::12,:,:)
        end if
        if (ff.eq.4) then
           tarr = zmsf_ann(5::12,:,:)
        end if
        do kk  = 0, nyr(ee)-1
          do ii = 0,1
            if(ii.eq.0) then 
              tmpx = tarr({lat|-30:0},time|:,{lev|900:200})
              nmax = dim_minind(tmpx,0)  
            else 
              tmpx = tarr({lat|0:30},time|:,{lev|900:200})
              nmax = dim_maxind(tmpx,0) 
            end if 
            if (ff.le.3) then
              zmsf_920_hc_lat_seas(ii,ff,kk) = tofloat(avg(tmpx&lat(nmax(kk,:))))
            end if 
            if (ff.eq.4) then
              zmsf_920_hc_lat_ann(ii,kk) = tofloat(avg(tmpx&lat(nmax(kk,:))))
            end if
            delete([/tmpx,nmax/])
          end do 
        end do
        delete(tarr)
    end do 

    delete([/zmsf_seas,zmsf_ann,zmsf,dpth,plev/])

    
     if (OUTPUT_DATA.eq."True") then
        modname = str_sub_str(names(ee)," ","_")
        bc = (/"/","'","(",")"/)
        do gg = 0,dimsizes(bc)-1
           modname = str_sub_str(modname,bc(gg),"_")
        end do
        fn = getenv("OUTDIR")+modname+".cvdp_data.zmsf.hovmoller."+syear(ee)+"-"+eyear(ee)+".nc"
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

        z->zmsf920_hovmoller_djf = set_varAtts(zmsf_920_hovmoller_seas(0,:,:),"zmsf 900-200hPa mean hovmoller (DJF)","","")
        z->zmsf920_hovmoller_mam = set_varAtts(zmsf_920_hovmoller_seas(1,:,:),"zmsf 900-200hPa mean hovmoller (MAM)","","")
        z->zmsf920_hovmoller_jja = set_varAtts(zmsf_920_hovmoller_seas(2,:,:),"zmsf 900-200hPa mean hovmoller (JJA)","","")
        z->zmsf920_hovmoller_son = set_varAtts(zmsf_920_hovmoller_seas(3,:,:),"zmsf 900-200hPa mean hovmoller (SON)","","")
        z->zmsf920_hovmoller_ann = set_varAtts(zmsf_920_hovmoller_ann,"zmsf 900-200hPa mean (annual)","","")

        z->zmsf740_hovmoller_djf = set_varAtts(zmsf_740_hovmoller_seas(0,:,:),"zmsf 700-400hPa mean hovmoller (DJF)","","")
        z->zmsf740_hovmoller_mam = set_varAtts(zmsf_740_hovmoller_seas(1,:,:),"zmsf 700-400hPa mean hovmoller (MAM)","","")
        z->zmsf740_hovmoller_jja = set_varAtts(zmsf_740_hovmoller_seas(2,:,:),"zmsf 700-400hPa mean hovmoller (JJA)","","")
        z->zmsf740_hovmoller_son = set_varAtts(zmsf_740_hovmoller_seas(3,:,:),"zmsf 700-400hPa mean hovmoller (SON)","","")
        z->zmsf740_hovmoller_ann = set_varAtts(zmsf_740_hovmoller_ann,"zmsf 700-400hPa mean hovmoller (annual)","","")


        z->zmsf920_hcext_djf = set_varAtts(zmsf_920_hc_lat_seas(:,0,:),"900-200hPa mean hadley cell extent (DJF)","","")
        z->zmsf920_hcext_mam = set_varAtts(zmsf_920_hc_lat_seas(:,1,:),"900-200hPa mean hadley cell extent (MAM)","","")
        z->zmsf920_hcext_jja = set_varAtts(zmsf_920_hc_lat_seas(:,2,:),"900-200hPa mean hadley cell extent (JJA)","","")
        z->zmsf920_hcext_son = set_varAtts(zmsf_920_hc_lat_seas(:,3,:),"900-200hPa mean hadley cell extent (SON)","","")
        z->zmsf920_hcext_ann = set_varAtts(zmsf_920_hc_lat_ann,"900-200hPa mean hadley cell extent (annual)","","")

        delete([/z,modname,fn/])
     end if
     
;==========================================================================================
     res = True
     res@vpWidthF   = 0.95
     res@vpHeightF  = 0.6

     if (wks_type.eq."png") then
       res@tmBorderThicknessF           = 2.0
       res@tmXBMajorThicknessF          = 2.0
       res@tmXBMinorThicknessF          = 2.0
       res@tmYLMajorThicknessF          = 2.0
       res@tmYLMinorThicknessF          = 2.0
       res@tmYRMajorThicknessF          = 2.0
       res@tmYRMinorThicknessF          = 2.0
       res@cnLineThicknessF             = 2.0
       res@gsnContourZeroLineThicknessF = 4.0
       res@gsnContourNegLineDashPattern = 2
       res@gsnContourPosLineDashPattern = 0
     else
       res@tmBorderThicknessF           = 1.0 
       res@tmXBMajorThicknessF          = 1.0 
       res@tmXBMinorThicknessF          = 1.0 
       res@tmYLMajorThicknessF          = 1.0 
       res@tmYLMinorThicknessF          = 1.0 
       res@tmYRMajorThicknessF          = 1.0 
       res@tmYRMinorThicknessF          = 1.0 
       res@cnLineThicknessF             = 1.0
       res@gsnContourZeroLineThicknessF = 2.0
       res@gsnContourNegLineDashPattern = 2
       res@gsnContourPosLineDashPattern = 0
     end if
    ;res@tmYRMode     = "Automatic"          ; turn off special labels on right axis

     res@gsnDraw      = False
     res@gsnFrame     = False
  
     res@tiYAxisString                = "Latitude"
     res@tiXAxisString                = "Year"

     res@gsnLeftStringFontHeightF     = 0.025
     res@gsnLeftStringOrthogonalPosF  = 0.015

     res@cnLineLabelsOn         = False
     res@cnFillOn               = True
     res@cnLinesOn              = True
     res@cnLineLabelsOn         = False        ; True is default
     res@cnInfoLabelOn          = False                ; turn off info label
     res@lbLabelBarOn           = False
     res@cnMissingValFillColor  = "White" ;"gray76"               ; black = 1

     res@trXMinF         = syear(ee)
     res@trXMaxF         = eyear(ee)
     res@tmXBMode        = "Explicit"
     if((eyear(ee)-syear(ee)+1).le.50) then
       int_major = 5
       int_minor = 1
     else if((eyear(ee)-syear(ee)+1).le.100) then
       int_major = 10 
       int_minor = 2
     else
       int_major = 20 
       int_minor = 5 
     end if
     end if
     res@trXMinF         = syear(ee)
     res@trXMaxF         = eyear(ee)
     res@tmXBMode        = "Explicit"
     res@tmXBValues      = ispan(syear(ee),eyear(ee),int_major)
     res@tmXBLabels      = ispan(syear(ee),eyear(ee),int_major) 
     res@tmXBMinorValues = ispan(syear(ee),eyear(ee),int_minor) 

     res@trYMinF         = -45.0
     res@trYMaxF         =  45.0 
     res@tmYLMode        = "Explicit"
     res@tmYLValues      = ispan(toint(res@trYMinF),toint(res@trYMaxF),15)
     res@tmYLLabels      = (/"45S","30S","15S","0", "15N","30N","45N"/)
     res@tmYLMinorValues = ispan(toint(res@trYMinF),toint(res@trYMaxF),5) 

     res@cnLevelSelectionMode = "ExplicitLevels"

     res@gsnLeftStringOrthogonalPosF  = 0.01
     res@gsnLeftStringParallelPosF    = .005
     res@gsnRightStringOrthogonalPosF = 0.01
     res@gsnRightStringParallelPosF   = 0.96
     res@gsnRightString  = ""
     res@gsnLeftString   = ""
     res@gsnLeftStringFontHeightF   = 0.014 * 2.0
     res@gsnCenterStringFontHeightF = 0.018 * 2.0
     res@gsnRightStringFontHeightF  = 0.014 * 2.0    

     res@cnLevelSelectionMode = "ExplicitLevels"
     res@cnLevels              = ispan(-160,160,20)    

     res@gsnLeftString   = names(ee) 
     res@gsnRightString  = syear(ee)+"-"+eyear(ee) 
     res@gsnCenterString = "" 
     map_djf(ee) = gsn_csm_lat_time(wks_hovmoller_djf,zmsf_920_hovmoller_seas(0,:,:),res)
     map_mam(ee) = gsn_csm_lat_time(wks_hovmoller_mam,zmsf_920_hovmoller_seas(1,:,:),res)
     map_jja(ee) = gsn_csm_lat_time(wks_hovmoller_jja,zmsf_920_hovmoller_seas(2,:,:),res)
     map_son(ee) = gsn_csm_lat_time(wks_hovmoller_son,zmsf_920_hovmoller_seas(3,:,:),res)
     map_ann(ee) = gsn_csm_lat_time(wks_hovmoller_ann,zmsf_920_hovmoller_ann(:,:),res)

     res1                              = res
     res1@cnFillOn                     = False                ; color on
     res1@tiMainString                 = ""
     res1@gsnLeftString                = ""
     res1@gsnRightString               = ""
     res1@cnLineColor                  = "Red"
     res1@cnLineLabelsOn               = False
     res1@cnLevelSelectionMode         = "ExplicitLevels"       ; manual levels
     res1@cnLevels                    := (/0.0/)
     res1@cnInfoLabelOn                = False
     res1@gsnContourZeroLineThicknessF = 10
     if (wks_type.eq."png") then
       res1@cnLineThicknessF             = 8
     else
       res1@cnLineThicknessF             = 2
     end if

     if(.not.isvar("dum_djf")) then
       dum_djf = new(1000,graphic)
       dum_mam = new(1000,graphic)
       dum_jja = new(1000,graphic)
       dum_son = new(1000,graphic)
       dum_ann = new(1000,graphic)
     end if

     dum_djf(ee) = gsn_csm_lat_time(wks_hovmoller_djf,zmsf_740_hovmoller_seas(0,:,:),res1)
     dum_mam(ee) = gsn_csm_lat_time(wks_hovmoller_mam,zmsf_740_hovmoller_seas(1,:,:),res1)
     dum_jja(ee) = gsn_csm_lat_time(wks_hovmoller_jja,zmsf_740_hovmoller_seas(2,:,:),res1)
     dum_son(ee) = gsn_csm_lat_time(wks_hovmoller_son,zmsf_740_hovmoller_seas(3,:,:),res1)
     dum_ann(ee) = gsn_csm_lat_time(wks_hovmoller_ann,zmsf_740_hovmoller_ann(:,:),res1)

     overlay(map_djf(ee),dum_djf(ee))
     overlay(map_mam(ee),dum_mam(ee))
     overlay(map_jja(ee),dum_jja(ee))
     overlay(map_son(ee),dum_son(ee))
     overlay(map_ann(ee),dum_ann(ee))

     res2                             = True
     res2@gsnDraw                     = False
     res2@gsnFrame                    = False
     res2@tiMainString                = ""
     res2@gsnLeftString               = ""
     res2@gsnRightString              = ""
     res2@trXMinF                     = syear(ee)
     res2@trXMaxF                     = eyear(ee)
     res2@tmXBOn                      = False 
     res2@tmXTOn                      = False 
     res2@trYMinF                     = -45.0
     res2@trYMaxF                     =  45.0
     res2@tmYLOn                      = False
     res2@tmYROn                      = False
     res2@xyMonoDashPattern           = False
     res2@xyMarkLineMode              = "Lines"  
     res2@xyDashPatterns              = (/2, 2/)             ; Make curves all solid
     res2@xyLineColors                = (/"Black","Black"/) ; change line color
     if (wks_type.eq."png") then
       res2@xyLineThicknesses         = (/8.0, 8.0/)     ; make second line thicker
     else
       res2@xyLineThicknesses         = (/2.0, 2.0/)    ; make second line thicker
     end if
     dum_djf(ee+100) = gsn_csm_xy(wks_hovmoller_djf,ispan(syear(ee),eyear(ee),1),zmsf_920_hc_lat_seas(:,0,:),res2) ; create plot
     dum_mam(ee+100) = gsn_csm_xy(wks_hovmoller_mam,ispan(syear(ee),eyear(ee),1),zmsf_920_hc_lat_seas(:,1,:),res2) ; create plot
     dum_jja(ee+100) = gsn_csm_xy(wks_hovmoller_jja,ispan(syear(ee),eyear(ee),1),zmsf_920_hc_lat_seas(:,2,:),res2) ; create plot
     dum_son(ee+100) = gsn_csm_xy(wks_hovmoller_son,ispan(syear(ee),eyear(ee),1),zmsf_920_hc_lat_seas(:,3,:),res2) ; create plot
     dum_ann(ee+100) = gsn_csm_xy(wks_hovmoller_ann,ispan(syear(ee),eyear(ee),1),zmsf_920_hc_lat_ann(:,:),res2) ; create plot

     overlay(map_djf(ee),dum_djf(ee+100))
     overlay(map_mam(ee),dum_mam(ee+100))
     overlay(map_jja(ee),dum_jja(ee+100))
     overlay(map_son(ee),dum_son(ee+100))
     overlay(map_ann(ee),dum_ann(ee+100))

     delete([/res,res1,res2/])
     delete([/zmsf_920_hc_lat_seas,zmsf_920_hc_lat_ann/])
     delete([/zmsf_740_hovmoller_seas,zmsf_740_hovmoller_ann/])
     delete([/zmsf_920_hovmoller_seas,zmsf_920_hovmoller_ann/])
  end do     
     
  panres = True
  panres@gsnMaximize = True  
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelLabelBar = True
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@lbTitleOn = True
  panres@lbBoxLineColor = "gray70"
  if (nsim.le.4) then
     if (nsim.eq.1) then
        panres@txFontHeightF = 0.020
        panres@gsnPanelBottom = 0.50
        panres@lbLabelFontHeightF = 0.016
        panres@lbTitleFontHeightF = 0.016
     else
        panres@txFontHeightF = 0.0125
        panres@gsnPanelBottom = 0.50
        panres@lbLabelFontHeightF = 0.010
        panres@lbTitleFontHeightF = 0.010
     end if
  else
     panres@txFontHeightF      = 0.014
     panres@gsnPanelBottom     = 0.05
     panres@lbLabelFontHeightF = 0.010
     panres@lbTitleFontHeightF = 0.010
  end if
  panres@lbLabelStride = 1
  panres@pmLabelBarWidthF  = 0.60
  panres@pmLabelBarHeightF = 0.04
  panres@pmLabelBarOrthogonalPosF = -0.02
  panres@pmLabelBarParallelPosF = 0.02

  panres@lbTitleString = "Meridional Stream function (SF) ("+lbunit+") "

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
  
  panres@txString = "Hovmoller Diagram of Meridional Stream Function (DJF)"
  gsn_panel2(wks_hovmoller_djf,map_djf,(/nrow,ncol/),panres)
  delete(wks_hovmoller_djf)
  
  panres@txString = "Hovmoller Diagram of Meridional Stream Function (MAM)"
  gsn_panel2(wks_hovmoller_mam,map_mam,(/nrow,ncol/),panres)
  delete(wks_hovmoller_mam)
  
  panres@txString = "Hovmoller Diagram of Meridional Stream Function (JJA)"
  gsn_panel2(wks_hovmoller_jja,map_jja,(/nrow,ncol/),panres)
  delete(wks_hovmoller_jja)
  
  panres@txString = "Hovmoller Diagram of Meridional Stream Function (SON)"
  gsn_panel2(wks_hovmoller_son,map_son,(/nrow,ncol/),panres)
  delete(wks_hovmoller_son)
  
  panres@txString = "Hovmoller Diagram of Meridional Stream Function (Annual)"
  gsn_panel2(wks_hovmoller_ann,map_ann,(/nrow,ncol/),panres)
  delete(wks_hovmoller_ann)

  panres@txString = "Hovmoller Diagram of Meridional Stream Function (Monthly)"
  gsn_panel2(wks_hovmoller_mon,map_mon,(/nrow,ncol/),panres)
  delete(wks_hovmoller_mon)

  delete([/nrow,ncol,map_djf,map_mam,map_jja,map_son,map_ann,map_mon,panres/])
  print("Finished: zmsf.hovmoller.ncl")
end
