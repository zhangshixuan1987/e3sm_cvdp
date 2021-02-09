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

;variable name in the climo file

 vars=(/"aeronet_aod"/)
 regn=(/"World","North_America","Europe","East_Asia","North_Africa","South_Africa","South_America","South_Asia"/)
 seas=(/"ann","djf","jja"/)
 lats=(/-90,20.,37.,20,0,-30,-30,0/)
 latn=(/90,58.,65,50,30,0,12,30/)
 lonl=(/0,235.,350,100,330,0,270,65/)
 lonr=(/360,295.,40,150,20,50,320,95/)
 fact=1.
 qmin=1.e-2
 qmax=1.6
;read in two files

 fs=systemfunc("ls $CPATH/*_climo.nc")
 fss=fs(0:11)
 f2=addfiles(fss,"r")
 aod2=f2[:]->AODVIS
 f2a=addfile(fs(0),"r")
 lon2 =doubletofloat(f2a->lon)
 
 delete(fs)
 fs=systemfunc("ls $TPATH/*_climo.nc")
 fss=fs(0:11)
 f1=addfiles(fss,"r")
 aod1=f1[:]->AODVIS
 f1a=addfile(fs(0),"r")
 lon1 =doubletofloat(f1a->lon)

 obs = asciiread(wkdir+"/obs/aeronet.txt",-1,"float")
 obs@_FillValue=-999

 mona =obs(0::5)
 mon =floattoint(mona)
 olat=obs(1::5)
 olon=obs(2::5)
 ovar=obs(3::5)

 do i=0, dimsizes(olon)-1
  if (olon(i) .lt. 0) then
   olon(i)= olon(i)+360.
  end if
 end do 
 olon1=olon
 olon2=olon

 var1 =ovar
 var2 =ovar

 do i=0,dimsizes(ovar)-1
  if (olon1(i) .ge. max(lon1)) then
   if ( olon1(i) .lt. max(lon1)+(lon1(1)-lon1(0))) then
   olon1(i) = max(lon1)
   else
   olon1(i) = 0.
   end if
  end if
  if (olon2(i) .ge. max(lon2)) then 
   if ( olon2(i) .lt. max(lon2)+(lon2(1)-lon2(0))) then
   olon2(i) = max(lon2)
   else
   olon2(i) = 0.
   end if
  end if
 end do

 do kk=0, dimsizes(regn)-1
 do ii=0,dimsizes(seas)-1
  ovar=(/obs(3::5)/)
 do i=0,dimsizes(ovar)-1
  var1(i)=aod1(mon(i)-1,{olat(i)},{olon1(i)})
  var2(i)=aod2(mon(i)-1,{olat(i)},{olon2(i)})
  if (regn(kk) .ne. "World" ) then
   if (lonl(kk) .lt. lonr(kk)) then
    if (olat(i) .gt. latn(kk) .or. olat(i) .lt. lats(kk) .or. olon(i) .lt. lonl(kk).or.olon(i).gt.lonr(kk) ) then
      ovar(i)=-999
      var1(i)=-999
      var2(i)=-999
    end if
   else
    if (olat(i) .gt. latn(kk) .or. olat(i) .lt. lats(kk) ) then
      ovar(i)=-999
      var1(i)=-999
      var2(i)=-999
    end if
    if (olon(i) .lt. lonl(kk).and.olon(i).gt.lonr(kk) ) then
      ovar(i)=-999
      var1(i)=-999
      var2(i)=-999
    end if
   end if
  end if
 end do

  if (seas(ii) .eq. "jja") then
   temp1=(/ovar(5::12)/)
   temp2=(/ovar(6::12)/)
   temp3=(/ovar(7::12)/)
   ovar=-999
   ovar(5::12)=temp1
   ovar(6::12)=temp2
   ovar(7::12)=temp3
   temp1=var1(5::12)
   temp2=var1(6::12)
   temp3=var1(7::12)
   var1=-999
   var1(5::12)=temp1
   var1(6::12)=temp2
   var1(7::12)=temp3
   temp1=var2(5::12)
   temp2=var2(6::12)
   temp3=var2(7::12)
   var2=-999
   var2(5::12)=temp1
   var2(6::12)=temp2
   var2(7::12)=temp3
  end if
  if (seas(ii) .eq. "djf") then
   temp1=(/ovar(0::12)/)
   temp2=(/ovar(1::12)/)
   temp3=(/ovar(11::12)/)
   ovar=-999
   ovar(0::12)=temp1
   ovar(1::12)=temp2
   ovar(11::12)=temp3
   temp1=var1(0::12)
   temp2=var1(1::12)
   temp3=var1(11::12)
   var1=-999
   var1(0::12)=temp1
   var1(1::12)=temp2
   var1(11::12)=temp3
   temp1=var2(0::12)
   temp2=var2(1::12)
   temp3=var2(11::12)
   var2=-999
   var2(0::12)=temp1
   var2(1::12)=temp2
   var2(11::12)=temp3
  end if

 var1@_FillValue=-999
 var2@_FillValue=-999
 ovar@_FillValue=-999

 ccr1 = esccr(var1,ovar,0)  
 ccr2 = esccr(var2,ovar,0)  
 ccro=esccr(ovar,ovar,0)

;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    Make the Plot
;
;;;;;;;;;;;;;;;;;;;;;;;;;
  wks = gsn_open_wks("eps",casedir+"/set03/"+vars+"_"+seas(ii)+"_"+regn(kk)+"_scat")
  gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred") ; merge two color maps
  plot=new(1,graphic)
  
  res1                   = True                     ; plot mods desired
  res1@xyMarkLineModes   = "Markers"
  res1@gsnFrame          = False                      ; don't advance frame yet
  res1@gsnDraw           = False                 ; Do not advance frame
  res1@xyMarkers         =  16                      ; choose type of marker
  res1@xyMarkerColor     = 15
  res1@xyMarkerSizeF     = 0.002                     ; Marker size (default 0.01)
  res1@tmLabelAutoStride = True                     ; nice tick mark labels
  res1@gsnRightString    = str_upper(seas(ii))
  res1@gsnLeftString     = regn(kk)
  res1@trYMinF =  qmin
  res1@trYMaxF =  qmax
  res1@trXMinF =  qmin
  res1@trXMaxF =  qmax
;  res1@trXLog     = True
;  res1@trYLog     = True
  res1@tmXBLabelFontHeightF = 0.02
  res1@tmYLLabelFontHeightF = 0.02
  res1@tiYAxisFontColor = 15
  res1@tiXAxisString = "Observation"
  res1@tiYAxisString = case1
  res2                   = True                     ; plot mods desired
  res2@gsnFrame          = False                      ; don't advance frame yet
  res2@gsnDraw           = False                 ; Do not advance frame
  res2@xyMarkLineModes   = "Markers"                ; choose which have markers
  res2@xyMarkers         =  16                      ; choose type of marker
  res2@xyMarkerColor     = 3
  res2@xyMarkerSizeF     = 0.002                     ; Marker size (default 0.01)
  res2@tmLabelAutoStride = True                     ; nice tick mark labels
  res2@trYMinF =  qmin
  res2@trYMaxF =  qmax
  res2@trXMinF =  qmin
  res2@trXMaxF =  qmax
;  res2@trXLog     = True
;  res2@trYLog     = True
  res2@tmXBLabelFontHeightF = 0.02
  res2@tmYLLabelFontHeightF = 0.02
  res2@tiYAxisFontColor = 3
  res2@tiYAxisString = case2
  res2@tiMainString  = str_upper(vars)

  plot  = gsn_csm_xy2 (wks,ovar,var1,var2,res1,res2) ; create plot
  resp                  = True                      ; polyline mods desired
  resp@gsLineColor      = 1
  resp@gsLineThicknessF = 2.0                       ; thickness of lines
  gsn_polyline(wks,plot,(/qmin,qmax/),(/qmin,qmax/),resp)
  resp2                  = True                      ; polyline mods desired
  resp2@gsLineColor      = 1
  resp2@gsLineThicknessF = 2.0                       ; thickness of lines 
  resp2@gsLineDashPattern= 2
  gsn_polyline(wks,plot,(/qmin*2,qmax/),(/qmin,qmax*0.5/),resp2)
  gsn_polyline(wks,plot,(/qmin,qmax*0.5/),(/qmin*2,qmax/),resp2)

  txres                       = True
  txres@txPerimOn             = False
  txres@txJust        = "CenterLeft"
  txres@txBackgroundFillColor = 0
  txres@txFontHeightF         = 0.013               
  txres@txFontColor = 3
  
  txid1 = gsn_add_text(wks, plot,  "mean="+sprintf("%5.2f",avg(var2))+" R="+sprintf("%5.2f",ccr2), qmin+0.05, qmax-0.17, txres)
  txres@txFontColor = 15
  txid2 = gsn_add_text(wks, plot, "mean="+sprintf("%5.2f",avg(var1))+" R="+sprintf("%5.2f",ccr1), qmin+0.05, qmax-0.11,txres)
  txres@txFontColor = 1
  txid3 = gsn_add_text(wks, plot, "mean="+sprintf("%5.2f",avg(ovar)),qmin+0.05, qmax-0.05,txres)



  draw(plot)
  frame(wks)
  delete(plot)
  delete(wks)
  end do
  end do 
end
