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

  out_dir   = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/"
  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/E3SMv2"
  exp_name  = (/"v2.LR.historical"/)
  out_name  = (/"v2.LR.historical"/)
  nexps     = dimsizes(exp_name)

  ystr      = 197901
  yend      = 201412
  time_tag  = "1979-2014"
  grid_tag  = "1x1"

  seasons  = (/"MON"/)
  nseas    = dimsizes(seasons)
  d2r      = get_d2r("float")

 ;define regions for eof analysis
  latS     = -90.  ;negative for southern hemisphere
  latN     =  90.  ;negative for southern hemisphere
  lonW     =  0.0
  lonE     = 360.0

  varList = (/"SF"/)
  untList = (/"kg s~S~-1~N~"/)
  facList = (/1.0/)
  nvars = dimsizes(varList)

  ;;get pressure level;;;;
  fera5 = "/global/cfs/cdirs/e3sm/zhan391/data/ERA5/monthly/ERA5_ens01_monthly_1979-2019_1x1.nc"
  fin   = addfile (fera5,"r")
  plev       = tofloat(fin->lev({50:1000}))
  plev!0     = "lev"
  plev&lev   = plev
  plev@units = "hPa"
  delete([/fera5,fin/])

  do k  = 0,nexps-1,1

   fl1   = systemfunc("ls "+data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"*"+time_tag(k)+".nc")
   nens  = dimsizes(fl1)

   do ie = 0,nens-1,1

    print(fl1(ie))
    f1 = addfile(fl1(ie),"r")

    lat  = f1->lat
    lon  = f1->lon

    time = f1->time
    time = time - 1

    year          = cd_calendar(time, 1) 
    indy          = ind(year.ge.ystr.and.year.le.yend)
    obstime       = time(indy)
    obstime@units = time@units

    lev           = tofloat(plev({50:1000}))
    lev           = lev * 100.0
    lev!0         = "lev"
    lev&lev       = lev
    lev@units     = "Pa"

    umx           = vinth2p(f1->U,f1->hyam,f1->hybm,plev({50:1000}),f1->PS,1,f1->P0/100.0,1,False)
    umi           = umx(indy,{50:1000},{latS:latN},{lonW:lonE})
    vmx           = vinth2p(f1->V,f1->hyam,f1->hybm,plev({50:1000}),f1->PS,1,f1->P0/100.0,1,False)
    vmi           = vmx(indy,{50:1000},{latS:latN},{lonW:lonE})
    psm           = f1->PS(indy,{latS:latN},{lonW:lonE})
    umi&lev       = lev
    vmi&lev       = lev
    umi&lev@units = "Pa"
    vmi&lev@units = "Pa"
    delete([/umx,vmx/])

    if(psm@units.eq."hPa") then
      psm = psm * 100.0
      psm@units = "Pa"
    end if

    smh = zonal_mpsi_Wrap(vmi,vmi&lat,lev,psm)

    do iv = 0,nvars-1,1
      vars   = varList(iv)
      varunt = untList(iv)
      facmod = facList(iv)
      print("working on variable "+ vars)
     
      if(vars.eq."SF") then     
        var0 = smh
      end if 

      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      delete(var0&time)
      var0&time  = obstime
 
      setfileoption("nc", "Format",  "NetCDF4")
      enstr     = "en"+sprinti("%02d",ie)
      DIR = out_dir+"/" + out_name
      system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
      out_file  = DIR+"/"+out_name(k)+"."+enstr+"."+vars+"."+ystr+"-"+yend+".nc"
      system("rm " + out_file)
      fout = addfile(out_file,"cw")
      vs1 = vars
      fout->$vs1$  = var0
      delete([/fout,var0/])
    end do 
  
    delete([/time,lat,lon,year,indy,obstime,lev,umi,vmi,psm,smh/])

  end do 

end do 

end
