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

  flmsk     = "/global/cfs/cdirs/e3sm/zhan391/local_diag/fig_data/lnd_msk/landmsk.nc"
  out_dir   = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/"
  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/Observation"
  exp_name  = (/"CERES_EBAF"/)
  out_name  = (/"CERES-OAFlux"/)
  nexps     = dimsizes(exp_name)
  time_tag  = "2001-2021"
  grid_tag  = "1x1"

  ystr      = 200101
  yend      = 201812

  seasons   = (/"MON"/)
  nseas     = dimsizes(seasons)
  d2r       = get_d2r("float")

 ;define regions for eof analysis
  latS       = -90.  ;negative for southern hemisphere
  latN       =  90.  ;negative for southern hemisphere
  lonW       =  0.0
  lonE       = 360.0

  fili    = "./share_var_info_2d.txt"
  dstr    = asciiread(fili, -1, "string")
  delim   = ","
  varList = str_squeeze(str_get_field(dstr, 1, delim))
  untList = str_squeeze(str_get_field(dstr, 2, delim))
  facList = stringtofloat(str_get_field(dstr, 3, delim))
  nvars = dimsizes(varList)

  do k  = 0,nexps-1,1

   f0    = addfile(flmsk,"r")
   fl1   = systemfunc("ls "+data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"*"+time_tag(k)+"_1x1.nc")
   fl2   = systemfunc("ls "+data_dir+"/OAFlux/OAFlux*1958-2018"+"_"+grid_tag+".nc")
   nens  = 1 

   do ie = 0,nens-1,1

    print(fl1(ie))
    f1 = addfile(fl1,"r")
    f2 = addfile(fl2,"r")

    do j = 0,nvars-1,1

    vars   = varList(j)
    varunt = untList(j)
    facmod = facList(j)

    print("working on variable "+ vars)

    lat  = f1->lat
    lon  = f1->lon

    cd_date       = cd_calendar(f1->time, 1)
    year          = tointeger(cd_date(:))
    indy          = ind(year.ge.ystr.and.year.le.yend)
    obstime       = f1->time(indy)
    obstime@units = f1->time@units

    cd_dat0       = cd_calendar(f2->time, 1)
    yea0          = tointeger(cd_dat0(:))
    ind0          = ind(yea0.ge.ystr.and.yea0.le.yend)
    obstim0       = f2->time(ind0)
    obstim0@units = f2->time@units

    if (vars.eq."NET_FLUX_SRF") then
      xtmp = f1->FSNS(indy,:,:)
      xtmp = xtmp - f1->FLNS(indy,:,:) \
                  - f2->SHFLX(ind0,:,:)  \
                  - f2->LHFLX(ind0,:,:)
      xtmp@_FillValue = -9999.
      msk  = f2->SHFLX(ind0,:,:)
      xtmp = where (ismissing(msk),xtmp@_FillValue,xtmp)
      delete([/msk/])
      var0 = xtmp(:,{latS:latN},{lonW:lonE})
      var0       = var0*facmod
      var0@units = varunt
      var0 = xtmp(:,{latS:latN},{lonW:lonE})
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
    else if(vars.eq."Qn_SRF") then
      beta = f1->ALBEDO_SRF(indy,:,:)
      xtmp = f1->FSDS(indy,:,:)
      xtmp = (1.0 - beta) * f1->FSDS(indy,:,:)         \
             + f1->FLDS(indy,:,:) - f1->FLUS(indy,:,:) \
             - f2->SHFLX(ind0,:,:)  \
             - f2->LHFLX(ind0,:,:)
      xtmp@_FillValue = -9999.
      msk  = f2->SHFLX(ind0,:,:)
      xtmp = where (ismissing(msk),xtmp@_FillValue,xtmp)
      delete([/msk/])
      var0 = xtmp(:,{latS:latN},{lonW:lonE})
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@long_name = "Net surface fluxes"
    else if(vars.eq."QnTur_SRF") then
      xtmp = f2->LHFLX(ind0,:,:)
      xtmp = -xtmp -f2->SHFLX(ind0,:,:)
      var0 = xtmp(:,{latS:latN},{lonW:lonE})
      var0@long_name = "Total surface turbulent fluxes (positive down)"
    else if (vars.eq."QnTot_SRF") then
      xtmp = f1->FSNS(indy,:,:)
      xtmp = xtmp - f1->FLNS(indy,:,:) - f2->SHFLX(ind0,:,:) - f2->LHFLX(ind0,:,:)
      xtmp@_FillValue = -9999.
      msk  = f2->SHFLX(ind0,:,:)
      xtmp = where (ismissing(msk),xtmp@_FillValue,xtmp)
      delete([/msk/])
      var0 = xtmp(:,{latS:latN},{lonW:lonE})
      var0       = var0*facmod
      var0@units = varunt
      var0@long_name = "Net surface total fluxes (positive down)"
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
    else if (vars.eq."QnRad_SRF") then
      xtmp = f1->FSNS
      xtmp = xtmp - f1->FLNS
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "Total surface radiative fluxes (positive down)"
    else if (vars.eq."RESTOA") then
      xtmp = f1->FSNTOA
      xtmp = f1->FSNTOA - f1->FLUT
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."FSNS") then
      xtmp = f1->FSNS
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."FSNSC") then
      xtmp = f1->FSNSC
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."FLNS") then
      xtmp = f1->FLNS
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."FLNSC") then
      xtmp = f1->FLNSC
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."FLDS") then
      xtmp = f1->FLDS
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."FLDSC") then
      xtmp = f1->FLDSC
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."CLDTOT") then 
      xtmp = f1->CLDTOT
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."LHFLX") then
      xtmp = f2->LHFLX
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
    else if (vars.eq."SHFLX") then
      xtmp = f2->SHFLX
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
    else if (vars.eq."TS") then
      xtmp = f2->TS
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
      var0 = var0 + 273.15
    else if (vars.eq."TREFHT") then
      xtmp = f2->TREFHT
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
      var0 = var0 + 273.15
    else if (vars.eq."QREFHT") then
      xtmp = f2->QREFHT
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
    else if (vars.eq."S10") then
      xtmp = f2->S10
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
    else if (vars.eq."EVAP") then
      xtmp = f2->EVAPOR
      xtmp = xtmp *100.0/365.0 ; to mm/day
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
    else if (vars.eq."OLR") then
      xtmp = f1->FLUT
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
    else if (vars.eq."FNET") then
      xtmp = f1->FSNTOA
      xtmp = xtmp - f1->FLNTOA
      var0 = xtmp(indy,{latS:latN},{lonW:lonE})
      var0@long_name = "TOA net radiative fluxes (positive down)"
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
    end if 
    end if 

    if(isvar("var0")) then 

      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      delete(var0&time)
      var0&time  = obstime
      delete([/xtmp/])

     ;printVarSummary(var0)
     ;printMinMax(var0, True)

      setfileoption("nc", "Format",  "NetCDF4")
      enstr     = "en"+sprinti("%02d",ie)
      out_file  = out_dir+out_name(k)+"/"+out_name(k)+"."+enstr+"."+vars+"."+ystr+"-"+yend+".nc"
      system("rm " + out_file)
      fout = addfile(out_file,"cw")
      vs1 = vars
      fout->$vs1$  = var0
      delete([/fout,var0/])
    end if 

    delete([/cd_date,year,indy,cd_dat0,yea0,ind0,obstim0,obstime/])

  end do 

 end do 

end do 

end
