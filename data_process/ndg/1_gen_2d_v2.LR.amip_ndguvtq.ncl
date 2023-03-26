;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;This script used to calculate and plot the zonal mean variables from CAM;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;The terms zonal and meridional are used to describe directions on a globe;;;;;;;
;;;;;;;Zonal means "along a latitudinal circle" or "in the west–east direction";;;;;;;;
;;;;;;;while meridional means "along a longitudinal circle" (a.k.a. meridian) ;;;;;;;;;
;;;;;;;or "in the north–south direction" [2];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  out_dir   = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_NDG/"
  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/E3SMv2"
  exp_name  = (/"v2.LR.amip.ndguvtq"/)
  nexps     = dimsizes(exp_name)
  ystr      = 200801
  yend      = 201712
  time_tag  = "2008-2017"
  grid_tag  = "1x1"

  seasons   = (/"MON"/)
  nseas     = dimsizes(seasons)
  d2r       = get_d2r("float")

 ;define regions for eof analysis
  latS       = -90.  ;negative for southern hemisphere
  latN       =  90.  ;negative for southern hemisphere
  lonW       =  0.0
  lonE       = 360.0

  fili    = "./share_var_info.txt"
  dstr    = asciiread(fili, -1, "string")
  delim   = ","
  varList = str_squeeze(str_get_field(dstr, 1, delim))
  untList = str_squeeze(str_get_field(dstr, 2, delim))
  facList = stringtofloat(str_get_field(dstr, 3, delim))
  nvars = dimsizes(varList)

  do k  = 0,nexps-1,1

   fl1        = systemfunc("ls "+data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"*"+time_tag(k)+".nc")
   nens  = dimsizes(fl1)

   do ie = 0,nens-1,1

    print(fl1(ie))
    f1 = addfile(fl1(ie),"r")

    do j = 0,nvars-1,1

    vars   = varList(j)
    varunt = untList(j)
    facmod = facList(j)

    print("working on variable "+ vars)

    lat  = f1->lat
    lon  = f1->lon

    time = f1->time
    time = time - 1

    year          = cd_calendar(time, 1) 
    indy          = ind(year.ge.ystr.and.year.le.yend)
    obstime       = time(indy)
    obstime@units = time@units

    if(vars.eq."Z500") then
      xtmp = vinth2p(f1->Z3,f1->hyam,f1->hybm,500.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(indy,0,{latS:latN},{lonW:lonE})
    else if (vars.eq."T850") then
      xtmp = vinth2p(f1->T,f1->hyam,f1->hybm,850.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(indy,0,{latS:latN},{lonW:lonE})
    else if (vars.eq."U850") then
      xtmp = vinth2p(f1->U,f1->hyam,f1->hybm,850.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(indy,0,{latS:latN},{lonW:lonE})
    else if (vars.eq."V850") then
      xtmp = vinth2p(f1->V,f1->hyam,f1->hybm,850.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(indy,0,{latS:latN},{lonW:lonE})
    else if (vars.eq."U200") then
      xtmp = vinth2p(f1->U,f1->hyam,f1->hybm,200.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(indy,0,{latS:latN},{lonW:lonE})
    else if (vars.eq."V200") then
      xtmp = vinth2p(f1->V,f1->hyam,f1->hybm,200.0,f1->PS,1,f1->P0/100.0,1,False)
      var0 = xtmp(indy,0,{latS:latN},{lonW:lonE})
    else if (vars.eq."PRECT") then
      xtmp = f1->PRECC
      xtmp = xtmp + f1->PRECL
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."PRECST") then
      xtmp = f1->PRECSC
      xtmp = xtmp + f1->PRECSL
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."SWCF_SRF") then
      xtmp = f1->FSNS
      xtmp = xtmp - f1->FSNSC
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."LWCF_SRF") then
      xtmp = f1->FLNSC
      xtmp = xtmp - f1->FLNS
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."CRE_SRF") then
      xtmp = f1->FLNSC
      xtmp = xtmp - f1->FLNS
      xtmp = xtmp + f1->FSNS
      xtmp = xtmp - f1->FSNSC
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface cloud radiative effects"
    else if (vars.eq."SWCRE_SRF") then
      xtmp = f1->FSNS
      xtmp = xtmp - f1->FSNSC
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface cloud radiative effects (SW)"
    else if (vars.eq."LWCRE_SRF") then
      xtmp = f1->FLNSC
      xtmp = xtmp - f1->FLNS
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface cloud radiative effects (LW)"
    else if (vars.eq."CRE") then
      xtmp = f1->LWCF
      xtmp = xtmp + f1->SWCF
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "TOA cloud radiative effects"
    else if (vars.eq."SWCRE") then
      xtmp = f1->SWCF
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "TOA cloud radiative effects (SW)"
    else if (vars.eq."LWCRE") then
      xtmp = f1->LWCF
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "TOA cloud radiative effects (LW)"
    else if (vars.eq."RESSURF") then
      xtmp = f1->FSNS
      xtmp = xtmp - f1->FLNS
      xtmp = xtmp - f1->SHFLX
      xtmp = xtmp - f1->LHFLX
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."QnRad_SRF") then
      xtmp = f1->FSNS
      xtmp = xtmp - f1->FLNS
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "Total surface radiative fluxes (positive down)"
    else if(vars.eq."QnTur_SRF") then
      xtmp = f1->LHFLX
      xtmp = -xtmp -f1->SHFLX
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "Total surface turbulent fluxes (positive down)"
    else if (vars.eq."QnTot_SRF") then
      xtmp = f1->FSNS
      xtmp = xtmp - f1->FLNS - f1->SHFLX - f1->LHFLX
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "Net surface total fluxes (positive down)"
    else if(vars.eq."Qn_SRF") then
      beta = f1->FSDS
      beta = where((f1->FSDS).eq.0,beta@_FillValue,beta)
      beta = (f1->FSDS - f1->FSNS)/beta
      xtmp = f1->FSDS
      xtmp = (1.0 - beta) * f1->FSDS         \
             + f1->FLDS - (f1->FLDS + f1->FLNS) \
             - f1->SHFLX  \
             - f1->LHFLX
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "Net surface total fluxes (positive down)"
    else if (vars.eq."RESTOA") then
      xtmp = f1->FSNTOA
      xtmp = f1->FSNTOA - f1->FLUT
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."S10") then
      xtmp = f1->U10
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."U10") then
      nlev = dimsizes(f1->lev)
      xtmp = f1->U(:,nlev-1,:,:)
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."V10") then
      nlev = dimsizes(f1->lev)
      xtmp = f1->V(:,nlev-1,:,:)
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."ETH1".or. vars.eq."ETH2".or.vars.eq."ETH12") then
      fcor  = coriolis_param(tofloat(f1->lat)); coriolis parm (1/s)
      cpair = 1005.0   ; heat capacity of air (J/kg/K)
      cp_sw = 3.996e3  ; specific heat salt water(J/kg/C)
      rho_sw= 1026.0   ; kg/m3
      tztmp = f1->TS    ; surface temperature (K)
      tztmp = tztmp - 273.15 ; convert to C
      txtmp = f1->TAUX  ; zonal surface stress (N/m2)
      tytmp = f1->TAUY  ; meridional surface stress (N/m2)
      txtmp = txtmp * -1.0
      tytmp = tytmp * -1.0
      tzclm = clmMonTLL (tztmp)
      txclm = clmMonTLL (txtmp)
      tyclm = clmMonTLL (tytmp)
      tzanm = calcMonAnomTLL(tztmp,tzclm)
      txanm = calcMonAnomTLL(txtmp,txclm) 
      tyanm = calcMonAnomTLL(tytmp,tyclm)
      if(vars.eq."ETH12") then       
        gradLatLon = grad_latlon_cfd (tztmp, tztmp&lat, tztmp&lon, True, False)
        dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list' 
        dzdx  = tofloat(gradLatLon[1])
        xtmp  = tztmp 
        xtmp  = -cp_sw/conform(tztmp,fcor,1) * (dzdx*tytmp - dzdy*txtmp)
        xtmp@long_name = "Full Ekman heat transport (ETH) anomaly" 
        xtmp@units     = "W m~S~-2~N~"
        delete([/gradLatLon,dzdy,dzdx/])
      end if 
      if(vars.eq."ETH1") then
        gradLatLon = grad_latlon_cfd (tzclm, tzclm&lat, tzclm&lon, True, False)
        dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'     
        dzdx  = tofloat(gradLatLon[1])
        dimx  = dimsizes(tztmp)
        ny    = dimx(0)/12
        xtmp  = tztmp
        ytmp  = -cp_sw/conform(tztmp,fcor,1)
        do iy = 0,ny-1
          iy1 = iy*12
          iy2 = (iy+1)*12-1
          xtmp(iy1:iy2,:,:) = ytmp(iy1:iy2,:,:) \
                              *(dzdx(:,:,:)*tyanm(iy1:iy2,:,:) - dzdy(:,:,:)*txanm(iy1:iy2,:,:))
        end do 
        xtmp@long_name = "ETH anomaly: anomalous winds acting on clim SST gradient" 
        xtmp@units     = "W m~S~-2~N~"
        delete([/dimx,ny,gradLatLon,dzdy,dzdx,ytmp/])
      end if
      if(vars.eq."ETH2") then
        gradLatLon = grad_latlon_cfd (tzanm, tzanm&lat, tzanm&lon, True, False)
        dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'
        dzdx  = tofloat(gradLatLon[1])
        dimx  = dimsizes(tztmp)
        ny    = dimx(0)/12
        xtmp  = tztmp
        ytmp  = -cp_sw/conform(tztmp,fcor,1)
        do iy = 0,ny-1
          iy1 = iy*12
          iy2 = (iy+1)*12-1
          xtmp(iy1:iy2,:,:) = ytmp(iy1:iy2,:,:) \
                              *(dzdx(iy1:iy2,:,:)*tyclm(:,:,:) - dzdy(iy1:iy2,:,:)*txclm(:,:,:))
        end do
        xtmp@long_name = "ETH anomaly: clim winds acting on anomalous SST gradient"
        xtmp@units     = "W m~S~-2~N~"
        delete([/dimx,ny,gradLatLon,dzdy,dzdx,ytmp/])
      end if
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      delete([/fcor,cpair,cp_sw,rho_sw,tztmp,txtmp,tytmp,tzclm,txclm,tyclm,tzanm,txanm,tyanm/])
    else
      xtmp = f1->$vars$
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
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

    var0@_FillValue = -9999.
    var0       = var0*facmod
    var0@units = varunt
    delete(var0&time)
    var0&time  = obstime
    delete([/time,year,indy,xtmp/])

   ;printVarSummary(var0)
   ;printMinMax(var0, True)

    setfileoption("nc", "Format",  "NetCDF4")
    enstr     = "en"+sprinti("%02d",ie)
    out_file  = out_dir+exp_name(k)+"."+enstr+"."+vars+"."+ystr+"-"+yend+".nc"
    system("rm " + out_file)
    fout = addfile(out_file,"cw")
    vs1 = vars
    fout->$vs1$  = var0
    delete([/fout,var0/])

  end do 

 end do 

end do 

end
