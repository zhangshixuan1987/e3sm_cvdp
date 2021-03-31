  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a 4-panel lat-lon plot
;          Data is vertically interpolated to pressure levels
;          1st panel: experiment 1
;          2nd panel: experiment 2
;          3rd panel: absolute difference (exp1-exp2)
;          4th panel: relative difference (exp1-exp2)/exp2
; Author : Shixuan Zhang
; Date   : Feb 22, 2021

begin

  compare                                    = getenv("COMPARE")
  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")
  case1name                                  = getenv("TEST_NAME")
  case2name                                  = getenv("CTRL_NAME")
  casedir                                    = getenv("CASEDIR")
  obstimtag                                  = getenv("OBS_TIME_TAG")
  statistical_test                           = getenv("DIFFERENCE_TEST")
  statistical_siglev                         = 0.05

;define regions for plot
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       = -55.  ;negative for southern hemisphere
  pout                                       = "55S-90S"
  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.806
  sigma                                      = 5.67e-8 ; Stefan-Boltzmann constant

;declear the season or annual mean data to be used;;;;;
  seasons                                       = (/"ANN","DJF","JJA"/)

;read in two files
;start to do the plot
  print ("Start to plot global map distribution for selected variables ")
  load "./share_info_for_latlon_map.ncl"

  do ll = 0, dimsizes(pout)-1

     do kk = 0, dimsizes(seasons)-1

        f 			   		= systemfunc("ls $TPATH/*"+seasons(kk)+"_means.nc")
        f1			   		= addfile(f,"r")
        gw1                                     = f1->gw 

        if(compare.eq."Model_vs_OBS") then
          f                                     = systemfunc("ls $CPATH/*_siglev_analysis_*_"+seasons(kk)+".nc")
          f2                                    = addfile(f,"r")
          gw2                                   = f2->gw 
        else
          f                                     = systemfunc("ls $CPATH/*"+seasons(kk)+"_means.nc")
          f2                                    = addfile(f,"r")
          gw2                                   = f2->gw 
        end if 

        do jj = 0, dimsizes(modvars)-1

          mvarnam  = modvars(jj)
          print("working on variable "+ mvarnam)
          mvarnam  = modvars(jj)
          print("working on variable "+ mvarnam)
          load "./function_read_model_var.ncl"

          if (compare.eq."Model_vs_OBS") then
            ovarnam  = obsvars(jj)
            load "./function_read_obs_var.ncl"
          end if

          var1@_FillValue                      = -9999.
          var2@_FillValue                      = -9999.

          if(compare.eq."Model_vs_OBS") then
            var1                               = var1*facmod(jj)
            var2                               = var2*facobs(jj)
          else
            var1                               = var1*facmod(jj)
            var2                               = var2*facmod(jj)
          end if

          var1@units                           = varunt(jj)
          var2@units                           = varunt(jj)

          ;;;;;;select the data for plots;;;;;;;;;;;;;;;;;;;;;;;;;;;
          vp1                                 = var1(:,{latS:latN},:)
          vp2                                 = var2(:,{latS:latN},:)
          gw                                  = gw1({latS:latN})
          ddd1                                = dimsizes(vp1)
          ddd2                                = dimsizes(vp2)
          delete([/var1,var2/])

          ;;check the two comparing files and see if they are in the same grid, otherwise, return the error message;;;;
          if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
            print("Error: this scripts requires the two files must in the same grid to run!!!")
            return
          end if

          ;;generate the weighting metrics 
          mcor                          = new((/ddd1(1),ddd1(2)/),float)
          mcor@_FillValue               = vp1@_FillValue
          do i = 0, ddd2(1)-1
             mcor(i,:)                  = tofloat(gw(i))*(2.*pi/ddd1(2))*rearth^2.
          end do

          if(str_lower(statistical_test).eq."true")then 
            l_plot_ttest = True 
            xtmp = vp1(lat|:,lon|:,time|:)       ; reorder but do it only once [temporary]
            ytmp = vp2(lat|:,lon|:,time|:)
           ;printVarSummary(xtmp) 
            xAve = dim_avg (xtmp)              ; calculate means at each grid point
            yAve = dim_avg (ytmp)
            xVar = dim_variance (xtmp)         ; calculate variances
            yVar = dim_variance (ytmp)
            xEqv = equiv_sample_size (xtmp, statistical_siglev,0)
            yEqv = equiv_sample_size (ytmp, statistical_siglev,0)
            xN   = wgt_areaave2 (xEqv, mcor, 0)    ; wgty could be gaussian weights
            yN   = wgt_areaave2 (yEqv, mcor, 0)
           ;print(xN+  " "+yN)          
            iflag = True                       ; population variance similar
            prob  = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False)
           ;print(min(prob)+ " " +max(prob))
           ;printVarSummary(prob)
            delete([/xtmp,ytmp,xAve,yAve,xVar,yVar,xEqv,yEqv,xN,yN/])
 	  end if 

	   vp1x				    = dim_avg_n_Wrap(vp1,0)
	   vp2x				    = dim_avg_n_Wrap(vp2,0)
	  ;print(vp1x@_FillValue)

           vp1a				    = vp1x
           vp2a				    = vp2x
           vp11                             = where(ismissing(vp1a(:,:)), vp1x@_FillValue, vp1a(:,:)*mcor)
           vp1m                             = sum(vp11)
           mcor1                            = where(ismissing(vp1a(:,:)), mcor@_FillValue, mcor)
           vp22                             = where(ismissing(vp2a(:,:)), vp2x@_FillValue, vp2a(:,:)*mcor)
           vp2m                             = sum(vp22)
           mcor2                            = where(ismissing(vp2a(:,:)), mcor@_FillValue, mcor)
           vp1m                             = vp1m / sum(mcor1)
           vp2m                             = vp2m / sum(mcor2)
           delete([/vp1,vp2,mcor1,mcor2,vp11,vp22/])

           vp1b                             = where(abs(vp1a) .lt. 1.e-30, vp1x@_FillValue, vp1a)
           vp2b                             = where(abs(vp2a) .lt. 1.e-30, vp2x@_FillValue, vp2a)
           vp1b                             = where(ismissing(vp2b), vp1x@_FillValue, vp1b)
           vp2b                             = where(ismissing(vp1b), vp2x@_FillValue, vp2b)

           adiff                            = vp1a
           adiff                            = vp1a-vp2a

           rdiff                            = vp1a
           rdiff                            = (vp1b-vp2b)*100./abs(vp2b)
              
           mcor3                            = where(ismissing(rdiff(:,:)), mcor@_FillValue, mcor)
           rdifft                           = where(ismissing(rdiff(:,:)), rdiff@_FillValue, rdiff(:,:)*mcor)
           rdiffm                           = sum(rdifft) / sum(mcor3)
           delete([/vp1x,vp2x,rdifft,mcor3,mcor/])

           if(l_plot_ttest)then 
            adiff                           = where(prob.le.statistical_siglev,adiff,adiff@_FillValue)
            rdiff                           = where(prob.le.statistical_siglev,rdiff,rdiff@_FillValue)
           end if 


           ;;;start to process the plot;;;;
           load "./share_color_bar_for_polar_map.ncl"
           wtype                        = "eps"
          ;wtype@wkWidth                = 2500
          ;wtype@wkHeight               = 2500
           figdir                       = casedir+"/Latitude-Longitude_Contour_Maps_"+pout(ll)+"/"
           fe                           = mvarnam+"_"+seasons(kk)+"_latlon_"+pout(ll) 
           wks                          = gsn_open_wks(wtype,figdir+ fe)

           gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")  ; merge two color maps

           plot   = new (4,graphic)


;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    Make the Plot
;
;;;;;;;;;;;;;;;;;;;;;;;;;
	      res                  	        = True                  ; plot mods desired
	      res@cnFillOn         	        = True                  ; turn on color fill
	      res@cnLinesOn          	        = False                 ; no contour lines
	      res@cnLineLabelsOn     	        = False
              res@gsnFrame                      = False                 ; Do not draw plot
              res@gsnDraw                       = False                 ; Do not advance frame

              FontHeightF = 0.018
              res@tiMainFontThicknessF          = 2.0
              res@tiMainFontHeightF             = FontHeightF*1.5
              res@tmYLLabelFontHeightF          = FontHeightF
              res@tmXBLabelFontHeightF          = FontHeightF 
              res@tiXAxisFontHeightF            = FontHeightF
              res@tiYAxisFontHeightF            = FontHeightF
              res@gsnStringFontHeightF          = FontHeightF
              res@cnLineLabelFontHeightF        = FontHeightF
              res@lbLabelFontHeightF            = FontHeightF*0.8
              res@lbTitleFontHeightF            = FontHeightF*0.8

              res@tmXTOn                        = False
	     ;res@tmYLLabelFontHeightF	 	= 0.015
              res@tmBorderThicknessF            = 1.0
              res@tmXBMajorThicknessF           = 1.0
              res@tmXBMinorThicknessF           = 1.0
              res@tmYLMajorThicknessF           = 1.0
              res@tmYLMinorThicknessF           = 1.0
              res@tmYRMajorThicknessF           = 1.0
              res@tmYRMinorThicknessF           = 1.0

              res@gsnPolarLabelFontHeightF      = 0.02
              res@gsnPolar                      = "SH"
              res@mpFillOn                      = False        ; turn off map fill
              res@mpMaxLatF                     = latN
              res@mpGeophysicalLineThicknessF   = 2.0
              res@tmYRMode                      = "Automatic"           ; turn off special labels on right axis

	      res@lbLabelBarOn      		= True
	      res@lbOrientation     		= "Vertical"
              res@lbPerimOn                     = False             ; default has box
             ;res@pmLabelBarHeightF             = 0.38
             ;res@pmLabelBarWidthF              = 0.1
             ;res@pmLabelBarParallelPosF        = 0.55
              res@pmLabelBarOrthogonalPosF      = 0.12
             ;res@lbTitleString                 = "" 
              res@lbLabelFontHeightF            = 0.02               ; make labels smaller

	      res@cnInfoLabelOn     		= False
	      res@cnLevelSelectionMode      	= "ExplicitLevels"       ; manual levels
	      res@cnMissingValFillColor 	= "White" ;"gray76"               ; black = 1

	      res@gsnRightStringFontHeightF	= 0.025
              res@gsnRightStringOrthogonalPosF  = 0.06
	      res@gsnLeftStringFontHeightF	= 0.025

              res1 = res
              res1@cnLevels                    := sprintf("%7.2f",s1)
              res1@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,29,30,15,16,17/)
              res1@gsnLeftString                = str_upper(mvarnam)+ " ("+varunt(jj)+")"
              res1@tiMainString                 = panelstr1
              if(max(abs(s1)).ge.100.0)then
                res1@gsnRightString             = "mean: "+sprintf("%5.1f",vp1m)
                res1@lbLabelStrings             = sprintf("%5.0f",s1)
              else
                res1@gsnRightString             = "mean: "+sprintf("%5.2f",vp1m)
                res1@lbLabelStrings             = sprintf("%5.2f",s1)
              end if 
	      plot(0)   			= gsn_csm_contour_map(wks,vp1a(:,:),res1)
             
              res1@gsnLeftString                = str_upper(mvarnam)+ " ("+varunt(jj)+")"
              res1@gsnCenterString              = ""
              res1@tiMainString                 = panelstr2
              if(max(abs(s1)).ge.100.0)then
                res1@gsnRightString             = "mean: "+sprintf("%5.1f",vp2m)
                res1@lbLabelStrings             = sprintf("%5.0f",s1)
              else
                res1@gsnRightString             = "mean: "+sprintf("%5.2f",vp2m)
                res1@lbLabelStrings             = sprintf("%5.2f",s1)
              end if
	      plot(1) 			        = gsn_csm_contour_map(wks,vp2a(:,:),res1)

              res2 = res
	      res2@cnLevels      		= sprintf("%7.2f",s2)
	      res2@cnFillColors  		= (/18,20,22,23,24,25,26,27,28,30,31,33/)
	      res2@gsnLeftString 		= str_upper(mvarnam)+ " ("+varunt(jj)+")"
              res2@tiMainString                 = panelstr1 + " - " + panelstr2 ; "absolute difference"
              res2@gsnCenterString              = ""
              if(max(abs(s2)).ge.100.0)then
                res2@gsnRightString             = "mean: "+sprintf("%5.1f",vp1m - vp2m)
                res2@lbLabelStrings             = sprintf("%5.0f",s2)
              else
                res2@gsnRightString             = "mean: "+sprintf("%5.2f",vp1m - vp2m)
                res2@lbLabelStrings             = sprintf("%5.2f",s2)
              end if
	      plot(2) 			        = gsn_csm_contour_map(wks,adiff(:,:),res2)
	
              res3 = res
              res3@cnLevels      		= sprintf("%7.2f",s3)
              res3@cnFillColors                 = (/18,20,22,23,24,25,26,27,28,30,31,33/)
              res3@gsnLeftString                = str_upper(mvarnam)+ " ("+varunt(jj)+")"
	      res3@tiMainString 		= "Relative difference (%)"
              res3@gsnCenterString              = ""
              if(max(abs(s3)).ge.10.0)then
                res3@gsnRightString             = "mean: "+sprintf("%5.1f", rdiffm)
                res3@lbLabelStrings             = sprintf("%5.0f",s3)
              else
                res3@gsnRightString             = "mean: "+sprintf("%5.2f", rdiffm)
                res3@lbLabelStrings             = sprintf("%5.2f",s3)
              end if
	      plot(3)	 		        = gsn_csm_contour_map(wks,rdiff(:,:),res3)
	 
              pres                              = True        ; panel plot mods desired
              pres@gsnMaximize                  = False       ; fill the page
              pres@txFontHeightF                = 0.020
              pres@txFontThicknessF             = 20.
              pres@gsnPanelXWhiteSpacePercent   = 3.
              pres@gsnPanelYWhiteSpacePercent   = 5.
              pres@txString                     = "Plot time: "+seasons(kk)
                                                  ;str_upper(mvarnam)+ " ("+seasons(kk)+"; unit: "+unit+")"
              gsn_panel(wks,plot(:),(/2,2/),pres)

              ;convert the figure 
              ;if (wtype .eq. "png") then
              ;  tmpa = systemfunc("convert "+figdir+fe+".png -trim del.png")
              ;  tmpb = systemfunc("mv del.png "+fe+".png")
              ;end if

              delete([/vp1a,vp2a,adiff,rdiff,vp1b,vp2b/])

           delete([/plot,res,pres,wks,ddd1,ddd2,s1,s2,s3/])

        end do       ; end of looping over variables

        delete([/f1,gw1/])
        delete([/f2,gw2/])

     end do          ; end of looping over seasons
  end do
end