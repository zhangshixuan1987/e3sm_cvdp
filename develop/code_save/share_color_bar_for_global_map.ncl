
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;this scripts save the setups for the color levels for the map plot ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   if ( mvarnam .eq. "PSL" ) then
      s1                              = (/984,988,992,996,1000,1004,1008,1012,1016,1020,1024,1028,1032,1036,1040/)*1.0
      s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0,1.0,5.0,10.0,15.0,20.0/)*1.0
      s3                              = (/-2,-1,-0.5,-0.2,-0.1,0,0.1,0.2,0.5,1,2/)*1.0
   else if  ( mvarnam .eq. "TREFHT" ) then
      s1                              = (/210,220,230,240,250,260,270,275,280,285,290,295,300,305,310/)*1.0
      s2                              = (/-5.0,-2.0,-1.0,-0.5,-0.1,0.0,0.1,0.5,1.0,2.0,5.0/)*1.0
      s3                              = (/-10,-8,-5,-2,-1,0,1,2,5,8,10/)/1.0
   else if  ( mvarnam .eq. "TS" ) then
      s1                              = (/210,220,230,240,250,260,270,275,280,285,290,295,300,305,310/)*1.0
      s2                              = (/-5.0,-2.0,-1.0,-0.5,-0.1,0.0,0.1,0.5,1.0,2.0,5.0/)*1.0
      s3                              = (/-10,-8,-5,-2,-1,0,1,2,5,8,10/)/1.0
   else if  ( mvarnam .eq. "U10" ) then
      s1                              = (/0,1,2,3,4,5,6,7,8,9,10,11,12,14,15/)*1.0
      s2                              = (/-6,-4,-2,-1,-0.1,0.0,0.1,1,2,4,6/)*1.0
      s3                              = (/-80,-40,-20,-10,-5,0,5,10,20,40,80/)*1.0
   else if  ( mvarnam .eq. "TMQ" ) then
      s1                              = (/1,2,4,8,12,16,20,24,28,32,36,40,50,60,80/)*1.0
      s2                              = (/-6.0,-4.0,-2.0,-1.0,-0.5,0.0,0.5,1.0,2.0,4.0,6.0/)*1.0
      s3                              = (/-80,-40,-20,-10,-5,0,5,10,20,40,80/)*1.0
   else if  ( mvarnam .eq. "SHFLX" ) then
      s1                              = (/-100,-75,-50,-25,-10,0,10,25,50,75,100,125,150,175,200/)
      s2                              = (/-40.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,40.0/)*1.0
      s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)*2.0
   else if  ( mvarnam .eq. "LHFLX" ) then
      s1                              = (/0,5,10,15,30,60,90,120,150,180,210,240,270,300,320/)*1.0
      s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*1.0
      s3                              = (/-100,-80,-40,-20,-10,0,10,20,40,80,100/)/1.0
   else if  ( mvarnam .eq. "TAUX" ) then
      s1                              = (/-0.2,-0.1, -0.08, -0.06, -0.04, -0.02, -0.01, 0, 0.01, 0.02, 0.04, 0.06, 0.08, 0.1, 0.2/)*1e2
      s2                              = (/-0.08,-0.06,-0.04,-0.02,-0.01,0.0,0.01,0.02,0.04,0.06,0.08/)*1e2
      s3                              = (/-80, -60, -40, -20, -10, 0, 10, 20, 40, 60, 80/)/1.0
   else if  ( mvarnam .eq. "TAUY" ) then
      s1                              = (/-0.2,-0.1, -0.08, -0.06, -0.04, -0.02, -0.01, 0, 0.01, 0.02, 0.04, 0.06, 0.08, 0.1, 0.2/)*1e2
      s2                              = (/-0.08,-0.06,-0.04,-0.02,-0.01,0.0,0.01,0.02,0.04,0.06,0.08/)*1e2
      s3                              = (/-80, -60, -40, -20, -10, 0, 10, 20, 40, 60, 80/)/1.0
   else if  ( mvarnam .eq. "PRECT" ) then
      s1                              = (/.2,.5,1,2,3,4,5,6,7,8,9,10,12,14,17/)*1.0
      s2                              = (/-5.0,-3.0,-2.0,-1.0,-0.1,0,0.1,1.0,2.0,3.0,5.0/)*1.0
      s3                              = (/-100,-80,-50,-20,-10,0,10,20,50,80,100/)/1.0
   else if  ( mvarnam .eq. "PRECC" ) then
      s1                              = (/0.01,0.05,0.08,0.1,0.2,0.5,0.8,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0/)*1.0
      s2                              = (/-5.0,-3.0,-2.0,-1.0,-0.1,0,0.1,1.0,2.0,3.0,5.0/)*1.0
      s3                              = (/-100,-80,-50,-20,-10,0,10,20,50,80,100/)/1.0
   else if  ( mvarnam .eq. "PRECL" ) then
      s1                              = (/0.01,0.05,0.08,0.1,0.2,0.5,0.8,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0/)*1.0
      s2                              = (/-5.0,-3.0,-2.0,-1.0,-0.1,0,0.1,1.0,2.0,3.0,5.0/)*1.0
      s3                              = (/-100,-80,-50,-20,-10,0,10,20,50,80,100/)/1.0
   else if(mvarnam.eq."TGCLDLWP")then
      s1                              = (/5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180/)*1.0
      s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*2.0
      s3                              = (/-50,-40,-30,-20,-10,0,10,20,30,40,50/)*2.0
   else if(mvarnam.eq."TGCLDIWP")then
      s1                              = (/0, 2, 5, 8, 10, 15, 20, 30, 40,50,60,70,80,100,120/)*1.0
      s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*1.0
      s3                              = (/-50,-40,-30,-20,-10,0,10,20,30,40,50/)*2.0
   else if(mvarnam.eq."TGCLDCWP")then
      s1                              = (/5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120,140,160,180/)*1.0
      s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*1.0
      s3                              = (/-80,-50,-30,-20,-10,0,10,20,30,50,80/)/1.0
   else if(mvarnam.eq."CLDLOW")then
      s1                              = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)/100.0
      s2                              = (/-0.30,-0.20,-0.1,-0.05,-0.01,0.0,0.01,0.05,0.1,0.20,0.30/)*1.0
      s3                              = (/-80,-40,-20,-10,-5,0,5,10,20,40,80/)*1.0
   else if(mvarnam.eq."CLDHGH")then
      s1                              = (/0.01,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.55,0.60,0.7,0.8/)*1.0
      s2                              = (/-0.6,-0.4,-0.2,-0.1,-0.05,0.,0.05,0.1,0.2,0.4,0.6/)*1.0
      s3                              = (/-80,-40,-20,-10,-5,0,5,10,20,40,80/)*1.0
   else if(mvarnam.eq."CLDTOT")then
      s1                              = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)/100.0
      s2                              = (/-0.30,-0.20,-0.1,-0.05,-0.01,0.0,0.01,0.05,0.1,0.20,0.30/)*1.0
      s3                              = (/-80,-40,-20,-10,-5,0,5,10,20,40,80/)*1.0
   else if (mvarnam .eq. "LWCF")then
      s1                              = (/-30,-20,-10,-5,0,5,10,20,30,40,50,60,70,85,100/)*1.0
      s2                              = (/-9.0,-7.0,-5.0,-3.0,-1.0,0.0,1.0,3.0,5.0,7.0,9.0/)*2.0
      s3                              = (/-200,-100,-50,-20,-10,0,10,20,50,100,200/)*1.0
   else if (mvarnam .eq. "SWCF")then
      s1                              = (/-120,-105,-90,-75,-60,-45,-30,-20,-10,-5, 0,5,10,20,50/)*1.0
      s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*2.0
      s3                              = (/-200,-100,-50,-20,-10,0,10,20,50,100,200/)*1.0
   else if (mvarnam .eq. "NETCF")then
      s1                              = (/-80,-70,-60,-50,-40,-30,-25,-20,-15,-10,-5,0,5,10,20/)*1.0
      s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*2.0
      s3                              = (/-200,-100,-50,-20,-10,0,10,20,50,100,200/)*1.0
   else if (mvarnam .eq. "RESTOM")then
      s1                              = (/-120,-100,-80,-60,-40,-20,-10,0,10,20,40,60,80,100,120/)*1.0
      s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*2.0
      s3                              = (/-200,-100,-50,-20,-10,0,10,20,50,100,200/)*1.0
   else if (mvarnam .eq. "RESTOA")then
      s1                              = (/-120,-100,-80,-60,-40,-20,-10,0,10,20,40,60,80,100,120/)*1.0
      s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*2.0
      s3                              = (/-200,-100,-50,-20,-10,0,10,20,50,100,200/)*1.0
   else if (mvarnam .eq. "NET_FLUX_SRF")then
      s1                              = (/-120,-100,-80,-60,-40,-20, -10, 0, 10, 20, 40, 60, 80, 100, 120/)*1.0
      s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*2.0
      s3                              = (/-200,-100,-50,-20,-10,0,10,20,50,100,200/)*1.0
   else if (mvarnam .eq. "FLUT")then
      s1                              = (/100,115,130,145,160,175,190,205,220,235,250,265,280,295,310/)*1.0
      s2                              = (/-10.0,-8.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,8.0,10.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FLNTOA")then
      s1                              = (/120,135,150,165,180,195,210,225,240,255,270,280,290,300,310/)*1.0
      s2                              = (/-10.0,-8.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,8.0,10.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FLUTC")then
      s1                              = (/120,135,150,165,180,195,210,225,240,255,270,280,290,300,310/)*1.0
      s2                              = (/-10.0,-8.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,8.0,10.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSNT")then
      s1                              = (/40,50,60,79,80,90,100,120,140,160,180,200,240,280,320/)*1.0
      s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*1.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSNTC")then
      s1                              = (/25,50,75,100,125,150,175,200,225,250,275,300,350,400,450/)*1.0
      s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSNTOA")then
      s1                              = (/10,30,60,90,120,150,180,210,240,270,300,330,360,390,420/)*1.0
      s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FLNS")then
      s1                              = (/10,20,30,40,50,60,70,80,90,100,110,120,130,140,150/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FLNSC")then
      s1                              = (/50,60,70,75,80,85,90,100,110,120,130,140,160,180,200/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FLUS")then
      s1                              = (/25,50,75,100,125,150,175,200,225,250,275,300,350,400,450/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSNTOAC")then
      s1                              = (/25,50,75,100,125,150,175,200,225,250,280,320,360,400,440/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*4.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSNS")then
      s1                              = (/20,40,60,80,100,120,160,180,200,220,240,260,280,300,320/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*3.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSNSC")then
      s1                              = (/25,50,75,100,125,150,175,200,225,250,275,300,325,350,375/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*3.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSUS")then
      s1                              = (/10,15,20,30,40,50,60,80,100,120,160,200,240,280,300/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSUSC")then
      s1                              = (/10,15,20,30,40,50,60,70,80,100,120,140,160,180,200/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSDS")then
      s1                              = (/25,50,75,100,125,150,175,200,225,250,275,300,325,350,375/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSDSC")then
      s1                              = (/25,50,75,100,125,150,175,200,225,250,275,300,325,350,375/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FLNT")then
      s1                              = (/100,115,130,145,160,175,190,205,220,235,250,265,280,295,310/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FLNTC")then
      s1                              = (/120,135,150,165,180,195,210,225,240,255,270,280,290,300,310/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FLDS")then
      s1                              = (/75,100,125,150,175,200,225,250,275,300,325,350,375,400,425/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FLDSC")then
      s1                              = (/75,100,125,150,175,200,225,250,275,300,325,350,375,400,425/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSUTOA")then
      s1                              = (/75,100,125,150,175,200,225,250,275,300,325,350,375,400,425/)*1.0
      s2                              = (/-30.0,-20.0,-10.0,-5.0,-2.0,0.0,2.0,5.0,10.0,20.0,30.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "FSUTOAC")then
      s1                              = (/20,25,30,35,40,45,50,60,70,80,100,120,130,140,150/)*1.0
      s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*2.0
      s3                              = (/-60,-40,-20,-10,-5,0,5,10,20,40,60/)*1.0
   else if (mvarnam .eq. "LWCF_SRF")then
      s1                              = (/5,10,15,20,25,30,40,50,60,70,80,90,95,100,105/)*1.0
      s2                              = (/-9.0,-7.0,-5.0,-3.0,-1.0,0.0,1.0,3.0,5.0,7.0,9.0/)*2.0
      s3                              = (/-200,-100,-50,-20,-10,0,10,20,50,100,200/)*1.0
   else if (mvarnam .eq. "SWCF_SRF")then
      s1                              = (/-195,-180,-165,-150,-135,-120,-105,-90,-75,-60,-45,-30,-15,-5,0/)*1.0
      s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*2.0
      s3                              = (/-200,-100,-50,-20,-10,0,10,20,50,100,200/)*1.0
   else if (mvarnam .eq. "NETCF_SRF")then
      s1                              = (/-135,-120,-105,-90,-75,-60,-45,-30,-15,-5,0,5,15,30,45/)*1.0 
                                       ;(/-80,-70,-60,-50,-40,-30,-25,-20,-15,-10,-5,0,5,10,20/)*1.0
      s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*2.0
      s3                              = (/-200,-100,-50,-20,-10,0,10,20,50,100,200/)*1.0
   else if (mvarnam .eq. "ALBEDOC")then
      s1                              = (/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/)*1.0
      s2                              = (/-.2,-.15,-.1,-.05,-.01,0.,.01,.05,.1,.15,.2/)*1.0
      s3                              = (/-80,-40,-20,-10,-5,0,5,10,20,40,80/)*1.0
   else if (mvarnam .eq. "ALBEDO")then
      s1                              = (/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/)*1.0
      s2                              = (/-.2,-.15,-.1,-.05,-.01,0.,.01,.05,.1,.15,.2/)*1.0
      s3                              = (/-80,-40,-20,-10,-5,0,5,10,20,40,80/)*1.0
   else if (mvarnam .eq. "ALBEDO_SRF")then
      s1                              = (/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/)*1.0
      s2                              = (/-.2,-.15,-.1,-.05,-.01,0.,.01,.05,.1,.15,.2/)*1.0
      s3                              = (/-80,-40,-20,-10,-5,0,5,10,20,40,80/)*1.0
   else if (mvarnam .eq. "PRECST")then
      s1                              = (/0.0,0.001,0.005,0.01,0.05,0.08,0.1,0.2,0.5,0.8,1.0,2.0,3.0,4.0,5.0/)*1.0
      s2                              = (/-5.0,-3.0,-2.0,-1.0,-0.1,0,0.1,1.0,2.0,3.0,5.0/)*1.0
      s3                              = (/-100,-80,-50,-20,-10,0,10,20,50,80,100/)/1.0
   else
             print("ERROR: User does not specify the explicit levels for " + mvarnam)
   end if 

   end if 
   end if 
   end if 
   end if 
   end if 

   end if
   end if
   end if 
   end if 
   end if 

   end if 
   end if 
   end if 
   end if 
   end if 

   end if 
   end if
   end if
   end if
   end if

   end if 
   end if
   end if
   end if
   end if

   end if
   end if
   end if
   end if
   end if

   end if
   end if 
   end if
   end if
   end if

   end if
   end if
   end if
   end if
   end if

   end if
   end if
   end if
   end if
   end if

   end if
   end if
   end if
   end if
   end if
   end if
   end if 
 