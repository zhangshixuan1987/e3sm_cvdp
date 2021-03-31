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
  case1                                      = getenv("TEST")
  case2                                      = getenv("CTRL")
  case1name                                  = getenv("TEST_NAME")
  case2name                                  = getenv("CTRL_NAME")
  casedir                                    = getenv("CASEDIR")

;variable name in the climo file

  vars 				   		= (/"CLDTOT","CLDLOW","CLDHGH","TGCLDCWP","TGCLDLWP", "TGCLDIWP",\
                                                    "PRECC","PRECL","PRECT", \
                                                    "FLUT","FSNTOA","FSNTOAC","FSUTOA","FSUTOAC","FSDS", \
                                                    "FSNS","FLNS","FLDS","RESTOM","QNET","TREFHT", \
                                                    "TS","U10","LHFLX","SHFLX","TMQ","PSL", \
                                                    "TAUX", "TAUY" \
                                                   /)
  seas 				   		= (/"ANN","DJF","JJA"/)
  pi                                            = 3.14159265
  rearth                                        = 6.37122e6
  grav 				   		= 9.806
  pout				   		= "bdn"

;define regions for plot
  latS                                          = -90.  ;negative for southern hemisphere
  latN                                          = -55.  ;negative for southern hemisphere

;read in two files

  do ll = 0, dimsizes(pout)-1

     do kk = 0, dimsizes(seas)-1

        f 			   		= systemfunc("ls $TPATH/*"+seasons(kk)+"_climo.nc")
        f1			   		= addfile(f,"r")
        ps1   	                                = f1->PS
        ha1   	                                = doubletofloat(f1->hyai)
        hb1   	                                = doubletofloat(f1->hybi)
        p0    	                                = doubletofloat(f1->P0)
        p1    	                                = pres_hybrid_ccm(ps1,p0,ha1,hb1)
        gw1                                     = doubletofloat(f1->gw)

        f                                       = systemfunc("ls $CPATH/*"+seasons(kk)+"_climo.nc")
        f2                                      = addfile(f,"r")
        ps2                                     = f2->PS
        ha2                                     = doubletofloat(f2->hyai)
        hb2                                     = doubletofloat(f2->hybi)
        p2                                      = pres_hybrid_ccm(ps2,p0,ha2,hb2)
        gw2                                     = doubletofloat(f2->gw)
        
        do jj = 0, dimsizes(vars)-1

           varnam                              = vars(jj)

           print("working on variable "+ varnam)

           if  ( varnam .eq. "PRECT" ) then
               var1                            = f1->PRECC(:,{latS:latN},:)
               var2                            = f2->PRECC(:,{latS:latN},:)
               var1                            = f1->PRECC(:,{latS:latN},:) + f1->PRECL(:,{latS:latN},:)
               var2                            = f2->PRECC(:,{latS:latN},:) + f2->PRECL(:,{latS:latN},:)
           else if (varnam .eq. "NETCF")then
               var1                            = f1->SWCF(:,{latS:latN},:)
               var2                            = f2->SWCF(:,{latS:latN},:)
               var1                            = f1->SWCF(:,{latS:latN},:) + f1->LWCF(:,{latS:latN},:)
               var2                            = f2->SWCF(:,{latS:latN},:) + f2->LWCF(:,{latS:latN},:)
           else if (varnam .eq. "RESTOM")then
               var1                            = f1->FSNT(:,{latS:latN},:)
               var2                            = f2->FSNT(:,{latS:latN},:)
               var1                            = f1->FSNT(:,{latS:latN},:) - f1->FLNT(:,{latS:latN},:)
               var2                            = f2->FSNT(:,{latS:latN},:) - f2->FLNT(:,{latS:latN},:)
           else if (varnam .eq. "QNET")then
               var1                            = f1->FSNS(:,{latS:latN},:)
               var2                            = f2->FSNS(:,{latS:latN},:)
               var1                            = f1->FSNS(:,{latS:latN},:)  - f1->FLNS(:,{latS:latN},:) - \
                                                 f1->SHFLX(:,{latS:latN},:) - f1->LHFLX(:,{latS:latN},:)
               var2                            = f2->FSNS(:,{latS:latN},:)  - f2->FLNS(:,{latS:latN},:) - \
                                                 f2->SHFLX(:,{latS:latN},:) - f2->LHFLX(:,{latS:latN},:) 
           else 
               var1                            = f1->$varnam$(:,{latS:latN},:)
               var2                            = f2->$varnam$(:,{latS:latN},:)
           end if 
           end if
           end if
           end if

	   ddd1  			= dimsizes(var1)
	   ddd2  			= dimsizes(var2)

           wks                          = gsn_open_wks("eps",casedir+"/set02/"+varnam+"_"+seasons(kk)+"_latlon_"+pout(ll))

           gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred")  ; merge two color maps

           plot   = new (4,graphic)

           if  ( varnam .eq. "PRECT" .or. varnam .eq. "PRECC" .or. varnam .eq. "PRECL" ) then
            fact                            = 24*3600.0*1000.0
            unit                            = "mm day~S~-1~N~"
           else if  ( varnam .eq. "TGCLDLWP" .or. varnam .eq. "TGCLDIWP" .or. varnam .eq. "TGCLDCWP") then
            fact                            = 1000.0
            unit                            = "g m~S~-2~N~"
           else if  ( varnam .eq. "PSL" .or. varnam .eq. "PS")
            fact                            = 0.01
            unit                            = "hPa" 
           else
            fact                            = 1.0
            unit                            = var1@units
           end if
           end if
           end if 

	   var1				    = var1*fact
	   var2				    = var2*fact
	   
	   vp1				    = dim_avg_n_Wrap(var1,0)
	   vp2				    = dim_avg_n_Wrap(var2,0)
	   
	   vp1@_FillValue                   = -999.
	   vp2@_FillValue                   = -999.
	   vp2x				    = vp2
	   vp1x				    = vp1

	   if  (ddd1(1) .lt. ddd2(1)) then
	      lat1				= f1->lat
	      lon1				= f1->lon
	      lat2				= f2->lat
	      lon2				= f2->lon
	      poisson_grid_fill(vp2x,True,1,1000,1e-2,0.5,0)
	      vp2a				= area_conserve_remap_Wrap (lon2,lat2,vp2x, lon1,lat1, False)
	      vp1a				= vp1x
              mcor                          = new((/ddd1(1),ddd1(2)/),float)
              mcor@_FillValue               = vp1@_FillValue
              do i = 0, ddd1(1)-1
                 mcor(i,:)                  = gw1(i)*(2.*pi/ddd1(2))*rearth^2.
              end do
              vp11                          = where(ismissing(vp1a(:,:)), vp1@_FillValue, vp1a(:,:)*mcor)
              vp1m                          = sum(vp11)
              vp22                          = where(ismissing(vp2a(:,:)), vp2@_FillValue, vp2a(:,:)*mcor)
              vp2m                          = sum(vp22)
              mcor1                         = where(ismissing(vp1a(:,:)), mcor@_FillValue, mcor)
              mcor2                         = where(ismissing(vp2a(:,:)), mcor@_FillValue, mcor)
              vp1m                          = vp1m / sum(mcor1)
              vp2m                          = vp2m / sum(mcor2)
              delete([/lat1,lon1,lat2,lon2,var1,var2,vp1x,vp2x,vp11,vp22,mcor,mcor1,mcor2/])
           end if

	   if  (ddd1(1) .gt. ddd2(1)) then
	      lat1				= f1->lat
	      lon1				= f1->lon
	      lat2				= f2->lat
              lon2				= f2->lon
	      poisson_grid_fill(vp1x,True,1,1000,1e-2,0.5,0)
	      vp1a				= area_conserve_remap_Wrap (lon1,lat1,vp1x, lon2,lat2, False)
	      vp2a				= vp2x
              mcor                          = new((/ddd2(1),ddd2(2)/),float)
              mcor@_FillValue               = vp1@_FillValue
              do i = 0, ddd2(1)-1           
                 mcor(i,:)                  = gw2(i)*(2.*pi/ddd2(2))*rearth^2.
              end do 
              vp11                          = where(ismissing(vp1a(:,:)), vp1@_FillValue, vp1a(:,:)*mcor)
              vp1m                          = sum(vp11)
              mcor1                         = where(ismissing(vp1a(:,:)), mcor@_FillValue, mcor)
              vp22                          = where(ismissing(vp2a(:,:)), vp2@_FillValue, vp2a(:,:)*mcor)
              vp2m                          = sum(vp22)
              mcor2                         = where(ismissing(vp2a(:,:)), mcor@_FillValue, mcor)
              vp1m                          = vp1m / sum(mcor1)
              vp2m                          = vp2m / sum(mcor2)
              delete([/lat1,lon1,lat2,lon2,var1,var2,vp1x,vp2x,mcor1,mcor2,vp11,vp22,mcor/])
	    end if

	    if  (ddd1(1) .eq. ddd2(1)) then
              vp1a				= vp1x
              vp2a				= vp2x
              mcor                          = new((/ddd2(1),ddd2(2)/),float)
              mcor@_FillValue               = vp1@_FillValue
              do i = 0, ddd2(1)-1           
                 mcor(i,:)                  = gw2(i)*(2.*pi/ddd2(2))*rearth^2.
              end do 
              vp11                          = where(ismissing(vp1a(:,:)), vp1@_FillValue, vp1a(:,:)*mcor)
              vp1m                          = sum(vp11)
              mcor1                         = where(ismissing(vp1a(:,:)), mcor@_FillValue, mcor)
              vp22                          = where(ismissing(vp2a(:,:)), vp2@_FillValue, vp2a(:,:)*mcor)
              vp2m                          = sum(vp22)
              mcor2                         = where(ismissing(vp2a(:,:)), mcor@_FillValue, mcor)
              vp1m                          = vp1m / sum(mcor1)
              vp2m                          = vp2m / sum(mcor2)
              delete([/var1,var2,vp1x,vp2x,mcor1,mcor2,vp11,vp22,mcor/])
	    end if

              vp1b                              = where(abs(vp1a) .lt. 1.e-30, vp1@_FillValue, vp1a)
              vp2b                              = where(abs(vp2a) .lt. 1.e-30, vp2@_FillValue, vp2a)
              vp1b                              = where(ismissing(vp2b), vp1@_FillValue, vp1b)
              vp2b                              = where(ismissing(vp1b), vp2@_FillValue, vp2b)

              adiff                             = vp1a
              adiff                             = vp1a-vp2a

              rdiff                             = vp1a
              rdiff                             = (vp1b-vp2b)/fabs(vp2b)*100.
              
              if  ( ddd1(1) .gt. ddd2(1) ) then
                  mcor                          = new((/ddd2(1),ddd2(2)/),float)
                  mcor@_FillValue               = vp2@_FillValue
                  do i = 0, ddd2(1)-1          
                     mcor(i,:)                  = gw2(i)*(2.*pi/ddd2(2))*rearth^2.
                  end do
              else
                  mcor                          = new((/ddd1(1),ddd1(2)/),float)
                  mcor@_FillValue               = vp1@_FillValue
                  do i = 0, ddd1(1)-1          
                     mcor(i,:)                  = gw1(i)*(2.*pi/ddd1(2))*rearth^2.
                  end do
              end if
              mcor                              = where(ismissing(rdiff(:,:)), mcor@_FillValue, mcor)
              rdifft                            = where(ismissing(rdiff(:,:)), rdiff@_FillValue, rdiff(:,:)*mcor)
              rdiffm                            = sum(rdifft) / sum(mcor)
              delete([/rdifft,mcor/])

              aagg                              = (max(vp2a)+max(vp1a))/2.
              aagg                              = log10(aagg)
              expo                              = floor(aagg)
              bbgg                              = aagg - expo
              s1                                = (/0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50/) 
              s1                                = s1*10^(round((aagg-2.7),3))

              aagg                              = max(abs(adiff)) ; 0.25*(abs(max(adiff))+abs(min(adiff)))/2.
              aagg                              = log10(aagg)
              expo                              = ceil(aagg)
              s2                                = (/-100.,-50.,-20.,-10.,-5.,-2.,2.,5.,10.,20.,50.,100./) * 10^expo / 100.
              s3                                = (/-100,-50,-20,-10,-5,-2,2,5,10,20,50,100/)*1.0

              if(varnam.eq."PSL")then
                s1                              = (/960,965,970,975,980,985,990,995,1000,1005,1008,1010/)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
                s3                              = (/-100,-50,-20,-10,-5,-2,2,5,10,20,50,100/)/100.0
              end if 

              if(varnam.eq."PS")then
                s1                              = (/900,925,950,955,960,965,970,975,980,985,995,1005/)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
              end if

              if(varnam.eq."CLDLOW" .or. varnam.eq."CLDTOT")then
                s1                              = (/0.05,0.10,0.20,0.25,0.30,0.40,0.50,0.60,0.70,0.80,0.90,0.95/)*1.0
                s2                              = (/-0.30,-0.20,-0.15,-0.1,-0.05,-0.01,0.01,0.05,0.1,0.15,0.20,0.30/)*1.0           
              end if

              if(varnam.eq."CLDHGH")then
                s1                              = (/0.01,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.60/)*1.0
                s2                              = (/-0.30,-0.20,-0.15,-0.1,-0.05,-0.01,0.01,0.05,0.1,0.15,0.20,0.30/)*1.0
              end if

              if(varnam.eq."TGCLDCWP")then
                s1                              = (/5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120/)*1.0
                s2                              = (/-40.0,-30.0,-20.0,-10.0,-5.0,-1.0,1.0,5.0,10.0,20.0,30.0,40.0/)*1.0
              end if

              if(varnam.eq."TGCLDLWP")then
                s1                              = (/5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120/)*1.0
                s2                              = (/-40.0,-30.0,-20.0,-10.0,-5.0,-1.0,1.0,5.0,10.0,20.0,30.0,40.0/)*1.0
              end if

              if(varnam.eq."PRECT")then
                s1                              = (/0.1,0.2,0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,8.0/)*1.0
                s2                              = (/-2.0,-1.0,-0.8,-0.5,-0.2,-0.1,0.1,0.2,0.5,0.8,1.0,2.0/)*1.0
              end if

              if(varnam.eq."PRECC")then
                s1                              = (/0.01,0.05,0.08,0.1,0.2,0.5,0.8,1.0,1.5,2.0,3.0,4.0/)*1.0
                s2                              = (/-2.0,-1.0,-0.8,-0.5,-0.2,-0.1,0.1,0.2,0.5,0.8,1.0,2.0/)*1.0
              end if

              if(varnam.eq."PRECL")then
                s1                              = (/0.01,0.05,0.08,0.1,0.2,0.5,0.8,1.0,1.5,2.0,3.0,4.0/)*1.0
                s2                              = (/-2.0,-1.0,-0.8,-0.5,-0.2,-0.1,0.1,0.2,0.5,0.8,1.0,2.0/)*1.0
              end if

              if(varnam.eq."TGCLDIWP")then
                s1                              = (/0, 2, 5, 8, 10, 15, 20, 30, 40, 50,60,80/)*1.0
                s2                              = (/-40.0,-30.0,-20.0,-10.0,-5.0,-1.0,1.0,5.0,10.0,20.0,30.0,40.0/)*1.0
              end if

              if (varnam .eq. "RESTOM") then
                s1                              = (/-120,-110,-100,-90,-80,-70,-60,-50,-40,-30,-20,-10/)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
              end if

              if (varnam .eq. "QNET") then
                s1                              = (/-60, -40, -20, -10, -5, 0, 5, 10, 20, 40, 60, 80/)*1.0
                s2                              = (/-30.0,-20.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,20.0,30.0/)*1.0
              end if

              if(varnam.eq."FLUT" .or. varnam .eq. "FLNTOA" )then
                s1                              = (/120,130,140,150,160,170,180,190,200,210,220,240/)*1.0
                s2                              = (/-10.0,-8.0,-5.0,-3.0,-1.0,-0.1,0.1,1.0,3.0,5.0,8.0,10.0/)
              end if

              if(varnam.eq."FSNT" )then
                s1                              = (/40,50,60,79,80,90,100,120,140,160,180,200/)*1.0
                s2                              = (/-30.0,-20.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,20.0,30.0/)*1.0
              end if

              if (varnam .eq. "FSNTOA") then
                s1                              = (/0.,5.,10.,20.,50.,100.,150.,175.,200.,225.,250.,300./)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
              end if

              if (varnam .eq. "FLNS") then
                s1                              = (/36,38,40,42,44,46,48,52,56,60,64,68/)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
              end if

              if (varnam .eq. "FSNTOAC") then
                s1                              = (/20,40,50,55,60,80,100,120,140,180,200,220/)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
              end if

              if (varnam .eq. "FSNS") then
                s1                              = (/10,20,30,40,50,60,70,80,90,100,110,120/)*1.0
                s2                              = (/-30.0,-20.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,20.0,30.0/)*1.0
              end if

              if (varnam .eq. "FSDS") then
                s1                              = (/0.0,5.0,10.,20.,50.,100.,150.,175.,200.,225.,250.,300./)*1.0
                s2                              = (/-30.0,-20.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,20.0,30.0/)*1.0
              end if

              if (varnam .eq. "FLDS") then
                s1                              = (/60,80,100,120,140,160,180,200,220,240,260,280/)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
              end if

              if (varnam .eq. "FSUTOA") then
                s1                              = (/25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.,300./)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
              end if

              if (varnam .eq. "FSUTOAC") then
                s1                              = (/20,25,30,35,40,60,80,100,120,130,140,150/)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
              end if


              if (varnam .eq. "TREFHT" .or. varnam .eq. "TS") then
                s1                              = (/228,232,236,244,252,260,268,270,272,274,276,280/)*1.0
                s2                              = (/-5.0,-2.0,-1.0,-0.5,-0.2,-0.1,0.1,0.2,0.5,1.0,2.0,5.0/)*1.0
              end if

              if (varnam .eq. "U10") then
                s1                              = (/0,1,2,3,4,5,6,7,8,10,12,15/)*1.0
                s2                              = (/-3.0,-2.0,-1.0,-0.5,-0.2,-0.1,0.1,0.2,0.5,1.0,2.0,3.0/)*1.0
              end if

              if (varnam .eq. "TMQ") then
                s1                              = (/0,1,2,3,4,5,6,7,8,10,12,15/)*1.0
                s2                              = (/-1.6,-1.2,-0.8,-0.4,-0.2,-0.1,0.1,0.2,0.4,0.8,1.2,1.6/)*1.0
              end if

              if (varnam .eq. "SHFLX") then
                s1                              = (/0, 1, 2, 5, 8, 10, 20, 30, 40, 50, 60, 80/)*1.0
                s2                              = (/-15.0,-12.0,-8.0,-4.0,-2.0,-1.0,1.0,2.0,4.0,8.0,12.0,15.0/)*1.0
              end if

              if (varnam .eq. "LHFLX") then
                s1                              = (/-5, 0, 5, 10, 15, 20, 25, 30, 40, 50, 60, 80/)*1.0
                s2                              = (/-20.0,-15.0,-10.0,-5.0,-2.0,-1.0,1.0,2.0,5.0,10.0,15.0,20.0/)*1.0
              end if

              if (varnam .eq. "TAUX") then
                s1                              = (/-0.2, -0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5/)*1.0
                s2                              = (/-0.12,-0.1,-0.08,-0.05,-0.02,-0.01,0.01,0.02,0.05,0.08,0.1,0.12/)
              end if                                
                        

              if (varnam .eq. "TAUY") then
                s1                              = (/-0.2, -0.16, -0.12, -0.08, -0.04, 0, 0.04, 0.08, 0.12, 0.16,0.2,0.24/)*1.0
                s2                              = (/-0.12,-0.1,-0.08,-0.05,-0.02,-0.01,0.01,0.02,0.05,0.08,0.1,0.12/)
              end if                                
                        

; rdiff=mask(rdiff,adiff.lt.s2(6).and.adiff.gt.s2(5),False)
 
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
	      res@cnMissingValFillColor 	= "gray76"               ; black = 1
	      res@cnLevels       		= sprintf("%7.2f",s1)
	      res@cnFillColors   		= (/3,4,5,6,7,8,9,10,11,12,13,14,15/)

	      res@gsnRightStringFontHeightF	= 0.025
              res@gsnRightStringOrthogonalPosF  = 0.06
	      res@gsnLeftStringFontHeightF	= 0.025

	      res@gsnLeftString     		= case1name
              res@gsnRightString                = "mean: "+sprintf("%5.2f",vp1m)
	      plot(0)   			= gsn_csm_contour_map(wks,vp1a(:,:),res)
	      res@gsnLeftString     		= case2name
              res@gsnRightString                = "mean: "+sprintf("%5.2f",vp2m)
	      plot(1) 			        = gsn_csm_contour_map(wks,vp2a(:,:),res)
	      res@cnLevels      		= sprintf("%7.2e",s2)
	      res@cnFillColors  		= (/18,20,21,22,23,24,0,27,28,29,30,31,33/)              ; contour interval
	      res@gsnLeftString 		= case1name + " - " + case2name ; "absolute difference"
              res@gsnRightString                = "mean: "+sprintf("%5.2f",vp1m - vp2m)
	      plot(2) 			        = gsn_csm_contour_map(wks,adiff(:,:),res)
	      res@cnLevels      		= sprintf("%7.2e",s3)
	      res@gsnLeftString 		= "relative diff. (%)"
              res@gsnRightString                = "mean: "+sprintf("%5.2f", rdiffm)
	      plot(3)	 		        = gsn_csm_contour_map(wks,rdiff(:,:),res)
	 
              pres                              = True        ; panel plot mods desired
              pres@gsnMaximize                  = False       ; fill the page
              pres@txFontHeightF                = 0.015
              pres@txFontThicknessF             = 2.
              pres@gsnPanelXWhiteSpacePercent   = 3.
              pres@gsnPanelYWhiteSpacePercent   = 5.
              pres@txString                     = str_upper(varnam)+ " ("+seasons(kk)+"; unit: "+unit+")"
              gsn_panel(wks,plot(:),(/2,2/),pres)

              delete([/vp1a,vp2a,adiff,rdiff,vp1,vp2,vp1b,vp2b/])

           delete([/plot,res,pres,wks,ddd1,ddd2,s1,s2,s3/])

        end do       ; end of looping over variables

        delete([/f1,ps1,ha1,hb1,p0,p1,f2,ps2,ha2,hb2,p2/])

     end do          ; end of looping over seasons

  end do

end
