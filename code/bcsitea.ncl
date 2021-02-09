load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

   tpath = getenv("TPATH")
   cpath = getenv("CPATH")
   case2 = getenv("CTRL")
   case1 = getenv("TEST")
   casedir=getenv("CASEDIR")
   wkdir=getenv("WKROOT")
   mam42 = getenv("CMAM4")
   mam41 = getenv("TMAM4")

 vars="zeppelin"

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

 fact=1.e12
 qmin=1.e-2
 qmax=1.e3

;read in two files

 fs2=systemfunc("ls $CPATH/*_climo.nc")
 fss=fs2(0:11)
 f2=addfiles(fss,"r")
 aod2=f2[:]->bc_a1
 if (mam42 .eq. "true") then
 aod2x=f2[:]->bc_a4
 aod2=aod2+aod2x
 end if
 t2a= f2[:]->T
 p2a= f2[:]->PS
 f2a=addfile(fss(0),"r")
 lev2=f2a->lev

 fs1=systemfunc("ls $TPATH/*_climo.nc")
 fss=fs1(0:11)
 f1=addfiles(fss,"r")
 aod1=f1[:]->bc_a1
 if (mam41 .eq. "true") then
 aod1x=f1[:]->bc_a4
 aod1=aod1+aod1x
 end if
 f1a=addfile(fss(0),"r")
 lev1=f1a->lev
 t1a= f1[:]->T
 p1a= f1[:]->PS

 mod1=aod1(:,dimsizes(lev1)-1,{79},{12})*fact
 mod2=aod2(:,dimsizes(lev2)-1,{79},{12})*fact
 t2=t2a(:,dimsizes(lev2)-1,{79},{12})
 t1=t1a(:,dimsizes(lev1)-1,{79},{12})
 p2=p2a(:,{79},{12})
 p1=p1a(:,{79},{12})

  rho1=p1/t1/287
  rho2=p2/t2/287

  mod1=mod1/rho1
  mod2=mod2/rho2

  obs=asciiread(wkdir+"/obs/bc2.txt",-1,"float")

  time=ispan(1,12,1)
  
; ===========================
; color plot
; ===========================
  wks = gsn_open_wks("eps",casedir+"/set05/"+vars)
  gsn_merge_colormaps(wks,"amwg","gsdtol") ; merge two color maps
  plot=new(1,graphic)
  bplot=new(1,graphic)
  cplot=new(1,graphic)

  res          = True
  res@gsnFrame          = False                 ; Do not draw plot
  res@gsnDraw           = False                 ; Do not advance frame
  res@trYMinF =  qmin
  res@trYMaxF =  qmax
  res@trXMinF =  1
  res@trXMaxF =  12
  res@vpHeightF = 0.3       ; Changes the aspect ratio
  res@vpWidthF  = 0.6
  res@trYLog        = True
  res@gsnRightStringFontHeightF    = 0.02
  res@gsnLeftStringFontHeightF    = 0.02
  res@gsnRightString    = "ng/m3"
  res@gsnLeftString    = ""
  res@tmXBMode            = "Explicit"         ; Define own tick mark labels.
  res@tmXBValues    = time
  res@tmXBLabels    = (/"J","F","M","A","M","J","J","A","S","O","N","D"/)
  res@tiMainString         =""
  res@gsnLeftString    = "Zeppelin"
  res@xyLineColors      = 1
  res@xyLineThicknesses = 4
  res@xyDashPatterns    = 0
  res@tiYAxisString =""
  res@tiXAxisString =""
  res@tmXBLabelFontHeightF = 0.02
  res@tmYLLabelFontHeightF = 0.02

  plot = gsn_csm_xy (wks,time,obs,res) ; create plot
  res@xyLineColors      = 15
  bplot = gsn_csm_xy (wks,time,mod1,res) ; create plot
  res@xyLineColors      = 3
  cplot = gsn_csm_xy (wks,time,mod2,res) ; create plot

  overlay(plot,bplot)
  overlay(plot,cplot)

  txres                       = True
  txres@txPerimOn             = False
  txres@txJust        = "CenterLeft"
  txres@txBackgroundFillColor = -1
  txres@txFontHeightF         = 0.015
  txres@txFontColor = 3

  txid1 = gsn_add_text(wks, plot, case2a, 8.4, qmax*0.3, txres)
  txres@txFontColor = 15
  txid2 = gsn_add_text(wks, plot, case1a, 3.6, qmax*0.3,txres)
  txres@txFontColor = 1
  txid3 = gsn_add_text(wks, plot, "Obs",1.2, qmax*0.3,txres)


  draw(plot)
  frame(wks)

  
end
