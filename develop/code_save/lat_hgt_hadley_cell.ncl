  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a 4-panel lat-height plot
;          Data is vertically interpolated to pressure levels
;          1st panel: experiment 1
;          2nd panel: experiment 2
;          3rd panel: absolute difference (exp1-exp2)
;          4th panel: relative difference (exp1-exp2)/exp2
; Author : Shixuan Zhang
; Date   : Feb 22, 2021

begin

  compare                                    = getenv("COMPARE")
  outdir                                     = getenv("CASEDIR")

  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")

  tcase                                      = getenv("TEST")
  ccase                                      = getenv("CTRL")

  tname                                      = getenv("TNAME")
  cname                                      = getenv("CNAME")

  tttag                                      = getenv("TTTAG")
  cttag                                      = getenv("CTTAG")

  refplev_file                               = getenv("REF_PRE_LEV")
  statistical_test                           = getenv("DIFFERENCE_TEST")
  statistical_siglev                         = 0.05

;define regions for plot
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       =  90.  ;negative for southern hemisphere
  pout                                       = "Global"

  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.806
  sigma                                      = 5.67e-8 ; Stefan-Boltzmann constant

;declear the season or annual mean data to be used;;;;;
  seasons                                   = (/"ANN","DJF","JJA"/)

;define the pressure levels for cross-section plot 
  pinterp                                      = asciiread(refplev_file,-1,"float")
  pinterp@longname                             = "lev"
  pinterp@units                                = "hPa"
  intyp                                     = 2

  pi                                        = 3.14159265
  rearth                                    = 6.37122e6
  grav                                      = 9.806

;read in two files

  do ll = 0, dimsizes(pout)-1
 
      f                                       = systemfunc("ls "+tpath+"/"+tcase+"*"+tttag+".nc")
      f1                                      = addfile(f,"r")
      gw1                                     = f1->gw

      f                                       = systemfunc("ls "+cpath+"/"+ccase+"*"+cttag+".nc")
      f2                                      = addfile(f,"r")
      gw2                                     = f2->gw

     ; =================================================================
     print ("Start to process the cross-section of  selected variables ")
     load "./share_info_for_hadley_cell_var.ncl"

        um                                  = vinth2p(f1->$modvars(0)$,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
        vm                                  = vinth2p(f1->$modvars(1)$,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
        wm                                  = vinth2p(f1->$modvars(2)$,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
        
        if(compare.ne."Model_vs_OBS") then
          uo                                = vinth2p(f2->$modvars(0)$,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
          vo                                = vinth2p(f2->$modvars(1)$,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
          wo                                = vinth2p(f2->$modvars(2)$,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        end if

        if(compare.eq."Model_vs_OBS") then
           uo                               = int2p_n_Wrap(f2->lev,f2->$obsvars(0)$,pinterp, intyp, 1) 
           vo                               = int2p_n_Wrap(f2->lev,f2->$obsvars(1)$,pinterp, intyp, 1)
           wo                               = int2p_n_Wrap(f2->lev,f2->$obsvars(2)$,pinterp, intyp, 1)
        end if

        um@_FillValue                       = -9999.
        vm@_FillValue                       = -9999.
        wm@_FillValue                       = -9999.
        vo@_FillValue                       = -9999.
        uo@_FillValue                       = -9999.
        vo@_FillValue                       = -9999.

        if(compare.eq."Model_vs_OBS") then
          um                                = um*facmod(0)
          uo                                = uo*facobs(0)
          vm                                = vm*facmod(1)
          vo                                = vo*facobs(1)
          wm                                = wm*facmod(2)
          wo                                = wo*facobs(2)
        else
          um                                = um*facmod(0)
          uo                                = uo*facmod(0)
          vm                                = vm*facmod(1)
          vo                                = vo*facmod(1)
          wm                                = wm*facmod(2)
          wo                                = wo*facmod(2)
        end if

        um@units                            = varunt(0)
        uo@units                            = varunt(0)
        vm@units                            = varunt(1)
        vo@units                            = varunt(1)
        wm@units                            = varunt(2)
        wo@units                            = varunt(2)

        ;;check the two comparing files and see if they are in the same grid,
        ddd1                                  = dimsizes(um)
        ddd2                                  = dimsizes(uo)
        ;;otherwise, return the error message;;;;
        if ((ddd1(2).ne.ddd2(2)).or.(ddd1(3).ne.ddd2(3)))then
          print("Error: this scripts requires the two files must in the same grid to run!!!")
          return
        end if

        printVarSummary(wm)
      ;derive the stream function and velocity potential 
        sfvpm  = uv2sfvpF (um,vm) 
        sfvpo  = uv2sfvpF (uo,vo) 
        sfm    = sfvpm(0,:,:,:,:)
        sfo    = sfvpo(0,:,:,:,:)

        ;======================================================================
        ;Save the derived data for the future use 
        ;======================================================================
         setfileoption("nc", "Format",  "NetCDF4")
         out_file1  = opath +"/"+"EOF_PCS_"+cname+"_monthly_mean_"+mvarnam+"_at_"+toint(pout(ll))+"hPa_"+seasons(kk)+".nc"
         out_file2  = opath +"/"+"EOF_PCS_"+tname+"_monthly_mean_"+mvarnam+"_at_"+toint(pout(ll))+"hPa_"+seasons(kk)+".nc"

         system("rm " + out_file1)
         system("rm " + out_file2)

         fout1 = addfile(out_file1,"c")
         fout2 = addfile(out_file2,"c")

         time1 = eof1_ts&time
         time2 = eof2_ts&time
         time1!0 = "time"
         time2!0 = "time"
         time1&time = time1
         time2&time = time2

         fout1->time         = time1
         fout2->time         = time2
         eof1@description    = "EOF pattern"
         eof2@description    = "EOF pattern"
         eof1_ts@description = "EOF PCs (standardized)"
         eof2_ts@description = "EOF PCs (standardized)"

         fout1->eof      = eof1
         fout2->eof      = eof2
         fout1->eof_ts   = eof1_ts
         fout2->eof_ts   = eof2_ts

         delete([/time1,time2,fout1,fout2,out_file1,out_file2/])

        printMinMax(sfm,False)
        printMinMax(sfo,False)       
        exit
 

        do kk = 0, dimsizes(seasons)-1

        ;;;;;;select the data for plots;;;;;;;;;;;;;;;;;;;;;;;;;;;
        if(seasons(kk).eq."ANN")then
          vp1                          = month_to_annual(var1(:,:,{latS:latN},:),1)
          vp2                          = month_to_annual(var2(:,:,{latS:latN},:),1)
        else
          vp1                          = month_to_season(var1(:,:,{latS:latN},:),seasons(kk))
          vp2                          = month_to_season(var2(:,:,{latS:latN},:),seasons(kk))
        end if
        vp1!0="time"
        vp1!1="lev"
        vp1!2="lat"
        vp1!3="lon"

        vp2!0="time"
        vp2!1="lev"
        vp2!2="lat"
        vp2!3="lon"

       if(str_lower(statistical_test).eq."true")then

         l_plot_ttest = True
         vpt1 = dim_avg_n_Wrap(vp1,3)
         vpt2 = dim_avg_n_Wrap(vp2,3) 
         xtmp = vpt1(lev|:,lat|:,time|:)       ; reorder but do it only once [temporary]
         ytmp = vpt2(lev|:,lat|:,time|:)
         xAve = dim_avg (xtmp)              ; calculate means at each grid point
         yAve = dim_avg (ytmp)
         xVar = dim_variance (xtmp)         ; calculate variances
         yVar = dim_variance (ytmp)
         xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
         yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
         xN   = dim_avg_n(dim_avg_wgt_n(xEqv, gw1, 0, 1),0)
         yN   = dim_avg_n(dim_avg_wgt_n(yEqv, gw2, 0, 1),0)
         iflag = True                       ; population variance similar
         prob  = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
         delete([/vpt1,vpt2,xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN/])

       end if

       vp1a                                = dim_avg_n_Wrap(dim_avg_n_Wrap(vp1,3),0)
       vp2a                                = dim_avg_n_Wrap(dim_avg_n_Wrap(vp2,3),0)

       vp1a@_FillValue                     = -9999.
       vp2a@_FillValue                     = -9999.

       vp1b                                = where(abs(vp1a) .lt. 1.e-1, vp1a@_FillValue, vp1a)
       vp2b                                = where(abs(vp2a) .lt. 1.e-1, vp2a@_FillValue, vp2a)
       vp1b                                = where(ismissing(vp2b), vp1a@_FillValue, vp1b)
       vp2b                                = where(ismissing(vp1b), vp2a@_FillValue, vp2b)

       adiff                               = vp1a
       adiff                               = vp1a-vp2a

       rdiff                               = vp1a
       rdiff                               = (vp1b-vp2b)/abs(vp2b)*100.

       prob0                               = adiff
       prob0                               = (1.0 - prob)*100.0
       prob0                               = where(prob.le.statistical_siglev,prob0,prob0@_FillValue)


       ;;;;;;;;;;start to process the figure ;;;;;;;
        plot                                = new((/4/),graphic)
        wtype                               = "eps"
        figdir                              = outdir+"/Pressure-Latitude_Zonal_Mean_Contour/"
        fe                                  = modvars(jj)+"_"+seasons(kk)+"_lathgt"+"_"+pout(ll)
        wks                                 = gsn_open_wks(wtype, figdir + fe)

        gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")             ; merge two color maps

        load "./share_color_bar_for_cross_section.ncl"

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ;    Make the Plot
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;
           res                              = True                  ; plot mods desired
           res@vpWidthF                     = 0.6
           res@vpHeightF                    = 0.6
           res@gsnFrame                     = False                 ; Do not draw plot
           res@gsnDraw                      = False                 ; Do not advance frame
          ;res@gsnMajorLatSpacing           =  10             ;-- change major lat tickmark spacing
          ;res@gsnMinorLatSpacing           =  2.5            ;-- change major lat tickmark spacing

           res@cnFillOn                     = True                  ; turn on color fill
           res@cnLinesOn                    = False                 ; no contour lines
           res@cnLineLabelsOn               = False
           res@cnMissingValFillColor        = "White" ;"gray76"               ; black = 1

           res@tmXTOn                       = False
           res@tmYLLabelFontHeightF         = 0.025
           res@tmBorderThicknessF           = 1.0
           res@tmXBMajorThicknessF          = 1.0
           res@tmXBMinorThicknessF          = 1.0
           res@tmYLMajorThicknessF          = 1.0
           res@tmYLMinorThicknessF          = 1.0
           res@tmYRMajorThicknessF          = 1.0
           res@tmYRMinorThicknessF          = 1.0
           res@tmYRMode                     = "Automatic"          ; turn off special labels on right axis

           res@tmXBMode                     = "Explicit"	
           res@tmXBValues                   = ispan(toint(latS),toint(latN),30)
           res@tmXBLabels                   = (/"90S","60S","30S","0", \
                                                "30N","60N","90N"/)
           res@tmXBMinorValues              = ispan(toint(latS),toint(latN),15)

           res@tmYLMode                     = "Explicit"                ; explicit labels
           res@tmYLValues                   = (/ 1000, 850, 700, 500, 300, 200, 100, 10, 1/)
           res@tmYLLabels                   = ""+res@tmYLValues         ; make strings

           res@lbLabelBarOn                 = True
           res@lbOrientation                = "Vertical"
           res@cnInfoLabelOn                = False
           res@cnLevelSelectionMode         = "ExplicitLevels"       ; manual levels
           res@cnLevels                     = sprintf("%5.2f",s1)
           res@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,14,15/)
           res@gsnRightStringFontHeightF    = 0.025
           res@gsnRightStringOrthogonalPosF = 0.02
           res@trYReverse                   = True
           res@tiYAxisString                = "Pressure (hPa)"
           res@gsnLeftStringFontHeightF     = 0.025
           res@gsnLeftStringOrthogonalPosF  = 0.015

           res@tiMainString                 = panelstr1
           res@gsnLeftString                = str_upper(modvars(jj))+" (unit: "+ vp1a@units+")" ;"relative diff. (%)"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(vp1a(:,:)))
           plot(0)              = gsn_csm_contour(wks,vp1a(:,:),res)

           res@tiMainString                 = panelstr2
           res@gsnLeftString                = str_upper(modvars(jj))+" (unit: "+ vp1a@units+")" ;"relative diff. (%)"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(vp2a(:,:)))
           plot(1)              = gsn_csm_contour(wks,vp2a(:,:),res)

           res@cnLevels                     = sprintf("%7.2e",s2)
           res@cnFillColors                 = (/18,20,21,22,23,24,0,27,28,29,30,31,33/)              ; contour interval

           res@tiMainString                 = panelstr1 + " - " + panelstr2 ; "absolute difference"
           res@gsnLeftString                = str_upper(modvars(jj))+" (unit: "+ vp1a@units+")" ;"relative diff. (%)"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(adiff(:,:)))
           plot(2)              = gsn_csm_contour(wks,adiff(:,:),res)

           res@cnLevels                     = sprintf("%7.2f",s3)
           res@tiMainString                 = "relative diff. (%)"
           res@gsnLeftString                = str_upper(modvars(jj))+" (unit: "+ vp1a@units+")" ;"relative diff. (%)"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(rdiff(:,:)))
           plot(3)              = gsn_csm_contour(wks,rdiff(:,:),res)

           rescn2 = res
           rescn2@lbLabelBarOn    = False 
           rescn2@tiMainString    = ""
           rescn2@gsnLeftString   = ""
           rescn2@gsnRightString  = ""
           rescn2@cnMinLevelValF  = (1.0 - statistical_siglev)*100.0
           rescn2@cnMaxLevelValF  = 100.0
           rescn2@cnLevelSpacingF = 10.
           rescn2@cnMonoFillPattern = True  
           rescn2@cnMonoFillColor = True 
           rescn2@cnFillMode      = "AreaFill" ; raster fill significance patterns
           rescn2@cnFillPattern   = 17
           rescn2@cnFillDotSizeF  = 0.002
           rescn2@cnFillColors    = "black"
           rescn2@cnFillColor     = "black"
           rescn2@cnFillOpacityF  = 0.5 
           plotA = gsn_csm_contour(wks,prob0,rescn2) ; contours are at 95,100
           plotB = gsn_csm_contour(wks,prob0,rescn2) ; contours are at 95,100

           overlay(plot(2),plotA)
           overlay(plot(3),plotB)

           pres                             = True        ; panel plot mods desired
           pres@gsnMaximize                 = False       ; fill the page
           pres@txFontHeightF               = 0.015       
           pres@txFontThicknessF            = 2.
           pres@gsnPanelXWhiteSpacePercent  = 3.
           pres@gsnPanelYWhiteSpacePercent  = 5.
           pres@txString                    = str_upper(compare)+" ("+seasons(kk)+")"
           gsn_panel(wks,(/plot(:)/),(/2,2/),pres)

           delete([/plotA,plotB/])

           delete([/vp1a,vp2a,adiff,rdiff,vp1,vp2,vp1b,vp2b,wks/])

        delete([/plot,res,pres,s1,s2,s3/])

     end do          ; end of looping over seasonsons

     delete([/f1,gw1,var1,ddd1/])
     delete([/f2,gw2,var2,ddd2/])

 end do
 
end
