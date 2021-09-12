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

  compare                                    = getenv("COMPARE")
  outdir                                     = getenv("CASEDIR")
  opath                                      = getenv("DIAG_DATA_ROOT")
  sampath                                    = getenv("WKROOT")

  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")

  tcase                                      = getenv("TEST")
  ccase                                      = getenv("CTRL")

  tname                                      = getenv("TNAME")
  cname                                      = getenv("CNAME")

  tttag                                      = getenv("TTTAG")
  cttag                                      = getenv("CTTAG")

;define regions for eof analysis
  latS                                       = -65.  ;negative for southern hemisphere
  latN                                       = -40.  ;negative for southern hemisphere

;define # of desired EOFs
  neof                                       = 3     ; Leading EOF only

;define constants for unit conversion
  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.80665

 print(cname + " " +tname)
;variable name in the climo file
  modvars                                    = (/"PSL"/)
  facmod                                     = (/1.0/100.0/)
  varunt                                     = (/"hPa"/)
  panelstr1                                  = tname + " ("+tttag+")"
  panelstr2                                  = cname + " ("+cttag+")"

  if((cname.eq."ERA5").or.(cname.eq."ERA20C"))
     obsvars                                 = (/"msl"/)
     facobs                                  = (/1.0/100.0/)
  else if (cname.eq."NOAA20C")
     obsvars                                 = (/"prmsl"/)
     facobs                                  = (/1.0/100.0/)
  else
    print("The observational source are not available; only allow ERA5, ERA20C or NOAA20C")
    exit
  end if
  end if

;declear the season or annual mean data to be used;;;;;
  seasons                                    = (/"monthly"/)
  pout                                    = (/"Surface"/)

  maxlev                                     = 11 
  minlev_eof1                                = (/-200.,-0.5, -0.5, -0.5/)              
  maxlev_eof1                                = (/ 200., 0.5,  0.5,  0.5/)
    
  minlev_eof2                                = (/-100.,-0.5, -0.5, -0.5/)
  maxlev_eof2                                = (/ 100., 0.5,  0.5,  0.5/)

  minlev_eof3                                = (/-100.,-0.5, -0.5, -0.5/)
  maxlev_eof3                                = (/ 100., 0.5,  0.5,  0.5/)

;read the sam index file constructed by observational data;;;;
  fx1    = sampath+"/pobs/Marshall_mslp_monthly_"+toint(abs(latS))+"S.txt"
  fx2    = sampath+"/pobs/Marshall_mslp_monthly_"+toint(abs(latN))+"S.txt"
  ncol   = 13
  marshall_slp65 = readAsciiTable(fx1, ncol, "float", (/1/))
  marshall_slp40 = readAsciiTable(fx2, ncol, "float", (/1/))

;read in two files

  do ll = 0,dimsizes(pout) - 1
 
      f                                       = systemfunc("ls "+tpath+"/"+tcase+"*"+tttag+".nc")
      f1                                      = addfile(f,"r")
      gw1                                     = f1->gw

      f                                       = systemfunc("ls "+cpath+"/"+ccase+"*"+cttag+".nc")
      f2                                      = addfile(f,"r")
      gw2                                     = f2->gw

      do kk = 0, dimsizes(seasons)-1


        do jj = 0, dimsizes(modvars)-1

           mvarnam                             = modvars(jj)
           vp1                                 = f1->$mvarnam$

           if(compare.ne."Model_vs_OBS") then
             vp2                               = f2->$mvarnam$(:,{latS:latN},:)
           end if 

           if(compare.eq."Model_vs_OBS") then
             ovarnam                           = obsvars(jj)
             vp2                               = f2->$ovarnam$
           end if

           vp1                                 = vp1*facmod(jj)
           vp2                                 = vp2*facobs(jj)

           vp1@_FillValue                      = -9999.
           vp2@_FillValue                      = -9999.
           vp1@units                           = varunt(jj)
           vp2@units                           = varunt(jj)

           ;;check the two comparing files and see if they are in the same grid, 
           ;;otherwise, return the error message;;;;
           ddd1                                = dimsizes(vp1)
           ddd2                                = dimsizes(vp2)
           if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
            print("Error: this scripts requires the two files must in the same grid to run!!!")
            return
           end if

       ; ==============================================================
       ; Zonal mean SLP at 40S and 65S 
       ; ==============================================================
         marshall_year = toint(marshall_slp65(:,0))
         time = yyyymm_time(min(marshall_year), max(marshall_year), "integer")
         marshall_time = yyyymm_to_yyyyfrac(time, 0.0)
         delete([/marshall_year,time/])

         z_slp65  = ndtooned(marshall_slp65(:,1:))
         z_slp40  = ndtooned(marshall_slp40(:,1:))
         x_slp65  = z_slp65
         x_slp40  = z_slp40
         y_slp65  = z_slp65
         y_slp40  = z_slp40
        
         x_slp65@_FillValue = -9999.0
         x_slp40@_FillValue = -9999.0
         y_slp65@_FillValue = -9999.0
         y_slp40@_FillValue = -9999.0
         z_slp65@_FillValue = -9999.0
         z_slp40@_FillValue = -9999.0

         x_slp65  = -9999.0
         x_slp40  = -9999.0
         y_slp65  = -9999.0
         y_slp40  = -9999.0

       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;select the data to consturct the sam index
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        utc_date1 = cd_calendar(vp1&time,1)
        utc_date2 = cd_calendar(vp2&time,1)
        yyyy1     = yyyymm_to_yyyyfrac(utc_date1, 0.0)
        yyyy2     = yyyymm_to_yyyyfrac(utc_date2, 0.0)
        ind1      = get1Dindex(marshall_time,yyyy1)        
        ind2      = get1Dindex(marshall_time,yyyy2)
       
        if(.not.all(ismissing(ind1)))then 
         x_slp65(ind1) = dim_avg_n_Wrap(vp1(:,{latS},:),1)
         x_slp40(ind1) = dim_avg_n_Wrap(vp1(:,{latN},:),1)
        else
         x_slp65(0:dimsizes(yyyy1)-1)  = dim_avg_n_Wrap(vp1(:,{latS},:),1)
         x_slp40(0:dimsizes(yyyy1)-1)  = dim_avg_n_Wrap(vp1(:,{latN},:),1)
        end if 

        if (.not.all(ismissing(ind1)))then
         y_slp65  = dim_avg_n_Wrap(vp2(:,{latS},:),1)
         y_slp40  = dim_avg_n_Wrap(vp2(:,{latN},:),1)
        else 
         y_slp65(0:dimsizes(yyyy2)-1)  = dim_avg_n_Wrap(vp2(:,{latS},:),1)
         y_slp40(0:dimsizes(yyyy2)-1)  = dim_avg_n_Wrap(vp2(:,{latN},:),1)
        end if 

        delete([/vp1,vp2,ind1,ind2,yyyy1,yyyy2/])

        delete([/utc_date1,utc_date2,marshall_slp65,marshall_slp40/])
        
       ; ================================================================================================
       ; compute sam indices 
       ; Based on the numerical definition of the SAM by Gong and Wang (1999), which is:
       ; SAM = P*40�S -  P*65°S
       ; where P*40°S and P*65°S are the normalized monthly zonal sea level pressur(SLP) at 40°S and 65�
       ; ================================================================================================
         nyear = dimsizes(marshall_time)/12
         a1 = reshape(x_slp40,(/nyear,12/))
         b1 = reshape(x_slp65,(/nyear,12/))
         x_samid = ndtooned(dim_standardize_n_Wrap(a1, 0, 0) - dim_standardize_n_Wrap(b1, 0, 0))
         a1 = reshape(y_slp40,(/nyear,12/))
         b1 = reshape(y_slp65,(/nyear,12/))
         y_samid = ndtooned(dim_standardize_n_Wrap(a1, 0, 0) - dim_standardize_n_Wrap(b1, 0, 0))
         a1 = reshape(z_slp40,(/nyear,12/))
         b1 = reshape(z_slp65,(/nyear,12/))
         z_samid = ndtooned(dim_standardize_n_Wrap(a1, 0, 0) - dim_standardize_n_Wrap(b1, 0, 0))
         delete([/a1,b1/]) 
 
       ; =================================================================
       ; Extract the data for plot 
       ; ================================================================
        legends  = "  "+(/tname,cname,"Obs. (Marshall)"/)
        pltdat1  = new((/3,dimsizes(marshall_time)/),typeof(x_slp40))
        pltdat2  = new((/3,dimsizes(marshall_time)/),typeof(x_slp40))
        pltdat3  = new((/3,dimsizes(marshall_time)/),typeof(x_slp40))
        pltdat1(0,:) = (/x_slp40/)
        pltdat1(1,:) = (/y_slp40/)
        pltdat1(2,:) = (/z_slp40/)
        pltdat2(0,:) = (/x_slp65/)
        pltdat2(1,:) = (/y_slp65/)
        pltdat2(2,:) = (/z_slp65/)
        pltdat3(0,:) = (/x_samid/)
        pltdat3(1,:) = (/y_samid/)
        pltdat3(2,:) = (/z_samid/)
        delete([/x_slp40,y_slp40,z_slp40/])
        delete([/x_slp65,y_slp65,z_slp65/])
        delete([/x_samid,y_samid,z_samid/])

       ; =================================================================
       ; Start to do plot
       ; =================================================================
         wtype                        = "eps"
         figdir                       = outdir+"/tables/"
         fe                           = modvars(jj)+"_"+seasons(kk)+"_sam_index_40S_65S_slp_"+pout(ll) 
         wks                          = gsn_open_wks(wtype, figdir + fe)

         plot      = new((/3/),graphic)
         tsmap1    = new((/3/),graphic)
         tsmap2    = new((/3/),graphic)
      
       ;============================================================
       ; PLOTS
       ;============================================================
         res                      = True         
         res@gsnDraw              = False        ; don't draw yet
         res@gsnFrame             = False        ; don't advance frame yet
         res@gsnScale             = True        ; force text scaling
         res@vpHeightF            = 0.3         ; Changes the aspect ratio
         res@vpWidthF             = 0.9
         res@vpXF                 = 0.10        ; change start locations
         res@vpYF                 = 0.75        ; the plot

         FontHeightF = 0.018
         res@tiMainFontHeightF        = FontHeightF*1.5
         res@tmYLLabelFontHeightF     = FontHeightF
         res@tmXBLabelFontHeightF     = FontHeightF
         res@gsnStringFontHeightF     = FontHeightF*1.2

         res@tmXTOn                   = False
         res@tmYROn                   = False
         res@tmYLLabelFontHeightF     = 0.025
         res@tmBorderThicknessF       = 1.0
         res@tmXBMajorThicknessF      = 1.0
         res@tmXBMinorThicknessF      = 1.0
         res@tmYLMajorThicknessF      = 1.0
         res@tmYLMinorThicknessF      = 1.0
         res@tmYRMajorThicknessF      = 1.0
         res@tmYRMinorThicknessF      = 1.0

         res@gsnYRefLine              = 0.              ; reference line
         res@gsnXYBarChart            = False ;True     ; create bar chart
        ;res@gsnAboveYRefLineColor    = "red"           ; above ref line fill red
        ;res@gsnBelowYRefLineColor    = "blue"          ; below ref line fill blue
         res@xyLineColors             = (/"blue", "red", "green4"/) 
         res@xyDashPatterns           = (/0,0,0/)
         res@xyLineThicknesses        = (/3,3,3/)
         res@tiXAxisString            = "Year"          ; y-axis label

         res@pmLegendDisplayMode      = "Always"   ; Display a legend.
         res@lgPerimOn                = False      ; No legend perimeter.
         res@pmLegendSide             = "Top"
         res@pmLegendOrthogonalPosF   = -0.75      ; Move closer to plot
         res@pmLegendParallelPosF     = 1.25      ; Move closer to plot
         res@pmLegendWidthF           = 0.24                ; Change width and
         res@pmLegendHeightF          = 0.18                ; height of legend.
         res@lgBoxMinorExtentF        = 0.4
         res@lgLabelFontHeightF       = FontHeightF*1.2
         res@xyExplicitLegendLabels   = legends 

        ;*******************************************
        ; First plot
        ;*******************************************
          res0 = res
          res0@tiYAxisString           = "(hPa)"          ; y-axis label      
          res0@trYMinF                 = min(pltdat1) - max(abs(pltdat1))/100.0
          res0@trYMaxF                 = max(pltdat1) + max(abs(pltdat1))/100.0
          res0@gsnLeftString           = "Zonal mean MSLP at 40~S~o~N~S"
          res0@gsnRightString          = "hPa" 
          res0@tiMainString            = "" ;"Case: "+panelstr1
          res0@xyLineOpacities         = (/0.4,0.4,0.4/)
          res0@xyLineThicknesses       = (/1,1,1/)
          plot(0)                      = gsn_csm_xy (wks,marshall_time,pltdat1,res0)
           
          res1 = res
          res1@gsnXYBarChart          = False
          res1@gsnLeftString          = ""
          res1@gsnRightString         = ""
          res1@gsnCenterString        = ""
          xyarr1                      = wgt_runave_Wrap(pltdat1,(/1.,3,5,6,5,3,1/), 0)   
          tsmap1(0)                   = gsn_csm_xy(wks,marshall_time,xyarr1,res1) 
          overlay(plot(0),tsmap1(0))
          delete([/xyarr1/])

        ;*******************************************
        ; Second plot
        ;*******************************************
          res0 = res
          res0@tiYAxisString           = "(hPa)"          ; y-axis label
          res0@trYMinF                 = min(pltdat2) - max(abs(pltdat2))/100.0
          res0@trYMaxF                 = max(pltdat2) + max(abs(pltdat2))/100.0
          res0@gsnLeftString           = "Zonal mean MSLP at 65~S~o~N~S"
          res0@gsnRightString          = "hPa"
          res0@tiMainString            = "" ;"Case: "+panelstr1
          res0@xyLineOpacities         = (/0.4,0.4,0.4/)
          res0@xyLineThicknesses       = (/1,1,1/)
          plot(1)                      = gsn_csm_xy (wks,marshall_time,pltdat2,res0)

          res1 = res
          res1@gsnXYBarChart          = False
          res1@gsnLeftString          = ""
          res1@gsnRightString         = ""
          res1@gsnCenterString        = ""
          xyarr1                      = wgt_runave_Wrap(pltdat2,(/1.,3,5,6,5,3,1/), 0)
          tsmap1(1)                   = gsn_csm_xy(wks,marshall_time,xyarr1,res1)
          overlay(plot(1),tsmap1(1))
          delete([/xyarr1/])


        ;*******************************************
        ; Thrid plot
        ;*******************************************
          res0 = res
          res0@tiYAxisString           = "(Standardize)"          ; y-axis label
          res0@trYMinF                 = min(pltdat3) - max(abs(pltdat3))/10.0
          res0@trYMaxF                 = max(pltdat3) + max(abs(pltdat3))/10.0
          res0@gsnLeftString           = "Sam index (normalized)"
          res0@gsnRightString          = "Unitless"
          res0@tiMainString            = "" ;"Case: "+panelstr1
          res0@xyLineOpacities         = (/0.4,0.4,0.4/)
          res0@xyLineThicknesses       = (/1,1,1/)
          plot(2)                     = gsn_csm_xy (wks,marshall_time,pltdat3,res0)

          res1 = res
          res1@gsnXYBarChart          = False
          res1@gsnLeftString          = ""
          res1@gsnRightString         = ""
          res1@gsnCenterString        = ""
          xyarr1                      = wgt_runave_Wrap(pltdat3,(/1.,3,5,6,5,3,1/), 0)
          tsmap1(2)                   = gsn_csm_xy(wks,marshall_time,xyarr1,res1)
          overlay(plot(2),tsmap1(2))
          delete([/xyarr1/])

       ; panel plot only resources
          pres1                          = True                ; mods desired
          pres1@gsnFrame                 = False               ; save panel until both ready
         ;pres1@gsnPanelBottom           = 0.45    ; space for label bar
         ;pres1@gsnPanelTop              = 0.85     ; only panel on lower half of page
         ;pres1@gsnPanelXF               = (/0.07,0.57/)
          gsn_panel(wks,plot,(/3,1/),pres1)          ; create first panel
          frame(wks)                                   ; draw both on same page

        end do                                              ; end of looping over seasons

        end do                                                 ; end of looping over variables

        delete([/f1,gw1/])
        delete([/f2,gw2/])

  end do                                                    ; end of looping over pressure levels


end

