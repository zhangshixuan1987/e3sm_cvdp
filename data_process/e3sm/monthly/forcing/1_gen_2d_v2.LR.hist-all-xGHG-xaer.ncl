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

  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/E3SMv2"
  exp_name  = (/"v2.LR.hist-all-xGHG-xaer"/)
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

  varList   = (/"PSL",       "PRECT",  "TS","TREFHT" /)
  facList   = (/  1.0,        8.64e7,   1.0,     1.0 /)
  untList   = (/ "Pa", "mm day~S~-1",   "K",     "K" /)
  nvars     = dimsizes(varList)

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
    if(vars.eq."PRECT") then
      xtmp        = f1->PRECC
      xtmp        = xtmp + f1->PRECL
    else
      xtmp          = f1->$vars$
    end if
    var0          = xtmp(:,{latS:latN},{lonW:lonE})
    var0@_FillValue = -9999.
    var0       = var0*facmod
    var0@units = varunt
    delete(var0&time)
    var0&time  = obstime
    delete([/time,year,indy,xtmp/])

    printVarSummary(var0)
    printMinMax(var0, True)

    setfileoption("nc", "Format",  "NetCDF4")
    enstr     = "en"+sprinti("%02d",ie)
    out_file  = exp_name(k)+"."+enstr+"."+vars+"."+ystr+"-"+yend+".nc"
    system("rm " + out_file)
    fout = addfile(out_file,"cw")
    vs1 = vars
    fout->$vs1$  = var0
    delete([/fout,var0/])

  end do 

 end do 

end do 

end
