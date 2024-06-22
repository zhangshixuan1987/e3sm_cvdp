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

  out_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  data_dir  = "/lcrc/group/acme/ac.dcomeau/scratch/chrys"
  data_dir  = "/lcrc/group/e3sm/ac.xylar/analysis/"
  data_dir  = "/lcrc/group/e3sm/ac.golaz/E3SMv3_dev"
  exp_name  = (/"20230224.v3atm_v21.piControl.chrysalis"/)
  out_name  = (/"v3.LR.piControl"/)
  nexps     = dimsizes(exp_name)

  data_tag = (/"0001-0300"/)
  data_tim = (/"0201-0300"/)

  time_tag  = (/"000101-030012"/)
  ystr      = (/000101/)
  yend      = (/030012/)

  ntags     = dimsizes(time_tag)
  grid_tag  = "1x1"

 ;define regions for eof analysis
  latS     = -90.  ;negative for southern hemisphere
  latN     =  90.  ;negative for southern hemisphere
  lonW     =  0.0
  lonE     = 360.0

 ;varList = (/"temperature","thermalForcing","mixedLayerDepth","totalVol","potentialDensity"/)
 ;varName = (/"TPOT","TFORCE","MLDEPTH","TVOL","RHOPOT"/)
 ;untList = (/"degC","degC","m","m3","kg/m3","m2"/)
  varList = (/"thermalForcing"/)
  varName = (/"TFORCE"/)
  untList = (/"degC"/)

  facList = (/1/)
  nvars = dimsizes(varList)

  varnam = varList(0)
  varunt = untList(0)
  varfac = facList(0)

  do k  = 0,nexps-1,1

   do it = 0, ntags-1,1

   run_dir  = data_dir+"/"+exp_name(k)+"/post/analysis/mpas_analysis/ts_0001-0300_climo_0201-0300/AntarcticRegions"
  ;run_dir  = data_dir+"/"+exp_name(k)+"/"+data_tag+ "/timeseries/AntarcticRegions"

   fl1      = run_dir+"/" + "AntarcticRegions_"+data_tim+".nc"

   nens = dimsizes(fl1)
   do ie = 0,nens-1,1

    f1     = addfiles(fl1,"r")
   
    regnam        = f1[0]->regionNames
    regnam!0      = "region"
    regnam&region = ispan(1,dimsizes(regnam),1)
    tarea         = f1[0]->totalArea
    tarea!0       = "region"
    tarea&region  = ispan(1,dimsizes(regnam),1)

    time   = f1[:]->Time
    year   = toint(f1[:]->year)
    month  = toint(f1[:]->month)
   ;print(year + " " + month)

    day    = month
    day    = 15
    hh     = month
    mn     = month
    sc     = month
    hh     = 0
    mn     = 0
    sc     = 0

    yyyy   = ystr/100
    time_unt = "months since " + yyyy+"-01-01  00:00:0.0"
    obstime  = cd_inv_calendar(year,month,day,hh,mn,sc,time_unt, 0)
    delete([/year,month,day,hh,mn,sc,hh,mn,sc,time/])

    do iv = 0,nvars-1,1

    var0 = tofloat(f1[:]->$varList(iv)$)

    printVarSummary(var0)
    var0!0      = "region"
    var0!1      = "time"
    var0&time   = obstime 
    var0&region = ispan(1,dimsizes(regnam),1)
    var0@_FillValue = -9999.
    var0            = var0 * varfac
    var0@units      = varunt
    var0@notes      = "1 Sv = 1.e6 m3/s"
    if(isatt(f1[0]->$varList(iv)$,"description")) then 
      var0@long_name  = f1[0]->$varList(iv)$@description
    end if 

    setfileoption("nc", "Format",  "NetCDF4")
    enstr = "en"+sprinti("%02d",ie)
    DIR   = out_dir+"/" + out_name(k)
    system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
    out_file  = DIR+"/"+out_name(k)+"."+enstr+"."+varName(iv)+"."+time_tag(it)+".nc"
    system("rm " + out_file)
    fout = addfile(out_file,"c")
    fout->regionNames    = regnam
    fout->totalArea      = tarea
    fout->$varName(iv)$  = var0
    delete([/fout,var0/])

    end do 
  
  end do 

end do 
end do 

end
