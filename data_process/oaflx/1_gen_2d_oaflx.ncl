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
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"

begin

  flmsk     = "/global/cfs/cdirs/e3sm/zhan391/local_diag/fig_data/lnd_msk/landmsk.nc"
  out_dir   = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/"
  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/Observation"
  exp_name  = (/"OAFlux"/)
  nexps     = dimsizes(exp_name)
  time_tag  = "1958-2018"
  grid_tag  = "1x1"

  ystr      = 195801
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

   fl1   = systemfunc("ls "+data_dir+"/OAFlux/OAFlux*1958-2018"+"_"+grid_tag+".nc")
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

    cd_date       = calendar_decode2(f1->time,-1) ;cd_calendar(f1->time, -1)
    year          = tointeger(cd_date(:))
    indy          = ind(year.ge.ystr.and.year.le.yend)
    obstime       = f1->time(indy)
    obstime@units = f1->time@units

    cd_dat0       = cd_calendar(f1->time, 1)
    yea0          = tointeger(cd_dat0(:))
    ind0          = ind(yea0.ge.ystr.and.yea0.le.yend)
    obstim0       = f1->time(ind0)
    obstim0@units = f1->time@units

    if(vars.eq."QnTur_SRF") then
      xtmp = f1->LHFLX
      xtmp = -f1->LHFLX-f1->SHFLX
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
      var0@long_name = "Total surface turbulent fluxes (positive down)"
    else if(vars.eq."EVAP") then
      xtmp = f1->EVAPOR
      xtmp = xtmp *100.0/365.0 ; to mm/day
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
    else 
      xtmp = f1->$vars$
      var0 = xtmp(ind0,{latS:latN},{lonW:lonE})
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
      out_file  = out_dir+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+ystr+"-"+yend+".nc"
      system("rm " + out_file)
      fout = addfile(out_file,"cw")
      fout->$vars$  = var0
      delete([/fout,var0/])
    end if 

    delete([/cd_date,year,indy,cd_dat0,yea0,ind0,obstim0,obstime/])

  end do 

 end do 

end do 

end
