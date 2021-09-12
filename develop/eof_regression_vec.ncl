  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a eof plot for AAO patterns 
;          Data is vertically interpolated to pressure levels
;          1st panel: EOFs for the first three modes
;          2nd panel: time series plot
; Author : Shixuan Zhang
; Date   : Dec 06, 2020

begin

  compare                                      = getenv("COMPARE")
  tpath                                        = getenv("TPATH")
  cpath                                        = getenv("CPATH")
  case1                                        = getenv("TEST")
  case2                                        = getenv("CTRL")
  case1name                                    = getenv("CTRL_NAME")
  case2name                                    = getenv("TEST_NAME")   
  casedir                                      = getenv("CASEDIR")

;define constants for unit conversion
  pi                                           = 3.14159265
  rearth                                       = 6.37122e6

;variable name in the climo file
  eofvar                                       = ("PSL")
  regvar                                       = (/"UBOT","VBOT"/)
  seasons                                      = (/"ANN","DJF","JJA"/)
  preslev                                      = (/"Surface"/)

  maxlev                                       = 11 
  minlev_eof1                                  = (/-200.,-0.5, -0.5/)              
  maxlev_eof1                                  = (/ 200., 0.5,  0.5/)
    
  minlev_eof2                                  = (/-100.,-0.5, -0.5/)
  maxlev_eof2                                  = (/ 100., 0.5,  0.5/)

  minlev_eof3                                  = (/-100.,-0.5, -0.5/)
  maxlev_eof3                                  = (/ 100., 0.5,  0.5/)
 
;define regions for eof analysis
  latS                                         = -90.  ;negative for southern hemisphere
  latN                                         = -20.  ;negative for southern hemisphere

;define # of desired EOFs
  neof                                         = 3     ; Leading EOF only

;read in two files

  do ll = 0,dimsizes(preslev) - 1

     do kk = 0,dimsizes(seasons) - 1

        f                                   = systemfunc("ls $TPATH/*"+seasons(kk)+"_means.nc")
        f1                                     = addfile(f,"r")
        ps1                                    = f1->PS
        ha1                                    = doubletofloat(f1->hyam)
        hb1                                    = doubletofloat(f1->hybm)
        p0                                     = doubletofloat(f1->P0)
        p1                                     = pres_hybrid_ccm(ps1,p0,ha1,hb1)
        p1                                     = p1/100.
        gw1                                    = doubletofloat(f1->gw)

        f                                   = systemfunc("ls $CPATH/*"+seasons(kk)+"_means.nc")
        f2                                     = addfile(f,"r")
        ps2                                    = f2->PS
        ha2                                    = doubletofloat(f2->hyam)
        hb2                                    = doubletofloat(f2->hybm)
        p2                                     = pres_hybrid_ccm(ps2,p0,ha2,hb2)
        p2                                     = p2/100.
        gw2                                    = doubletofloat(f2->gw)

        do jj = 0, dimsizes(vars)-1

           varnam                              = vars(jj)
           var1                                = f1->$varnam$
           var2                                = f2->$varnam$
           
           ddd1                                = dimsizes(var1)
           ddd2                                = dimsizes(var2)
 
           vp1                                 = var1 
           vp2                                 = var2

           vp1@_FillValue                      = -999.
           vp2@_FillValue                      = -999.
           vp1x                                = vp1
           vp2x                                = vp2


           if  ( ddd1(2) .lt. ddd2(2) ) then

               lat1                         = f1->lat
               lon1                         = f1->lon
               lat2                         = f2->lat
               lon2                         = f2->lon
               poisson_grid_fill(vp2x,True,1,1000,1e-2,0.5,0)
               vp2a                         = area_conserve_remap_Wrap (lon2,lat2,vp2x, lon1,lat1, False)
               vp1a                         = vp1x
               delete([/lat1,lon1,lat2,lon2,vp1x,vp2x,var1,var2/])
           end if
                          
           if  ( ddd1(2) .gt. ddd2(2) ) then
               lat1                         = f1->lat
               lon1                         = f1->lon
               lat2                         = f2->lat
               lon2                         = f2->lon
               poisson_grid_fill(vp1x,True,1,1000,1e-2,0.5,0)
               vp1a                         = area_conserve_remap_Wrap (lon1,lat1,vp1x, lon2,lat2, False)
               vp2a                         = vp2x
               delete([/lat1,lon1,lat2,lon2,vp1x,vp2x,var1,var2/])
           end if

           if  ( ddd1(2) .eq. ddd2(2) ) then
               vp1a                         = vp1x
               vp2a                         = vp2x
               delete([/var1,var2,vp1x,vp2x/])
          end if

       ; ==============================================================
       ; User defined parameters that specify region of globe and
       ; ==============================================================
         x1     = vp1a(:,{latS:latN},:)
         y1     = vp2a(:,{latS:latN},:)

       ; ==============================================================
       ; compute climatology and Anomalies
       ; ==============================================================
         xClm   = dim_avg_n_Wrap(x1,0)                      ; (12,lat,lon)
         yClm   = dim_avg_n_Wrap(y1,0)

         xAnom  = x1
         yAnom  = y1
        
         xAnom  = x1 - conform(x1,xClm,(/1,2/))
         yAnom  = y1 - conform(y1,yClm,(/1,2/))

         ;printVarSummary(xAnom)         
         ;printMinMax(xAnom, True)

       ; =================================================================
       ; create weights:  sqrt(cos(lat))   [or sqrt(gw) ]
       ; =================================================================
         rad    = get_d2r("float")
         xclat  = xAnom&lat            
         xclat  = sqrt( cos(rad*xclat) )                 ; gw for gaussian grid
         yclat  = yAnom&lat 
         yclat  = sqrt( cos(rad*yclat) )                 ; gw for gaussian grid
   
       ; =================================================================
       ; weight all data 
       ; =================================================================
         xw     = xAnom*conform(xAnom, xclat, 1)
         yw     = yAnom*conform(yAnom, yclat, 1)
         copy_VarMeta(x1, xw)
         copy_VarMeta(y1, yw) 
         xw@long_name = "Wgt: "+x1@long_name
         yw@long_name = "Wgt: "+y1@long_name
       
       ; =================================================================
       ; Compute EOFs & Standardize time series
       ; =================================================================
         optEOF  = True
         optETS  = False

         eof1    = eofunc_n_Wrap(xw, neof, optEOF, 0)      
         eof2    = eofunc_n_Wrap(yw, neof, optEOF, 0)
    
         do n = 0,neof-1
          pcor = pattern_cor(eof1(n,:,:),eof2(n,:,:),1.0,0)
          if(pcor.lt.0)then
            eof2(n,:,:) = eof2(n,:,:) * -1.0
          end if
         end do 

         eof1_ts = eofunc_ts_n_Wrap (xw, eof1, optETS, 0)
         eof2_ts = eofunc_ts_n_Wrap (yw, eof2, optETS, 0)

         eof1_ts = dim_standardize_n( eof1_ts, 0, 1)      ; normalize
         eof2_ts = dim_standardize_n( eof2_ts, 0, 1)      ; normalize

         ;printVarSummary( eof1 )                         ; examine EOF variables
         ;printVarSummary( eof1_ts )

         ;printVarSummary( eof2 )                         ; examine EOF variables
         ;printVarSummary( eof2_ts )

       ; =================================================================
       ; Regress
       ; =================================================================

         eof1_regres = eof1                               ; create an array w meta data
         eof2_regres = eof2                               ; create an array w meta data
         do ne=0,neof-1
            eof1_regres(ne,:,:) = (/ regCoef_n(eof1_ts(ne,:), xAnom, 0, 0) /)
            eof2_regres(ne,:,:) = (/ regCoef_n(eof2_ts(ne,:), yAnom, 0, 0) /)
         end do

       ; =================================================================
       ; Extract the YYYYMM from the time coordinate 
       ; associated with eof_ts [same as x&time] 
       ; =================================================================

         utc_date1 = cd_calendar(eof1_ts&time,0)  
         utc_date2 = cd_calendar(eof2_ts&time,0)
         
         yyyy1     = utc_date1(:,0)
         yyyy2     = utc_date2(:,0)
 
       do n = 0, neof-1

         wks                                 = gsn_open_wks("eps",casedir+"/set03/"+vars(jj)+"_"+seasons(kk)+"_eof"+sprinti("%02d",n+1)+"_"+preslev(ll))
         plot      = new((/4/),graphic)
         tsmap1    = new((/4/),graphic)
         tsmap2    = new((/4/),graphic)
      
       ;============================================================
       ; PLOTS
       ;============================================================
         res                      = True         
         res@gsnDraw              = False        ; don't draw yet
         res@gsnFrame             = False        ; don't advance frame yet
         res@gsnPolar             = "SH"
 
         res@mpFillOn             = False        ; turn off map fill
         res@mpMaxLatF            = latN
        ;res@mpCenterLonF         = 180

         FontHeightF = 0.018
         res@tiMainFontHeightF        = FontHeightF*1.5
         res@tmYLLabelFontHeightF     = FontHeightF
         res@tmXBLabelFontHeightF     = FontHeightF
         res@lbLabelFontHeightF       = FontHeightF
         res@gsnStringFontHeightF     = FontHeightF*1.2

         res@cnFillOn                 = True         ; turn on color fill
         res@cnFillPalette            = "BlueWhiteOrangeRed"  
         res@cnLinesOn                = False        ; True is default
         res@cnLineLabelsOn           = False        ; True is default

         res@lbLabelBarOn             = True
         res@lbOrientation            = "Vertical"
         res@lbTitleString            = varnam +" ("+xAnom@units+")" ;Geopential height (gpm)";
         res@lbTitlePosition          = "Right"                           ; title location
         res@lbTitleDirection         = "Across"                          ; letter angle
         res@lbTitleAngleF            = 90.                               ; title angle
         res@lbTitleFontHeightF       = FontHeightF                    ; font height
        ;res@pmLabelBarParallelPosF   = 0.61
         res@pmLabelBarOrthogonalPosF = 0.15

         res@tmXTOn                   = False
         res@tmYLLabelFontHeightF     = 0.025
         res@tmBorderThicknessF       = 1.0
         res@tmXBMajorThicknessF      = 1.0
         res@tmXBMinorThicknessF      = 1.0
         res@tmYLMajorThicknessF      = 1.0
         res@tmYLMinorThicknessF      = 1.0
         res@tmYRMajorThicknessF      = 1.0
         res@tmYRMinorThicknessF      = 1.0

        ;set symmetric plot min/ma
        ;tmpdat = (/eof1_regres,eof2_regres/)
        ;symMinMaxPlt(tmpdat, 16, False, res)      ; contributed.ncl
        ;delete(tmpdat)

        res@cnLevelSelectionMode = "ManualLevels"  ; manually set the contour levels with the following 3 resources
        if(n.eq.0)then
          mnmxint = nice_mnmxintvl( minlev_eof1(jj), maxlev_eof1(jj), maxlev, False)
        else if (n.eq.1)then 
          mnmxint = nice_mnmxintvl( minlev_eof2(jj), maxlev_eof2(jj), maxlev, False)
        else
          mnmxint = nice_mnmxintvl( minlev_eof3(jj), maxlev_eof3(jj), maxlev, False)
        end if 
        end if
  
        res@cnMinLevelValF           = mnmxint(0) ; set the minimum contour level
        res@cnMaxLevelValF           = mnmxint(1) ; set the maximum contour level     
        res@cnLevelSpacingF          = mnmxint(2) ; *special* match CPC

        delete([/mnmxint/])

       ;*******************************************
       ; first plot
       ;*******************************************
          res@mpLabelFontHeightF           = FontHeightF*2.0
          res@gsnPolarLabelFontHeightF     = FontHeightF

          ;---Draw first plot in upper left corner
          res@gsnLeftString     = "EOF "+(n+1)
          res@gsnRightString    = sprintf("%5.1f", eof1@pcvar(n)) +"%"
          res@gsnCenterString   = "" ;case1name
          res@tiMainString      = "Case: "+case1name
          plot(0)   = gsn_csm_contour_map_polar(wks,eof1_regres(n,:,:),res)

          ;---Draw second plot in upper right corner
          res@gsnLeftString     = "EOF "+(n+1)
          res@gsnRightString    = sprintf("%5.1f", eof2@pcvar(n)) +"%"
          res@gsnCenterString   = "" ;case2name
          res@tiMainString      = "Case: "+case2name
          plot(1) = gsn_csm_contour_map_polar(wks,eof2_regres(n,:,:),res)
      
       ;*******************************************
       ; second plot
       ;*******************************************
        ; EOF time series  [bar form]

          rts           = True
          rts@gsnDraw   = False       ; don't draw yet
          rts@gsnFrame  = False       ; don't advance frame yet
          rts@gsnScale  = True        ; force text scaling               

          rts@tiYAxisString = "Standardized"          ; y-axis label      

          rts@vpHeightF = 0.40        ; Changes the aspect ratio
          rts@vpWidthF  = 0.85
          rts@vpXF      = 0.10        ; change start locations
          rts@vpYF      = 0.75        ; the plot

          rts@gsnYRefLine           = 0.              ; reference line   
          rts@gsnXYBarChart         = True            ; create bar chart 
          rts@gsnAboveYRefLineColor = "red"           ; above ref line fill red
          rts@gsnBelowYRefLineColor = "blue"          ; below ref line fill blue

          rts@tmXTOn                       = False
          rts@tmYLLabelFontHeightF         = 0.025
          rts@tmBorderThicknessF           = 1.0
          rts@tmXBMajorThicknessF          = 1.0
          rts@tmXBMinorThicknessF          = 1.0
          rts@tmYLMajorThicknessF          = 1.0
          rts@tmYLMinorThicknessF          = 1.0
          rts@tmYRMajorThicknessF          = 1.0
          rts@tmYRMinorThicknessF          = 1.0

          rts@trYMinF                      = -3.0
          rts@trYMaxF                      =  3.0

         ;create individual plots
         ;---Draw third plot in lower left corner
          rts@gsnLeftString     = "EOF "+(n+1)
          rts@gsnRightString    = sprintf("%5.1f", eof1_regres@pcvar(n)) +"%"
          rts@tiMainString      = "" ;"Case: "+case1name
          plot(2) = gsn_csm_xy (wks,yyyy1,eof1_ts(n,:),rts)
           
          rts1 = rts
          rts1@gsnXYBarChart       = False
          rts1@gsnLeftString       = ""
          rts1@gsnRightString      = ""
          rts1@gsnCenterString     = ""
          rts1@xyLineThicknesses   = 3            
          rts1@xyLineColors        = "Black"
          xyarr1                   = wgt_runave_Wrap(eof1_ts(n,:),(/1.,3,5,6,5,3,1/), 0)   
          tsmap1(2)            = gsn_csm_xy(wks,yyyy1,xyarr1,rts1) 
          overlay(plot(2),tsmap1(2))
          delete([/xyarr1/])


          ;---Draw fourth plot in upper right corner
          rts@gsnLeftString        = "EOF "+(n+1)
          rts@gsnRightString       = sprintf("%5.1f", eof2_regres@pcvar(n)) +"%"
          rts@tiMainString         = "" ;"Case: "+case2name
          plot(3) = gsn_csm_xy (wks,yyyy2,eof2_ts(n,:),rts)

          rts2 = rts
          rts2@gsnXYBarChart       = False
          rts2@gsnLeftString       = ""
          rts2@gsnRightString      = ""
          rts2@gsnCenterString     = ""
          rts2@xyLineThicknesses   = 3 
          rts2@xyLineColors        = "Black"
          xyarr2                   = wgt_runave_Wrap(eof2_ts(n,:),(/1.,3,5,6,5,3,1/), 0) 
          tsmap2(3)            = gsn_csm_xy(wks,yyyy2,xyarr2,rts2)
          overlay(plot(3),tsmap2(3))
          delete([/xyarr2/])

       ; panel plot only resources
          pres1                          = True                ; mods desired
          pres1@gsnFrame                 = False               ; save panel until both ready
          pres1@gsnPanelBottom           = 0.45    ; space for label bar
          pres1@gsnPanelTop              = 0.85     ; only panel on lower half of page
          pres1@gsnPanelXF               = (/0.07,0.57/)
          gsn_panel(wks,plot(0:1),(/1,2/),pres1)          ; create first panel
          
          pres2                           = True                ; mods desired
          pres2@gsnFrame                  = False               ; save panel until both ready
          pres2@gsnPanelBottom            = 0.05                ; draw from center to right edge
          pres2@gsnPanelTop               = 0.5		       ; draw from center to right edge 
          gsn_panel(wks,plot(2:3),(/1,2/),pres2)       ; create first panel
       
          frame(wks)                                   ; draw both on same page

         ;delete([/xyarr1,xyarr2,tsmap1,tsmap2/])
         end do ; end of eof mods 
 
         delete([/xAnom,yAnom,x1,y1,xclat,yclat,eof1,eof2/])
         ;delete([/f1,ps1,ha1,hb1,p0,p1,f2,ps2,ha2,hb2,p2/])
          
        end do                                              ; end of looping over variables
     end do                                                 ; end of looping over seasons

  end do                                                    ; end of looping over pressure levels


end

