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

  run_dir   = "/lcrc/group/e3sm/ac.forsyth2/E3SMv2/"
  out_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  data_dir  = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  ensnum    = (/"en00"/)
  exp_name  = (/"v2.LR.piControl"/)
  out_name  = (/"v2.LR.piControl"/)
  nexps     = dimsizes(exp_name)
  ystr      = 1
  yend      = 350
  time_tag  = (/sprinti("%04d01",ystr)+"-"+sprinti("%04d12",yend)/)
  ntags     = dimsizes(time_tag)
  grid_tag  = "1x1"

 ;define regions for eof analysis
  latS     = -90.  ;negative for southern hemisphere
  latN     =  90.  ;negative for southern hemisphere
  lonW     =  0.0
  lonE     = 360.0

  varList = (/"AMOC"/)
  untList = (/"Sv"/)
  facList = (/1/)
  nvars = dimsizes(varList)

  varnam = varList(0)
  varunt = untList(0)
  varfac = facList(0)

  do k  = 0,nexps-1,1

    fref = out_dir + "/v2_1.LR.piControl/v2_1.LR.piControl.en00.AMOC.000101-050012.nc"
    fr   = addfile(fref,"r")
    levr = fr->lev
    latr = fr->lat 

    fils = systemfunc("ls -1 " + data_dir +"/"+exp_name(k)+"/SE_MOC/*MOC*.nc")
    print(fils)
    f1    = addfiles(fils,"r")

    lat   = f1[0]->binBoundaryMocStreamfunction * get_r2d(1.0) 
    var   = f1[:]->timeMonthly_avg_mocStreamvalLatAndDepthRegion  ;timeMonthly_avg_mocStreamvalLatAndDepth 
    mstr  = chartostring(f1[:]->xtime_startMonthly)
    mend  = chartostring(f1[:]->xtime_endMonthly)
   ;mcon  = f1[:]->timeMonthly_counter
   ;print(mstr + " " + mend + " " + mcon)

    year  = toint(str_get_cols(mstr,0,3))
    month = toint(str_get_cols(mstr,5,6))
    ys1   = toint(str_get_cols(tostring(ystr),0,3))
    ye1   = toint(str_get_cols(tostring(yend),0,3))
    indy  = ind(year.ge.ys1.and.year.le.ye1)
    yy1   = year(indy)
    mm1   = month(indy)
    dd1   = yy1
    dd1   = 1 
    hh1   = yy1 
    hh1   = 0 
    mn1   = yy1
    mn1   = 0 
    sc1   = yy1
    sc1   = 0
    tunit   = "months since "+ sprinti("%04d",ys1) +"-01-15 00:00:00"
    obstime = cd_inv_calendar(yy1,mm1,dd1,hh1,mn1,sc1,tunit,0)
    obstime@units = tunit
    ;print(cd_calendar(obstime,-1))
    delete([/yy1,mm1,dd1,hh1,mn1,sc1,tunit,mstr,mend,year,month/])

    var0 = tofloat(var(indy,0,:,:))
    printVarSummary(var0)

    var0!0 = "time"
    var0!1 = "lev"
    var0!2 = "lat"
    var0&time = obstime 
    var0&lat  = latr
    var0&lev  = levr
 
    var0@_FillValue = -9999.
    var0       = var0 * varfac
    var0@units = varunt
    var0@notes = "1 Sv = 1.e6 m3/s"
    delete(var0&time)
    var0&time  = obstime
    var0@long_name = "Atlantic Meridional Overturning Circulation (AMOC)"
 
    setfileoption("nc", "Format",  "NetCDF4")
    enstr = ensnum(k) 
    DIR   = out_dir+"/" + out_name
    system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
    out_file = DIR+"/"+out_name+"."+enstr+"."+varnam+"."+time_tag(it)+".nc"
    system("rm " + out_file)
    fout        = addfile(out_file,"cw")
    vs1         = varnam
    fout->$vs1$ = var0
    delete([/fout,var0,var/])
    delete([/time,lat,year,indy,obstime,lev/])
end do 

end
