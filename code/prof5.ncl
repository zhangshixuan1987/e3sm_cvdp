  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: Scatter plot
; Author : Po-Lun Ma
; Date   : Jan 22, 2013


begin

   tpath = getenv("TPATH")
   cpath = getenv("CPATH")
   case2 = getenv("CTRL")
   case1 = getenv("TEST")
   casedir=getenv("CASEDIR")
   wkdir=getenv("WKROOT")
   mam42 = getenv("CMAM4")
   mam41 = getenv("TMAM4")

 nchr = dimsizes(stringtochar(case1))-1
 if (nchr .lt. 12) then
 case1a=case1
 else
 case1b=stringtochar(case1)
 case1a=chartostring(case1b(:10))
 end if
 nchr = dimsizes(stringtochar(case2))-1
 if (nchr .lt. 12) then
 case2a=case2
 else
 case2b=stringtochar(case2)
 case2a=chartostring(case2b(:10))
 end if

;variable name in the climo file

 vars=(/"carb"/)
 lata=(/  35.0,   50.0,  50.00 /)
 lona=(/ -120.,-90.,-120./)
 labs=(/"JUN"/)
 fact=1.e12
 qmin=1.e-2
 qmax=1.e3
 plow=1000.
 phgh=10.

 do i=0,dimsizes(lona)-1
  if (lona(i) .lt. 0.) then
   lona(i)=lona(i)+360.
  end if
 end do

;read in two files

 f=systemfunc("ls $CPATH/*06_climo.nc")
 f2=addfile(f,"r")
 f=systemfunc("ls $TPATH/*06_climo.nc")
 f1=addfile(f,"r")

 temp1=f1->so4_a1
 ddd1=dimsizes(temp1)
 so4a1=f1->bc_a1
 if (mam41 .eq. "true") then
 aod1x=f1->bc_a4
 so4a1=so4a1+aod1x
 end if
 lon1 =doubletofloat(f1->lon)
 lev1 =doubletofloat(f1->lev)
 so4a1=so4a1*fact

 temp2=f2->so4_a1
 ddd2=dimsizes(temp2)
 so4b1=f2->bc_a1
 if (mam42 .eq. "true") then
 aod2x=f2->bc_a4
 so4b1=so4b1+aod2x
 end if
 lon2 =doubletofloat(f2->lon)
 lev2 =doubletofloat(f2->lev)
 so4b1=so4b1*fact

 wks = gsn_open_wks("eps",casedir+"/set04/"+vars+"_prof")
 gsn_merge_colormaps(wks,"amwg","gsdtol") ; merge two color maps
 plot=new(2,graphic)
 bplot=new(1,graphic)
 cplot=new(1,graphic)
 xplot=new(1,graphic)


;read in observational data

 do ii=0,0
 obs=asciiread(wkdir+"/obs/"+vars+".txt",-1,"float")
 mob=obs(::4)
 hob=obs(1::4)
 sob=obs(2::4)

 ppp=new((/2,dimsizes(hob)/),float)
 ppp(0,:)=mob+sob
 ppp(1,:)=mob-sob
 ppp=ppp>1.e-5

 
 sim1=new((/dimsizes(lata),dimsizes(lev1)/),float)
 sim2=sim1
 do k=0,dimsizes(lata)-1
  sim1(k,:)=so4a1(0,:,{lata(k)},{lona(k)})
  sim2(k,:)=so4b1(0,:,{lata(k)},{lona(k)})
 end do
 
 sim1a=dim_avg_n_Wrap(sim1,0)
 sim2a=dim_avg_n_Wrap(sim2,0)


  res          = True
  res@gsnFrame          = False                 ; Do not draw plot
  res@gsnDraw           = False                 ; Do not advance frame
  res@trXMinF =  qmin
  res@trXMaxF =  qmax
  res@trYMinF =  phgh
  res@trYMaxF =  plow
  res@trYReverse    = True
  res@gsnRightString    = labs(ii)
  res@gsnLeftString     = ""
  res@xyLineColors      = 1
  res@xyLineThicknesses = 4
  res@xyDashPatterns    = 0
  res@trXLog        = True
  res@tiYAxisString ="Pressure (hPa)"
  res@tiXAxisString =""
  res@tmXBLabelFontHeightF = 0.02
  res@tmYLLabelFontHeightF = 0.02

  plot(ii) = gsn_csm_xy (wks,mob,hob,res) ; create plot
  res@xyLineColors      = 15
  bplot(ii) = gsn_csm_xy (wks,sim1a,lev1,res) ; create plot
  res@xyLineColors      = 3
  cplot(ii) = gsn_csm_xy (wks,sim2a,lev2,res) ; create plot

  overlay(plot(ii),bplot(ii))
  overlay(plot(ii),cplot(ii))

  res2 = True
  res2@gsnFrame          = False                 ; Do not draw plot
  res2@gsnDraw           = False                 ; Do not advance frame
  res2@trXMinF =  qmin
  res2@trXMaxF =  qmax
  res@trYMinF =  phgh
  res@trYMaxF =  plow
  res2@trYReverse    = True
  res2@tmXTOn = False
  res2@pmLegendDisplayMode    = "Never"         ; Turn on a legend
  res2@gsnXYFillColors = 42
  res2@xyLineColor     = -1                           ; We don't want the line, so make it transparent.
  res2@tiXAxisString =""

  xplot(ii)  = gsn_csm_xy (wks,ppp,hob,res2)  ; Create another filled XY plot.
  overlay(plot(ii),xplot(ii))

  delete(obs)
  delete(mob)
  delete(hob)
  delete(sim1)
  delete(sim2)
  delete(sim1a)
  delete(sim2a)
  end do

  txres                       = True
  txres@txPerimOn             = False
  txres@txJust        = "CenterLeft"
  txres@txBackgroundFillColor = -1
  txres@txFontHeightF         = 0.02
  txres@txFontColor = 3

  txid1 = gsn_add_text(wks, plot(0), case2a, qmax*0.02, phgh+(plow-phgh)/13*3, txres)
  txres@txFontColor = 15
  txid2 = gsn_add_text(wks, plot(0), case1a, qmax*0.02, phgh+(plow-phgh)/13*2,txres)
  txres@txFontColor = 1
  txid3 = gsn_add_text(wks, plot(0), "Obs",qmax*0.02, phgh+(plow-phgh)/13,txres)

  res3                        = True               ; plot mods desired
  res3@gsnFrame          = False                 ; Do not draw plot
  res3@gsnDraw           = False                 ; Do not advance frame
  res3@mpMinLatF         = -10
  res3@mpMaxLatF         = 90
  res3@mpMinLonF         = -180
  res3@mpMaxLonF         = -0.5
  res3@mpCenterLonF      = -90
  res3@mpGeophysicalLineThicknessF = 3.  
  res3@mpGridSpacingF         = 10
  res3@tmXBLabelFontHeightF = 0.02
  res3@tmYLLabelFontHeightF = 0.02
  res3@vpWidthF = 0.6
  res3@vpHeightF =0.6

  plot(1) = gsn_csm_map_ce(wks,res3)           ; draw global map
  mkres               = True
  mkres@gsMarkerIndex = 17     ; Filled circle
  mkres@gsMarkerSizeF = 0.015
  mkres@gsMarkerColor  = 9
  dum = gsn_add_polymarker(wks,plot(1),lona ,lata ,mkres)

  pres                            = True        ; panel plot mods desired
  pres@gsnMaximize                = True        ; fill the page
  pres@txFontHeightF = 0.015
  pres@txString   =str_upper(vars)
  
  gsn_panel(wks,plot,(/3,1/),pres)



end
