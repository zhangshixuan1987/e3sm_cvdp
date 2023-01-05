; Calculates seasonal/annual SAM/PSA1/PSA2 indices, regression pattern
;
; Variables used: psl
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: polar.ninoreg_pattern.ncl")
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

  variable  = (/"psl","sst","trefht","prect","u10","v10","taux","tauy","eth","hflx", \
                "swcre","fldsc","u850","v850","z500","u200","v200"/)
  varunits  = (/"hPa","~S~o~N~C","~S~o~N~C","mm day~S~-1~N~", "m s~S~-1~N~","m s~S~-1~N~", \
                "N m s~S~-2~N~", "N m s~S~-2~N~", "W m~S~-2~N~", "W m~S~-2~N~", "W m~S~-2~N~", \
                "W m~S~-2~N~", "m s~S~-1~N~","m s~S~-1~N~", "m","m s~S~-1~N~","m s~S~-1~N~", ""/)
  variname   = variable + "nino34_pattern_jja"
  variname_title = variname
  variname_title_seas = variname
  do gg = 0,dimsizes(variname)-1
     txttt = str_split(variname(gg),"_")
     variname_title(gg) = changeCaseChar(txttt(0))+" Pattern"
     variname_title_seas(gg) = changeCaseChar(txttt(2))
  end do

  varlist_fn  = (/"nino34_regr"/)

  mmename     = (/"ERA5", "CMIP6-COUP",  "E3SMv2-COUP",  "E3SMv2-AMIP"/)
  titname     = (/"ERA5", "CMIP6 (MME)", "E3SM (Couple)","E3SMv2 (AMIP)"/)
  nmme        = dimsizes(mmename)

  figstr      = (/ "(a)", "(b)",   "(c)",  "(d)"/)
  figstr      = titname ; figstr + " "+titname
  figstr(0)   = figstr(0)+ " (Obs.)"
 
  minlat = -90.0
  maxlat = -20.0
  minlon = 0.0
  maxlon = 360.0

  if (GENERATE_DATA) then

    do dd = 0,dimsizes(variname)-1

      if(variable(dd).eq."sst") then
        finarr   = diagnostic_read_in("ts")
      else if(variable(dd).eq."qnet") then
        finarr   = diagnostic_read_in("qn")
      else
        finarr   = diagnostic_read_in(variable(dd))
      end if
      end if

      modname  = str_squeeze(finarr(0,:))
      syear    = toint(finarr(1,:))
      eyear    = toint(finarr(2,:))
      EM_num   = toint(finarr(3,:))
      names    = str_squeeze(finarr(4,:))
      names_EM = str_squeeze(finarr(5,:))
      paths    = str_squeeze(finarr(6,:)) 
      delete(finarr)

      nyr = eyear-syear+1
      nyr_max = max(nyr)
 
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
         fnt = getenv("OUTDIR")+modname_mod+".cvdp_data."+varlist_fn+"."+syear_mod+"-"+eyear_mod+".nc"
         fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
         arr  = read_cvdp_le_data(fnt,fnt2,variname(dd))

         if (ee.eq.0) then
           arr_obs       = new((/nenso,dimsizes(arr&lat0),dimsizes(arr&lon0)/),typeof(arr))
           arr_obs!0     = "ensmem"
           arr_obs!1     = "lat"
           arr_obs&lat   = arr&lat0
           arr_obs!2     = "lon"
           arr_obs&lon   = arr&lon0
           arr_obs@nens  = 0
         end if
         arr_obs(ee,:,:) = (/ arr /)
         arr_obs@nens = arr_obs@nens+1
      end do

      obs_EM = dim_avg_n_Wrap(arr_obs,0)
      obs_EM@long_name = variname_title(dd)
      obs_EM@units     = "hPa"

      fout = getenv("OUTDIR")+"Model_vs_obs_MME.cvdp_data.ninoreg.mean_bias.nc"
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
        ncens     = 0
        do hh = 0,nensm-1
           modname_mod = modname(cntr_ens(hh))
           syear_mod = syear(cntr_ens(hh))
           eyear_mod = eyear(cntr_ens(hh))
           names_mod = names(cntr_ens(hh))
           names_EM_mod = names_EM(cntr_ens(hh))
           fnt  = getenv("OUTDIR")+modname_mod+".cvdp_data."+varlist_fn+"."+syear_mod+"-"+eyear_mod+".nc"
           fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,variname(dd))

           if (.not.all(ismissing(arr))) then
             if (ncens.eq.0) then
               arr_mod      = new((/nensm,dimsizes(arr&lat0),dimsizes(arr&lon0)/),typeof(arr))
               arr_mod!0    = "ensmem"
               arr_mod!1    = "lat"
               arr_mod&lat  = arr&lat0
               arr_mod!2    = "lon"
               arr_mod&lon  = arr&lon0
               arr_mod@nens = 0
             end if
             arr_mod(ncens,:,:)   = (/arr/)
             arr_mod@nens = arr_mod@nens+1
             ncens = ncens + 1
           end if
        end do

        mod_EM = dim_avg_n_Wrap(arr_mod,0)
        mod_EM@long_name = variname_title(dd)
        mod_EM@units     = "hPa"

        ;;generate the probility entry
        p_val   = mod_EM
        nsign   = mod_EM
        nsign   = 1.0
        arr_tmp1 = conform_dims((/nenso,nensm,dimsizes(arr_mod&lat),dimsizes(arr_mod&lon)/),arr_obs,(/0,2,3/))
        arr_tmp2 = conform_dims((/nenso,nensm,dimsizes(arr_mod&lat),dimsizes(arr_mod&lon)/),arr_mod,(/1,2,3/))
        arr_tmp3 = reshape(arr_tmp1,(/nensm*nenso,dimsizes(arr_mod&lat),dimsizes(arr_mod&lon)/))
        arr_tmp4 = reshape(arr_tmp2,(/nensm*nenso,dimsizes(arr_mod&lat),dimsizes(arr_mod&lon)/))
        nsign    = dim_num_n((arr_tmp3.gt.0.and.arr_tmp4.gt.0).or.(arr_tmp3.lt.0.and.arr_tmp4.lt.0),0)
        p_val    = 100.0 - nsign*100.0 / (nensm*nenso)
        delete([/arr_tmp1,arr_tmp2,arr_tmp3,arr_tmp4/])

        ;;generate the probility entry
        z->$(/mmename(ff)+"_"+variname(dd)+"_em"/)$   = set_varAtts(mod_EM,mod_EM@long_name+" Ensemble Mean","hPa","")
        z->$(/mmename(ff)+"_"+variname(dd)+"_pval"/)$ = set_varAtts(p_val,"p-val statistics of model agreement on the sign with obs","%","")
        delete([/arr_mod,mod_EM,arr,p_val/])
      end do
 
      delete([/obs_EM,arr_obs/])

    end do

  end if

  if (CREATE_GRAPHICS.eq."False") then
     print("Finished: polar.ninoreg_pattern.ncl")
     exit
  end if 

;========================================================================
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if

  res = True      ; spatial plot resource list
  res@gsnDraw   = False
  res@gsnFrame  = False
 
  res@cnLineLabelsOn = False
  res@cnFillOn       = False
  res@cnLinesOn      = True
  res@gsnContourZeroLineThicknessF = 0      ; eliminates zero contour
  res@gsnContourNegLineDashPattern = 1       ; sets negative contours to dash pattern 1
  if (wks_type.eq."png") then
     res@cnLineThicknessF             = 4
  else
     res@cnLineThicknessF             = 1
  end if

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
  res@gsnCenterStringOrthogonalPosF = 0.10
  res@gsnRightStringParallelPosF   = 0.96
  res@gsnLeftStringFontHeightF     = 0.014 * 1.5
  res@gsnCenterStringFontHeightF   = 0.018 * 1.5
  res@gsnRightStringFontHeightF    = 0.014 * 1.5
  res@gsnLeftString = ""
  res@gsnCenterString = ""
  res@gsnRightString = ""

  FontHeightF = 0.020
  res@tiMainFontThicknessF       = 3.0
  res@tiMainFontHeightF          = FontHeightF*1.2
  res@tmYLLabelFontHeightF       = FontHeightF
  res@tmXBLabelFontHeightF       = FontHeightF
  res@tiXAxisFontHeightF         = FontHeightF
  res@tiYAxisFontHeightF         = FontHeightF

  res@tmXTOn                        = False
  res@tmBorderThicknessF            = res@cnLineThicknessF
  res@tmXBMajorThicknessF           = res@cnLineThicknessF
  res@tmXBMinorThicknessF           = res@cnLineThicknessF
  res@tmYLMajorThicknessF           = res@cnLineThicknessF
  res@tmYLMinorThicknessF           = res@cnLineThicknessF
  res@tmYRMajorThicknessF           = res@cnLineThicknessF
  res@tmYRMinorThicknessF           = res@cnLineThicknessF

  res2 = res    ; spatial differences resource list
  res2@cnLineLabelsOn = False
  res2@cnFillOn     = True
  res2@cnLinesOn    = False

  res2@mpGeophysicalLineColor = "black" ;gray42"
  res2@mpPerimOn    = True
  res2@mpFillOn     = False
  res2@gsnPolar     = "SH"
  res2@gsnPolarLabelFontHeightF = FontHeightF
  res2@mpMaxLatF    = -20.
  res2@mpOutlineOn  = True
  res2@mpOutlineDrawOrder          = "PostDraw"
  res2@mpCenterLonF = 0.
  res2@mpGridAndLimbOn = True
  res2@mpGridLineThicknessF   = 3.0
  res2@mpGridLineColor        = "black"
  if (wks_type.eq."png") then
     res2@mpGeophysicalLineThicknessF = 4.
  else
     res2@mpGeophysicalLineThicknessF = 1.
  end if


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
     wks = gsn_open_wks(wks_type,getenv("OUTDIR")+"nino")
     plot_summary = new((nmme),"graphic")
     plot_summary1 = new((nmme),"graphic")

     res@cnLevels  = fspan(-5,5,21)
     res2@cnLevels = (/-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4/)      ;fspan(-4,4,11)

     if(isStrSubset(variname(dd),"psl")) then
       res2@cnLevels  = (/-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4/)      ;fspan(-4,4,11)
     end if

     if(isStrSubset(variname(dd),"sst").or.isStrSubset(variname(dd),"trefht").or.isStrSubset(variname(dd),"th850")) then
       res2@cnLevels  = (/-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5/)      ;fspan(-4,4,11)
     end if

     if(isStrSubset(variname(dd),"eth").or.isStrSubset(variname(dd),"hflx")) then
       res2@cnLevels = (/-12,-8,-4,-2,-1,0,1,2,4,8,12/)      ;fspan(-4,4,11)
     end if

     if(isStrSubset(variname(dd),"u10").or.isStrSubset(variname(dd),"v10")) then
       res2@cnLevels  = (/-2.0,-1.5,-1.0,-0.5,-0.1,0,0.1,0.5,1.0,1.5,2.0/)      ;fspan(-4,4,11)
     end if

     if(isStrSubset(variname(dd),"u850").or.isStrSubset(variname(dd),"v850")) then
       res2@cnLevels  = (/-2.0,-1.5,-1.0,-0.5,-0.1,0,0.1,0.5,1.0,1.5,2.0/)      ;fspan(-4,4,11)
     end if

     if(isStrSubset(variname(dd),"taux").or.isStrSubset(variname(dd),"tauy")) then
       res2@cnLevels  = (/-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5/)      ;fspan(-4,4,11)
     end if

     if(isStrSubset(variname(dd),"swcre").or.isStrSubset(variname(dd),"fldsc")) then
       res2@cnLevels  = (/-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5/)      ;fspan(-4,4,11)
     end if

     if(isStrSubset(variname(dd),"z500")) then
       res2@cnLevels = (/-20,-15,-10,-5,-1,0,1,5,10,15,20/)      ;fspan(-4,4,11)
     end if

     if(isStrSubset(variname(dd),"prect")) then
       res2@cnLevels  = (/-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5/)      ;fspan(-4,4,11)
     end if

     fout = getenv("OUTDIR")+"Model_vs_obs_MME.cvdp_data.ninoreg.mean_bias.nc"
     z    = addfile(fout,"r")

     obs0 = z->$(/mmename(0)+"_"+variname(dd)+"_em"/)$  

     res@gsnCenterStringFontColor = "black"
     res2@gsnCenterStringFontColor = "black"
     res@lbLabelBarOn = False
     res2@lbLabelBarOn = False
     tres@lbLabelBarOn = False

     do gg = 0,nmme-1   ; operate on each ensemble mean
        obs0                = z->$(/mmename(gg)+"_"+variname(0)+"_em"/)$
        mod0                = z->$(/mmename(gg)+"_"+variname(dd)+"_em"/)$
        res@gsnLeftString   = "" ;
        res@gsnRightString  = variname_title_seas(dd)
        res@gsnCenterString = figstr(gg)
        plot_summary(gg)    = gsn_csm_contour_map(wks,mod0,res2)
        plot_summary1(gg)   = gsn_csm_contour(wks,obs0,res)
        overlay(plot_summary(gg),plot_summary1(gg))
     end do

     if (variable(dd).eq."sst") then
       panres2@lbTitleString = str_upper("ts")+ " anomaly ("+varunits(dd)+")"
     else
       panres2@lbTitleString = str_upper(variable(dd))+ " anomaly ("+varunits(dd)+")"
     end if
     panres2@txString = "" ;"Ensemble Summary: "+variname_title(dd)+" ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_summary,(/1,4/),panres2)
     delete(wks)

     system("mv "+OUTDIR+"nino.png "+OUTDIR+variname(dd)+".ensm.clim.png")
     if (PNG_SCALE_SUMMARY.ne.100) then
        system("convert -resize "+PNG_SCALE_SUMMARY+"% "+OUTDIR+variname(dd)+".ensm.clim.png "+OUTDIR+variname(dd)+".ensm.clim.png")
     end if

  end do
  delete([/panres,panres2/])
  print("Finished: polar.ninoreg_pattern.ncl")
end



