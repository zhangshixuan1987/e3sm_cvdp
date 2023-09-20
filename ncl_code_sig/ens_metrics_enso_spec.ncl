; This script calculates various metrics scores. 
;
load "$CVDP_SCRIPTS/functions.ncl"

begin

  print("Starting: ens_metrics_enso_spec.ncl")
  OUTDIR = getenv("OUTDIR")  
  OBS = getenv("OBS")

  SCALE_TIMESERIES = getenv("SCALE_TIMESERIES")
  OUTPUT_DATA      = getenv("OUTPUT_DATA")
  PNG_SCALE        = tofloat(getenv("PNG_SCALE"))
  OPT_CLIMO        = getenv("OPT_CLIMO")
  CLIMO_SYEAR      = toint(getenv("CLIMO_SYEAR"))
  CLIMO_EYEAR      = toint(getenv("CLIMO_EYEAR"))
  OUTPUT_TYPE      = getenv("OUTPUT_TYPE")
  COLORMAP         = getenv("COLORMAP")

  if (OBS.eq."False") then
    print("ens_metrics_enso_spec.ncl: Observations not present.")
    print("Exiting: ens_metrics_enso_spec.ncl")    
  end if

  nclver = stringtochar(get_ncl_version())   ; check NCL version to turn off error messages
  num0 = toint(tostring(nclver(0)))    
  num1 = toint(tostring(nclver(2)))
  errmsg = True
  if (num0.le.5) then
     errmsg = False
  end if
  if (num0.eq.6) then
     if (num1.le.4) then
        errmsg = False
     else
        errmsg = True
     end if
  end if  
  if (num0.ge.7) then
     errmsg = True
  end if
  delete([/num0,num1/])

;---------------------
  nsim  = numAsciiRow("namelist_byvar/namelist_ts")
  na    = asciiread("namelist_byvar/namelist_ts",(/nsim/),"string")
  names = new(nsim,"string")
  syear = new(nsim,"integer",-999)
  eyear = new(nsim,"integer",-999)
  names_EM = new(nsim,"string")
  EM_num = new(nsim,"integer",-999)
  delim = "|"

  do ee = 0,nsim-1
     names(ee) = str_strip(str_get_field(na(ee),1,delim))
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

  nsim_tas = numAsciiRow("namelist_byvar/namelist_trefht")
  na_tas = asciiread("namelist_byvar/namelist_trefht",(/nsim_tas/),"string")
  names_tas = new(nsim_tas,"string")
  paths_tas = new(nsim_tas,"string")
  syear_tas = new(nsim_tas,"integer",-999)
  eyear_tas = new(nsim_tas,"integer",-999)
  do gg = 0,nsim_tas-1
     names_tas(gg) = str_strip(str_get_field(na_tas(gg),1,delim))
     paths_tas(gg) = str_strip(str_get_field(na_tas(gg),2,delim))
     syear_tas(gg) = stringtointeger(str_strip(str_get_field(na_tas(gg),3,delim)))
     eyear_tas(gg) = stringtointeger(str_strip(str_get_field(na_tas(gg),4,delim)))
  end do
  modname_tas = str_sub_str(names_tas," ","_")
  do ff = 0,dimsizes(modname_tas)-1
     do gg = 0,dimsizes(bc)-1
        modname_tas(ff) = str_sub_str(modname_tas(ff),bc(gg),"_")
     end do
  end do
  delete(na_tas)

  nsim_pr = numAsciiRow("namelist_byvar/namelist_prect")
  na_pr = asciiread("namelist_byvar/namelist_prect",(/nsim_pr/),"string")
  names_pr = new(nsim_pr,"string")
  paths_pr = new(nsim_pr,"string")
  syear_pr = new(nsim_pr,"integer",-999)
  eyear_pr = new(nsim_pr,"integer",-999)

  do gg = 0,nsim_pr-1
     names_pr(gg) = str_strip(str_get_field(na_pr(gg),1,delim))
     paths_pr(gg) = str_strip(str_get_field(na_pr(gg),2,delim))
     syear_pr(gg) = stringtointeger(str_strip(str_get_field(na_pr(gg),3,delim)))
     eyear_pr(gg) = stringtointeger(str_strip(str_get_field(na_pr(gg),4,delim)))
  end do
  modname_pr = str_sub_str(names_pr," ","_")
  do ff = 0,dimsizes(modname_pr)-1
     do gg = 0,dimsizes(bc)-1
        modname_pr(ff) = str_sub_str(modname_pr(ff),bc(gg),"_")
     end do
  end do
  delete(na_pr)

  nsim_psl = numAsciiRow("namelist_byvar/namelist_psl")
  na_psl = asciiread("namelist_byvar/namelist_psl",(/nsim_psl/),"string")
  names_psl = new(nsim_psl,"string")
  paths_psl = new(nsim_psl,"string")
  syear_psl = new(nsim_psl,"integer",-999)
  eyear_psl = new(nsim_psl,"integer",-999)

  do gg = 0,nsim_psl-1
     names_psl(gg) = str_strip(str_get_field(na_psl(gg),1,delim))
     paths_psl(gg) = str_strip(str_get_field(na_psl(gg),2,delim))
     syear_psl(gg) = stringtointeger(str_strip(str_get_field(na_psl(gg),3,delim)))
     eyear_psl(gg) = stringtointeger(str_strip(str_get_field(na_psl(gg),4,delim)))
  end do
  modname_psl = str_sub_str(names_psl," ","_")
  do ff = 0,dimsizes(modname_psl)-1
     do gg = 0,dimsizes(bc)-1
        modname_psl(ff) = str_sub_str(modname_psl(ff),bc(gg),"_")
     end do
  end do
  delete(na_psl)

;---------------------------------------------------------------------------------------------------------
  cr = "~C~"
  varlist          = (/"nino34_spectra"/)
  varlist_obs      = varlist
  ncol_labels      = (/"ENSO Power"/)
  ncol_units       = (/"~S~o~N~C~S~2~N~"/)
  varlist_fn       = (/"sst.indices"/)
  domain           = (/"nino34"/)
  variable         = (/"sst"/)

  power_thre       = (/10, 6, 2.5/) ; unit = years 
  nthre            = dimsizes(power_thre)
  power_band       = (/">10 yrs","6-10 yrs", "2.5-6 yrs", "< 2.5 yrs"/)
  csubtitle_color  = set_subtitle_colors(max(EM_num))
  csubtitle        = new(max(EM_num),string)

  csubexp          = (/"OBS"  ,"CMIP6","E3SMv3dev", "E3SMv2.1","E3SMv2"/)
  csubexp_color    = (/"Black","Grey25","firebrick2","deepskyblue4","Green4"/)
  csubgroup        = (/"OBS"  ,"HISTORICAL", "piControl","SORRM"/)
  csubgroup_marker = (/7,4,16,3/)
 
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
  do dd = 0,dimsizes(varlist)-1  

     nEM            = max(EM_num)+1
     finpc_EM       = new((/nEM,nthre+1,6/),double,9.99)
     finEM_names    = new(nEM,string)
     finname_mod    = new(nsim,string)
     finpc          = new((/nsim,nthre+1/),double,9.99)
     dimquery = dimsizes(finpc)

    ;read each simulation and process band-power

     do gg = 0,nEM-1 ; operate on each ensemble mean
        nens      = num(EM_num.eq.gg) ; determines how many model simulations in each ensemble
        cntr_ens := ind(EM_num.eq.gg) ; cntr_ens(hh) are the indices where each ensemble member of an ensemble reside 
        if (ismissing(finEM_names(gg))) then
           finEM_names(gg) = names_EM(cntr_ens(0))   
        end if

        do hh = 0,nens-1
           modname_mod  = modname(cntr_ens(hh))
           syear_mod    = syear(cntr_ens(hh))
           eyear_mod    = eyear(cntr_ens(hh))
           names_mod    = names(cntr_ens(hh))
           names_EM_mod = names_EM(cntr_ens(hh))
           if (ismissing(finname_mod(cntr_ens(hh)))) then
              finname_mod(cntr_ens(hh)) = (/ names_mod /)
           end if
           fnt = getenv("OUTDIR")+modname_mod+".cvdp_data."+varlist_fn(dd)+"."+syear_mod+"-"+eyear_mod+".nc"
           fnt2 = getenv("OUTDIR")+modname_mod+".cvdp_data."+syear_mod+"-"+eyear_mod+".nc"
          ;print(fnt)
          ;print(fnt2)
           arr := read_cvdp_le_data(fnt,fnt2,varlist(dd))
           frq := read_cvdp_le_data(fnt,fnt2,"frequency")

           if (isatt(arr,"is_all_missing").or.isatt(frq,"is_all_missing")) then 
              continue
           end if

           frq = 1.0 / frq / 12.0  ; convert months to years
           do kk = 0,nthre,1
              if(kk.eq.0) then 
                indx = ind(frq.ge.power_thre(kk))
              else if (kk.eq.nthre)  then
                indx = ind(frq.le.power_thre(kk-1))
              else 
                indx = ind(frq.lt.power_thre(kk-1).and.frq.ge.power_thre(kk))
              end if
              end if
              finpc(cntr_ens(hh),kk)  = (/dim_avg_n(arr(0,indx),0)/)
              delete(indx)
           end do 
           delete([/arr,frq/])
        end do   
        opt = False ;
        opt@PrintStat = False
        do kk = 0,nthre,1 
          xsort = finpc(cntr_ens,kk)
          qsort(xsort) 
          nx    = dimsizes(xsort)
          finpc_EM(gg,kk,0) = xsort(toint(0.1*nx))
          finpc_EM(gg,kk,1) = xsort(toint(0.25*nx))
          finpc_EM(gg,kk,2) = xsort(toint(0.5*nx))
          finpc_EM(gg,kk,3) = xsort(toint(0.75*nx))
          finpc_EM(gg,kk,4) = xsort(toint(0.9*nx))
          finpc_EM(gg,kk,5) = avg(xsort)
          delete([/xsort,nx/])
         ;if(nens.gt.1) then 
         ;  g = stat_dispersion(finpc(cntr_ens,kk),opt)
         ;  finpc_EM(gg,kk,0) = g(2)  ; min
         ;  finpc_EM(gg,kk,1) = g(6)  ; 25th percentile 
         ;  finpc_EM(gg,kk,2) = g(8)  ; median 
         ;  finpc_EM(gg,kk,3) = g(10) ; 75th percentile
         ;  finpc_EM(gg,kk,4) = g(13) ; max 
         ;  finpc_EM(gg,kk,5) = g(0)  ; mean
         ;  delete(g)
         ;else
         ;  finpc_EM(gg,kk,5) = dim_avg_n(finpc(cntr_ens,kk),0)
         ;  finpc_EM(gg,kk,2) = finpc_EM(gg,kk,5)
         ;  finpc_EM(gg,kk,0) = finpc_EM(gg,kk,5) - finpc_EM(gg,kk,5)/100.0
         ;  finpc_EM(gg,kk,1) = finpc_EM(gg,kk,5) - finpc_EM(gg,kk,5)/1000.0
         ;  finpc_EM(gg,kk,3) = finpc_EM(gg,kk,5) + finpc_EM(gg,kk,5)/1000.0
         ;  finpc_EM(gg,kk,4) = finpc_EM(gg,kk,5) + finpc_EM(gg,kk,5)/100.0
         ;end if 
        end do 
     end do   ; gg loop (each EM)

;======================================================================
; Create ensemble summary graphics
;
   wks_type = OUTPUT_TYPE
   if (wks_type.eq."png") then
     wks_type@wkWidth =  2400*PNG_SCALE
     wks_type@wkHeight = 2400*PNG_SCALE
   end if

   dum1 = new(nEM+1,graphic)
   dum2 = new((/nthre+1,nEM+1/),graphic)
   wks = gsn_open_wks(wks_type,OUTDIR+"enso_spec_power_ens")

   if(domain(dd).eq."nino34".or.domain(dd).eq."pdo") then
     vmax = 80.0
     vmin = 0.0
   else if(domain(dd).eq."ipo") then
     vmax = 200.0
     vmin = 0.0
   else
     vmax = 120.0
     vmin = 0.0
   end if
   end if

   if (nEM.le.3) then
     ph = .55
   end if
   if (nEM.ge.4.and.nEM.lt.7) then
     ph = .7
   end if
   if (nEM.ge.7.and.nEM.lt.10) then
     ph = .85
   end if
   if (nEM.ge.10) then
     ph = .95
   end if

   res                  = True         ; PersonalizaÃ§Ã£o do boxplot.
   res@vpHeightF        = 0.28
   res@vpWidthF         = ph 

   res@trXMinF          = 0.0          ; MÃ­nimo valor do eixo y.
   res@trXMaxF          = (nthre+1)*nEM + 1
   res@tmXBMode         = "Explicit"
   res@tmXBValues       = ispan(0,nthre+1,1)*nEM  - 0.5*nEM
   res@tmXBLabels       = power_band   ; RÃ³tulos do eixo x.
 
   res@trYMinF          = vmin         ; MÃ­nimo valor do eixo y.      
   res@trYMaxF          = vmax 
   res@tmYLMode         = "Explicit"   ; Eixo y esquerdo (YL) de forma manual.
   res@tmYLValues       = fspan(res@trYMinF,res@trYMaxF,5)
   res@tmYLMinorValues  = fspan(res@trYMinF,res@trYMaxF,13)
   res@tmYLLabels       = " " + res@tmYLValues

   res@tmYROn               = False
   res@tmXTOn               = False
   res@tmYLMinorOn          = True    ; Desliga o minortick do eixo y esquerdo.
   res@tmYRBorderOn         = True    ; Habilita a borda do eixo y direito (YR). 
   res@tmXTBorderOn         = True    ; Habilita a borda do eixo x superior (XB). 

   FontHeightF = 0.016
   res@tmXBLabelFontHeightF = FontHeightF   ; Tamanho da fonte do eixo x inferior (XB).
   res@tmYLLabelFontHeightF = FontHeightF   ;
   res@tiMainFontHeightF    = FontHeightF
   res@tiXAxisFontHeightF   = FontHeightF
   res@tiYAxisFontHeightF   = FontHeightF

   res@tiXAxisString        = "Frequency band"
   res@tiYAxisString        = "Power (" +ncol_units(dd)+")" 
   res@tiMainString         = "Simulated " + ncol_labels(dd)

   res@tmBorderLineColor   = "black"
   res@tmXBMajorLineColor  = "black"
   res@tmXBMinorLineColor  = "black"
   res@tmYLMajorLineColor  = "black"
   res@tmYLMinorLineColor  = "black"

   lthick = 5.0
   res@tmBorderThicknessF  = lthick
   res@tmXBMajorThicknessF = lthick
   res@tmXBMinorThicknessF = lthick
   res@tmYLMajorThicknessF = lthick
   res@tmYLMinorThicknessF = lthick
   res@tmYRMajorThicknessF = lthick
   res@tmYRMinorThicknessF = lthick

   res@pmTitleDisplayMode  = "Always"                   ; allow titles
   res@tiMainOn            = True

   do jj = 0,nEM-1,1

     fin_EM = finpc_EM(jj,:,:)
     dima   = dimsizes(fin_EM(0,:))

    ;if(dd.eq.0) then 
    ;   print(names_EM(jj) + " " + finEM_names(jj))
    ;end if 

     xx = ispan(1,nthre+1,1)*nEM -0.89*nEM + 0.95*jj; Valores para o eixo x.

     boxColors = new(dimsizes(fin_EM(:,0)),string)
     boxMarker = new(dimsizes(fin_EM(:,0)),integer)

     if(finEM_names(jj).eq."Observations") then 
       boxColors = csubexp_color(0)
     else if (isStrSubset(finEM_names(jj),"CMIP6")) then
       boxColors = csubexp_color(1)
     else if (isStrSubset(finEM_names(jj),"v3-")) then
       boxColors = csubexp_color(2) 
     else if (isStrSubset(finEM_names(jj),"v2.1-")) then
       boxColors = csubexp_color(3)
     else if (isStrSubset(finEM_names(jj),"v2-")) then
       boxColors = csubexp_color(4)
     else if (isStrSubset(finEM_names(jj),"SORRM.CRYO")) then
       boxColors = csubexp_color(5)
     else 
       boxColors = csubtitle_color(jj)
       csubtitle(jj) = finEM_names(jj)
     end if 
     end if 
     end if 
     end if
     end if
     end if 

     if(finEM_names(jj).eq."Observations") then
       boxMarker = csubgroup_marker(0)
     else if (isStrSubset(finEM_names(jj),csubgroup(1))) then
       boxMarker = csubgroup_marker(1)
     else if (isStrSubset(finEM_names(jj),csubgroup(2))) then
       boxMarker = csubgroup_marker(2)
     else if (isStrSubset(finEM_names(jj),csubgroup(3))) then
       boxMarker = csubgroup_marker(3)
     else
       boxMarker = csubgroup_marker(4)
     end if
     end if
     end if
     end if

     llres                   = True     ; PersonalizaÃ§Ã£o das linhas do boxplot.
     llres@gsLineThicknessF  = 8.0      ; Espessura da linha.
      
     opti           = True ; Habilita personalizaÃ§Ã£o da caixa.
     opti@boxWidth  = 0.70 ; Largura da caixa. Quanto maior o valor, mais larga serÃ¡ a caixa.
     opti@boxColors = boxColors

     res@tmXBMajorOutwardLengthF = 0.016	; set tickmarks 
     res@tmXBMinorOutwardLengthF = 0.010
     res@tmXBMajorLengthF        = 0.016
     res@tmXBMinorLengthF        = 0.009

     res@tmYLMajorOutwardLengthF = 0.016       ; set tickmarks
     res@tmYLMinorOutwardLengthF = 0.010
     res@tmYLMajorLengthF = 0.016
     res@tmYLMinorLengthF = 0.009

     if(jj.eq.0) then 
       res1 = res
       res1@tmXBLabelsOn = True
       res1@tmYLLabelsOn = True
       plot = boxplot(wks,xx,fin_EM(:,0:dima-2),opti,res1,llres)
       delete(res1)
     else 
       res1 = res
       res1@tmXBLabelsOn = False
       res1@tmYLLabelsOn = False
       res1@tmYLOn       = False
       res1@tmXBOn       = False
       res1@tiXAxisString = "" 
       res1@tiYAxisString = "" 
       res1@tiMainString  = "" 
       dum1(jj) = boxplot(wks,xx,fin_EM(:,0:dima-2),opti,res1,llres)
       overlay(plot,dum1(jj))
       delete(res1)
     end if 
     delete([/llres,opti/])

     ;***********************************************
     ; add some polymarkers
     ;***********************************************
     mres                    = True                     ; marker mods desired
     mres@gsMarkerIndex      = boxMarker                ; polymarker style
     mres@gsMarkerSizeF      = 0.008                    ; polymarker size
     mres@gsMarkerThicknessF = 10.                      ; polymarker size
     mres@gsMarkerColor      = boxColors                ; polymarker color
     do ff = 0,dimsizes(fin_EM(:,0))-1,1
      dum2(ff,jj) = gsn_add_polymarker(wks,plot,xx(ff),fin_EM(ff,dima-1),mres) 
     end do 

   end do

   ;***********************************************
   ; add some polylines
   ;***********************************************
   res_lines                   = True        ; polyline mods desired
   res_lines@gsLineColor       = "Grey35"   ; line color
   res_lines@gsLineThicknessF  = 5.0           ; line thicker
   res_lines@gsLineDashPattern = 5   ; dash pattern
   xi = ispan(1,nthre+1,1)*nEM  + 0.03*nEM
   yi = (/res@trYMinF,res@trYMaxF/)
   dumx = new(dimsizes(xi),graphic) 
   do ff = 0, dimsizes(xi)-2,1
     dumx(ff) = gsn_add_polyline(wks, plot, (/xi(ff),xi(ff)/), yi, res_lines)
   end do
   delete([/xi,yi/])

   gsres               = True
   txres               = True
   txres@txJust        = "bottomleft"
   txres@txFontHeightF = FontHeightF*0.65
   do i = 0, dimsizes(csubexp)-1
     xtxt = 0.15 + 0.65
     ytxt = 0.43 + i * 0.022
     txres@txFontColor = csubexp_color(i)
     gsn_text_ndc (wks,csubexp(i),xtxt,ytxt,txres)
   end do 
  
   do i = 0, dimsizes(csubgroup)-1
     xleg = 0.15 + 0.65
     xtxt = 0.17 + 0.65
     yleg = 0.57 + i * 0.022
     ytxt = 0.57 + i * 0.022
     gsres@gsMarkerIndex      = csubgroup_marker(i)
     gsres@gsMarkerColor      = "Black" ;colors(i)
     gsres@gsMarkerThicknessF = 8.0
     gsres@gsMarkerSizeF      = 0.008
     gsn_polymarker_ndc(wks,          xleg,yleg,gsres)
     txres@txJust      = "centerleft"
     txres@txFontColor = "Black"
     gsn_text_ndc      (wks,csubgroup(i),xtxt,ytxt,txres)
   end do

   panres = True
   panres@gsnPanelYWhiteSpacePercent = 4.0
   gsn_panel(wks,plot,(/1,1/),panres)
   delete(wks)
   ofile = "ens_spectrum_power_"+varlist(dd)
   system("convert -density 2400 -trim +repage -border 40 -bordercolor white "+OUTDIR+"enso_spec_power_ens."+wks_type+" "+OUTDIR+ofile+"_ensemble.png") 
   system("rm "+OUTDIR+"enso_spec_power_ens.png")
   delete([/finpc,finpc_EM/])

 end do   ; dd loop (each metric)

 print("Finished: ens_metrics_enso_spec.ncl")
end
