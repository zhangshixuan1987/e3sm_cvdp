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

 vars=(/"mahowald_dst_conc_ann"/)
 fact=1.e9
 qmin=5.e-3
 qmax=5.e2
;read in two files

 f=systemfunc("ls $CPATH/*ANN_climo.nc")
 f2=addfile(f,"r")
 f=systemfunc("ls $TPATH/*ANN_climo.nc")
 f1=addfile(f,"r")

 temp1=f1->so4_a1
 ddd1=dimsizes(temp1)
 so4a1=f1->dst_a1(:,ddd1(1)-1,:,:)
 so4a2=f1->dst_a3(:,ddd1(1)-1,:,:)
 ps1  =f1->PS
 t1   =f1->T(:,ddd1(1)-1,:,:)
 lon1 =doubletofloat(f1->lon)
 so4a1=so4a1+so4a2
 so4a1=so4a1*fact
 rho1=ps1/t1/287.
 so4a1=so4a1*rho1

 temp2=f2->so4_a1        
 ddd2=dimsizes(temp2)       
 so4b1=f2->dst_a1(:,ddd2(1)-1,:,:)
 so4b2=f2->dst_a3(:,ddd2(1)-1,:,:)
 ps2  =f2->PS
 t2   =f2->T(:,ddd2(1)-1,:,:)
 lon2 =doubletofloat(f2->lon)
 so4b1=so4b1+so4b2
 so4b1=so4b1*fact
 rho2=ps2/t2/287.
 so4b1=so4b1*rho2

 obs = asciiread(wkdir+"/obs/mahowald_dst_conc_ann.txt",-1,"float")
 olat=obs(::4)
 olon=obs(1::4)
 ohgt=obs(2::4)
 ovar=obs(3::4)

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
  var1(i)=so4a1(0,{olat(i)},{olon1(i)})
  var2(i)=so4b1(0,{olat(i)},{olon2(i)})
 end do

 ccr1 = esccr(var1,ovar,0)  
 ccr2 = esccr(var2,ovar,0)  
 ccro=esccr(ovar,ovar,0)

;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    Make the Plot
;
;;;;;;;;;;;;;;;;;;;;;;;;;
  wks = gsn_open_wks("eps",casedir+"/set03/"+vars+"_scat")
  gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred") ; merge two color maps
  plot=new(1,graphic)
  
  res1                   = True                     ; plot mods desired
  res1@xyMarkLineModes   = "Markers"
  res1@gsnFrame          = False                      ; don't advance frame yet
  res1@gsnDraw           = False                 ; Do not advance frame
  res1@xyMarkers         =  16                      ; choose type of marker
  res1@xyMarkerColor     = 15
  res1@xyMarkerSizeF     = 0.005                     ; Marker size (default 0.01)
  res1@tmLabelAutoStride = True                     ; nice tick mark labels
  res1@trYMinF =  qmin
  res1@trYMaxF =  qmax
  res1@trXMinF =  qmin
  res1@trXMaxF =  qmax
  res1@trXLog     = True
  res1@trYLog     = True
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
  res2@xyMarkerSizeF     = 0.005                     ; Marker size (default 0.01)
  res2@tmLabelAutoStride = True                     ; nice tick mark labels
  res2@trYMinF =  qmin
  res2@trYMaxF =  qmax
  res2@trXMinF =  qmin
  res2@trXMaxF =  qmax
  res2@trXLog     = True
  res2@trYLog     = True
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
  
  aaa=log10(qmax)
  bbb=log10(qmin)
  aba=(aaa-bbb)/2

  txid1 = gsn_add_text(wks, plot,  "mean="+sprintf("%5.2f",avg(var2))+" R="+sprintf("%5.2f",ccr2), qmin+qmin*0.2, 10.^(aaa-0.3*aba), txres)
  txres@txFontColor = 15
  txid2 = gsn_add_text(wks, plot, "mean="+sprintf("%5.2f",avg(var1))+" R="+sprintf("%5.2f",ccr1), qmin+qmin*0.2, 10.^(aaa-0.2*aba),txres)
  txres@txFontColor = 1
  txid3 = gsn_add_text(wks, plot, "mean="+sprintf("%5.2f",avg(ovar)),qmin+qmin*.2, 10.^(aaa-0.1*aba),txres)



  draw(plot)
  frame(wks)

end
