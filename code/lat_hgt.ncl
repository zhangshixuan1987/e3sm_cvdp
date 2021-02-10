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
; Date   : Nov 30, 2020

begin

  compare                                    = getenv("COMPARE")
  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")
  case1name                                  = getenv("TEST_NAME")
  case2name                                  = getenv("CTRL_NAME")
  casedir                                    = getenv("CASEDIR")
  statistical_test                           = getenv("DIFFERENCE_TEST")
  statistical_siglev                         = 0.05


;variable name in the climo file
  vars                                      = (/"U","T","Q","RELHUM"/) ;"OMEGA"
  seasons                                   = (/"ANN","DJF","JJA"/)

;define regions for plot
  latS                                      = -90.  ;negative for southern hemisphere
  latN                                      =   0.  ;negative for southern hemisphere
  figstr                                    = "0-90S"

;define the pressure levels for cross-section plot 
  pout                                      = asciiread("pres_lev.txt",-1,"float")
  pout@longname                             = "lev"
  pout@units                                = "mb"

;read in two files

  do kk = 0, dimsizes(seasons)-1
 
       f                                       = systemfunc("ls $TPATH/*"+seasons(kk)+"_means.nc")
       f1                                      = addfile(f,"r")
       ps1                                     = f1->PS(:,{latS:latN},:)
       ha1                                     = doubletofloat(f1->hyam)
       hb1                                     = doubletofloat(f1->hybm)
       p0                                      = doubletofloat(f1->P0)
       p1                                      = pres_hybrid_ccm(ps1,p0,ha1,hb1)
       p1                                      = p1/100.
       gw1                                     = doubletofloat(f1->gw)

      if(compare.eq."Model_vs_OBS") then
        f                                       = systemfunc("ls $CPATH/*_prelev_analysis_*_"+seasons(kk)+".nc")
        f2                                      = addfile(f,"r")
        ps2                                     = -9999.0
        gw2                                     = doubletofloat(f2->gw)
        p2                                      = f2->t(:,:,{latS:latN},:)
        p2                                      = conform(f2->t(:,:,{latS:latN},:),doubletofloat(f2->lev),1)
      else
        f                                       = systemfunc("ls $CPATH/*"+seasons(kk)+"_means.nc")
        f2                                      = addfile(f,"r")
        ps2                                     = f2->PS(:,{latS:latN},:)
        ha2                                     = doubletofloat(f2->hyai)
        hb2                                     = doubletofloat(f2->hybi)
        p2                                      = pres_hybrid_ccm(ps2,p0,ha2,hb2)
        p2                                      = p2/100.
        gw2                                     = doubletofloat(f2->gw)
      end if


     do jj = 0, dimsizes(vars)-1

        varnam                              = vars(jj)

        if  ( varnam .eq. "Q" ) then
          var1                                  = f1->$varnam$(:,:,{latS:latN},:)
          var1                                  = var1*1000.0
          var1@units                            = "g kg~S~-1~N~"

          if (compare.eq."Model_vs_OBS") then
            var2                                = f2->q(:,:,{latS:latN},:)
            var2                                = var2*1000.0
            var2@units                          = "g kg~S~-1~N~"
          else
            var2                                = f2->$varnam$(:,:,{latS:latN},:)
            var2                                = var2*1000.0
            var2@units                          = "g kg~S~-1~N~"

          end if 
          s1                                    = (/1,2,3,4,5,6,7,9,11,12,13,15/)
          s2                                    = (/-1.,-0.5,-0.2,-0.1,-0.05,-0.02,0.02,0.05,0.1,0.2,0.5,1./)
          s3                                    = (/-100,-50,-20,-10,-5,-2,2,5,10,20,50,100/)

        else if ( varnam .eq. "RELHUM" ) 
          var1                                  = f1->$varnam$(:,:,{latS:latN},:)

          if (compare.eq."Model_vs_OBS") then
            var2                                = f2->r(:,:,{latS:latN},:)
          else
            var2                                = f2->$varnam$(:,:,{latS:latN},:)
          end if
          s1                                    = (/10,20,30,40,50,60,70,75,80,85,90,95/)
          s2                                    = (/-50.,-20.,-10.,-5.,-2.,-1.,1.,2.,5.,10.,20.,50./)
          s3                                    = (/-100,-50,-20,-10,-5,-2,2,5,10,20,50,100/)

         else if ( varnam .eq. "T" )
          var1                                  = f1->$varnam$(:,:,{latS:latN},:)

          if (compare.eq."Model_vs_OBS") then
            var2                                = f2->t(:,:,{latS:latN},:)
          else
            var2                                = f2->$varnam$(:,:,{latS:latN},:)
          end if
          s1                                    = (/190,200,210,220,230,240,250,260,270,280,290,295/)
          s2                                    = (/-10.,-5.0,-2.0,-1.0,-0.5,-0.2,0.2,0.5,1.0,2.0,5.0,10./)
          s3                                    = (/-30,-20,-10,-5,-2,-1,1,2,5,10,20,30/)/1.0

         else if ( varnam .eq. "U")
          var1                                  = f1->$varnam$(:,:,{latS:latN},:)

          if (compare.eq."Model_vs_OBS") then
            var2                                = f2->u(:,:,{latS:latN},:)
          else
            var2                                = f2->$varnam$(:,:,{latS:latN},:)
          end if
          s1                                    = (/-20,-15,-10,-5,0,5,10,15,20,25,30,40/)
          s2                                    = (/-10.,-5.,-2.,-1.,-0.5,-0.2,0.2,0.5,1.,2.,5.,10./)
          s3                                    = (/-100,-50,-20,-10,-5,-2,2,5,10,20,50,100/)

         else if ( varnam .eq. "OMEGA")
          var1                                  = f1->$varnam$(:,:,{latS:latN},:)
          var1                                  = var1*24.0*3600.0
          var1@units                            = "hPa day~S~-1~N~"

          if (compare.eq."Model_vs_OBS") then
            var2                                = f2->w(:,:,{latS:latN},:)
            var2                                = var2*24.0*3600.0
            var2@units                          = "hPa day~S~-1~N~"

          else
            var2                                = f2->$varnam$(:,:,{latS:latN},:)
            var2                                = var2*24.0*3600.0
            var2@units                          = "hPa day~S~-1~N~"
          end if
          s1                                    = (/-20,-15,-10,-5,0,5,10,15,20,25,30,40/)
          s2                                    = (/-12.,-8.,-4.,-2.,-1.,-0.1,0.1,1.,2.,4.,8.,12./)
          s3                                    = (/-100,-50,-20,-10,-5,-2,2,5,10,20,50,100/)

         end if 
         end if 
         end if 
         end if 
         end if 

        ddd1                                = dimsizes(var1)
        ddd2                                = dimsizes(var2)

        plot                                = new((/4/),graphic)

        wtype                               = "eps"
       ;wtype@wkWidth                       = 2500
       ;wtype@wkHeight                      = 2500
        figdir                              = casedir+"/Pressure-Latitude_Zonal_Mean_Contour/"
        fe                               = vars(jj)+"_"+seasons(kk)+"_lathgt"+"_"+figstr
        wks                                 = gsn_open_wks(wtype, figdir + fe)

        gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")             ; merge two color maps

        ;printVarSummary(p1)
        ;printVarSummary(var1)

        vp1                                 = int2p_n_Wrap(p1,var1,pout,2,1)
        vp2                                 = int2p_n_Wrap(p2,var2,pout,2,1)

        ;;generate the weighting metrics
        mcor                          = new((/ddd1(1),ddd1(2)/),float)
        mcor@_FillValue               = var1@_FillValue
        do i = 0, ddd2(1)-1
           mcor(i,:)                  = gw1(i)*(2.*pi/ddd1(2))*rearth^2.
        end do

        if(str_lower(statistical_test).eq."true")then
         l_plot_ttest = True
         xtmp = var1(lat|:,lon|:,time|:)       ; reorder but do it only once [temporary]
         ytmp = var2(lat|:,lon|:,time|:)
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
           res@tmXBValues                   = ispan(toint(latS),toint(latN),15)
           res@tmXBLabels                   = (/"90S","75S","60S","45S","30S","15S","0", \
                                                "15N","30N","45N","60N","75N","90N"/)
           res@tmXBMinorValues              = ispan(toint(latS),toint(latN),5)

           res@tmYLMode                     = "Explicit"                ; explicit labels
           res@tmYLValues                   = (/ 1000, 850, 700, 500, 300, 200, 100, 10, 1/)
           res@tmYLLabels                   = ""+res@tmYLValues         ; make strings

           res@lbLabelBarOn                 = True
           res@lbOrientation                = "Vertical"
           res@cnInfoLabelOn                = False
           res@cnLevelSelectionMode         = "ExplicitLevels"       ; manual levels
           res@cnMissingValFillColor        = "gray76"               ; black = 1
           res@cnLevels                     = sprintf("%5.2f",s1)
           res@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,14,15/)
           res@gsnRightStringFontHeightF    = 0.025
           res@gsnRightStringOrthogonalPosF = 0.02
           res@trYReverse                   = True
           res@tiYAxisString                = "Pressure (hPa)"
           res@gsnLeftStringFontHeightF     = 0.025
           res@gsnLeftStringOrthogonalPosF  = 0.015

           res@gsnLeftString                = case1name
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(vp1a(:,:)))
           plot(0)              = gsn_csm_contour(wks,vp1a(:,:),res)

           res@gsnLeftString                = case2name
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(vp2a(:,:)))
           plot(1)              = gsn_csm_contour(wks,vp2a(:,:),res)

           res@cnLevels                     = sprintf("%7.2e",s2)
           res@cnFillColors                 = (/18,20,21,22,23,24,0,27,28,29,30,31,33/)              ; contour interval
           res@gsnLeftString                = case1name + " - " + case2name ; "absolute difference"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(adiff(:,:)))
           plot(2)              = gsn_csm_contour(wks,adiff(:,:),res)

           res@cnLevels                     = sprintf("%7.2f",s3)
           res@gsnLeftString                = "relative diff. (%)"
           res@gsnRightString               = "mean: "+sprintf("%5.2f",avg(rdiff(:,:)))
           plot(3)              = gsn_csm_contour(wks,rdiff(:,:),res)

           pres                             = True        ; panel plot mods desired
           pres@gsnMaximize                 = False       ; fill the page
           pres@txFontHeightF               = 0.015       
           pres@txFontThicknessF            = 2.
           pres@gsnPanelXWhiteSpacePercent  = 3.
           pres@gsnPanelYWhiteSpacePercent  = 5.
           pres@txString                    = str_upper(vars(jj))+" ("+seasons(kk)+"; unit: "+ vp1a@units+")"
           gsn_panel(wks,(/plot(:)/),(/2,2/),pres)

          ;if (wtype .eq. "png") then
          ;   tmpa = systemfunc("convert "+fe+".png -trim del.png")
          ;   tmpb = systemfunc("mv del.png "+fe+".png")
          ;end if

           delete([/var1,var2,vp1a,vp2a,adiff,rdiff,vp1,vp2,vp1b,vp2b,wks/])

        delete([/plot,res,pres,ddd1,ddd2,s1,s2/])

     end do       ; end of looping over variables

     delete([/f1,ps1,ha1,hb1,p0,p1/])

     if(compare.eq."Model_vs_OBS") then
       delete([/f2,ps2/])
     else
       delete([/f2,ps2,ha2,hb2,p2/])
     end if 

  end do          ; end of looping over seasonsons

end
