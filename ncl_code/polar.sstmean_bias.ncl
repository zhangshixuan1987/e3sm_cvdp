; Calculates TS mean biases 
;
; Variables used: TS
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: polar.sstmean_bias.ncl")
  CREATE_GRAPHICS  = getenv("CREATE_GRAPHICS")  
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
  COLORMAP         = getenv("COLORMAP")
  OUTDIR           = getenv("OUTDIR") 
  POLAR            = getenv("POLAR")
  PNG_SCALE_SUMMARY = tofloat(getenv("PNG_SCALE_SUMMARY"))
  GENERATE_DATA     = False 

  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if

  if (POLAR.eq."SH") then
    rlatn = -20.0
    rlats = -90.0
  else if (POLAR.eq."NH") then
    rlatn =  90.0
    rlats =  20.0
  else
    rlatn =   90.0
    rlats =  -90.0
  end if
  end if

  variname            = (/"mean_djf","mean_jfm","mean_mam","mean_jja","mean_jas",\
                          "mean_son","mean_ndjfma","mean_mjjaso","mean_ann"/)
  variname            = "sst_spatial"+variname
  variname_title      = variname
  variname_title      = "Surface skin temperature (TS)" 
  variname_title_seas = (/"DJF","JFM","MAM","JJA","JAS","SON","NDJFMA","MJJASO","ANN"/)

  mmename             = (/"ERA5", "CMIP6-COUP",  "E3SMv2-COUP",  "E3SMv2-AMIP",   "E3SMv2-COUP"/)
  titname             = (/"ERA5", "CMIP6 (MME)", "E3SM (Couple)","E3SMv2 (AMIP)", "E3SM - CMIP6"/)
  nmme                = dimsizes(mmename)

  figstr              = (/ "(a)", "(b)",   "(c)",  "(d)", "(e)"/)
  figstr              = figstr + " "+titname
  figstr(1:nmme-2)    = figstr(1:nmme-2) + " - Obs."
  figstr(0)           = figstr(0)+ " (Obs.)"


  if (GENERATE_DATA) then 

    nsim = numAsciiRow("namelist_byvar/namelist_ts")
    na = asciiread("namelist_byvar/namelist_ts",(/nsim/),"string")
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
         fnt  = getenv("OUTDIR")+modname_mod+".cvdp_data.sst.mean_stddev."+syear_mod+"-"+eyear_mod+".nc"
         fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
         arr := read_cvdp_le_data(fnt,fnt2,variname(dd))
        ;m = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")     ; mask ocean for TAS array
        ;arr = mask(arr,landsea_mask(m->LSMASK,arr&lat,arr&lon).ge.1,False) 
        ;delete(m)
         if (ee.eq.0) then 
           arr_obs   = new((/nenso,dimsizes(arr&lat),dimsizes(arr&lon)/),typeof(arr))
           arr_obs!0 = "ensmem"
           arr_obs!1 = "lat"
           arr_obs&lat = arr&lat
           arr_obs!2 = "lon"
           arr_obs&lon = arr&lon
           arr_obs@nens = 0
         end if 
         arr_obs(ee,:,:) = (/ arr /)
         arr_obs@nens = arr_obs@nens+1
      end do

      obs_EM = dim_avg_n_Wrap(arr_obs,0)
      obs_EM@long_name = variname_title(dd)
      obs_EM@units = "~S~o~N~C"

      fout = getenv("OUTDIR")+"Model_vs_obs_MME.cvdp_data.sstmean.mean_bias.nc"
      if (isfilepresent2(fout)) then
        ;system ("rm -rvf " + fout)
         z = addfile(fout,"w")
      else
         z = addfile(fout,"c")
      end if
      z->$(/mmename(0)+"_"+variname(dd)+"_em"/)$  = set_varAtts(obs_EM,obs_EM@long_name+" Ensemble Mean","","")

      do ff = 1,nmme-2

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
           fnt  = getenv("OUTDIR")+modname_mod+".cvdp_data.sst.mean_stddev."+syear_mod+"-"+eyear_mod+".nc"
           fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,variname(dd))
          ;m = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")     ; mask ocean for TAS array
          ;arr = mask(arr,landsea_mask(m->LSMASK,arr&lat,arr&lon).ge.1,False)
          ;delete(m)
           if (.not.all(ismissing(arr))) then 
             if (ncens.eq.0) then
               arr_raw1      = new((/nensm,dimsizes(arr&lat),dimsizes(arr&lon)/),typeof(arr))
               arr_raw1!0    = "ensmem"
               arr_raw1!1    = "lat"
               arr_raw1&lat  = arr&lat
               arr_raw1!2    = "lon"
               arr_raw1&lon  = arr&lon
               arr_raw1@nens = 0
               arr_mod1      = new((/nensm*nenso,dimsizes(arr&lat),dimsizes(arr&lon)/),typeof(arr))
               arr_mod1!0    = "ensmem"
               arr_mod1!1    = "lat"
               arr_mod1&lat  = arr&lat
               arr_mod1!2    = "lon"
               arr_mod1&lon  = arr&lon
               arr_mod1@nens = 0
             end if
             hh1 = ncens*nenso
             hh2 = (ncens+1)*nenso-1
             arr_raw1(ncens,:,:) = (arr)
             arr_raw1@nens = arr_raw1@nens+1
             arr_mod1(hh1:hh2,:,:) = (/ conform(arr_obs,arr,(/1,2/)) - arr_obs/)
             arr_mod1@nens = arr_mod1@nens+nenso
             ncens = ncens + 1
           end if 
        end do 
        arr_raw      = arr_raw1(0:ncens-1,:,:)
        arr_raw@nens = ncens
        arr_mod      = arr_mod1(0:ncens*nenso-1,:,:)
        arr_mod@nens = ncens*nenso 
        delete([/arr_raw1,arr_mod1/])

        mod_EM = dim_avg_n_Wrap(arr_raw,0)
        mod_EM@long_name = variname_title(dd)
        modd_EM = dim_avg_n_Wrap(arr_mod,0)
        modd_EM@long_name = variname_title(dd)+" difference" 

        ;;generate the probility entry 
        p_val   = mod_EM
        nsign   = mod_EM
        nsign   = 1.0
        arr_tmp = arr_mod 
        arr_tmp = arr_mod * conform(arr_mod,arr_mod(0,:,:),(/1,2/))
        nsign   = dim_num_n((arr_mod.gt.0.and.arr_tmp.gt.0).or.(arr_mod.lt.0.and.arr_tmp.lt.0),0)
        p_val   = 100.0 - nsign*100.0 / (nensm*nenso)  

        z->$(/mmename(ff)+"_"+variname(dd)+"_em"/)$           = set_varAtts(mod_EM,mod_EM@long_name+" Ensemble Mean","~S~o~N~C","")
        z->$(/mmename(ff)+"_"+variname(dd)+"_em_diffobs"/)$   = set_varAtts(modd_EM,modd_EM@long_name+" Ensemble Mean difference from observations","~S~o~N~C","")
        z->$(/mmename(ff)+"_"+variname(dd)+"_pval_diffobs"/)$ = set_varAtts(p_val,"p-val statistics of model agreement on the sign of the bias","%","")

        if(mmename(ff).eq."CMIP6-COUP") then 
          arr_mod_ref = arr_raw
        end if 

        if(mmename(ff).eq."E3SMv2-COUP") then
          arr_mod_com = arr_raw
        end if

        delete([/mod_EM,modd_EM,p_val,arr_tmp,nsign,arr_mod,arr_raw/])

     end do

     arr_mod      = new((/arr_mod_com@nens*arr_mod_ref@nens,dimsizes(arr_mod_ref&lat),dimsizes(arr_mod_ref&lon)/),typeof(arr_mod_ref))
     arr_mod!0    = "ensmem"
     arr_mod!1    = "lat"
     arr_mod&lat  = arr&lat
     arr_mod!2    = "lon"
     arr_mod&lon  = arr&lon
     arr_mod@nens = 0
     do hh = 0,arr_mod_com@nens-1
        hh1 = hh*arr_mod_ref@nens 
        hh2 = (hh+1)*arr_mod_ref@nens-1
        arr_mod(hh1:hh2,:,:) = (/ conform(arr_mod_ref,arr_mod_com(hh,:,:),(/1,2/)) - arr_mod_ref/)
        arr_mod@nens = arr_mod@nens+arr_mod_ref@nens
     end do

     mod_EM = dim_avg_n_Wrap(arr_mod,0)
     mod_EM@long_name =variname_title(dd)

     ;;generate the probility entry
     p_val   = mod_EM
     nsign   = mod_EM 
     nsign   = 1.0 
     arr_tmp = arr_mod 
     arr_tmp = arr_tmp * conform(arr_mod,arr_mod(0,:,:),(/1,2/))
     nsign   = dim_num_n((arr_mod.gt.0.and.arr_tmp.gt.0).or.(arr_mod.lt.0.and.arr_tmp.lt.0),0)
     p_val   = 100.0 - nsign*100.0 / (nensm*arr_mod_ref@nens)

     z->$(/mmename(nmme-1)+"_"+variname(dd)+"_em_diffmme"/)$   = set_varAtts(mod_EM,mod_EM@long_name+" Ensemble Mean difference from observations","C","")
     z->$(/mmename(nmme-1)+"_"+variname(dd)+"_pval_diffmme"/)$ = set_varAtts(p_val,"p-val statistics of model agreement on the sign of the bias","%","")
     delete([/mod_EM,p_val,arr_tmp,nsign,arr_mod/])

     delete([/arr_mod_ref,obs_EM,arr_obs/])

   end do 

  end if 

  if (CREATE_GRAPHICS.eq."False") then
     print("Finished: polar.sstmean.mean_bias.ncl")
     exit
  end if

;==========================================================================================
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if

  cmap = read_colormap_file("t2m_29lev")
  LineColors      = cmap((/0,25,7,16,28/),:)
  LineThicknesses = (/20.,20.,20.,20.0,20.0/)*1.2      ; line thicknesses
  DashPatterns    = (/0.,0.,0.,0.,0./)      ; make all lines solid
  delete(cmap)

  ;start to process zonal mean line plot
  xyres = True    ; individual obs/model line plot resource list
  xyres@gsnDraw          = True 
  xyres@gsnFrame         = False
  xyres@gsnMaximize      = True

  if(wks_type.eq."png") then
   lthick = 8.0
  else
   lthick = 1.0
  end if

  xyres@tmBorderThicknessF    = lthick
  xyres@tmXBMajorThicknessF   = lthick
  xyres@tmXBMinorThicknessF   = lthick
  xyres@tmYLMajorThicknessF   = lthick
  xyres@tmYLMinorThicknessF   = lthick
  xyres@tmYRMajorThicknessF   = lthick
  xyres@tmYRMinorThicknessF   = lthick

  FontHeightF = 0.022
  xyres@tiMainFontThicknessF       = 3.0
  xyres@tiMainFontHeightF          = FontHeightF*1.2
  xyres@tmYLLabelFontHeightF       = FontHeightF
  xyres@tmXBLabelFontHeightF       = FontHeightF
  xyres@tiXAxisFontHeightF         = FontHeightF
  xyres@tiYAxisFontHeightF         = FontHeightF
  xyres@gsnStringFontHeightF       = FontHeightF*1.2
  xyres@gsnLeftStringFontHeightF   = FontHeightF
  xyres@gsnCenterStringFontHeightF = FontHeightF
  xyres@gsnRightStringFontHeightF  = xyres@gsnCenterStringFontHeightF

  xyres@gsnLeftStringOrthogonalPosF   = 0.02
  xyres@gsnRightStringOrthogonalPosF  = xyres@gsnLeftStringOrthogonalPosF
  xyres@gsnCenterStringOrthogonalPosF = 0.02
  xyres@gsnCenterStringParallelPosF   = 0.05

  xyres@vpHeightF       = 0.5
  xyres@vpWidthF        = 0.8

  xyres@gsnLeftString   = ""
  xyres@gsnCenterString = ""
  xyres@gsnRightString  = ""

  xyres@pmLegendDisplayMode    = "Always"              ; turn on legend
  xyres@pmLegendSide           = "Top"                 ; Change location of
  xyres@pmLegendParallelPosF   = .75                   ; move units right
  xyres@pmLegendOrthogonalPosF = -0.55                  ; more neg = down
  xyres@pmLegendWidthF         = 0.12                  ; Change width and
  xyres@pmLegendHeightF        = 0.16                  ; height of legend.
  xyres@lgLabelFontHeightF     = .018                   ; change font height
  xyres@lgPerimOn              = False                 ; no box around

  xyres@trXMinF         = -70.0
  xyres@trXMaxF         = -30.0
  xyres@tmXBMode        = "Explicit"                ; explicit labels
  xyres@tmXBValues      = ispan(-90,90,10)
  xyres@tmXBLabels      = ""+xyres@tmXBValues         ; make strings
  xyres@tiXAxisString   = "Latitude (degree)"    ; y-axis label      

  xyres@trYMinF         = -2.0
  xyres@trYMaxF         =  4.0
  xyres@tmYLMode        = "Explicit"                ; explicit labels
  xyres@tmYLValues      = fspan(-10,10,21)
  xyres@tmYLMinorValues = fspan(-10,10,61)
  xyres@tmYLLabels      = ""+xyres@tmYLValues         ; make strings
  xyres@tiYAxisString   = "~F33~D~N~~F~TS (~S~o~N~C)"    ; y-axis label
  xyres@gsnLeftString   = "Zonal mean bias in TS (model - ERA5)"
  xyres@tiMainString    = ""
  xyres@gsnRightString  = ""

  xyres@pmLegendOrthogonalPosF = -0.55  ; more neg = down
  xyres@xyExplicitLegendLabels = "  "+titname(1:nmme-2)
  xyres@xyLineColors           = LineColors(2:nmme-1,:)
  xyres@xyLineThicknesses      = LineThicknesses(2:nmme-1)
  xyres@xyDashPatterns         = DashPatterns(2:nmme-1)

  cline_color = set_subtitle_colors(nmme)
 
  xyres@xyMonoLineColor        = False             ; want colored lines
  xyres@xyMarkLineMode         = "Lines" ;"MarkLines"
  xyres@gsnYRefLine            = 0.0
  xyres@gsnYRefLineColor       = "gray42"
  xyres@gsnYRefLineThicknessF  = 2.0 

  do dd = 0,dimsizes(variname)-1

     do gg = 1, nmme-2

       fout = getenv("OUTDIR")+"Model_vs_obs_MME.cvdp_data.sstmean.mean_bias.nc"
       z = addfile(fout,"r")
       obs0 = z->$(/mmename(gg)+"_"+variname(dd)+"_em_diffobs"/)$ 
       obs0@units = "~S~o~N~C"
      
       if (gg.eq.1) then 
         ;compute zonal mean and zonal mean difference
         grad_zmn       = new((/nmme-2,dimsizes(obs0&lat)/),typeof(obs0))
         grad_zmn!0     = "nmodels"
         grad_zmn!1     = "lat"
         grad_zmn&lat   = obs0&lat
         grad_zmn@units = obs0@units
      end if 
      grad_zmn(gg-1,:) = dim_avg_n(obs0,1)
      delete([/obs0/])
     end do 

     xyres@gsnRightString = variname_title_seas(dd)
    ;xyres@trYMaxF        = max(grad_zmn(:,{-90:-30})) + 1.0
    ;xyres@trYMinF        = min(grad_zmn(:,{-90:-30})) - 1.0

     wks   = gsn_open_wks(wks_type,getenv("OUTDIR")+"sstmean.mean_zmn")
     plotF = gsn_csm_xy (wks,grad_zmn&lat,grad_zmn,xyres) ; create plot
     frame(wks)                                     ; now advance frame

     if (wks_type.eq."png") then
       system("mv "+OUTDIR+"sstmean.mean_zmn.png "+OUTDIR+variname(dd)+".zmn.clim.summary.png")
     else
       system("psplit "+OUTDIR+"sstmean.mean_zmn.ps "+OUTDIR+"sstmean.mean_zmn")
       system("mv "+OUTDIR+"sstmean.mean_zmn.ps "+OUTDIR+variname(dd)+".zmn.clim.summary.ps")
       system("rm "+OUTDIR+"sstmean.mean_zmn.ps")
     end if

  end do

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;;process the map plot;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  res = True      ; spatial plot resource list
  if (abs(rlats).lt.90.0.or.abs(rlatn).lt.90.0) then
    res@mpGeophysicalLineColor = "gray42"
    res@mpPerimOn    = True
    res@mpFillOn = False
    if(POLAR.eq."SH")
      res@gsnPolar = "SH"
      res@mpMaxLatF = -20.
    else
      res@gsnPolar = "NH"
      res@mpMaxLatF =  20.
    end if 
    res@mpOutlineOn = True
    res@mpCenterLonF = 0.
    res@mpGridAndLimbOn = True 
  else
    res@mpProjection = "WinkelTripel"
    res@mpGeophysicalLineColor = "gray42"
    res@mpPerimOn    = False
    res@mpGridLatSpacingF =  90         ; change latitude  line spacing
    res@mpGridLonSpacingF = 180.        ; change longitude line spacing
    res@mpGridLineColor   = "transparent"  ; trick ncl into drawing perimeter
    res@mpGridAndLimbOn   = True        ; turn on lat/lon lines
    res@mpFillOn = False
    res@mpCenterLonF = 210.
    res@mpOutlineOn = True
  end if
  if (wks_type.eq."png") then
     res@mpGeophysicalLineThicknessF = 2.  
  else
     res@mpGeophysicalLineThicknessF = 1.  
  end if
  res@gsnDraw   = False
  res@gsnFrame  = False
  
  res@cnLineLabelsOn = False
  res@cnFillOn     = True
  res@cnLinesOn    = False

  res@tmXBLabelFontHeightF = 0.018
  res@tmYLLabelFontHeightF = 0.018

  res@lbLabelBarOn       = False 
  res@pmLabelBarWidthF   = 0.63
  res@pmLabelBarHeightF  = 0.075
  res@lbBoxLineColor     = "gray70"
  res@lbLabelFontHeightF = 0.02
  res@lbLabelStride = 1
  res@lbTitleOn = True
  res@lbTitleFontHeightF = res@lbLabelFontHeightF
  res@lbTitlePosition = "Bottom"
  res@cnNoDataLabelOn = False

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@gsnLeftStringOrthogonalPosF  = .005
  res@gsnLeftStringParallelPosF    = .005
  res@gsnRightStringOrthogonalPosF = .005
  res@gsnRightStringParallelPosF   = 0.96
  res@gsnLeftStringFontHeightF     = 0.024
  res@gsnCenterStringFontHeightF   = 0.024
  res@gsnRightStringFontHeightF    = 0.024
  res@gsnRightString = ""
  res@gsnLeftString = ""

  res2 = res    ; stddev differences resource list
  sres = res     ; means resource list
  sres2 = sres   ; mean differences resource list

  res@cnLevels   = ispan(0,24,2) ;(/0,2,4,6,8,10,12,14,16,20,24/)
  res2@cnLevels  = (/-3,-2,-1,-0.6,-0.3,0.3,0.6,1,2,3/)
  sres@cnLevels  = (/-1.5,-1,-0.5,-0.3,0.3,0.5,1,1.5/)

  cmap = read_colormap_file("cb_rainbow")
  res@cnFillPalette    = "wgne15" ;"percent_11lev" ;cmap((/33,45,61,77,93,109,122,153,173/),:) 
  res2@cnFillPalette   = "cmocean_balance"
  sres@cnFillPalette   = "cmp_flux" ;"BlueDarkRed18";"hotcold_18lev" ;"cmp_flux"

  panres = True   ; panel resource list for individual simulations
  panres@gsnMaximize = True  
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelLabelBar = False 
  panres@gsnPanelYWhiteSpacePercent = 3.0
  panres@pmLabelBarHeightF = 0.05
  panres@pmLabelBarWidthF = 0.65
  panres@pmLabelBarOrthogonalPosF = -0.02
  panres@lbBoxLineColor = "gray70"
  panres@txFontHeightF = 0.016
  panres@gsnPanelBottom = 0.05
  panres@lbLabelFontHeightF = 0.013
  panres@lbLabelStride = 1
  panres@lbTitleOn = True
  panres@lbTitleFontHeightF = panres@lbLabelFontHeightF
  panres@lbTitlePosition = "Bottom"
  ncol = nmme 
  nrow = 1 

  panres2 = panres     ; summary panel resource list
  panres2@gsnFrame = False
  panres2@gsnMaximize = False
  panres2@gsnPanelLabelBar = False
  panres2@lbTitleOn = False

  pres2 = True
  pres2@lbLabelBarOn    = False
  pres2@gsnTickMarksOn  = False     ; no tickmarks
  pres2@gsnDraw         = False     ; don't draw
  pres2@gsnFrame        = False     ; don't advance frame
  pres2@tiMainString    = ""
  pres2@gsnLeftString   = ""
  pres2@gsnRightString  = ""
  pres2@cnMinLevelValF  = 90.0
  pres2@cnMaxLevelValF  = 100.0
 ;pres2@cnLevelSpacingF = 1.
  pres2@cnMonoFillPattern = True
  pres2@cnMonoFillColor = True
  pres2@cnFillOn        = True      ; color fill
  pres2@cnLinesOn       = False
  pres2@cnLineLabelsOn  = False        ; True is default
  pres2@cnInfoLabelOn   = False                ; turn off info label
  pres2@cnFillMode      = "AreaFill" ; raster fill significance patterns
  pres2@cnFillPattern   = 17
  pres2@cnFillDotSizeF  = 0.002
  pres2@cnFillColor     = "black"
  pres2@cnFillOpacityF  = 0.8

  do dd = 0,dimsizes(variname)-1

     wks = gsn_open_wks(wks_type,getenv("OUTDIR")+"sstmean.mean_bias")
     plot_summary = new((nmme),"graphic")
     plot_dum     = new(1000,"graphic")

     qres  = res    ; mean resource list
     qres1 = res2
     qres2 = sres   ; mean diff resource list

     fout = getenv("OUTDIR")+"Model_vs_obs_MME.cvdp_data.sstmean.mean_bias.nc"
     z = addfile(fout,"r")
     obs0 = z->$(/mmename(0)+"_"+variname(dd)+"_em"/)$  
     obs0@units = "~S~o~N~C"

     qres@lbLabelBarOn = True
     qres1@lbLabelBarOn = True
     qres2@lbLabelBarOn = True

     qres@gsnCenterStringFontColor = "black"
     qres1@gsnCenterStringFontColor = "black"
     qres2@gsnCenterStringFontColor = "black"
     qres@lbTitleString    = "TS (" + obs0@units + ")"
     qres1@lbTitleString   = "~F33~D~N~~F~"+qres@lbTitleString
     qres2@lbTitleString   = "~F33~D~N~~F~"+qres@lbTitleString

     qres@gsnLeftString    = "" 
     qres@gsnRightString   = ""
     qres@gsnCenterString  = "" 

     qres@cnLinesOn        = True 
     qres1@cnLinesOn       = True
     qres2@cnLinesOn       = True

     qres@gsnLeftString    = ""
     qres@gsnRightString   = "(" +variname_title_seas(dd)+")"
     qres@gsnCenterString  = figstr(0)
     qres@gsnCenterStringFontColor = "black"
     plot_summary(0) = gsn_csm_contour_map(wks,obs0,qres)

     do cntr_EM = 1,nmme-2
       qres1@gsnLeftString            = "" ;
       qres1@gsnCenterString          = figstr(cntr_EM)
       qres1@gsnCenterStringFontColor = "black"
       qres1@gsnRightString           = "(" +variname_title_seas(dd)+")"
       obs_diff = z->$(/mmename(cntr_EM)+"_"+variname(dd)+"_em_diffobs"/)$
       p_obs    = z->$(/mmename(cntr_EM)+"_"+variname(dd)+"_pval_diffobs"/)$
       p_obs    = where(p_obs.ge.20,p_obs@_FillValue,p_obs)
       plot_summary(cntr_EM)          = gsn_csm_contour_map(wks,obs_diff,qres1)
       if(mmename(cntr_EM).ne."E3SMv2-AMIP") then
         plot_dum(cntr_EM)            = gsn_csm_contour(wks,p_obs,pres2) ; contours are at 95,100
         overlay(plot_summary(cntr_EM),plot_dum(cntr_EM))
       end if
     end do

     qres2@gsnCenterStringFontColor = "black"
     qres2@gsnLeftString            = ""
     qres2@gsnCenterString          = figstr(nmme-1)
     qres2@gsnRightString           = "(" +variname_title_seas(dd)+")"
     mod_diff = z->$(/mmename(nmme-1)+"_"+variname(dd)+"_em_diffmme"/)$
     p_mod    = z->$(/mmename(nmme-1)+"_"+variname(dd)+"_pval_diffmme"/)$
     p_mod    = where(p_mod.ge.20,p_mod@_FillValue,p_mod)
     plot_summary(nmme-1) = gsn_csm_contour_map(wks,mod_diff,qres2)
     plot_dum(nmme-1)     = gsn_csm_contour(wks,p_mod,pres2) ; contours are at 95,100
     overlay(plot_summary(cntr_EM),plot_dum(cntr_EM))

     panres2@txString = "" 
     gsn_panel2(wks,plot_summary,(/nrow,ncol/),panres2)
     frame(wks)
     delete(wks)

     if (wks_type.eq."png") then
       system("mv "+OUTDIR+"sstmean.mean_bias.png "+OUTDIR+variname(dd)+".clim.summary.png")
       if (PNG_SCALE_SUMMARY.ne.100) then
          system("convert -resize "+PNG_SCALE_SUMMARY+"% "+OUTDIR+variname(dd)+".clim.summary.png "+OUTDIR+variname(dd)+".clim.summary.png")
       end if
     else
       system("psplit "+OUTDIR+"sstmean.mean_bias.ps "+OUTDIR+"sstmean.mean_bias")
       system("mv "+OUTDIR+"sstmean.mean_bias.ps "+OUTDIR+variname(dd)+".clim.summary.ps")
       system("rm "+OUTDIR+"sstmean.mean_bias.ps")
     end if
  end do 

  print("Finished: polar.sstmean_bias.ncl")
end
