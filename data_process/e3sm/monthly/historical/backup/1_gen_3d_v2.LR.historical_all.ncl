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
  nexps     = dimsizes(exp_name)
  ystr      = 197901
  yend      = 201412
  time_tag  = "1979-2014"
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

  ;;get pressure level;;;;
  fera5 = "/global/cfs/cdirs/e3sm/zhan391/data/ERA5/monthly/ERA5_ens01_monthly_1979-2019_1x1.nc"
  fin   = addfile (fera5,"r")
  plev  = fin->lev
  delete([/fera5,fin/])

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

    if(vars.eq."Z3") then
      xtmp = vinth2p(f1->Z3,f1->hyam,f1->hybm,plev,f1->PS,1,f1->P0/100.0,1,False)
      var0 = clmMonTLLL(xtmp(indy,:,{latS:latN},{lonW:lonE})) 
    else if (vars.eq."T") then
      xtmp = vinth2p(f1->T,f1->hyam,f1->hybm,plev,f1->PS,1,f1->P0/100.0,1,False)
      var0 = clmMonTLLL(xtmp(indy,:,{latS:latN},{lonW:lonE}))
    else if (vars.eq."U") then
      xtmp = vinth2p(f1->U,f1->hyam,f1->hybm,plev,f1->PS,1,f1->P0/100.0,1,False)
      var0 = clmMonTLLL(xtmp(indy,:,{latS:latN},{lonW:lonE}))
    else if (vars.eq."Q") then
      xtmp = vinth2p(f1->Q,f1->hyam,f1->hybm,plev,f1->PS,1,f1->P0/100.0,1,False)
      var0 = clmMonTLLL(xtmp(indy,:,{latS:latN},{lonW:lonE}))
    else if (vars.eq."V") then
      xtmp = vinth2p(f1->V,f1->hyam,f1->hybm,plev,f1->PS,1,f1->P0/100.0,1,False)
      var0 = clmMonTLLL(xtmp(indy,:,{latS:latN},{lonW:lonE}))
    else
      print("variables does not exist ")
      exit 
    end if
    end if 
    end if 
    end if 
    end if 

    var0@_FillValue = -9999.
    var0            = var0*facmod
    var0@units      = varunt
    delete([/time,year,indy,xtmp/])

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
