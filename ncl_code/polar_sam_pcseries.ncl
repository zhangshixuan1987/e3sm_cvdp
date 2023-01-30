; Calculates seasonal/annual SAM/PSA1/PSA2 indices, regression pcseries
;
; Variables used: psl
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: polar.sam_pcseries.ncl")
  CREATE_GRAPHICS  = getenv("CREATE_GRAPHICS")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")
  OUTDIR           = getenv("OUTDIR") 
  PNG_SCALE_SUMMARY = tofloat(getenv("PNG_SCALE_SUMMARY"))
  GENERATE_DATA     = False 

  pi=4.*atan(1.0)
  rad=(pi/180.)
 
  nsim = numAsciiRow("namelist_byvar/namelist_psl")

  na = asciiread("namelist_byvar/namelist_psl",(/nsim/),"string")
  names = new(nsim,"string")
  paths = new(nsim,"string")
  syear = new(nsim,"integer",-999)
  eyear = new(nsim,"integer",-999)
  names_EM = new(nsim,"string")
  EM_num = new(nsim,"integer",-999)
  delim = "|"

  do ee = 0,nsim-1
     names(ee) = str_strip(str_get_field(na(ee),1,delim))
     paths(ee) = str_strip(str_get_field(na(ee),2,delim))
     syear(ee) = stringtointeger(str_strip(str_get_field(na(ee),3,delim)))
     eyear(ee) = stringtointeger(str_strip(str_get_field(na(ee),4,delim)))
     temp      = str_split(str_strip(str_get_field(na(ee),5,delim)),"-")
     EM_num(ee)    = toint(temp(0))
     names_EM(ee)  = str_join(temp(1:),"-")
     delete(temp)
  end do
  modname = str_sub_str(names," ","_")
  bc = (/"/","'","(",")"/)
  do ff = 0,dimsizes(modname)-1
     do ee = 0,dimsizes(bc)-1
        modname(ff) = str_sub_str(modname(ff),bc(ee),"_")
     end do
  end do
  nyr = eyear-syear+1
  nyr_max = max(nyr)

  variname = (/"sam_timeseries_djf","sam_timeseries_jfm","sam_timeseries_mam",\
               "sam_timeseries_jja","sam_timeseries_jas","sam_timeseries_son",\
               "sam_timeseries_ndjfma","sam_timeseries_mjjaso","sam_timeseries_ann"/)
  variname_title = variname
  variname_title_seas = variname
  do gg = 0,dimsizes(variname)-1
     txttt = str_split(variname(gg),"_")
     variname_title(gg) = changeCaseChar(txttt(0))+" Pattern"
     variname_title_seas(gg) = changeCaseChar(txttt(2))
  end do

  mmename     = (/"ERA5", "CMIP6-COUP",  "E3SMv2-COUP",  "E3SMv2-AMIP"/)
  titname     = (/"ERA5", "CMIP6 (MME)", "E3SM (Couple)","E3SMv2 (AMIP)"/)
  nmme        = dimsizes(mmename)

  figstr      = (/ "(e)", "(f)",   "(g)",  "(h)"/)
  figstr      = figstr + " "+titname
  figstr(0)   = figstr(0)+ " (Obs.)"
 
  minlat = -90.0
  maxlat = -20.0
  minlon = 0.0
  maxlon = 360.0

  if (GENERATE_DATA) then

    nsim = numAsciiRow("namelist_byvar/namelist_psl")
    na = asciiread("namelist_byvar/namelist_psl",(/nsim/),"string")
    names = new(nsim,"string")
    paths = new(nsim,"string")
    syear = new(nsim,"integer",-999)
    eyear = new(nsim,"integer",-999)
    names_EM = new(nsim,"string")
    EM_num = new(nsim,"integer",-999)
    delim = "|"

    do gg = 0,nsim-1
       names(gg) = str_strip(str_get_field(na(gg),1,delim))
       paths(gg) = str_strip(str_get_field(na(gg),2,delim))
       syear(gg) = stringtointeger(str_strip(str_get_field(na(gg),3,delim)))
       eyear(gg) = stringtointeger(str_strip(str_get_field(na(gg),4,delim)))
       temp      = str_split(str_strip(str_get_field(na(gg),5,delim)),"-")
       EM_num(gg)    = toint(temp(0))
       names_EM(gg)  = str_join(temp(1:),"-")
       delete(temp)
    end do
    modname = str_sub_str(names," ","_")

    bc = (/"/","'","(",")"/)
    do ff = 0,dimsizes(modname)-1
       do gg = 0,dimsizes(bc)-1
          modname(ff) = str_sub_str(modname(ff),bc(gg),"_")
       end do
    end do
    nyr = eyear-syear+1
    nyr_max = max(nyr)

    do dd = 0,dimsizes(variname)-1

      ;;;read and process observations;;;
      subStrs  := str_get_field(modname,1,"-")
      cntr_ens := ind(subStrs.eq.mmename(0))
      nenso     = dimsizes(cntr_ens)
      do ee = 0,nenso-1
         modname_mod  = modname(cntr_ens(ee))
         syear_mod    = syear(cntr_ens(ee))
         eyear_mod    = eyear(cntr_ens(ee))
         names_mod    = names(cntr_ens(ee))
         names_EM_mod = names_EM(cntr_ens(ee))
         fnt  = getenv("OUTDIR")+modname_mod+".cvdp_data.sam_psa."+syear_mod+"-"+eyear_mod+".nc"
         fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
         arr  = read_cvdp_le_data(fnt,fnt2,variname(dd))
         if (ee.eq.0) then
           arr_obs       = new((/nenso,dimsizes(arr&TIME)/),typeof(arr))
           arr_obs!0     = "ensmem"
           arr_obs!1     = "time"
           arr_obs&time  = arr&TIME 
           arr_obs@nens  = 0
           arr_obs@pcvar = new(nenso,float)
         end if
         arr_obs(ee,:)     = (/ arr /)
         arr_obs@nens      = arr_obs@nens+1
      end do

      obs_EM = dim_avg_n_Wrap(arr_obs,0)
      obs_EM@long_name = variname_title(dd)
      obs_EM@units     = "1"
      obs_sd = dim_stddev_n_Wrap(arr_obs,0)
      obs_sd@long_name = variname_title(dd)
      obs_sd@units     = "1"

      fout = getenv("OUTDIR")+"Model_vs_obs_MME.cvdp_data.sampcs.mean_bias.nc"
      if (isfilepresent2(fout)) then
         z = addfile(fout,"w")
      else
         z = addfile(fout,"c")
      end if
      z->$(/mmename(0)+"_"+variname(dd)+"_em"/)$  = set_varAtts(obs_EM,obs_EM@long_name+" Ensemble Mean","","")
      z->$(/mmename(0)+"_"+variname(dd)+"_sd"/)$  = set_varAtts(obs_sd,obs_sd@long_name+" Ensemble Mean","","")

      do ff = 1,nmme-1

        subStrs  := str_get_field(modname,1,"_")
        cntr_ens := ind(subStrs.eq.mmename(ff))
        nensm     = dimsizes(cntr_ens)
        ncens = 0
        do hh = 0,nensm-1
           modname_mod = modname(cntr_ens(hh))
           syear_mod = syear(cntr_ens(hh))
           eyear_mod = eyear(cntr_ens(hh))
           names_mod = names(cntr_ens(hh))
           names_EM_mod = names_EM(cntr_ens(hh))
           fnt  = getenv("OUTDIR")+modname_mod+".cvdp_data.psl.mean_stddev."+syear_mod+"-"+eyear_mod+".nc"
           fnt2  = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
           arr   = read_cvdp_le_data(fnt,fnt2,variname(dd))

           if (.not.all(ismissing(arr))) then
             if (ncens.eq.0) then
               arr_mod      = new((/nensm,dimsizes(arr&TIME)/),typeof(arr))
               arr_mod!0    = "ensmem"
               arr_mod!1    = "time"
               arr_mod&time = arr&TIME 
               arr_mod@nens = 0
             end if
             arr_mod(ncens,:)   = (/arr/)
             arr_mod@nens = arr_mod@nens+1
             ncens = ncens + 1
           end if
        end do

        mod_EM = dim_avg_n_Wrap(arr_mod,0)
        mod_EM@long_name = variname_title(dd)
        mod_EM@units     = "hPa"
        mod_sd = dim_stddev_n_Wrap(arr_mod,0)
        mod_sd@long_name = variname_title(dd)
        mod_sd@units     = "hPa"

        ;;generate the probility entry
        z->$(/mmename(ff)+"_"+variname(dd)+"_em"/)$  = set_varAtts(mod_EM,mod_EM@long_name+" Ensemble Mean","","")
        z->$(/mmename(ff)+"_"+variname(dd)+"_sd"/)$  = set_varAtts(mod_sd,mod_sd@long_name+" Ensemble Mean","","")
        delete([/arr_mod,mod_EM,arr/])
      end do
 
      delete([/obs_EM,arr_obs/])

    end do

  end if

  if (CREATE_GRAPHICS.eq."False") then
     print("Finished: polar.sam_pcseries.ncl")
     exit
  end if 

;========================================================================
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if

;---Timeseries plotting section--------------------------------------------------------------------------------------------
  res = True    ; individual obs/model line plot resource list
  res@gsnDraw = False
  res@gsnFrame = False
  res@gsnYRefLine = 0.0
  res@gsnYRefLineColor = "gray42"

  if (wks_type.eq."png") then
     res@xyLineThicknessF = 4.
  else
     res@xyLineThicknessF = 2.
  end if
  res@xyLineColor = "royalblue"
  res@tiYAxisString = ""
  res@tmXBLabelFontHeightF = 0.015
  res@tmYLLabelFontHeightF = 0.015
  res@vpHeightF = 0.25
  res@vpWidthF = 0.7

  if(wks_type.eq."png") then
   lthick = 8.0
  else
   lthick = 1.0
  end if

  res@tmBorderThicknessF    = lthick
  res@tmXBMajorThicknessF   = lthick
  res@tmXBMinorThicknessF   = lthick
  res@tmYLMajorThicknessF   = lthick
  res@tmYLMinorThicknessF   = lthick
  res@tmYRMajorThicknessF   = lthick
  res@tmYRMinorThicknessF   = lthick

  FontHeightF = 0.018
  res@tiMainFontThicknessF       = 3.0
  res@tiMainFontHeightF          = FontHeightF*1.2
  res@tmYLLabelFontHeightF       = FontHeightF
  res@tmXBLabelFontHeightF       = FontHeightF
  res@tiXAxisFontHeightF         = FontHeightF
  res@tiYAxisFontHeightF         = FontHeightF

  res@gsnLeftStringFontHeightF     = FontHeightF 
  res@gsnCenterStringFontHeightF   = FontHeightF 
  res@gsnRightStringFontHeightF    = FontHeightF 
  res@gsnLeftString = ""
  res@gsnCenterString = ""
  res@gsnRightString = ""

  res2 = res     ; for observational line overlays in individual panels
  res2@xyLineColor = "gray60"
  res2@xyCurveDrawOrder = "PreDraw"

  res_sum = res
  res_sum@xyLineColor        = "dodgerblue2"
  res_sum@gsnCenterStringFontColor = "black"
  
  if (wks_type.eq."png") then
     res_sum@xyLineThicknessF = 16.
  else
     res_sum@xyLineThicknessF = 3.
  end if

  res2A = res2   ; for observational line overlays in ensemble mean summary
  res2A@xyLineThicknessF = res_sum@xyLineThicknessF

  res_sumA = res   ; for summary ensemble mean line plot
  res_sumA@xyLineThicknessF = res_sum@xyLineThicknessF

  res3_sum = res_sum   ; resource list for shaded 2 std dev range
  res3_sum@gsnXYFillColors      = (/30/356.,144/256.,1.,0.25/)  ;"dodgerblue"
  res3_sum@xyLineColors        := (/"transparent","transparent"/)
  res3_sum@xyDashPattern        = 0
  res3_sum@xyLineColor = "transparent"
  res3_sum@gsnRightStringFontColor = "black"

  res3b_sum = res3_sum   ; resource list for shaded 1 std dev range
  res3b_sum@gsnXYFillColors = (/30/356.,144/256.,1.,0.5/)  ;"dodgerblue"

  panres = True  ; panel resource list for individual member plots
  panres@gsnMaximize = True
  panres@gsnPaperOrientation = "portrait"
  panres@gsnMainPanelFontHeightF = 0.016
  panres@gsnPanelBottom = 0.05
  panres@gsnPanelYWhiteSpacePercent = 2.5

  panres2 = panres  ; panel resource list for ensemble plots
  panres2@gsnMainPanelFontHeightF = 0.014
  panres2@gsnMaximize = False
  panres2@gsnFrame = False
  panres2@gsnPanelTop = 0.94
  panres2@gsnPanelXWhiteSpacePercent = 3.0
  panres2@gsnPanelYWhiteSpacePercent = 3.0

  txres = True
  txres@txFontHeightF = 0.010
  txres@txFontColor = res2@xyLineColor

  csubtitle_color = set_subtitle_colors(max(EM_num))
  nEM = max(EM_num)
  do dd = 0,dimsizes(variname)-1
     wks = gsn_open_wks(wks_type,getenv("OUTDIR")+"sam_pcs")
     plot_summary     := new(nmme,"graphic")    ; for ensemble plots  to show the 2 std dev range
     plot_summary1    := new(nmme,"graphic")    ; for ensemble plots to show the 1 std dev range
     plot_summary2    := new(nmme,"graphic")    ; for ensemble plots to show the ensemble mean

     XMinF := new(1,double)    ; used for summary timeseries plot showing all ensemble means
     XMaxF := new(1,double)
     YMinF := new(1,double)
     YMaxF := new(1,double)

     fout = getenv("OUTDIR")+"Model_vs_obs_MME.cvdp_data.sampcs.mean_bias.nc"
     z    = addfile(fout,"r")

     res@gsnLeftStringFontColor = "black"
     res2@gsnLeftStringFontColor = "black"
     if (isatt(res,"trYMinF")) then
        delete([/res@trYMinF,res@trYMaxF/])
     end if
     res@trXMinF = syear(0)-.5
     res@trXMaxF = eyear(0)+0.5
     res@gsnLeftString = names(0)

     res@gsnCenterStringFontColor = "black"
     res@lbLabelBarOn = False

     do gg = 0,nmme-1   ; operate on each ensemble mean

        obs0  = z->$(/mmename(gg)+"_"+variname(dd)+"_em"/)$
        std0  = z->$(/mmename(gg)+"_"+variname(dd)+"_sd"/)$

        ztxt  = "Trend = "
        tttt := dtrend_msg(ispan(0,dimsizes(obs0&time)-1,1),obs0,False,True)
        obs_val := decimalPlaces(tttt@slope*dimsizes(obs0&time),2,True) +" "+nyr(0)+"yr~S~-1~N~" ;+obs0@units+" "+nyr(0)+"yr~S~-1~N~"

        res3_sum@trXMinF   := min(obs0&time)-.5
        res3_sum@trXMaxF   := max(obs0&time)+0.5
        res3_sum@trYMinF    = -3.0
        res3_sum@trYMaxF    =  3.0
        res3_sum@gsnLeftString   = figstr(gg)
        res3_sum@gsnRightString  = variname_title_seas(dd)
        res3_sum@gsnCenterString = ztxt+obs_val 

        arr_EM     = obs0
        arr_range  = new((/2,dimsizes(obs0)/),typeof(obs0))
        arr_range(0,:) = obs0 - std0 
        arr_range(1,:) = obs0 + std0 
                 
        plot_summary(gg)  = gsn_csm_xy(wks,ispan(min(arr_EM&time),max(arr_EM&time),1),arr_range,res3_sum)
        plot_summary1(gg) = gsn_csm_xy(wks,ispan(min(arr_EM&time),max(arr_EM&time),1),arr_EM,res_sum)
        overlay(plot_summary(gg),plot_summary1(gg))
        delete([/arr_EM,arr_range/])
     end do

     panres2@txString = "" 
     gsn_panel2(wks,plot_summary,(/4,1/),panres2)
     frame(wks)
     delete(wks)

     system("mv "+OUTDIR+"sam_pcs.png "+OUTDIR+variname(dd)+".ensm.clim.png")
     if (PNG_SCALE_SUMMARY.ne.100) then
        system("convert -resize "+PNG_SCALE_SUMMARY+"% "+OUTDIR+variname(dd)+".ensm.clim.png "+OUTDIR+variname(dd)+".ensm.clim.png")
     end if

  end do
  delete([/panres,panres2/])
  print("Finished: polar.sam_pcseries.ncl")
end



