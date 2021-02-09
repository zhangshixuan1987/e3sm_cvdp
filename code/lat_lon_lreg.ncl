  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a 4-panel lat-lon plot
;          Data is vertically interpolated to pressure levels
;          1st panel: experiment 1
;          2nd panel: experiment 2
;          3rd panel: absolute difference (exp1-exp2)
;          4th panel: relative difference (exp1-exp2)/exp2
; Author : Po-Lun Ma
; Date   : Jan 22, 2013
;          Feb 06, 2020 - Jian Sun modified to add plots for aerosol number mixing ratios and cloud-borne aerosols
;          Feb 19, 2020 - Jian Sun changed the plot style and added unit conversion based on Kai's suggestion

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

  modvars 				     = (/"CLDTOT","CLDLOW","CLDHGH",\
                                                 "TGCLDCWP","TGCLDLWP", "TGCLDIWP",\
                                                 "PRECC","PRECL","PRECT", \
                                                 "LWCF","SWCF","NETCF", \
                                                 "FLUT","FSNTOA","FSNTOAC","FSUTOA","FSUTOAC","FSDS", \
                                                 "FSNS","FLNS","FLDS","RESTOM","QNET", \
                                                 "LHFLX","SHFLX","TMQ",\
                                                 "TS","U10","PSL","TREFHT", \
                                                 "TAUX", "TAUY" \
                                                 /)
  seas 				   		= (/"ANN","DJF","JJA"/)
  pi                                            = 3.14159265
  rearth                                        = 6.37122e6
  grav 				   		= 9.806

;define regions for plot
  latS                                          = -90.  ;negative for southern hemisphere
  latN                                          = -20.  ;negative for southern hemisphere
  pout                                          = "20S-90S"

;read in two files

  do ll = 0, dimsizes(pout)-1

     do kk = 0, dimsizes(seas)-1

        f 			   		= systemfunc("ls $TPATH/*"+seas(kk)+"_means.nc")
        f1			   		= addfile(f,"r")
        ps1   	                                = f1->PS
        ha1   	                                = doubletofloat(f1->hyai)
        hb1   	                                = doubletofloat(f1->hybi)
        p0    	                                = doubletofloat(f1->P0)
        p1    	                                = pres_hybrid_ccm(ps1,p0,ha1,hb1)
        gw1                                     = doubletofloat(f1->gw)

        if(compare.eq."Model_vs_OBS") then
          f                                       = systemfunc("ls $CPATH/*_siglev_analysis_*_"+seas(kk)+".nc")
          f2                                      = addfile(f,"r")
          ps2                                     = f2->sp
          gw2                                     = doubletofloat(f2->gw)
        else
          f                                       = systemfunc("ls $CPATH/*"+seas(kk)+"_means.nc")
          f2                                      = addfile(f,"r")
          ps2                                     = f2->PS
          ha2                                     = doubletofloat(f2->hyai)
          hb2                                     = doubletofloat(f2->hybi)
          p2                                      = pres_hybrid_ccm(ps2,p0,ha2,hb2)
          gw2                                     = doubletofloat(f2->gw)
        end if 

        do jj = 0, dimsizes(modvars)-1

          mvarnam                              = modvars(jj)

          print("working on variable "+ mvarnam)

           if  ( mvarnam .eq. "PSL" ) then
             var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then 
               var2                          = f2->msl(:,{latS:latN},:)
               var2                          = var2 * 0.01 ; convert to hPa
             else
               var2                          = f2->$mvarnam$(:,{latS:latN},:)
             end if 
             s1                              = (/960,965,970,975,980,985,990,995,1000,1005,1008,1010/)*1.0
             s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0,1.0,5.0,10.0,15.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/100.0

           else if  ( mvarnam .eq. "TREFHT" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->t2m(:,{latS:latN},:)
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/228,232,236,244,252,260,268,270,272,274,276,280/)*1.0
             s1                              = (/228,232,236,244,252,260,268,270,272,275,280,290/)*1.0
             s2                              = (/-2.0,-1.0,-0.5,-0.2,-0.1,0.0,0.1,0.2,0.5,1.0,2.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if  ( mvarnam .eq. "TS" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->skt(:,{latS:latN},:)
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/228,232,236,244,252,260,268,270,272,274,276,280/)*1.0
             s2                              = (/-2.0,-1.0,-0.5,-0.2,-0.1,0.0,0.1,0.2,0.5,1.0,2.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if  ( mvarnam .eq. "U10" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->si10(:,{latS:latN},:)
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0,1,2,3,4,5,6,7,8,10,12,15/)*1.0
             s2                              = (/-2.0,-1.0,-0.5,-0.2,-0.1,0.0,0.1,0.2,0.5,1.0,2.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if  ( mvarnam .eq. "TMQ" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tcwv(:,{latS:latN},:)
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0,1,2,3,4,5,8,10,15,20,30/)*1.0
             s2                              = (/-1.2,-0.8,-0.5,-0.2,-0.1,0.0,0.1,0.2,0.5,0.8,1.2/)*1.0
             s2                              = (/-4.0,-3.0,-2.0,-1.0,-0.5,0.0,0.5,1.0,2.0,3.0,4.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if  ( mvarnam .eq. "SHFLX" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->sshf(:,{latS:latN},:)
               var2                            = -var2/86400.0
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0, 1, 2, 5, 8, 10, 20, 30, 40, 50, 60, 80/)*1.0
             s2                              = (/-12.0,-8.0,-4.0,-2.0,-1.0,0.0,1.0,2.0,4.0,8.0,12.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if  ( mvarnam .eq. "LHFLX" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->slhf(:,{latS:latN},:)
               var2                            = -var2 /86400.0
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/-5, 0, 5, 10, 15, 20, 25, 30, 40, 50, 60, 80/)*1.0
             s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if  ( mvarnam .eq. "TAUX" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->metss(:,{latS:latN},:)
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/-0.2, -0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5/)*1.0
             s2                              = (/-0.30,-0.20,-0.10,-0.05,-0.01,0.0,0.01,0.05,0.10,0.20,0.30/)
             s3                              = (/-90.0, -60, -30, -10,1,0,1,10,30,60,90/)/1.0

           else if  ( mvarnam .eq. "TAUY" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->mntss(:,{latS:latN},:)
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/-0.2, -0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5/)*1.0
             s2                              = (/-0.30,-0.20,-0.10,-0.05,-0.01,0.0,0.01,0.05,0.10,0.20,0.30/)
             s3                              = (/-90.0, -60, -30, -10,1,0,1,10,30,60,90/)/1.0

           else if  ( mvarnam .eq. "PRECT" ) then
             vnm1  = "PRECC"
             vnm2  = "PRECL"
             var1                              = f1->$vnm1$(:,{latS:latN},:)
             var1                              = f1->$vnm1$(:,{latS:latN},:) + f1->$vnm2$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->mtpr(:,{latS:latN},:)
               var2                            = var2*24.0*3600.0 ; covert to mm day^-1
             else
               var2                            = f2->$vnm1$(:,{latS:latN},:)
               var2                            = f2->$vnm1$(:,{latS:latN},:) + f2->$vnm2$(:,{latS:latN},:)
             end if
             s1                              = (/0.1,0.2,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,8.0/)*1.0
             s2                              = (/-10.0,-5.0,-2.0,-1.0,-0.1,0,0.1,1.0,2.0,5.0,10.0/)*1.0
             s3                              = (/-80,-50,-20,-10,-1,0,1,10,20,50,80/)/1.0
           else if  ( mvarnam .eq. "PRECC" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->mcpr(:,{latS:latN},:)
               var2                            = var2*24.0*3600.0 ; covert to mm day^-1
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0.01,0.05,0.08,0.1,0.2,0.5,0.8,1.0,1.5,2.0,3.0,4.0/)*1.0
             s2                              = (/-10.0,-5.0,-2.0,-1.0,-0.1,0,0.1,1.0,2.0,5.0,10.0/)*1.0
             s3                              = (/-80,-50,-20,-10,-1,0,1,10,20,50,80/)/1.0

           else if  ( mvarnam .eq. "PRECL" ) then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->mlspr(:,{latS:latN},:)
               var2                            = var2*24.0*3600.0 ; covert to mm day^-1
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0.01,0.05,0.08,0.1,0.2,0.5,0.8,1.0,1.5,2.0,3.0,4.0/)*1.0
             s2                              = (/-10.0,-5.0,-2.0,-1.0,-0.1,0,0.1,1.0,2.0,5.0,10.0/)*1.0
             s3                              = (/-80,-50,-20,-10,-1,0,1,10,20,50,80/)/1.0
           else if(mvarnam.eq."TGCLDLWP")then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tclw(:,{latS:latN},:)
               var2                            = var2*1000.0
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120/)*1.0
             s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*1.0
             s3                              = (/-80,-50,-30,-20,-10,0,10,20,30,50,80/)/1.0

           else if(mvarnam.eq."TGCLDIWP")then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tciw(:,{latS:latN},:)
               var2                            = var2*1000.0
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0, 2, 5, 8, 10, 15, 20, 30, 40, 50,60,80/)*1.0
             s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*1.0
             s3                              = (/-80,-50,-30,-20,-10,0,10,20,30,50,80/)/1.0

           else if(mvarnam.eq."TGCLDCWP")then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tclw(:,{latS:latN},:)
               var2                            = f2->tclw(:,{latS:latN},:) + f2->tciw(:,{latS:latN},:)
               var2                            = var2*1000.0
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120/)*1.0
             s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*1.0
             s3                              = (/-80,-50,-30,-20,-10,0,10,20,30,50,80/)/1.0

           else if(mvarnam.eq."CLDLOW")then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->lcc(:,{latS:latN},:)
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0.05,0.10,0.20,0.25,0.30,0.40,0.50,0.60,0.70,0.80,0.90,0.95/)*1.0
             s2                              = (/-0.30,-0.20,-0.1,-0.05,-0.01,0.0,0.01,0.05,0.1,0.20,0.30/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if(mvarnam.eq."CLDHGH")then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->hcc(:,{latS:latN},:)
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0.01,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.60/)*1.0
             s2                              = (/-0.30,-0.20,-0.1,-0.05,-0.01,0.0,0.01,0.05,0.1,0.20,0.30/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if(mvarnam.eq."CLDTOT")then
             var1                              = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tcc(:,{latS:latN},:)
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0.05,0.10,0.20,0.25,0.30,0.40,0.50,0.60,0.70,0.80,0.90,0.95/)*1.0
             s2                              = (/-0.30,-0.20,-0.1,-0.05,-0.01,0.0,0.01,0.05,0.1,0.20,0.30/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "LWCF")then
              var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->ttr(:,{latS:latN},:)
               var2                            = f2->ttr(:,{latS:latN},:) - f2->ttrc(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/-80,-70,-65,-60,-55,-50,-40,-30,-20,-10,-5,0/)*1.0
             s2                              = (/-9.0,-7.0,-5.0,-3.0,-1.0,0.0,1.0,3.0,5.0,7.0,9.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "SWCF")then
              var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tsr(:,{latS:latN},:)
               var2                            = f2->tsr(:,{latS:latN},:) - f2->tsrc(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/-80,-70,-65,-60,-55,-50,-40,-30,-20,-10,-5,0/)*1.0
             s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "NETCF")then
              var1                            = f1->SWCF(:,{latS:latN},:)
              var1                            = f1->SWCF(:,{latS:latN},:) + f1->LWCF(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->ttr(:,{latS:latN},:)
               var2                            = f2->ttr(:,{latS:latN},:) - f2->ttrc(:,{latS:latN},:) + \
                                                 f2->tsr(:,{latS:latN},:) - f2->tsrc(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->SWCF(:,{latS:latN},:)
               var2                            = f2->SWCF(:,{latS:latN},:) + f2->LWCF(:,{latS:latN},:)
             end if 
             s1                              = (/-60,-50,-40,-30,-25,-20,-15,-10,-5,0,5/)*1.0
             s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "RESTOM")then
               var1                            = f1->FSNT(:,{latS:latN},:)
               var1                            = f1->FSNT(:,{latS:latN},:) - f1->FLNT(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->ttr(:,{latS:latN},:)
               var2                            = f2->tsr(:,{latS:latN},:) + f2->ttr(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->FSNT(:,{latS:latN},:)
               var2                            = f2->FSNT(:,{latS:latN},:) - f2->FLNT(:,{latS:latN},:)
             end if 
             s1                              = (/-120,-110,-100,-90,-80,-70,-60,-50,-40,-30,-20,-10/)*1.0
             s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "QNET")then
               var1                            = f1->FSNS(:,{latS:latN},:)
               var1                            = f1->FSNS(:,{latS:latN},:)  - f1->FLNS(:,{latS:latN},:) - \
                                                 f1->SHFLX(:,{latS:latN},:) - f1->LHFLX(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->ssr(:,{latS:latN},:)
               var2                            = f2->ssr(:,{latS:latN},:)  + f2->str(:,{latS:latN},:) + \
                                                 f2->slhf(:,{latS:latN},:) + f2->sshf(:,{latS:latN},:) 
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->FSNS(:,{latS:latN},:)
               var2                            = f2->FSNS(:,{latS:latN},:)  - f2->FLNS(:,{latS:latN},:) - \
                                                 f2->SHFLX(:,{latS:latN},:) - f2->LHFLX(:,{latS:latN},:)
             end if 
             s1                              = (/-60, -40, -20, -10, -5, 0, 5, 10, 20, 40, 60/)*1.0
             s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "FLUT")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->ttr(:,{latS:latN},:)
               var2                            = -var2/86400.0
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/120,130,140,150,160,170,180,190,200,210,220,240/)*1.0
             s2                              = (/-10.0,-8.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,8.0,10.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "FLNTOA")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->ttr(:,{latS:latN},:)
               var2                            = -f2->ttr(:,{latS:latN},:) + f2->ttrc(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/120,130,140,150,160,170,180,190,200,210,220,240/)*1.0
             s2                              = (/-10.0,-8.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,8.0,10.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "FLUTC")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->ttrc(:,{latS:latN},:)
               var2                            = -var2/86400.0
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/120,130,140,150,160,170,180,190,200,210,220,240/)*1.0
             s2                              = (/-10.0,-8.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,8.0,10.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "FSNT")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tsr(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/40,50,60,79,80,90,100,120,140,160,180,200/)*1.0
             s2                              = (/-30.0,-20.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,20.0,30.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "FSNTOA")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tsr(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0.,5.,10.,20.,50.,100.,150.,175.,200.,225.,250.,300./)*1.0
             s2                              = (/-20.0,-15.0,-10.0,-5.0,-1.0,0.0,1.0,5.0,10.0,15.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.

           else if (mvarnam .eq. "FLNS")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->str(:,{latS:latN},:)
               var2                            = -var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/36,38,40,42,44,46,48,52,56,60,64,68/)*1.0
             s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.

           else if (mvarnam .eq. "FSNTOAC")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tsrc(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/20,40,50,55,60,80,100,120,140,180,200,220/)*1.0
             s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.

           else if (mvarnam .eq. "FSNS")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->ssr(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/10,20,30,40,50,60,70,80,90,100,110,120/)*1.0
             s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "FSDS")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->ssrd(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0.0,5.0,10.,20.,50.,100.,150.,175.,200.,225.,250.,300./)*1.0
             s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "FLDS")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->strd(:,{latS:latN},:)
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/0.0,5.0,10.,20.,50.,100.,150.,175.,200.,225.,250.,300./)*1.0
             s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "FSUTOA")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tisr(:,{latS:latN},:)
               var2                            = f2->tisr(:,{latS:latN},:)  - f2->tsr(:,{latS:latN},:) 
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.,300./)*1.0
             s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0

           else if (mvarnam .eq. "FSUTOAC")then
               var1                            = f1->$mvarnam$(:,{latS:latN},:)
             if (compare.eq."Model_vs_OBS") then
               var2                            = f2->tisr(:,{latS:latN},:)
               var2                            = f2->tisr(:,{latS:latN},:)  - f2->tsrc(:,{latS:latN},:) 
               var2                            = var2/86400.0 ; convert to W m^-2
             else
               var2                            = f2->$mvarnam$(:,{latS:latN},:)
             end if
             s1                              = (/20,25,30,35,40,60,80,100,120,130,140,150/)*1.0
             s2                              = (/-20.0,-10.0,-5.0,-2.0,-1.0,0.0,1.0,2.0,5.0,10.0,20.0/)*1.0
             s3                              = (/-50,-20,-10,-5,-1,0,1,5,10,20,50/)/1.0
           else 
             print("ERROR: variable does not exist or can not be processed by this script")
             exit
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

           ;;convert the unit for some of the variables;;;;;;;;;
           if  ( mvarnam .eq. "PRECT" .or. mvarnam .eq. "PRECC" .or. mvarnam .eq. "PRECL" ) then
            fact                            = 24*3600.0*1000.0
            unit                            = "mm day~S~-1~N~"
           else if  ( mvarnam .eq. "TGCLDLWP" .or. mvarnam .eq. "TGCLDIWP" .or. mvarnam .eq. "TGCLDCWP") then
            fact                            = 1000.0
            unit                            = "g m~S~-2~N~"
           else if  ( mvarnam .eq. "PSL" .or. mvarnam .eq. "PS")
            fact                            = 0.01
            unit                            = "hPa"
           else
            fact                            = 1.0
            unit                            = var1@units
           end if
           end if
           end if

           var1                             = var1*fact
           var2                             = var2*1.0

           var1@_FillValue                  = -9999.
           var2@_FillValue                  = -9999.

           ddd1                         = dimsizes(var1)
           ddd2                         = dimsizes(var2)

           ;;check the two comparing files and see if they are in the same grid, otherwise, return the error message;;;;
           if ((ddd1(1).ne.ddd2(1)).or.(ddd1(2).ne.ddd2(2)))then
            print("Error: this scripts requires the two files must in the same grid to run!!!")
            return
           end if

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

	   vp1x				    = dim_avg_n_Wrap(var1,0)
	   vp2x				    = dim_avg_n_Wrap(var2,0)
	  ;print(vp1x@_FillValue)

           vp1a				    = vp1x
           vp2a				    = vp2x
           vp11                             = where(ismissing(vp1a(:,:)), vp1x@_FillValue, vp1a(:,:)*mcor)
           vp1m                             = sum(vp11)
           mcor1                            = where(ismissing(vp1a(:,:)), mcor@_FillValue, mcor)
           vp22                             = where(ismissing(vp2a(:,:)), vp2x@_FillValue, vp2a(:,:)*mcor)
           vp2m                             = sum(vp22)
           mcor2                            = where(ismissing(vp2a(:,:)), mcor@_FillValue, mcor)
           vp1m                             = vp1m / sum(mcor1)
           vp2m                             = vp2m / sum(mcor2)
           delete([/var1,var2,mcor1,mcor2,vp11,vp22/])

           vp1b                             = where(abs(vp1a) .lt. 1.e-30, vp1x@_FillValue, vp1a)
           vp2b                             = where(abs(vp2a) .lt. 1.e-30, vp2x@_FillValue, vp2a)
           vp1b                             = where(ismissing(vp2b), vp1x@_FillValue, vp1b)
           vp2b                             = where(ismissing(vp1b), vp2x@_FillValue, vp2b)

           adiff                            = vp1a
           adiff                            = vp1a-vp2a

           rdiff                            = vp1a
           rdiff                            = (vp1b-vp2b)*100./abs(vp2b)
              
           mcor3                            = where(ismissing(rdiff(:,:)), mcor@_FillValue, mcor)
           rdifft                           = where(ismissing(rdiff(:,:)), rdiff@_FillValue, rdiff(:,:)*mcor)
           rdiffm                           = sum(rdifft) / sum(mcor3)
           delete([/vp1x,vp2x,rdifft,mcor3,mcor/])

           if(l_plot_ttest)then 
            adiff                           = where(prob.le.statistical_siglev,adiff,adiff@_FillValue)
            rdiff                           = where(prob.le.statistical_siglev,rdiff,rdiff@_FillValue)
           end if 
          
           wtype                        = "eps"
           ;wtype@wkWidth                = 2500
           ;wtype@wkHeight               = 2500
           figdir                       = casedir+"/Latitude-Longitude_Contour_Maps_"+pout(ll)+"/"
           fname                        = mvarnam+"_"+seas(kk)+"_latlon_"+pout(ll) 
           wks                          = gsn_open_wks(wtype,figdir+ fname)

           gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")  ; merge two color maps

           plot   = new (4,graphic)


;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    Make the Plot
;
;;;;;;;;;;;;;;;;;;;;;;;;;
	      res                  	        = True                  ; plot mods desired
	      res@cnFillOn         	        = True                  ; turn on color fill
	      res@cnLinesOn          	        = False                 ; no contour lines
	      res@cnLineLabelsOn     	        = False
	      res@tmXTOn    		 	= False

	      res@tmYLLabelFontHeightF	 	= 0.015
              res@tmBorderThicknessF            = 1.0
              res@tmXBMajorThicknessF           = 1.0
              res@tmXBMinorThicknessF           = 1.0
              res@tmYLMajorThicknessF           = 1.0
              res@tmYLMinorThicknessF           = 1.0
              res@tmYRMajorThicknessF           = 1.0
              res@tmYRMinorThicknessF           = 1.0
              res@mpGeophysicalLineThicknessF   = 0.5

              res@gsnPolarLabelFontHeightF      = 0.02
              res@gsnPolar                      = "SH"
              res@mpFillOn                      = False        ; turn off map fill
              res@mpMaxLatF                     = latN

	      res@gsnFrame          		= False                 ; Do not draw plot
	      res@gsnDraw           		= False                 ; Do not advance frame
	      res@tmYRMode          	   	= "Automatic"           ; turn off special labels on right axis
	      res@lbLabelBarOn      		= True
	      res@lbOrientation     		= "Vertical"
             ;res@pmLabelBarParallelPosF        = 0.61
              res@pmLabelBarOrthogonalPosF      = 0.15
              res@lbLabelFontHeightF            = 0.02               ; make labels smaller

	      res@cnInfoLabelOn     		= False
	      res@cnLevelSelectionMode      	= "ExplicitLevels"       ; manual levels
	      res@cnMissingValFillColor 	= "White" ;"gray76"               ; black = 1

	      res@gsnRightStringFontHeightF	= 0.025
              res@gsnRightStringOrthogonalPosF  = 0.06
	      res@gsnLeftStringFontHeightF	= 0.025

              res1 = res
              res1@cnLevels                    := sprintf("%7.2f",s1)
              res1@cnFillColors                 = (/3,4,5,6,7,8,9,10,11,12,13,14,15/)
	      res1@gsnLeftString     		= case1name
              res1@gsnRightString               = "mean: "+sprintf("%5.2f",vp1m)
	      plot(0)   			= gsn_csm_contour_map(wks,vp1a(:,:),res1)
             
	      res1@gsnLeftString     		= case2name
              res1@gsnRightString               = "mean: "+sprintf("%5.2f",vp2m)
	      plot(1) 			        = gsn_csm_contour_map(wks,vp2a(:,:),res1)

              res2 = res
	      res2@cnLevels      		= sprintf("%7.2e",s2)
	      res2@cnFillColors  		= (/18,20,22,23,24,25,26,27,28,30,31,33/)
                                                  ;(/18,20,21,22,23,24,27,28,29,30,31,33/)              ; contour interval
	      res2@gsnLeftString 		= case1name + " - ~C~" + case2name ; "absolute difference"
              res2@gsnRightString               = "mean: "+sprintf("%5.2f",vp1m - vp2m)
	      plot(2) 			        = gsn_csm_contour_map(wks,adiff(:,:),res2)
	
              res3 = res
              res3@cnLevels      		= sprintf("%7.2e",s3)
              res3@cnFillColors                 = (/18,20,22,23,24,25,26,27,28,30,31,33/)
                                                  ;(/18,20,21,22,23,24,27,28,29,30,31,33/)              ; contour interval
	      res3@gsnLeftString 		= "relative diff. (%)"
              res3@gsnRightString               = "mean: "+sprintf("%5.2f", rdiffm)
	      plot(3)	 		        = gsn_csm_contour_map(wks,rdiff(:,:),res3)
	 
              pres                              = True        ; panel plot mods desired
              pres@gsnMaximize                  = False       ; fill the page
              pres@txFontHeightF                = 0.015
              pres@txFontThicknessF             = 2.
              pres@gsnPanelXWhiteSpacePercent   = 3.
              pres@gsnPanelYWhiteSpacePercent   = 5.
              pres@txString                     = str_upper(mvarnam)+ " ("+seas(kk)+"; unit: "+unit+")"
              gsn_panel(wks,plot(:),(/2,2/),pres)

              ;convert the figure 
              ;if (wtype .eq. "png") then
              ;  tmpa = systemfunc("convert "+figdir+fname+".png -trim del.png")
              ;  tmpb = systemfunc("mv del.png "+fname+".png")
              ;end if

              delete([/vp1a,vp2a,adiff,rdiff,vp1b,vp2b/])

           delete([/plot,res,pres,wks,ddd1,ddd2,s1,s2,s3/])

        end do       ; end of looping over variables

        delete([/f1,ps1,ha1,hb1,p0,p1/])
        if(compare.eq."Model_vs_OBS") then
           delete([/f2,ps2/])
        else
           delete([/f2,ps2,ha2,hb2,p2/])
        end if
     end do          ; end of looping over seasons
  end do
end
