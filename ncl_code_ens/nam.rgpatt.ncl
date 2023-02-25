; Calculates seasonal/annual southern hemisphere sst regrs, regression pattern
;
; Variables used: namsfcvar  
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
 print("Starting: nam.rgpatt.ncl")
 CREATE_GRAPHICS  = getenv("CREATE_GRAPHICS")  
 PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
 OUTPUT_TYPE      = getenv("OUTPUT_TYPE") 
 COLORMAP         = getenv("COLORMAP")
 OUTDIR           = getenv("OUTDIR") 
 POLAR            = "NH"
 PNG_SCALE_SUMMARY = tofloat(getenv("PNG_SCALE_SUMMARY"))

 ;;region for regression analysis
 rlats = -90.0
 rlatn =  90.0
 rlonw =   0.0
 rlone = 360.0

 nsim_psl  = numAsciiRow("namelist_byvar/namelist_psl")
 na_psl    = asciiread("namelist_byvar/namelist_psl",(/nsim_psl/),"string")
 names_psl = new(nsim_psl,"string")
 paths_psl = new(nsim_psl,"string")
 syear_psl = new(nsim_psl,"integer",-999)
 eyear_psl = new(nsim_psl,"integer",-999)
 delim     = "|"

 do ee = 0,nsim_psl-1
    names_psl(ee) = str_strip(str_get_field(na_psl(ee),1,delim))
    paths_psl(ee) = str_strip(str_get_field(na_psl(ee),2,delim))
    syear_psl(ee) = stringtointeger(str_strip(str_get_field(na_psl(ee),3,delim)))
    eyear_psl(ee) = stringtointeger(str_strip(str_get_field(na_psl(ee),4,delim)))
 end do
 modname_psl = str_sub_str(names_psl," ","_")
 bc = (/"/","'","(",")"/)
 do ff = 0,dimsizes(modname_psl)-1
    do ee = 0,dimsizes(bc)-1
       modname_psl(ff) = str_sub_str(modname_psl(ff),bc(ee),"_")
    end do
 end do
 nyr_psl = eyear_psl-syear_psl+1

 namsfcvars = (/"psl","sst","trefht","prect","u10","v10","taux","tauy","sh","lh", "eth", \
                "swcre","fldsc","cldtot","u850","v850","th850","z500","u200","v200"/)
 nsvars  = dimsizes(namsfcvars)

 do ss = 0, nsvars-1,1

  vnm   = namsfcvars(ss)
  if(vnm.eq."sst") then 
    nsim = numAsciiRow("namelist_byvar/namelist_ts")
    na   = asciiread("namelist_byvar/namelist_ts",(/nsim/),"string")
  else 
    nsim = numAsciiRow("namelist_byvar/namelist_"+vnm)
    na   = asciiread("namelist_byvar/namelist_"+vnm,(/nsim/),"string")
  end if 
  names = new(nsim,"string")
  paths = new(nsim,"string")
  syear = new(nsim,"integer",-999)
  eyear = new(nsim,"integer",-999)
  names_EM = new(nsim,"string")
  EM_num = new(nsim,"integer",-999)

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
 
  seas = (/"DJF","JFM","MAM","JJA","JAS","SON","NDJFMA","MJJASO","ANN"/)
  si   = (/ 1,1,3,6,7, 9,10, 5, 1 /)
  se   = (/ 2,3,5,8,9,11, 5,10,12 /)

  d = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")   ; mask out land (this is redundant for data that is already masked)

  do ee = 0,nsim-1
    
     fnt = getenv("OUTDIR")+modname(ee)+".cvdp_data.nam_regr."+syear(ee)+"-"+eyear(ee)+".nc"
     fnt2 = getenv("OUTDIR")+modname(ee)+".cvdp_data."+syear(ee)+"-"+eyear(ee)+".nc"
     f_test := read_cvdp_le_data(fnt,fnt2,vnm+"_regon_nam_pattern_ann")
     if (.not.isatt(f_test,"is_all_missing")) then
        continue
     end if

    ;read in data, orient lats/lons correctly, set time coordinate variable up
     if(vnm.eq."sst") then
       vnmi = "TS"
     else if(vnm.eq."qnet") then
       vnmi = "Qn"
     else
       vnmi = str_upper(vnm) 
     end if
     end if

     arr_indv = data_read_in(paths_psl(ee),"PSL",syear(ee),eyear(ee))
     arr_rgrv = data_read_in(paths(ee),vnmi,syear(ee),eyear(ee))

     if (isatt(arr_rgrv,"is_all_missing")) then
        delete([/arr_rgrv,arr_indv/])
        continue
     end if 

     arr_indv = rmMonAnnCycTLL(arr_indv)
     arr_rgrv = rmMonAnnCycTLL(arr_rgrv)

     if (isfilepresent2(fnt)) then
        z = addfile(fnt,"w")
     else
        z = addfile(fnt,"c")
        set_global_ncfile_attributes(z,names(ee),syear(ee),eyear(ee),getenv("VERSION"))
     end if

     nyyyy  = dimsizes(arr_indv&time)/12
     tmsk   = arr_indv&time
     do iyy = 0,nyyyy-1
       tmsk((iyy*12):((iyy+1)*12-1)) = ispan(1,12,1)
     end do

     do gg = 0,8 

       if(gg.eq.0) then
         indxx = ind((tmsk.ge.si(gg).and.tmsk.le.se(gg)).or.tmsk.eq.12)
       else if(gg.eq.6) then
         indxx = ind(tmsk.lt.5.or.tmsk.gt.10)
       else
         indxx = ind(tmsk.ge.si(gg).and.tmsk.le.se(gg))
       end if
       end if

       rarr      = arr_rgrv(indxx,{rlats:rlatn},{rlonw:rlone})
       tarr      = arr_indv(indxx,{20:90},{0:360})

       tarr_CW   = SqrtCosWeight(tarr)
       tevecv    = eofunc_n(tarr_CW,4,75,0)
       tpcts     = eofunc_ts_n(tarr_CW,tevecv,False,0)
       
       latcheck  = (/ 85./)  ; make signs consistent if possible
       loncheck  = (/  5./)
       climmodes = vnm+ "_regon_"+(/"nam"/)

       do ff = 0,0

          pcts   = dim_standardize(tpcts(ff,:),0)
          rc     = regCoef_n(pcts, rarr, 0, 0) ; rc(nlat,mlon)

          tval   = onedtond(rc@tval , dimsizes(rc))
          df     = onedtond(rc@nptxy, dimsizes(rc)) - 2
          b      = tval    ; b must be same size as tval (and df)
          b      = 0.5

          foeof      = (/rc/)
          foeof!0    = "lat0"
          foeof!1    = "lon0"
          foeof&lat0 = rarr&lat
          foeof&lon0 = rarr&lon

          foprb      = foeof
          foprb      = betainc(df/(df+tval^2),df/2.0,b)       ; prob(nlat,nlon)

          ;coefficients of determination
          fpval      = foeof
          fpval      = (/escorc_n(pcts, rarr, 0, 0)/)
          fpval      = fpval*fpval * 100.0  ;variance explained (r-square)
          ;adjusted with freedom
          fpval      = 100.0 - (100.0-fpval) *((dimsizes(pcts)-1)/(dimsizes(pcts)-2))

          fieof = (/ regCoef_n(pcts,tarr,0,0) /)
          fieof!0   = "lat"
          fieof!1   = "lon"
          fieof&lat = tarr&lat
          fieof&lon = tarr&lon
          fieof@$(/"pcvar_seas"+(gg+1)/)$ = str_join(tostring(tevecv@pcvar),",")
          pcvar := str_split(fieof@$(/"pcvar_seas"+(gg+1)/)$,",")

         ;attempt to make all plots have the same sign
          if (.not.ismissing(fieof({latcheck(ff)},{loncheck(ff)}))) then    
            if (fieof({latcheck(ff)},{loncheck(ff)}).ge.0) then
               fieof(:,:) = fieof(:,:)*-1.
               foeof(:,:) = foeof(:,:)*-1.
               pcts(:)    = pcts(:)*-1
            end if
          end if

          if(gg.le.5) then
            pcts!0      = "tim3mo"
            pcts&tim3mo = arr_rgrv&time(indxx)
            pcts&tim3mo@units = arr_rgrv&time@units
            pcts&tim3mo@long_name = "time"
            pcts&tim3mo@standard_name = "time"
            pcts&tim3mo@calendar = "standard"
          else if(gg.le.7) then
            pcts!0      = "tim6mo"
            pcts&tim6mo = arr_rgrv&time(indxx)
            pcts&tim6mo@units = arr_rgrv&time@units
            pcts&tim6mo@long_name = "time"
            pcts&tim6mo@standard_name = "time"
            pcts&tim6mo@calendar = "standard"
          else
            pcts!0    = "time"
            pcts&time = arr_rgrv&time
            pcts&time@units = arr_rgrv&time@units
            pcts&time@long_name = "time"
            pcts&time@standard_name = "time"
            pcts&time@calendar = "standard"
          end if
          end if

          z->$(/climmodes(ff)+"_timeseries_"+changeCaseChar(seas(gg))/)$ \
            = set_varAtts(pcts(:),climmodes(ff)+" normalized principal component timeseries ("+seas(gg)+")","1","")
 
          foeof@units = rarr@units 
          foeof@pcvar = sprintf("%4.1f", tofloat(pcvar(ff)))+"%"

          z->$(/climmodes(ff)+"_pattern_"+changeCaseChar(seas(gg))/)$ \
            = set_varAtts(foeof,climmodes(ff)+" spatial pattern ("+seas(gg)+")","","")
          
          z->$(/climmodes(ff)+"_prob_"+changeCaseChar(seas(gg))/)$ \
            = set_varAtts(foprb,climmodes(ff)+" regression probability ("+seas(gg)+")","","")
 
          z->$(/climmodes(ff)+"_pval_"+changeCaseChar(seas(gg))/)$ \
            = set_varAtts(fpval,climmodes(ff)+" regression probability ("+seas(gg)+")","","")

          delete([/rc,pcts,tval,df,b,fieof,fpval,foeof,foprb/])
       end do
       delete([/rarr,tarr,tarr_CW,indxx,tevecv,tpcts/])
     end do     
     delete([/fnt,fnt2,z,arr_indv,arr_rgrv,tmsk/])
  end do

  delete([/modname,nyr,nsim,na,names,paths,syear,eyear,names_EM,EM_num/])

 end do ; end of var loop

 if (CREATE_GRAPHICS.eq."False") then
    print("Finished: nam.rgpatt.ncl")
    exit
 end if 

 do ss = 0, nsvars-1,1

  vnm   = namsfcvars(ss)
  if(namsfcvars(ss).eq."sst") then
    nsim = numAsciiRow("namelist_byvar/namelist_ts")
    na   = asciiread("namelist_byvar/namelist_ts",(/nsim/),"string")
  else
    nsim = numAsciiRow("namelist_byvar/namelist_"+vnm)
    na   = asciiread("namelist_byvar/namelist_"+vnm,(/nsim/),"string")
  end if
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

;========================================================================
  wks_type = OUTPUT_TYPE
  if (wks_type.eq."png") then
     wks_type@wkWidth = 1500*PNG_SCALE
     wks_type@wkHeight = 1500*PNG_SCALE
  end if

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
    res@mpGridAndLimbOn = False
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
  res@gsnLeftStringOrthogonalPosF = -0.03
  res@gsnLeftStringParallelPosF = .005
  res@gsnRightStringOrthogonalPosF = -0.06
  res@gsnRightStringParallelPosF = 0.96
  res@gsnLeftStringFontHeightF = 0.014
  res@gsnCenterStringFontHeightF = 0.018
  res@gsnRightStringFontHeightF = 0.014
  res@gsnLeftString = ""
  res@gsnCenterString = ""
  res@gsnRightString = ""

  res2 = res    ; spatial differences resource list

  tres = res    ; p-value plot resource list
  tres@cnFillMode      = "RasterFill"
 ;tres@lbBoxSizing     = "ExplicitSizing"
 ;tres@lbBoxFractions  = (/0.,.0833,.166,.25,.417,.583,.75,.834,.917,1./)
  tres@cnFillPalette   = "NCV_jaisnd" ;temp_diff_18lev" ;"precip2_17lev"
  tres@cnMissingValFillColor = "gray90"
  tres@lbTitleString   = "%"
  tres@gsnLeftString   = ""
  tres@gsnCenterString = "Regression variance explained (relative diff.)"
  tres@gsnRightString  = ""
  tres@cnLevels       := (/-60,-40,-20,-10,-5,5,10,20,40,60/) ;(/1,2,5,10,20,30,40,50,75,100/)

  res@cnLevels = fspan(-1,1,11)
  res2@cnLevels = fspan(-1,1,11)
 ;res@cnLevels  := (/-0.8,-0.6,-0.4,-0.2,-0.1,0,0.1,0.2,0.4,0.6,0.8/)
 ;res2@cnLevels := (/-0.8,-0.6,-0.4,-0.2,-0.1,0,0.1,0.2,0.4,0.6,0.8/)
  if (COLORMAP.eq.0) then
     res@cnFillPalette = "ncl_default"
     res2@cnFillPalette = "ncl_default"
  end if
  if (COLORMAP.eq.1) then
     res@cnFillPalette = "BlueDarkRed18"
     res2@cnFillPalette = "BlueDarkRed18"
  end if 

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
  panres2@gsnPanelLabelBar = False
  panres2@pmLabelBarHeightF = 0.05
  panres2@pmLabelBarWidthF = 0.3

  variname = (/"nam_pattern_djf","nam_pattern_jfm","nam_pattern_mam","nam_pattern_jja","nam_pattern_jas",\
               "nam_pattern_son","nam_pattern_ndjfma","nam_pattern_mjjaso","nam_pattern_ann"/)
  variname = vnm+ "_regon_"+ variname
  variname_title = variname
  variname_title_seas = variname
  do gg = 0,dimsizes(variname)-1
     txttt = str_split(variname(gg),"_")
     variname_title(gg) = changeCaseChar(txttt(0))+" Pattern" + " (" +str_upper(txttt(2))+")"
     variname_title_seas(gg) = changeCaseChar(txttt(4))
    ;variname_title_seas(gg) = "Monthly"
  end do 

  csubtitle_color = set_subtitle_colors(max(EM_num))
  nEM = max(EM_num)
  do dd = 0,dimsizes(variname)-1
     wks = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+"namregr")
     plot_indmem      = new(nsim,"graphic")
     plot_indmem_diff = new(nsim,"graphic")
     plot_summary     = new((nEM*4),"graphic")
     plot_summary_anno = new(nEM*4,"graphic")
     xy_anno = new(nEM*4,"graphic")

     numobs = num(EM_num.eq.0) 
     if (numobs.eq.0) then  ; if observations were not specified, set dummy file names, resulting in empty obs0 array
        fnt = getenv("OUTDIR")+"obs.cvdp_data.nam_regr."+syear(0)+"-"+eyear(0)+".nc"
        fnt2 = getenv("OUTDIR")+"obs.cvdp_data."+syear(0)+"-"+eyear(0)+".nc"
        cntr = 0
     else
        fnt = getenv("OUTDIR")+modname(0)+".cvdp_data.nam_regr."+syear(0)+"-"+eyear(0)+".nc"
        fnt2 = getenv("OUTDIR")+modname(0)+".cvdp_data."+syear(0)+"-"+eyear(0)+".nc"
        cntr = 1
     end if

     obs0 := read_cvdp_le_data(fnt,fnt2,variname(dd))
     obs0!0 = "lat"
     obs0!1 = "lon"

     vtmp      = str_sub_str(variname(dd),"pattern","pval")
     obspval  := read_cvdp_le_data(fnt,fnt2,vtmp)
     obspval!0 = "lat"
     obspval!1 = "lon"

     vtmp    = str_sub_str(variname(dd),"pattern","prob")
     obsp0  := read_cvdp_le_data(fnt,fnt2,vtmp)
     obsp0!0 = "lat"
     obsp0!1 = "lon"

     x1d = ndtooned(abs(obs0({rlats:rlatn},:)))
     xm  = dim_median(x1d)
     if(xm.gt.1) then
       sfcfacs= xm
     else if (xm.gt.0.1) then
       sfcfacs = 1.0
     else if (xm.gt.0.01) then
       sfcfacs = 0.1
     else if (xm.gt.0.001) then
       sfcfacs = 0.01
     end if
     end if
     end if
     end if
     delete([/xm,x1d/])

     sfcfacs = sfcfacs * 2.0

     res@cnLevels = res@cnLevels * sfcfacs
     res2@cnLevels = res2@cnLevels * sfcfacs
     res@gsnCenterStringFontColor = "black"
     res2@gsnCenterStringFontColor = "black"
     res@lbLabelBarOn = False
     res2@lbLabelBarOn = False
     tres@lbLabelBarOn = False
     res@gsnLeftString = syear(0)+"-"+eyear(0) 
     res@gsnRightString = obs0@pcvar
     res@gsnCenterString = names(0)    
     plot_indmem(0) = gsn_csm_contour_map(wks,obs0,res)
     cntr_EM = 0
     if (numobs.ge.2) then     ; plot obs #2-
        do ff = 1,numobs-1
           fnt = getenv("OUTDIR")+modname(cntr)+".cvdp_data.nam_regr."+syear(cntr)+"-"+eyear(cntr)+".nc"
           fnt2 = getenv("OUTDIR")+modname(cntr)+".cvdp_data."+syear(cntr)+"-"+eyear(cntr)+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,variname(dd))
           arr!0 = "lat"
           arr!1 = "lon"

           vtmp      = str_sub_str(variname(dd),"pattern","pval")
           arrpval  := read_cvdp_le_data(fnt,fnt2,vtmp)
           arrpval!0 = "lat"
           arrpval!1 = "lon"

           vtmp    = str_sub_str(variname(dd),"pattern","prob")
           arrp0  := read_cvdp_le_data(fnt,fnt2,vtmp)
           arrp0!0 = "lat"
           arrp0!1 = "lon"

           if (isatt(arr,"is_all_missing")) then 
              cntr = cntr+1
              continue
           end if
           obs0_rg = linint2_Wrap(obs0&lon,obs0&lat,obs0,True,arr&lon,arr&lat,0)
           obs_diff = arr
           obs_diff = (/ arr - obs0_rg /)
           obsp0_rg = linint2_Wrap(obsp0&lon,obsp0&lat,obs0,True,arrp0&lon,arrp0&lat,0)
           obs_diff = mask(obs_diff, obsp0_rg.le.0.1, False)

           res@gsnLeftString = syear(cntr)+"-"+eyear(cntr) 
           res@gsnRightString = arr@pcvar+"~C~   r="+pattern_correlation(obs0_rg({20:},:),arr({20:},:))
           res@gsnCenterString = names(cntr)   
           plot_indmem(cntr) = gsn_csm_contour_map(wks,arr,res)
           res2@gsnLeftString = ""  
           res2@gsnRightString = "" 
           res2@gsnCenterString = names(cntr)+"-"+names(0)
           plot_indmem_diff(cntr) = gsn_csm_contour_map(wks,obs_diff,res2)
           delete([/arr,arrp0,obs_diff,obs0_rg, arrpval/])
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

           fnt = getenv("OUTDIR")+modname_mod+".cvdp_data.nam_regr."+syear_mod+"-"+eyear_mod+".nc"
           fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,variname(dd))
           arr!0 = "lat"
           arr!1 = "lon"

           vtmp    = str_sub_str(variname(dd),"pattern","prob")
           arrp0  := read_cvdp_le_data(fnt,fnt2,vtmp)
           arrp0!0 = "lat"
           arrp0!1 = "lon"

           vtmp      = str_sub_str(variname(dd),"pattern","pval")
           arrpval  := read_cvdp_le_data(fnt,fnt2,vtmp)
           arrpval!0 = "lat"
           arrpval!1 = "lon"

           if (isatt(arr,"is_all_missing")) then 
              cntr = cntr+1
              continue
           end if
           if (.not.isvar("arr_store")) then  ; create an array to house all members, to be used to calculate EM
              arr_store = new((/nens,dimsizes(arr&lat),dimsizes(arr&lon)/),typeof(arr))
              arr_store!0 = "ensmem"
              arr_store!1 = "lat"
              arr_store&lat = arr&lat
              arr_store!2 = "lon"
              arr_store&lon = arr&lon
              arr_store@nens = 0
              copy_VarAtts(arr,arr_store)
              arr_store_pcvar = new(nens,float)
              arr_store_pval  = arr_store
              syear_em0 = syear_mod
              eyear_em0 = eyear_mod
              showyr = True
           end if
           if (showyr) then
              if (syear_em0.ne.syear_mod.or.eyear_em0.ne.eyear_mod.and.showyr) then
                 showyr = False
              end if
           end if
           res@gsnCenterStringFontColor = csubtitle_color(gg-1)
           res2@gsnCenterStringFontColor = csubtitle_color(gg-1)

           arr_store(hh,:,:) = (/ arr /)
           arr_store@nens = arr_store@nens+1
           arr_store_pcvar(hh) = (/ tofloat(arr@pcvar) /)
           arr_store_pval(hh,:,:) = (/ arrpval /)
           arr_store_pval@nens = arr_store_pval@nens+1
           panres@lbTitleString = arr@units

           if (.not.isvar("obs0_rg")) then  
              obs0_rg = linint2_Wrap(obs0&lon,obs0&lat,obs0,True,arr&lon,arr&lat,0)
           end if
           if (.not.isvar("obsp0_rg")) then
              obsp0_rg = linint2_Wrap(obsp0&lon,obsp0&lat,obsp0,True,arrp0&lon,arrp0&lat,0)
           end if
           if (.not.isvar("obspval_rg")) then
              obspval_rg = linint2_Wrap(obspval&lon,obspval&lat,obspval,True,arrpval&lon,arrpval&lat,0)
           end if
           obs_diff = arr
           obs_diff = (/ arr - obs0_rg /)
           obs_diff = mask(obs_diff, obsp0_rg.le.0.1,False)

           res@gsnLeftString = syear_mod+"-"+eyear_mod
           res@gsnRightString = arr@pcvar+"~C~   r="+pattern_correlation(obs0_rg({20:},:),arr({20:},:))
           res@gsnCenterString = names_mod
           plot_indmem(cntr) = gsn_csm_contour_map(wks,arr,res)
           res2@gsnLeftString = "" 
           res2@gsnRightString = ""  
           res2@gsnCenterString = names_mod+"-"+names(0)  
           plot_indmem_diff(cntr) = gsn_csm_contour_map(wks,obs_diff,res2)
           delete([/arr,obs_diff,arrpval,arrp0/])
           cntr = cntr+1
        end do
        if (.not.isvar("arr_store")) then
           cntr_EM = cntr_EM+4
           continue
        end if
        if (lbFlag) then
           res@lbLabelBarOn = True
           res2@lbLabelBarOn = True
           tres@lbLabelBarOn = True
        end if
        arr_EM = dim_avg_n_Wrap(arr_store,0)

        res@lbTitleString = arr_EM@units
        res2@lbTitleString = arr_EM@units

        res@gsnCenterStringFontColor = "black"
        res2@gsnCenterStringFontColor = "black"

        res@gsnLeftString = syear(0)+"-"+eyear(0) 
        res@gsnRightString = decimalPlaces(tofloat(obs0@pcvar),0,True)+"%"
        res@gsnCenterString = "Observations ("+names(0)+")"    
        plot_summary(cntr_EM+1) = gsn_csm_contour_map(wks,obs0,res)

        if (showyr) then
           res@gsnLeftString = syear_em0+"-"+eyear_em0 
        else
           res@gsnLeftString = (eyear_em0-syear_em0+1)+"yrs" 
        end if
        res@gsnCenterStringFontColor = csubtitle_color(gg-1)
        delete([/syear_em0,eyear_em0,showyr/])

        if(.not.all(ismissing(arr_store_pcvar))) then
          stats := boxplot_stat(arr_store_pcvar)
          res@gsnRightString = decimalPlaces(stats(0),0,True)+"/"\
                              + decimalPlaces(avg(arr_store_pcvar),0,True)+"/"\
                              + decimalPlaces(stats(4),0,True)+"%~C~       r=" \
                              + pattern_correlation(arr_EM({20:},:),obs0_rg({20:},:))
        else
          stats := boxplot_stat(arr_store_pcvar)
          res@gsnRightString = "-999/-999/-999"+"%~C~       r=" \
                              + pattern_correlation(arr_EM({20:},:),obs0_rg({20:},:))
        end if
        res@gsnCenterString = names_EM_mod +" ("+arr_store@nens+" Members)"                   
        plot_summary(cntr_EM) = gsn_csm_contour_map(wks,arr_EM,res)
        ares@gsLineColor = res@gsnCenterStringFontColor
        if (isatt(obs0,"pcvar")) then
           ares@obsval = obs0@pcvar
        end if
        plot_summary_anno(cntr_EM) = add_xy_plot(wks,arr_store_pcvar,ares)
        xy_anno(cntr_EM) = gsn_add_annotation(plot_summary(cntr_EM),plot_summary_anno(cntr_EM),amres)

        obs_diff = arr_EM
        obs_diff = (/ arr_EM - obs0_rg /)
        res2@gsnLeftString = ""
        res2@gsnCenterString = names_EM_mod+" - Observations"   
        res2@gsnRightString = "" 
        plot_summary(cntr_EM+2) = gsn_csm_contour_map(wks,obs_diff,res2)

        arr_pval_EM = dim_avg_n_Wrap(arr_store_pval,0) ; variance explained
        arr_pval_EM = arr_pval_EM - obspval_rg
        obspval_tmp = obspval_rg
        obspval_tmp = abs(arr_pval_EM - obspval_rg)
        ;arr_pval_EM = (arr_pval_EM/obspval_tmp) - 1.0
        ;arr_pval_EM = where(obspval_rg.eq.0,1,arr_pval_EM)
        ;arr_pval_EM = where(arr_pval_EM.le.-1,-1.0,arr_pval_EM)
        ;arr_pval_EM = where(arr_pval_EM.ge. 1, 1.0,arr_pval_EM)
        ;arr_pval_EM = arr_pval_EM * 100.0
        tres@gsnRightString = calculate_area_in_range(obspval_tmp({20:},:),10,100)+"%"
        plot_summary(cntr_EM+3) = gsn_csm_contour_map(wks,arr_pval_EM,tres)

        fno = getenv("OUTDIR")+str_sub_str(names_EM_mod," ","_")+"_EM.cvdp_data.nam_regr."+syear_mod+"-"+eyear_mod+".nc"
        if (isfilepresent2(fno)) then
           z = addfile(fno,"w")
        else
           z = addfile(fno,"c")
           set_global_ncfile_attributes(z,names_EM_mod,syear_mod,eyear_mod,getenv("VERSION"))
        end if
        z->$(/variname(dd)+"_em"/)$         = set_varAtts(arr_EM,arr_EM@long_name+" Ensemble Mean","","")
        z->$(/variname(dd)+"_em_diffobs"/)$ = set_varAtts(obs_diff,obs_diff@long_name+" Ensemble Mean difference from observations","","")           
        z->$(/variname(dd)+"_pval"/)$       = set_varAtts(arr_pval_EM,arr_EM@long_name+" variance explained statistic","%","")
        delete([/arr_pval_EM,arr_store,arr_store_pval,obs0_rg,z,obs_diff,arr_EM,arr_store_pcvar,obspval_tmp,obspval_rg/])
        cntr_EM = cntr_EM+4
     end do
     panres@txString = variname_title(dd)+" ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_indmem,(/nrow,ncol/),panres)

     panres@txString = variname_title(dd)+" Differences ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_indmem_diff,(/nrow,ncol/),panres)

     panres2@txString = "Ensemble Summary: "+variname_title(dd)+" ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_summary,(/nEM,4/),panres2)
     delete(wks)

     if (wks_type.eq."png") then
        system("mv "+OUTDIR+vnm+"namregr.000001.png "+OUTDIR+variname(dd)+".indmem.png")
        system("mv "+OUTDIR+vnm+"namregr.000002.png "+OUTDIR+variname(dd)+".indmemdiff.png")
        system("mv "+OUTDIR+vnm+"namregr.000003.png "+OUTDIR+variname(dd)+".summary.png")
        if (PNG_SCALE_SUMMARY.ne.100) then
           system("convert -resize "+PNG_SCALE_SUMMARY+"% "+OUTDIR+variname(dd)+".summary.png "+OUTDIR+variname(dd)+".summary.png")
        end if
     else
        system("psplit "+OUTDIR+vnm+"namregr.ps "+OUTDIR+vnm+"namregr")
        system("mv "+OUTDIR+vnm+"namregr0001.ps "+OUTDIR+variname(dd)+".indmem.ps")
        system("mv "+OUTDIR+vnm+"namregr0002.ps "+OUTDIR+variname(dd)+".indmemdiff.ps")
        system("mv "+OUTDIR+vnm+"namregr0003.ps "+OUTDIR+variname(dd)+".summary.ps")
        system("rm "+OUTDIR+vnm+"namregr.ps")
     end if
  end do
  delete([/panres,panres2/])
;---Timeseries plotting section--------------------------------------------------------------------------------------------
  xyres = True    ; individual obs/model line plot resource list
  xyres@gsnDraw = False
  xyres@gsnFrame = False
  xyres@gsnYRefLine = 0.0
  xyres@gsnYRefLineColor = "gray42"
     
  if (wks_type.eq."png") then
     xyres@xyLineThicknessF = 4.
  else
     xyres@xyLineThicknessF = 2.
  end if
  xyres@xyLineColor = "royalblue"
  xyres@tiYAxisString = ""
  xyres@tmXBLabelFontHeightF = 0.015
  xyres@tmYLLabelFontHeightF = 0.015
  xyres@gsnLeftStringFontHeightF = 0.0175     
  xyres@gsnCenterStringFontHeightF = 0.0135     
  xyres@gsnRightStringFontHeightF = xyres@gsnCenterStringFontHeightF  
  xyres@gsnLeftStringOrthogonalPosF = 0.025
  xyres@gsnCenterStringOrthogonalPosF = -1.0
  xyres@gsnCenterStringParallelPosF = 0.05
  xyres@gsnRightStringOrthogonalPosF = xyres@gsnLeftStringOrthogonalPosF
  xyres@vpHeightF = 0.25
  xyres@vpWidthF = 0.7
  xyres@gsnLeftString = ""     
  xyres@gsnCenterString = ""
  xyres@gsnRightString = ""
     
  xyres2 = xyres     ; for observational line overlays in individual panels
  xyres2@xyLineColor = "gray60"
  xyres2@xyCurveDrawOrder = "PreDraw"

  xyres_sum = xyres
  xyres_sum@xyLineColor        = "dodgerblue2"
  xyres_sum@gsnCenterStringFontColor = "black"

  xyres2_sum = xyres2   ; for observational line overlays in ensemble panels

  if (wks_type.eq."png") then
     xyres_sum@xyLineThicknessF = 16.
     xyres2_sum@xyLineThicknessF = 16.
  else
     xyres_sum@xyLineThicknessF = 3.
     xyres2_sum@xyLineThicknessF = 3.
  end if

  xyres2A = xyres2   ; for observational line overlays in ensemble mean summary
  xyres2A@xyLineThicknessF = xyres_sum@xyLineThicknessF

  xyres_sumA = xyres   ; for summary ensemble mean line plot
  xyres_sumA@xyLineThicknessF = xyres_sum@xyLineThicknessF  

  xyres3_sum = xyres_sum   ; resource list for shaded 2 std dev range
  xyres3_sum@gsnXYFillColors = (/30/356.,144/256.,1.,0.25/)  ;"dodgerblue"
  xyres3_sum@xyLineColors        := (/"transparent","transparent"/)       
  xyres3_sum@xyDashPattern      = 0
  xyres3_sum@xyLineColor = "transparent"
  xyres3_sum@gsnRightStringFontColor = "black"

  xyres3b_sum = xyres3_sum   ; resource list for shaded 1 std dev range
  xyres3b_sum@gsnXYFillColors = (/30/356.,144/256.,1.,0.5/)  ;"dodgerblue"

  panres3 = True  ; panel resource list for individual member plots
  panres3@gsnMaximize = True  
  panres3@gsnPaperOrientation = "portrait"
  panres3@gsnMainPanelFontHeightF = 0.016
  panres3@gsnPanelBottom = 0.05
  panres3@gsnPanelYWhiteSpacePercent = 2.5

  panres4 = panres3  ; panel resource list for ensemble plots
  panres4@gsnMainPanelFontHeightF = 0.014
  panres4@gsnMaximize = False
  panres4@gsnFrame = False
  panres4@gsnPanelTop = 0.94
  panres4@gsnPanelXWhiteSpacePercent = 3.0
  panres4@gsnPanelYWhiteSpacePercent = 3.0

  txres = True
  txres@txFontHeightF = 0.010
  txres@txFontColor = xyres2@xyLineColor

  ncolE = floattointeger(sqrt(nEM+1))   ; +1 for the summary plot
  nrowE = ((nEM+1)/ncolE)+mod(nEM+1,ncolE)
  variname := (/"nam_timeseries_djf","nam_timeseries_jfm","nam_timeseries_mam","nam_timeseries_jja","nam_timeseries_jas",\
                "nam_timeseries_son","nam_timeseries_ndjfma","nam_timeseries_mjjaso","nam_timeseries_ann"/)
  variname = vnm + "_regon_" + variname 
  variname_title := variname
  variname_title_seas := variname
  do gg = 0,dimsizes(variname)-1
     txttt = str_split(variname(gg),"_")
     variname_title(gg) = changeCaseChar(txttt(0))+" Timeseries" + " (" + str_upper(txttt(2))+")"
     variname_title_seas(gg) = changeCaseChar(txttt(4))
    ;variname_title_seas(gg) = "Monthly"
  end do 

  do dd = 0,dimsizes(variname)-1
     wks = gsn_open_wks(wks_type,getenv("OUTDIR")+vnm+"namregr.timeseries")
     plot_indmem      := new(nsim,"graphic")   ; for individual obs/models
     plot_obs_overlay := new(nsim,"graphic")   ; for obs overlaid onto individual models
     plot_summary     := new(nEM,"graphic")    ; for ensemble plots  to show the 2 std dev range
     plot_summary1    := new(nEM,"graphic")    ; for ensemble plots to show the 1 std dev range
     plot_summary2    := new(nEM,"graphic")    ; for ensemble plots to show the ensemble mean
     plot_summary_obs_overlay := new(nEM,"graphic")  ; for ensemble plots to show overlaid obs
     plot_sum         := new(nEM,"graphic")    ; for individual panel in ensemble plots showing each ensemble mean
     plot_sum2        := new(nEM,"graphic")    ; for individual panel in ensemble plots showing each ensemble 10-90% range     

     XMinF := new(1,double)    ; used for summary timeseries plot showing all ensemble means
     XMaxF := new(1,double)
     YMinF := new(1,double)
     YMaxF := new(1,double)

     numobs = num(EM_num.eq.0) 
     if (numobs.eq.0) then
        fnt = getenv("OUTDIR")+"obs.cvdp_data.nam_regr."+syear(0)+"-"+eyear(0)+".nc"
        fnt2 = getenv("OUTDIR")+"obs.cvdp_data."+syear(0)+"-"+eyear(0)+".nc"
        cntr = 0
     else
        fnt = getenv("OUTDIR")+modname(0)+".cvdp_data.nam_regr."+syear(0)+"-"+eyear(0)+".nc"
        fnt2 = getenv("OUTDIR")+modname(0)+".cvdp_data."+syear(0)+"-"+eyear(0)+".nc"
        cntr = 1
     end if
     obs0 := read_cvdp_le_data(fnt,fnt2,variname(dd))
     obs0!0 = "time"

     TTIME = cd_calendar(obs0&time, -1)
     yyyyFrac = yyyymm_to_yyyyfrac(TTIME, 0.0)
     delete(TTIME)
    
     if (isatt(obs0,"is_all_missing")) then
       obs0   := yyyyFrac 
       obs0!0  = "time"
       obs0&time = yyyyFrac 
     end if 

     xyres@gsnLeftStringFontColor = "black"
     xyres2@gsnLeftStringFontColor = "black"
     if (isatt(xyres,"trYMinF")) then
        delete([/xyres@trYMinF,xyres@trYMaxF/])
     end if
     xyres@trXMinF = syear(0)-.5
     xyres@trXMaxF = eyear(0)+0.5
     xyres@gsnLeftString = names(0)
     if (all(ismissing(obs0))) then
        obs_val = "Insufficient Coverage"
        ztxt = ""
     else
        ztxt = "Linear trend = "
        tttt := dtrend_msg(ispan(0,dimsizes(obs0&time)-1,1),obs0,False,True)   
        obs_val := decimalPlaces(tttt@slope*dimsizes(obs0&time),2,True) +" "+nyr(0)+"yr~S~-1~N~" ;+obs0@units+" "+nyr(0)+"yr~S~-1~N~"
     end if
     xyres@gsnRightString = obs_val
     plot_indmem(0) = gsn_csm_xy(wks,yyyyFrac,obs0,xyres)
     xyres2A@gsnLeftString = "Ensemble Mean Summary"
     plot_obs := gsn_csm_xy(wks,yyyyFrac,obs0,xyres2A)
     cntr_EM = 0
     if (numobs.ge.2) then     ; plot obs #2-
        do ff = 1,numobs-1
           fnt = getenv("OUTDIR")+modname(cntr)+".cvdp_data.nam_regr."+syear(cntr)+"-"+eyear(cntr)+".nc"
           fnt2 = getenv("OUTDIR")+modname(cntr)+".cvdp_data."+syear(cntr)+"-"+eyear(cntr)+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,variname(dd))
           arr!0 = "time"
           if (isatt(arr,"is_all_missing")) then 
              cntr = cntr+1
              continue
           end if
           xyres@trXMinF = syear(cntr)-.5
           xyres@trXMaxF = eyear(cntr)+0.5
           xyres@trYMinF = min((/min(obs0),min(arr)/))-dim_stddev(arr)/2.
           xyres@trYMaxF = max((/max(obs0),max(arr)/))+dim_stddev(arr)/2.
           tttt := dtrend_msg(ispan(0,dimsizes(arr&time)-1,1),arr,False,True)   
           xyres@gsnLeftString = names(cntr)
           xyres@gsnRightString = decimalPlaces(tttt@slope*dimsizes(arr&time),2,True)+" "+nyr(cntr)+"yr~S~-1~N~"
           plot_indmem(cntr) = gsn_csm_xy(wks,yyyyFrac,arr,xyres)
           plot_obs_overlay(cntr) = gsn_csm_xy(wks,yyyyFrac,obs0,xyres2)
           overlay(plot_indmem(cntr),plot_obs_overlay(cntr))
           delete([/arr,tttt/])
           cntr = cntr+1
        end do
     end if
     do gg = 1,nEM   ; operate on each ensemble mean
        nens = num(EM_num.eq.gg) ; determines how many model simulations in each ensemble
        cntr_ens := ind(EM_num.eq.gg)   ; cntr_ens(hh) are the indices where each ensemble member of an ensemble reside 

        do hh = 0,nens-1
           modname_mod = modname(cntr_ens(hh))
           syear_mod = syear(cntr_ens(hh))
           eyear_mod = eyear(cntr_ens(hh))
           names_mod = names(cntr_ens(hh))
           names_EM_mod = names_EM(cntr_ens(hh))

           fnt = getenv("OUTDIR")+modname_mod+".cvdp_data.nam_regr."+syear_mod+"-"+eyear_mod+".nc"
           fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
           arr := read_cvdp_le_data(fnt,fnt2,variname(dd))
           arr!0 = "time"
           if (isatt(arr,"is_all_missing")) then 
              cntr = cntr+1
              continue
           end if

           TTIME     = cd_calendar(arr&time, -1)
           yyyyFrac0 = yyyymm_to_yyyyfrac(TTIME, 0.0)
           delete(TTIME)

           if (.not.isvar("arr_store")) then  ; create an array to house all members, to be used to calculate EM
              arr_store := new((/nens,dimsizes(arr&time)/),typeof(arr))
              arr_store!0 = "ensmem"
              arr_store!1 = "time"
              arr_store&time = arr&time
              arr_store@nens = 0
              copy_VarAtts(arr,arr_store)
              syear_em0 = syear_mod
              eyear_em0 = eyear_mod
              showyr = True
           end if
           if (showyr) then
              if (syear_em0.ne.syear_mod.or.eyear_em0.ne.eyear_mod.and.showyr) then
                 showyr = False
              end if
           end if
           arr_store(hh,:) = (/ arr /)
           arr_store@nens = arr_store@nens+1
           xyres@gsnLeftStringFontColor = csubtitle_color(gg-1)
           xyres2@gsnLeftStringFontColor = csubtitle_color(gg-1)
           xyres@trXMinF = syear_mod-.5
           xyres@trXMaxF = eyear_mod+0.5
           xyres@trYMinF = min((/min(obs0),min(arr)/))-dim_stddev(arr)/2.
           xyres@trYMaxF = max((/max(obs0),max(arr)/))+dim_stddev(arr)/2.
           tttt := dtrend_msg(ispan(0,dimsizes(arr&time)-1,1),arr,False,True)   
           xyres@gsnLeftString = names_mod
           xyres@gsnRightString = decimalPlaces(tttt@slope*dimsizes(arr&time),2,True)+" "+nyr(cntr)+"yr~S~-1~N~"
           plot_indmem(cntr) = gsn_csm_xy(wks,yyyyFrac,arr,xyres)
           plot_obs_overlay(cntr) = gsn_csm_xy(wks,yyyyFrac,obs0,xyres2)
           overlay(plot_indmem(cntr),plot_obs_overlay(cntr))
           delete([/arr,tttt/])
           cntr = cntr+1
        end do
        if (.not.isvar("arr_store")) then
           cntr_EM = cntr_EM+1
           continue
        end if
        arr_EM := dim_avg_n_Wrap(arr_store,0)
        arr_range1 := define_arr_range_array(arr_EM,1)
        arr_range2 := define_arr_range_array(arr_EM,2)
        do zz = 0,dimsizes(arr_EM)-1
           ds := boxplot_stat(arr_store(:,zz))
           arr_range1(0,zz) = (/ ds(1) /)
           arr_range1(1,zz) = (/ ds(3) /)
           arr_range2(0,zz) = (/ ds(0) /)
           arr_range2(1,zz) = (/ ds(4) /)
        end do

        xyres3_sum@trXMinF := min(arr_EM&time)-.5
        xyres3_sum@trXMaxF := max(arr_EM&time)+0.5
        xyres3_sum@trYMinF = (/ min((/min(arr_EM),min(obs0),min(arr_range2)/))-dim_stddev(arr_EM)/2. /)
        xyres3_sum@trYMaxF = (/ max((/max(arr_EM),max(obs0),max(arr_range2)/))+dim_stddev(arr_EM)/2. /)

        XMinF = min((/XMinF,min(arr_EM&time)/))
        XMaxF = max((/XMaxF,max(arr_EM&time)/))
        YMinF = min((/YMinF,min(arr_EM),min(obs0)/))
        YMaxF = max((/YMaxF,max(arr_EM),max(obs0)/))

        ssss := dtrend_msg(ispan(0,dimsizes(arr_store&time)-1,1),arr_store,False,True)
        tttt := dtrend_msg(ispan(0,dimsizes(arr_EM&time)-1,1),arr_EM,False,True)  
        xyres3_sum@gsnXYFillColors = (/30/356.,144/256.,1.,0.25/)  ;"dodgerblue"
        xyres3b_sum@gsnXYFillColors = (/30/356.,144/256.,1.,0.5/)  ;"dodgerblue"
        if (all(ismissing(arr_range2(0,:)))) then  ; necessary as gsnXYFillColors causes NCL to fail when data all missing
           delete(xyres3_sum@gsnXYFillColors)
           delete(xyres3b_sum@gsnXYFillColors)
        end if
        xyres_sum@gsnLeftString = names_EM_mod +" ("+arr_store@nens+" Members)"   
        xyres_sum@gsnLeftStringFontColor = csubtitle_color(gg-1)
        xyres_sumA@xyLineColor = csubtitle_color(gg-1)
        xyres_sum@gsnCenterString = calculate_percent_in_range(obs0,arr_range2)+"%"
        ss_slope := ssss@slope
        ss_slope@_FillValue = arr_store@_FillValue
        stats := boxplot_stat(ss_slope)
        xyres3_sum@gsnRightString = decimalPlaces(stats(0)*dimsizes(arr_EM),2,True)+"/"+decimalPlaces(tttt@slope*dimsizes(arr_EM),2,True)+"/"+decimalPlaces(stats(4)*dimsizes(arr_EM),2,True)+" "+(max(arr_EM&time)-min(arr_EM&time)+1)+"yr~S~-1~N~"
        plot_summary(cntr_EM) = gsn_csm_xy(wks,yyyyFrac0,arr_range2,xyres3_sum)
        plot_summary1(cntr_EM) = gsn_csm_xy(wks,yyyyFrac0,arr_range1,xyres3b_sum)
        plot_summary2(cntr_EM) = gsn_csm_xy(wks,yyyyFrac0,arr_EM,xyres_sum)
        plot_summary_obs_overlay(cntr_EM) = gsn_csm_xy(wks,yyyyFrac,obs0,xyres2_sum)
        plot_sum(cntr_EM) = gsn_csm_xy(wks,yyyyFrac0,arr_EM,xyres_sumA)
        overlay(plot_summary(cntr_EM),plot_summary1(cntr_EM))
        overlay(plot_summary(cntr_EM),plot_summary_obs_overlay(cntr_EM))
        overlay(plot_summary(cntr_EM),plot_summary2(cntr_EM))
                                                                
        fout = getenv("OUTDIR")+str_sub_str(names_EM_mod," ","_")+"_EM.cvdp_data.nam_regr."+syear_mod+"-"+eyear_mod+".nc"
        if (isfilepresent2(fout)) then
           z = addfile(fout,"w")
        else
           z = addfile(fout,"c")
           set_global_ncfile_attributes(z,names_EM_mod,syear_mod,eyear_mod,getenv("VERSION"))
        end if
        if(dd.le.5) then
          arr_EM!0 = "tim3mo"
          arr_range1!1 = "tim3mo"
          arr_range2!1 = "tim3mo"
        else if(dd.le.7) then
          arr_EM!0 = "tim6mo"
          arr_range1!1 = "tim6mo"
          arr_range2!1 = "tim6mo"
        else
          arr_EM!0 = "time"
          arr_range1!1 = "time"
          arr_range2!1 = "time"
        end if
        end if
       ;arr_EM!0 = "TIME"
       ;arr_range1!1 = "TIME"        
       ;arr_range2!1 = "TIME"
        z->$(/variname(dd)+"_em"/)$ = set_varAtts(arr_EM,arr_EM@long_name+" Ensemble Mean","","")
        z->$(/variname(dd)+"_2575range"/)$ = set_varAtts(arr_range1,arr_EM@long_name+" 25/75% range","","")
        z->$(/variname(dd)+"_1090range"/)$ = set_varAtts(arr_range2,arr_EM@long_name+" 10/90% range","","")
        delete([/z,tttt,ssss,arr_store,arr_EM,arr_range1,arr_range2/])
        cntr_EM = cntr_EM+1
     end do
     panres3@txString = variname_title(dd)+" ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_indmem,(/nrow,ncol/),panres3)

     YMinF = YMinF - ((YMaxF - YMinF)*.05)
     YMaxF = YMaxF + ((YMaxF - YMinF)*.05)
     plot_final := new(nEM+1,graphic)
     plot_final(:nEM-1) = plot_summary
     ii_ind := id_firstvalid_ind(plot_sum)
     if (.not.ismissing(ii_ind)) then
        if (.not.ismissing(plot_obs)) then
           overlay(plot_sum(ii_ind),plot_obs)
        end if
        do ii = ii_ind,nEM-1 
           if (.not.ismissing(plot_sum(ii)).and.ii.ne.ii_ind) then
              overlay(plot_sum(ii_ind),plot_sum(ii))
           end if
        end do     
        setvalues plot_sum(ii_ind)
           "trXMinF" : XMinF-0.5
           "trXMaxF" : XMaxF+0.5
           "trYMinF" : YMinF
           "trYMaxF" : YMaxF
        end setvalues
        plot_final(nEM)    = plot_sum(ii_ind)
     end if
     panres4@gsnPanelMainPosYF = set_panel_title_YF(nEM+1,xyres)
     panres4@gsnPanelMainString = "Ensemble Summary: "+variname_title(dd)+" ("+variname_title_seas(dd)+")"
     gsn_panel2(wks,plot_final,(/nrowE,ncolE/),panres4)
     if (numobs.ne.0) then  
        gsn_text_ndc(wks,names(0)+" "+syear(0)+"-"+eyear(0)+", "+ztxt+obs_val,0.5,panres4@gsnPanelMainPosYF-.025,txres)
     end if
     frame(wks)
     delete(wks)
     delete(yyyyFrac)
     delete(yyyyFrac0)

     if (wks_type.eq."png") then
        system("mv "+OUTDIR+vnm+"namregr.timeseries.000001.png "+OUTDIR+variname(dd)+".indmem.png")
        system("mv "+OUTDIR+vnm+"namregr.timeseries.000002.png "+OUTDIR+variname(dd)+".summary.png")
        if (PNG_SCALE_SUMMARY.ne.100) then
           system("convert -resize "+PNG_SCALE_SUMMARY+"% "+OUTDIR+variname(dd)+".summary.png "+OUTDIR+variname(dd)+".summary.png")
        end if
     else
        system("psplit "+OUTDIR+vnm+"namregr.timeseries.ps "+OUTDIR+vnm+"namregr.timeseries")
        system("mv "+OUTDIR+vnm+"namregr.timeseries0001.ps "+OUTDIR+variname(dd)+".indmem.ps")
        system("mv "+OUTDIR+vnm+"namregr.timeseries0002.ps "+OUTDIR+variname(dd)+".summary.ps")
        system("rm "+OUTDIR+vnm+"namregr.timeseries.ps")
     end if
  end do

  delete([/modname,nyr,nsim,na,names,paths,syear,eyear,names_EM,EM_num,delim/])

 end do ; end of var loop

 print("Finished: nam.rgpatt.ncl")

end



