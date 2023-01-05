; Calculates seasonal/annual SAM/PSA1/PSA2 indices, regression pattern
;
; Variables used: psl
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: polar.sameof_pattern.ncl")
  CREATE_GRAPHICS  = getenv("CREATE_GRAPHICS")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")
  OUTDIR           = getenv("OUTDIR") 
  PNG_SCALE_SUMMARY = tofloat(getenv("PNG_SCALE_SUMMARY"))
  GENERATE_DATA     = True  

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

  variname = (/"sameof_pattern_djf","sameof_pattern_jfm","sameof_pattern_mam",\
               "sameof_pattern_jja","sameof_pattern_jas","sameof_pattern_son",\
               "sameof_pattern_ndjfma","sameof_pattern_mjjaso","sameof_pattern_ann"/)
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

  figstr      = (/ "(a)", "(b)",   "(c)",  "(d)"/)
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

    do dd = 3,dimsizes(variname)-1

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
         arr0 = read_cvdp_le_data(fnt,fnt2,variname(dd))
         arr  = arr0({minlat:maxlat},{minlon:maxlon}) 
         delete(arr0)

         if (ee.eq.0) then
           arr_obs       = new((/nenso,dimsizes(arr&lat),dimsizes(arr&lon)/),typeof(arr))
           arr_obs!0     = "ensmem"
           arr_obs!1     = "lat"
           arr_obs&lat   = arr&lat
           arr_obs!2     = "lon"
           arr_obs&lon   = arr&lon
           arr_obs@nens  = 0
           arr_obs@pcvar = new(nenso,float)
         end if
         arr_obs(ee,:,:) = (/ arr /)
         arr_obs@nens = arr_obs@nens+1
         arr_obs@pcvar(ee) = tofloat(arr@pcvar) 
      end do

      obs_EM = dim_avg_n_Wrap(arr_obs,0)
      obs_EM@long_name = variname_title(dd)
      obs_EM@units     = "hPa"
      obs_EM@pcvar_em  = avg(arr_obs@pcvar)
      obs_EM@pcvar_sd  = stddev(arr_obs@pcvar)

      print(obs_EM@pcvar_em + "+/-" + obs_EM@pcvar_sd )

      fout = getenv("OUTDIR")+"Model_vs_obs_MME.cvdp_data.sampat.mean_bias.nc"
      if (isfilepresent2(fout)) then
         z = addfile(fout,"w")
      else
         z = addfile(fout,"c")
      end if
      z->$(/mmename(0)+"_"+variname(dd)+"_em"/)$  = set_varAtts(obs_EM,obs_EM@long_name+" Ensemble Mean","","")

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
           arr0 := read_cvdp_le_data(fnt,fnt2,variname(dd))
           arr   = arr0({minlat:maxlat},{minlon:maxlon})
           delete(arr0)

           if (.not.all(ismissing(arr))) then
             if (ncens.eq.0) then
               arr_mod      = new((/nensm,dimsizes(arr&lat),dimsizes(arr&lon)/),typeof(arr))
               arr_mod!0    = "ensmem"
               arr_mod!1    = "lat"
               arr_mod&lat  = arr&lat
               arr_mod!2    = "lon"
               arr_mod&lon  = arr&lon
               arr_mod@nens = 0
               arr_mod@pcvar= new(nensm,float)
               arr_mod@pcor = new(nensm*nenso,double)
               arr_mod@rmse = new(nensm*nenso,double)
             end if
             arr_mod(ncens,:,:)   = (/arr/)
             arr_mod@pcvar(ncens) = tofloat(arr@pcvar)
             hh1  = ncens*nenso
             hh2  = (ncens+1)*nenso-1
             tmp1 = conform(arr_obs,arr,(/1,2/))
             wgt := tofloat(cos(rad*arr&lat))
             arr_mod@pcor(hh1:hh2) = pattern_cor(tmp1,arr_obs,wgt,0)
             arr_mod@rmse(hh1:hh2) = wgt_arearmse(tmp1,arr_obs,wgt,1,0)
             delete([/tmp1,hh1,hh2,wgt/])     
             arr_mod@nens = arr_mod@nens+1
             ncens = ncens + 1
           end if
        end do

        mod_EM = dim_avg_n_Wrap(arr_mod,0)
        mod_EM@long_name = variname_title(dd)
        mod_EM@units     = "hPa"
        mod_EM@pcvar_em  = avg(arr_mod@pcvar)
        mod_EM@pcvar_sd  = stddev(arr_mod@pcvar)
        mod_EM@pcor_em   = avg(arr_mod@pcor)
        mod_EM@pcor_sd   = stddev(arr_mod@pcor)
        mod_EM@rmse_em   = avg(arr_mod@rmse)
        mod_EM@rmse_sd   = stddev(arr_mod@rmse)
        print(mod_EM@pcvar_em + "+/-" +mod_EM@pcvar_sd )
        print(mod_EM@pcor_em + "+/-" +mod_EM@pcor_sd )
        print(mod_EM@rmse_em + "+/-" +mod_EM@rmse_sd )

        ;;generate the probility entry
        z->$(/mmename(ff)+"_"+variname(dd)+"_em"/)$  = set_varAtts(mod_EM,mod_EM@long_name+" Ensemble Mean","hPa","")
        delete([/arr_mod,mod_EM,arr/])
      end do
 
      delete([/obs_EM,arr_obs/])

    end do

  end if

  if (CREATE_GRAPHICS.eq."False") then
     print("Finished: polar.sameof_pattern.ncl")
     exit
  end if 

;========================================================================
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if

  res = True      ; spatial plot resource list
  res@mpGeophysicalLineColor = "black" ;gray42"
  res@mpPerimOn    = True
  res@mpFillOn     = False
  res@gsnPolar     = "SH"
  res@mpMaxLatF    = -20.
  res@mpOutlineOn  = True 
  res@mpCenterLonF = 0. 
  res@mpGridAndLimbOn = False
  if (wks_type.eq."png") then
     res@mpGeophysicalLineThicknessF = 4.  
  else
     res@mpGeophysicalLineThicknessF = 1.  
  end if
  res@gsnDraw   = False
  res@gsnFrame  = False
  
  res@cnLineLabelsOn = False
  res@cnFillOn     = True
  res@cnLinesOn    = False

  res@lbLabelBarOn    = False
  res@pmLabelBarWidthF = 0.55
  res@pmLabelBarHeightF = 0.075
  res@lbBoxLineColor = "gray70"
  res@lbLabelFontHeightF = 0.02
  res@lbLabelStride = 1
  res@lbTitleOn = True
  res@lbTitleFontHeightF = res@lbLabelFontHeightF
  res@lbTitlePosition = "Bottom"
  res@cnNoDataLabelOn = False

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@gsnLeftStringOrthogonalPosF  = -0.03
  res@gsnLeftStringParallelPosF    = .005
  res@gsnRightStringOrthogonalPosF = -0.06
  res@gsnRightStringParallelPosF   = 0.96
  res@gsnLeftStringFontHeightF     = 0.014 * 1.5
  res@gsnCenterStringFontHeightF   = 0.018 * 1.5
  res@gsnRightStringFontHeightF    = 0.014 * 1.5
  res@gsnLeftString = ""
  res@gsnCenterString = ""
  res@gsnRightString = ""

  FontHeightF = 0.035
  res@tiMainFontThicknessF       = 3.0
  res@tiMainFontHeightF          = FontHeightF*1.2
  res@tmYLLabelFontHeightF       = FontHeightF
  res@tmXBLabelFontHeightF       = FontHeightF
  res@tiXAxisFontHeightF         = FontHeightF
  res@tiYAxisFontHeightF         = FontHeightF

  res2 = res    ; spatial differences resource list

  tres = res    ; p-value plot resource list
  copy_VarAtts(retrieve_summary_res(),tres)

 ;res@cnLevels = fspan(-5,5,11)
 ;res2@cnLevels = fspan(-5,5,11)
;  if (COLORMAP.eq.0) then
;     res@cnFillPalette = "ncl_default"
;     res2@cnFillPalette = "ncl_default"
;  end if
;  if (COLORMAP.eq.1) then
     res@cnFillPalette = "BlueDarkRed18"
     res2@cnFillPalette = "BlueDarkRed18"
;  end if 

  amres                  = True
  amres@amParallelPosF   = 0.465    ; -0.5 is the left edge of the plot.
  amres@amOrthogonalPosF = -0.505   ; -0.5 is the top edge of the plot.
  amres@amJust           = "BottomRight"

  ares = True   ; % variance explained xy plot for summary plots

  panres = True   ; panel resource list for individual simulations
  panres@gsnMaximize = True  
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelLabelBar = True
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@pmLabelBarHeightF = 0.05
  panres@pmLabelBarWidthF = 0.65
  panres@pmLabelBarOrthogonalPosF = -0.02
  panres@lbTitleOn = False
  panres@lbBoxLineColor = "gray70"
  panres@txFontHeightF = 0.016
  panres@gsnPanelBottom = 0.05
  panres@lbLabelFontHeightF = 0.013
  panres@lbLabelStride = 1
  panres@lbTitleOn = True
  panres@lbTitleFontHeightF = panres@lbLabelFontHeightF
  panres@lbTitlePosition = "Bottom"
  ncol = floattointeger(sqrt(nsim))
  nrow = (nsim/ncol)+mod(nsim,ncol)

  panres2 = panres     ; summary panel resource list
  panres2@gsnMaximize = False
  panres2@gsnPanelLabelBar  = True 
  panres2@pmLabelBarHeightF = 0.05
  panres2@pmLabelBarWidthF  = 0.65

  csubtitle_color = set_subtitle_colors(max(EM_num))
  nEM = max(EM_num)
  do dd = 0,dimsizes(variname)-1
     wks = gsn_open_wks(wks_type,getenv("OUTDIR")+"sam")
     plot_summary = new((nmme),"graphic")

     if(isStrSubset(variname(dd),"sam")) then 
       res@cnLevels = (/-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4/)      ;fspan(-4,4,11)
       res2@cnLevels = (/-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4/) 
     else
       res@cnLevels = (/-3,-2,-1,-0.5,-0.1,0,0.1,0.5,1,2,3/) 
       res2@cnLevels = (/-3,-2,-1,-0.5,-0.1,0,0.1,0.5,1,2,3/) ;fspan(-2,2,11)
     end if 

     fout = getenv("OUTDIR")+"Model_vs_obs_MME.cvdp_data.sampat.mean_bias.nc"
     z    = addfile(fout,"r")

     obs0 = z->$(/mmename(0)+"_"+variname(dd)+"_em"/)$  

     res@gsnCenterStringFontColor = "black"
     res2@gsnCenterStringFontColor = "black"
     res@lbLabelBarOn = False
     res2@lbLabelBarOn = False
     tres@lbLabelBarOn = False

     do gg = 0,nmme-1   ; operate on each ensemble mean
        obs0 = z->$(/mmename(gg)+"_"+variname(dd)+"_em"/)$
        res@gsnLeftString   = "" ;
        res@gsnRightString  = variname_title_seas(dd) 
        res@gsnCenterString = figstr(gg)
        plot_summary(gg) = gsn_csm_contour_map(wks,obs0,res)
     end do

     panres2@lbTitleString = "PSL anomaly (hPa)"
     panres2@txString = "" ;"Ensemble Summary: "+variname_title(dd)+" ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_summary,(/2,2/),panres2)
     delete(wks)

     system("mv "+OUTDIR+"sam.png "+OUTDIR+variname(dd)+".ensm.clim.png")
     if (PNG_SCALE_SUMMARY.ne.100) then
        system("convert -resize "+PNG_SCALE_SUMMARY+"% "+OUTDIR+variname(dd)+".ensm.clim.png "+OUTDIR+variname(dd)+".ensm.clim.png")
     end if

  end do
  delete([/panres,panres2/])
  print("Finished: polar.sameof_pattern.ncl")
end



