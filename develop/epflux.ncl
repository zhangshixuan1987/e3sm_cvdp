;----------------------------------------------------------------------
; epflux_2.ncl
;
; Concepts illustrated:
;   - Reading variables
;   - Using cd_inv_calendar and indexing subscripting to access a time segment
;   - Using the 'epflux' to calculate EP-fluxes
;   - Extracting data from a variable of type 'list'
;   - Plotting vectors and overlaying contours 
;=======================================================================
;                  MAIN: 6.4.0 or later
;=======================================================================
; All needed libraries are automatically loaded
;=======================================================================

;---Set options

  show_accel = 0                 ; plot option
  dataflag   = "dailyavg"        ; '4xdaily' or 'dailyavg'

  pltDir     = "./"              ; dir for output plot
  pltType    = "png"             ; getenv("pltType")
  pltRoot    = "epflux"          ; getenv("pltRoot")

;---Set date explicitly or via  environment variables

                                 ; 'getenv' are from the original (NOAA) code
  yearStrt  = 2016               ; toint(getenv("yearStrt"))
  monStrt   =   12               ; toint(getenv("monStart"))
  dayStrt   =    7               ; toint(getenv("dayStart"))

  yearLast  = 2016               ; toint(getenv("yearLast"))
  monLast   =   12               ; toint(getenv("monLast"))
  dayLast   =    7               ; toint(getenv("dayLast"))
  
                                 ; specify the sampling interval  
  if (.not.(dataflag.eq."dailyavg" .or. dataflag.eq."4xdaily")) then
      print("EP_FLUX: dataflag not recognized")
      print("         dataflag="+dataflag )    
      exit
  end if

  hourStrt = 0
  if (dataflag .eq. "dailyavg") then
    hourLast  = 0
    avgoffset = 24
  else
    hourLast = 18
    avgoffset = 6
  end if

; open files and get some basic coordinate information.  
; file names; open each; size information  

  dir     = "./"                      ; directory with files
  ufil    = "uwnd.2016.nc"            ; NCEP Reanalysis 
  vfil    = "vwnd.2016.nc"
  tfil    = "air.2016.nc"
  
  uf      = addfile(dir+ufil, "r")    ; file references (pointers)
  vf      = addfile(dir+vfil, "r")
  tf      = addfile(dir+tfil, "r")

; access the specified time period
  
  TIME    = uf->time                  ; all times on file: "hours since ..."
  YMDH    = cd_calendar(TIME, -3)     ; YYYYMMDDHH

  ymdhStrt= yearStrt*1000000 + monStrt*10000 + dayStrt*100 + hourStrt
  ymdhLast= yearLast*1000000  + monLast*10000  + dayLast*100  + hourLast

                                      ; find appropriate indices
  iStrt   = ind(ymdhStrt.eq.YMDH)     ; time start index
  iLast   = ind(ymdhLast.eq.YMDH)     ; time last  index
  tStrt   = TIME(iStrt)               ; extract file times
  tLast   = TIME(iLast)

  print("tStrt="+tStrt+": yr="+yearStrt+"  mon="+monStrt\
       +"  day="+dayStrt+"  hr="+hourStrt )
  print("tLast="+tLast+": yr="+yearLast+"  mon="+monLast \
       +"  day="+dayLast+"  hr="+hourLast )

; import the desired variables for the specified time period
                                                      ; (time,level,lat,lon)
  U       = uf->uwnd(iStrt:iLast,:,:,:)    ; m/s
  V       = vf->vwnd(iStrt:iLast,:,:,:)
  T       = tf->air (iStrt:iLast,:,:,:)    ; degK

;---Compute EP-Flux and other quantities
;   For NCEP reanalysis: 
;   plvl=(/1000,925,850,700,600,500,400,300,250,200,150,100,70,50,30,20,10/)

  lat     = U&lat
  plvl    = U&level 
  sf      =    5.0        ; tofloat(getenv("sc_fact_start"))
                          ; stratospheric magnification factor (plot) 
                          ; NOAA used an environment variable
  opt     = True          
  opt@magf= sf            ; make NCL attribute for use by 'epflux'
  opt@print_var_info = False   ; True (print); False (no Print)

  epf     =  epflux(U,V,T,plvl,lat,opt)   

  Fphi  = epf[0]          ; extract variables from 'list' for clarity
  Fp    = epf[1]
  EPdiv = epf[2]
  dudt  = epf[3]
  delete(epf)             ; delete list variable; no longer needed
                          ; cursory overview of variable contents
  printVarSummary(Fphi)
  printMinMax(Fphi, 0)
  print("+++")
  printVarSummary(Fp)
  printMinMax(Fp, 0)
  print("+++")
  printVarSummary(EPdiv)
  printMinMax(EPdiv, 0)
  print("+++")
  printVarSummary(dudt)
  printMinMax(dudt, 0)
  print("+++")
  
  monthname = (/"January  ","February ","March    ","April    " \
               ,"May      ","June     ","July     ","August   " \
               ,"September","October  ","November ","December " /)
  
; plot title
; .  avgper is calculated from the first and last times (in hours).  
; .  avgoffset is determined from the dataflag
; .  **** This assumes that time has units "hours since ..."   ****

  avgper = round((tLast - tStrt + avgoffset)/24 ,3) ; Note:  round(.,3) outputs type integer

  if ( avgper .eq. 1 ) then
       vectitle =   "EPFlux: " + avgper + " day average " + \
                    dayLast + " " + monthname(monLast-1) + " " + yearLast
  else 
       vectitle =   "EPFlux  " + avgper + " day average ending  " + \
                     dayLast + " " + monthname(monLast-1) + " " + yearLast
  end if
  
 ;pltID   = pltRoot+"." + sprinti("%i",avgper) + "davg."      \
 ;                 + sprinti("%0.4i",yearLast)  \
 ;                 + sprinti("%0.2i",monLast)   \
 ;                 + sprinti("%0.2i",dayLast)

  ;************************************************
  ; Create Plot 
  ;************************************************
  ; create vector plot resources for pressure-level grid 
  ;************************************************
    res_vec = True
    res_vec@gsnMaximize           = True              ; make ps/eps/pdf large (no effect otherwise)
    res_vec@gsnDraw               = False             ; allows for manual overlaying        
    res_vec@gsnFrame              = False        

    res_vec@vfXArray              = lat               ; use lat for x axis
    res_vec@vfYArray              = plvl              ; use pressure for y axis
    res_vec@trYReverse            = True              ; reverse y-axis
    res_vec@gsnYAxisIrregular2Log = True              ; set y-axis to log scale

    res_vec@tiXAxisString         = "latitude"        ; x-axis label
    res_vec@tiYAxisString         = "pressure (mb)"   ; y-axis label
    res_vec@tiXAxisFontHeightF    = 0.0175
    res_vec@tiYAxisFontHeightF    = 0.0175

    res_vec@vcRefMagnitudeF       = 200               ; add a reference vector
    res_vec@vcRefLengthF          = 0.05              ; what the ref length is
    res_vec@vcMonoLineArrowColor  = False             ; vec's colored by their mag
    res_vec@vcLevelPalette        = "rainbow"         
    res_vec@vcLevelSelectionMode  = "ManualLevels"
    res_vec@vcLevelSpacingF       = 25.0
    res_vec@vcMinLevelValF        = 0.0
    res_vec@vcMaxLevelValF        = 400.0
    res_vec@vcRefAnnoOn           = False              ; turn off ref wind barb
    res_vec@vcMinDistanceF        = 0.00875            ; trial and error
  
    res_vec@pmLabelBarDisplayMode = "Always"          ; Turn on a label bar.
    res_vec@pmLabelBarWidthF      = 0.08              ; make it thinner
    res_vec@lbPerimOn             = False             ; no box around it

    res_vec@tiMainString          = vectitle          ; plot title
    res_vec@tiMainFontHeightF     = 0.0185

    res_vec@tmXBLabelFontHeightF  = 0.0125
    res_vec@tmYLLabelFontHeightF  = 0.0125
    res_vec@tmXBMajorLengthF      = -0.0075           ; minus mean outward face
    res_vec@tmYLMajorLengthF      = -0.0075           ; minus mean outward face

    res_vec@tmYLMode              = "Explicit"        ; Pressure (YL) axis
    res_vec@tmYLValues            = plvl            
    res_vec@tmYLLabels            = tostring(toint(plvl)) 
    res_vec@tmYLLabels(1)         = ""                ; no 925 label
    res_vec@tmYLLabels(2)         = ""                ;    850
    res_vec@tmYLLabels(4)         = ""                ;    600
    res_vec@tmYLLabels(8)         = ""                ;    250
  
    res_vec@vpWidthF              = 0.60              ; shape
    res_vec@vpHeightF             = 0.35

; Create contour plot resources

    res_con                       = True
    res_con@gsnDraw               = False
    res_con@gsnFrame              = False

    res_con@sfXArray              = res_vec@vfXArray   ; =lat 
    res_con@sfYArray              = res_vec@vfYArray   ; =plvl
    res_con@trYReverse            = True               ; reverse y-axis

    res_con@gsnYAxisIrregular2Log = True               ; set y-axis to log scale
    res_con@gsnContourZeroLineThicknessF = 0.0
    res_con@gsnContourPosLineDashPattern = 0
    res_con@gsnContourNegLineDashPattern = 2

    res_con@cnSmoothingOn         = True
    res_con@cnLineColor           = "black"      
    res_con@cnLineThicknessF      = 2.0                ; default is 1.0
   ;res_con@gsnContourLineThicknessesScale  = 0.5
    res_con@cnLineLabelsOn        = False
   ;res_con@cnInfoLabelOn         = False              ; default is True
  
; open file and create graphic

  pltType = "png"
  pltPath = pltDir+pltRoot+"."  \
                  + sprinti("%0.4i",yearStrt)    \
                  + sprinti("%0.2i",monStrt)     \
                  + sprinti("%0.2i",dayStrt)+"_" \
                  + sprinti("%0.4i",yearLast)    \
                  + sprinti("%0.2i",monLast)     \
                  + sprinti("%0.2i",dayLast)       
  wks     = gsn_open_wks(pltType,pltPath)                
  Fp(0,:) = Fp@_FillValue                          ; Hide the 1000 mb level
  plotvec = gsn_vector(wks,Fphi,Fp,res_vec)    

  if (show_accel .eq. 1) then 
      dudt@_FillValue = -999.0
      dudt(0,:) = dudt@_FillValue                  ; Hide the 1000 mb level
      res_con@cnLevelSpacingF        = 5.          ; Contour level Spacing
      plotvec2 = gsn_contour(wks,dudt,res_con)     ; Creates plot for du/dt = div(F)/(a*cos(phi))
      overlay(plotvec,plotvec2)
  end if
  if (show_accel .eq. 0) then 
      EPdiv@_FillValue = -999.0
      EPdiv(0,:) = EPdiv@_FillValue                ; Hide the 1000 mb level
      res_con@cnLevelSpacingF        = 200.        ; Contour level Spacing
      plotvec3 = gsn_contour(wks,EPdiv,res_con)    ; Creates plot for div(F)
      overlay(plotvec,plotvec3)
  end if

  draw(plotvec)
  frame(wks)
  
  print ( "done" )
