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

 vars=(/"hippo"/)
 regn=(/"60n80n","20n60n","20s20n","60s20s","70s60s"/)
 lats=(/60.,20,-20,-60,-67/)
 latn=(/80.,60,20,-20,-60/)
 lonl=(/248.,251,210,170,179/)
 lonr=(/198.,197,187,207,185/)
 labs=(/"60N-80N, 112W-162W","20N-60N, 109W-163W","20S-20N, 150W-173W","20S-60S, 170E-153W","60S-67S, 179E-175W"/)
 fact=1.e12
 qmin=1.e-2
 qmax=1.e3
 phgh=10.
 plow=1000.

;read in two files

 f=systemfunc("ls $CPATH/*01_climo.nc")
 f2=addfile(f,"r")
 f=systemfunc("ls $TPATH/*01_climo.nc")
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

 ccl=(/2,6,8,13,17/)

  wks = gsn_open_wks("eps",casedir+"/set04/"+vars+"_bc_prof")
  gsn_merge_colormaps(wks,"amwg","gsdtol") ; merge two color maps
  plot=new(6,graphic)
  xplot=new(5,graphic)
  yplot=new(5,graphic)
  bplot=new(5,graphic)

;read in observational data

 do ii=0, dimsizes(regn)-1
 obs=asciiread(wkdir+"/obs/hippo_"+regn(ii)+".txt",-1,"float")
 mob=obs(::3)
 sob=obs(1::3)
 hob=obs(2::3)
 hob1=hob
 hob2=hob
 
 sim1=so4a1(0,:,{lats(ii):latn(ii)},{lonl(ii):lonr(ii)})
 sim2=so4b1(0,:,{lats(ii):latn(ii)},{lonl(ii):lonr(ii)})

 sim1a=lev1
 sim2a=lev2

 do ik=0,dimsizes(lev1)-1
  sim1a(ik)=avg(sim1(ik,:,:))
 end do
 do ik=0,dimsizes(lev2)-1
  sim2a(ik)=avg(sim2(ik,:,:))
 end do

 ppp=new((/2,dimsizes(hob)/),float)

 ppp(0,:)=mob+sob
 ppp(1,:)=mob-sob
 ppp=ppp>1.e-5

  res          = True
  res@gsnFrame          = False                 ; Do not draw plot
  res@gsnDraw           = False                 ; Do not advance frame
  res@trXMinF =  qmin
  res@trXMaxF =  qmax
  res@trYMinF =  phgh
  res@trYMaxF =  plow
  res@trYReverse    = True
  res@gsnRightString    = "JAN"
  res@gsnLeftStringFontColor = ccl(ii)
  res@gsnLeftString     = labs(ii)
  res@xyLineColors      = 1
  res@xyLineThicknesses = 4
  res@xyDashPatterns    = 0
  res@trXLog        = True
  res@tiYAxisString ="Pressure (hPa)"
  plot(ii) = gsn_csm_xy (wks,mob,hob,res) ; create plot
  res@xyLineColors      = 15
  xplot(ii) = gsn_csm_xy (wks,sim1a,lev1,res) ; create plot
  res@xyLineColors      = 3
  yplot(ii) = gsn_csm_xy (wks,sim2a,lev2,res) ; create plot

  overlay(plot(ii),xplot(ii))
  overlay(plot(ii),yplot(ii))

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

  bplot(ii)  = gsn_csm_xy (wks,ppp,hob,res2)  ; Create another filled XY plot.
  overlay(plot(ii),bplot(ii))

  delete(ppp)
  delete(obs)
  delete(mob)
  delete(sob)
  delete(hob)
  delete(hob1)
  delete(hob2)
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

  res3                   = True               ; plot mods desired
  res3@gsnFrame          = False                 ; Do not draw plot
  res3@gsnDraw           = False                 ; Do not advance frame
  res3@mpMinLatF         = min(lats)-10
  res3@mpMaxLatF         = max(latn)+10
  res3@mpMinLonF         = min(lonl)-50
  res3@mpMaxLonF         = max(lonr)+80
  res3@mpCenterLonF      = (avg(lonl)+avg(lonr))/2
  res3@mpGeophysicalLineThicknessF = 3.
  res3@mpGridSpacingF         = 10
  res3@tmXBLabelFontHeightF = 0.02
  res3@tmYLLabelFontHeightF = 0.02
  res3@vpWidthF = 0.6
  res3@vpHeightF =0.6

  plot(dimsizes(plot)-1) = gsn_csm_map_ce(wks,res3)           ; draw global map

  gnres             = True
  gnres@gsEdgesOn   = False
  gnres@gsFillIndex = 6
  gnres@gsFillScaleF = 0.5

  latbox=new((/dimsizes(lats),5/),float)
  lonbox=latbox
  dum=new(dimsizes(lats),graphic)
  do ii=0,dimsizes(lats)-1
  latbox(ii,:) = (/lats(ii),lats(ii),latn(ii),latn(ii),lats(ii)/)
  lonbox(ii,:) = (/lonl(ii),lonr(ii),lonr(ii),lonl(ii),lonl(ii)/)
  gnres@gsFillColor = ccl(ii)
  dum(ii) = gsn_add_polygon(wks, plot(dimsizes(plot)-1), lonbox(ii,:), latbox(ii,:), gnres)
  end do


  pres                            = True        ; panel plot mods desired
  pres@gsnMaximize                = True        ; fill the page
  pres@txFontHeightF = 0.015
  pres@txString   =str_upper(vars)
  gsn_panel(wks,plot,(/3,2/),pres)



end
