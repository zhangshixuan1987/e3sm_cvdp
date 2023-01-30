; Calculates sea level pressure global means and standard deviations
;
; Variables used: ua,va,ta,qa
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: ta.zonalmean_biases.ncl")
  CREATE_GRAPHICS   = getenv("CREATE_GRAPHICS")  
  PNG_SCALE         = tofloat(getenv("PNG_SCALE"))
  OUTPUT_TYPE       = getenv("OUTPUT_TYPE") 
  COLORMAP          = getenv("COLORMAP")
  OUTDIR            = getenv("OUTDIR") 
  PNG_SCALE_SUMMARY = tofloat(getenv("PNG_SCALE_SUMMARY"))

  rlatn =   90.0
  rlats =  -90.0
 
  nsim  = numAsciiRow("namelist_byvar/namelist_ta")
  na    = asciiread("namelist_byvar/namelist_ta",(/nsim/),"string")
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

  do ee = 0,nsim-1
     fnt = getenv("OUTDIR")+modname(ee)+".cvdp_data.ta.zonalmean_biases."+syear(ee)+"-"+eyear(ee)+".nc"
     fnt2 = getenv("OUTDIR")+modname(ee)+".cvdp_data."+syear(ee)+"-"+eyear(ee)+".nc"
     f_test := read_cvdp_le_data(fnt,fnt2,"ta_zonalmean_ann")
     if (.not.isatt(f_test,"is_all_missing")) then
        continue
     end if

   ;read in data, orient lats/lons correctly, set time coordinate variable up
    arr  = data_monthly_clim_read_in(paths(ee),"T",syear(ee),eyear(ee)) 

    if (isatt(arr,"is_all_missing")) then
       delete(arr)
       continue
    end if 

    finarr = calculate_clim_zonal_means(arr)

    if(isfilepresent(fnt)) then
      system("/bin/rm " + fnt)
    end if
    z = addfile(fnt,"c")
    set_global_ncfile_attributes(z,names(ee),syear(ee),eyear(ee),getenv("VERSION"))

    z->ta_zonalmean_djf       = set_varAtts(finarr(0,:,:),"ta climatology (DJF)","","")
    z->ta_zonalmean_jfm       = set_varAtts(finarr(1,:,:),"ta climatology (JFM)","","")
    z->ta_zonalmean_mam       = set_varAtts(finarr(2,:,:),"ta climatology (MAM)","","")
    z->ta_zonalmean_jja       = set_varAtts(finarr(3,:,:),"ta climatology (JJA)","","")
    z->ta_zonalmean_jas       = set_varAtts(finarr(4,:,:),"ta climatology (JAS)","","")
    z->ta_zonalmean_son       = set_varAtts(finarr(5,:,:),"ta climatology (SON)","","")
    z->ta_zonalmean_ndjfma    = set_varAtts(finarr(6,:,:),"ta climatology (NDJFMA)","","")
    z->ta_zonalmean_mjjaso    = set_varAtts(finarr(7,:,:),"ta climatology (MJJASO)","","")
    z->ta_zonalmean_ann       = set_varAtts(finarr(8,:,:),"ta climatology (annual)","","")     
    delete([/z,arr,finarr/])
  end do

  if (CREATE_GRAPHICS.eq."False") then
     print("Finished: ta.zonalmean_biases.ncl")
     exit
  end if 

;==========================================================================================
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if

  res = True      ; zonal plot resource list
  res@vpWidthF                     = 0.8
  res@vpHeightF                    = 0.6
  res@gsnFrame                     = False                 ; Do not draw plot
  res@gsnDraw                      = False                 ; Do not advance frame
 ;res@gsnMajorLatSpacing           =  10             ;-- change major lat tickmark spacing
 ;res@gsnMinorLatSpacing           =  2.5            ;-- change major lat tickmark spacing

  res@cnFillOn                     = True                  ; turn on color fill
  res@cnLinesOn                    = False                 ; no contour lines
  res@cnLineLabelsOn               = False
  res@cnMissingValFillColor        = "White" ;"gray76"               ; black = 1

  if (wks_type.eq."png") then
    boxLineThicknessF = 2.
  else 
    boxLineThicknessF = 1.
  end if

  res@tmXTOn                       = False
  res@tmYLLabelFontHeightF         = 0.025
  res@tmBorderThicknessF           = boxLineThicknessF
  res@tmXBMajorThicknessF          = boxLineThicknessF
  res@tmXBMinorThicknessF          = boxLineThicknessF
  res@tmYLMajorThicknessF          = boxLineThicknessF
  res@tmYLMinorThicknessF          = boxLineThicknessF
  res@tmYRMajorThicknessF          = boxLineThicknessF
  res@tmYRMinorThicknessF          = boxLineThicknessF
  res@tmYRMode                     = "Automatic"          ; turn off special labels on right axis

  res@tmXBMode                     = "Explicit"
  res@tmXBValues                   = ispan(toint(rlats),toint(rlatn),30)
  res@tmXBLabels                   = (/"90S","60S","30S","0","30N","60N","90N"/)
  res@tmXBMinorValues              = ispan(toint(rlats),toint(rlatn),15)

  res@trYReverse                   = True
  res@tiYAxisString                = "Pressure (hPa)"
  res@tmYLMode                     = "Explicit"                ; explicit labels
  res@tmYLValues                   = (/ 1000, 850, 700, 500, 300, 200, 100, 10, 1/)
  res@tmYLLabels                   = ""+res@tmYLValues         ; make strings

  res@cnLineLabelsOn               = False
  res@cnFillOn                     = True
  res@cnLinesOn                    = False
  res@cnInfoLabelOn                = False

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
  res@gsnLeftStringOrthogonalPosF = -0.05
  res@gsnLeftStringParallelPosF = .005

  res@gsnRightStringOrthogonalPosF = -0.05
  res@gsnRightStringParallelPosF   = 0.96

  res@gsnLeftStringFontHeightF = 0.014
  res@gsnCenterStringFontHeightF = 0.018
  res@gsnRightStringFontHeightF = 0.014
  res@gsnRightString = ""
  res@gsnLeftString = ""

  sres  = res    ; means resource list
  sres2 = sres   ; mean differences resource list
  tres  = res    ; p-value plot resource list
  copy_VarAtts(retrieve_summary_res(),tres)

  if (COLORMAP.eq.0) then
     sres@cnLevels     = (/210,220,230,240,250,260,270,275,280,285,290,295,300,305,310/) ;mean 
     sres2@cnLevels    = (/-7,-6,-5,-4,-3,-2,-1.5,-1,-0.5,0.5,1,1.5,2,3,4,5,6,7/)
     cmap = read_colormap_file("precip3_16lev")
     res@cnFillPalette = cmap((/0,2,4,6,8,10,12,14,16/),:) 
     delete(cmap)
     sres@cnFillPalette = "ncl_default"
     sres2@cnFillPalette = "ncl_default"
  end if
  if (COLORMAP.eq.1) then
     sres@cnLevels      = (/210,220,230,240,250,260,270,275,280,285,290,295,300,305,310/) ;mean
     sres2@cnLevels     = (/-7,-6,-5,-4,-3,-2,-1.5,-1,-0.5,0.5,1,1.5,2,3,4,5,6,7/)
     cmap = read_colormap_file("cb_rainbow")
     res@cnFillPalette   = cmap((/33,45,61,77,93,109,122,153,173/),:) 
     res2@cnFillPalette  = "BlueDarkRed18"
     sres@cnFillPalette  = "BlueDarkRed18"
     sres2@cnFillPalette = "BlueDarkRed18"
  end if 

  panres = True   ; panel resource list for individual simulations
  panres@gsnMaximize = True  
  panres@gsnPaperOrientation = "portrait"
  panres@gsnPanelLabelBar = True
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
  ncol = floattointeger(sqrt(nsim))
  nrow = (nsim/ncol)+mod(nsim,ncol)

  panres2 = panres   ; summary panel resource list
  panres2@gsnFrame = False
  panres2@gsnMaximize = False
  panres2@gsnPanelLabelBar = False
  panres2@lbTitleOn = False

  variname = (/"mean_djf","mean_jfm","mean_mam","mean_jja","mean_jas","mean_son","mean_ndjfma","mean_mjjaso","mean_ann"/)
  variname = "ta_zonal"+variname
  variname_title = variname
  variname_title(:8) = "T Zonal Mean Climatologies"
  variname_title_seas = (/"DJF","JFM","MAM","JJA","JAS","SON","NDJFMA","MJJASO","ANN"/)

  csubtitle_color = set_subtitle_colors(max(EM_num))
  nEM = max(EM_num)
  do dd = 0,dimsizes(variname)-1
     wks = gsn_open_wks(wks_type,getenv("OUTDIR")+"ta.zonalmean_biases")
     plot_indmem      = new(nsim,"graphic")
     plot_indmem_diff = new(nsim,"graphic")
     plot_summary     = new((nEM*4),"graphic")

     qres = sres    ; mean resource list
     qres2 = sres2  ; mean diff resource list

     numobs = num(EM_num.eq.0) 
     if (numobs.eq.0) then  ; if observations were not specified, set dummy file names, resulting in empty obs0 array
        fnt = getenv("OUTDIR")+"obs.cvdp_data.ta.zonalmean_biases."+syear(0)+"-"+eyear(0)+".nc"  
        fnt2 = getenv("OUTDIR")+"obs.cvdp_data."+syear(0)+"-"+eyear(0)+".nc"
        cntr = 0
     else
        fnt = getenv("OUTDIR")+modname(0)+".cvdp_data.ta.zonalmean_biases."+syear(0)+"-"+eyear(0)+".nc"
        fnt2 = getenv("OUTDIR")+modname(0)+".cvdp_data."+syear(0)+"-"+eyear(0)+".nc"
        cntr = 1
     end if
     obs0 := read_cvdp_le_data(fnt,fnt2,variname(dd))
     qres@gsnCenterStringFontColor = "black"
     qres2@gsnCenterStringFontColor = "black"
     qres@gsnLeftString = syear(0)+"-"+eyear(0) 
     qres@gsnRightString = "" 
     qres@gsnCenterString = names(0)    
     plot_indmem(0) = gsn_csm_contour(wks,obs0,qres)
     cntr_EM = 0
     if (numobs.ge.2) then     
        do ff = 1,numobs-1
           fnt = getenv("OUTDIR")+modname(cntr)+".cvdp_data.ta.zonalmean_biases."+syear(cntr)+"-"+eyear(cntr)+".nc"
           fnt2 = getenv("OUTDIR")+modname(cntr)+".cvdp_data."+syear(cntr)+"-"+eyear(cntr)+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,variname(dd))
           if (isatt(arr,"is_all_missing")) then 
              cntr = cntr+1
              continue
           end if

           obs0_vg = int2p_n_Wrap(obs0&lev,obs0, arr&lev,-1,0)
           obs0_rg = linint1_Wrap (obs0_vg&lat, obs0_vg, False, arr&lat, 0)
           delete([/obs0_vg/])

           obs_diff = arr
           obs_diff = (/ arr - obs0_rg /)

           qres@gsnLeftString = syear(cntr)+"-"+eyear(cntr) 
           qres@gsnRightString = "r="+pattern_correlation(obs0_rg(lat|:,lev|:),arr(lat|:,lev|:))
           qres@gsnCenterString = names(cntr)   
           plot_indmem(cntr) = gsn_csm_contour(wks,arr,qres)

           qres2@gsnLeftString = ""   
           qres2@gsnRightString = ""  
           qres2@gsnCenterString = names(cntr)+"-"+names(0)
           plot_indmem_diff(cntr) = gsn_csm_contour(wks,obs_diff,qres2)
           delete([/arr,obs_diff,obs0_rg/])
           cntr = cntr+1

        end do
     end if

     do gg = 1,nEM   ; operate on each ensemble mean
        lbFlag = summary_lb_flag(paths,EM_num,gg,nEM)  ; lbFlag set to True if summary labelbars should be drawn
        nens = num(EM_num.eq.gg) ; determines how many model simulations in each ensemble
        cntr_ens := ind(EM_num.eq.gg)   ; cntr_ens(hh) are the indices where each ensemble member of an ensemble reside 
        do hh = 0,nens-1
           modname_mod = modname(cntr_ens(hh))
           syear_mod = syear(cntr_ens(hh))
           eyear_mod = eyear(cntr_ens(hh))
           names_mod = names(cntr_ens(hh))
           names_EM_mod = names_EM(cntr_ens(hh))

           fnt = getenv("OUTDIR")+modname_mod+".cvdp_data.ta.zonalmean_biases."+syear_mod+"-"+eyear_mod+".nc"
           fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,variname(dd))
           if (isatt(arr,"is_all_missing")) then 
              cntr = cntr+1
              continue
           end if

           if (.not.isvar("arr_store")) then  ; create an array to house all members, to be used to calculate EM
              arr_store = new((/nens,dimsizes(arr&lev),dimsizes(arr&lat)/),typeof(arr))
              arr_store!0 = "ensmem"
              arr_store!1 = "lev"
              arr_store&lev = arr&lev
              arr_store!2 = "lat"
              arr_store&lat = arr&lat
              arr_store@nens = 0
              copy_VarAtts(arr,arr_store)

              syear_em0 = syear_mod
              eyear_em0 = eyear_mod
              showyr = True
           end if
           if (syear_em0.ne.syear_mod.or.eyear_em0.ne.eyear_mod.and.showyr) then
              showyr = False
           else
              showyr = True
           end if
           qres@gsnCenterStringFontColor = csubtitle_color(gg-1)
           qres2@gsnCenterStringFontColor = csubtitle_color(gg-1)

           arr_store(hh,:,:) = (/ arr /)
           arr_store@nens = arr_store@nens+1
           panres@lbTitleString = arr@units
           if (.not.isvar("obs0_rg")) then  
              obs0_vg = int2p_n_Wrap(obs0&lev,obs0, arr&lev,-1,0)
              printVarSummary(obs0_vg)
              obs0_rg = linint1_Wrap(obs0_vg&lat, obs0_vg, False, arr&lat, 0)
              printVarSummary(obs0_rg)
              delete([/obs0_vg/])
           end if
           obs_diff = arr
           obs_diff = (/ arr - obs0_rg /)
           printVarSummary(obs_diff)
           printMinMax(obs_diff,0)
           exit
           qres@gsnLeftString = syear_mod+"-"+eyear_mod
           qres@gsnRightString = "r="+pattern_correlation(obs0_rg(lat|:,lev|:),arr(lat|:,lev|:))
           qres@gsnCenterString = names_mod
           plot_indmem(cntr) = gsn_csm_contour(wks,arr,qres)
           qres2@gsnLeftString = "" 
           qres2@gsnRightString = ""  
           qres2@gsnCenterString = names_mod+"-"+names(0)  
           plot_indmem_diff(cntr) = gsn_csm_contour(wks,obs_diff,qres2)
           delete([/arr,obs_diff/])
           cntr = cntr+1
        end do
        if (.not.isvar("arr_store")) then
           cntr_EM = cntr_EM+4
           continue
        end if
        if (lbFlag) then
           qres@lbLabelBarOn = True
           qres2@lbLabelBarOn = True
           tres@lbLabelBarOn = True
        else
           qres@lbLabelBarOn = False
           qres2@lbLabelBarOn = False
           tres@lbLabelBarOn = False     
        end if
        arr_EM = dim_avg_n_Wrap(arr_store,0)

        qres@gsnCenterStringFontColor = "black"
        qres2@gsnCenterStringFontColor = "black"
        qres@lbTitleString = arr_EM@units   
        qres2@lbTitleString = qres@lbTitleString  

        qres@gsnLeftString = syear(0)+"-"+eyear(0) 
        qres@gsnRightString = ""  
        qres@gsnCenterString = "Observations ("+names(0)+")"    
        plot_summary(cntr_EM+1) = gsn_csm_contour(wks,obs0,qres)

        if (showyr) then
           qres@gsnLeftString = syear_em0+"-"+eyear_em0 
        else
           qres@gsnLeftString = (eyear_em0-syear_em0+1)+"yrs" 
        end if
        delete([/syear_em0,eyear_em0,showyr/])

        qres@gsnCenterStringFontColor = csubtitle_color(gg-1)
        qres@gsnRightString = "r="+pattern_correlation(obs0_rg(lat|:,lev|:),arr_EM(lat|:,lev|:))
        qres@gsnCenterString = names_EM_mod +" ("+arr_store@nens+" Members)"                   
        plot_summary(cntr_EM) = gsn_csm_contour(wks,arr_EM,qres)
        obs_diff = arr_EM
        obs_diff = (/ arr_EM - obs0_rg /)
        qres2@gsnLeftString = ""
        qres2@gsnCenterString = names_EM_mod+" - Observations"    
        qres2@gsnRightString = "" 
        plot_summary(cntr_EM+2) = gsn_csm_contour(wks,obs_diff,qres2)

        fout = getenv("OUTDIR")+str_sub_str(names_EM_mod," ","_")+"_EM.cvdp_data.ta.zonalmean_biases."+syear_mod+"-"+eyear_mod+".nc"
        if (isfilepresent2(fout)) then
           z = addfile(fout,"w")
        else
           z = addfile(fout,"c")
           set_global_ncfile_attributes(z,names_EM_mod,syear_mod,eyear_mod,getenv("VERSION"))
        end if
        z->$(/variname(dd)+"_em"/)$ = set_varAtts(arr_EM,arr_EM@long_name+" Ensemble Mean","","")
        z->$(/variname(dd)+"_em_diffobs"/)$ = set_varAtts(obs_diff,obs_diff@long_name+" Ensemble Mean difference from observations","C","")        
        delete([/arr_store,obs0_rg,obs_diff,arr_EM/])
        cntr_EM = cntr_EM+4
     end do
     panres@txString = variname_title(dd)+" ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_indmem,(/nrow,ncol/),panres)

     panres@txString = variname_title(dd)+" Differences ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_indmem_diff,(/nrow,ncol/),panres)

     panres2@txString = "Ensemble Summary: "+variname_title(dd)+" ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_summary,(/nEM,4/),panres2)
     frame(wks)
     delete(wks)

     if (wks_type.eq."png") then
        system("mv "+OUTDIR+"ta.zonalmean_biases.000001.png "+OUTDIR+variname(dd)+".indmem.png")
        system("mv "+OUTDIR+"ta.zonalmean_biases.000002.png "+OUTDIR+variname(dd)+".indmemdiff.png")
        system("mv "+OUTDIR+"ta.zonalmean_biases.000003.png "+OUTDIR+variname(dd)+".summary.png")
        if (PNG_SCALE_SUMMARY.ne.100) then
           system("convert -resize "+PNG_SCALE_SUMMARY+"% "+OUTDIR+variname(dd)+".summary.png "+OUTDIR+variname(dd)+".summary.png")
        end if
     else
        system("psplit "+OUTDIR+"ta.zonalmean_biases.ps "+OUTDIR+"ta.zonalmean_biases")
        system("mv "+OUTDIR+"ta.zonalmean_biases0001.ps "+OUTDIR+variname(dd)+".indmem.ps")
        system("mv "+OUTDIR+"ta.zonalmean_biases0002.ps "+OUTDIR+variname(dd)+".indmemdiff.ps")
        system("mv "+OUTDIR+"ta.zonalmean_biases0003.ps "+OUTDIR+variname(dd)+".summary.ps")
        system("rm "+OUTDIR+"ta.zonalmean_biases.ps")
     end if
  end do
  print("Finished: ta.zonalmean_biases.ncl")
end

