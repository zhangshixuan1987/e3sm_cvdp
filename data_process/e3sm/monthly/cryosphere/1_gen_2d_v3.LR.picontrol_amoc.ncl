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

  out_name  = "v2_CRYO1950.SORRM.piControl"
  exp_name  = (/"20221116.CRYO1950.ne30pg2_SOwISC12to60E2r4.N2Dependent.submeso.chrysalis"/)
  nexps     = dimsizes(exp_name)
  data_tag1 = (/"651-700"/)
  data_tag2 = (/"0500-0700"/)

  time_tag  = (/"060001-070012"/)
  ystr      = (/060001/)
  yend      = (/070012/)

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

  do it = 0, ntags-1,1

   datdir = data_dir+"/"+exp_name(k)+"/mpas_analysis_output/yrs"+data_tag1+ "/timeseries/moc"
   fl1    = datdir+"/" + "mocTimeSeries_"+data_tag2+".nc"
   nens   = dimsizes(fl1)

   do ie = 0,nens-1,1

    f1   = addfile(fl1,"r")

    lat  = f1->lat
    lev  = f1->depth
    time = f1->Time
    time = time - 1

    year          = cd_calendar(time, 1)  
    indy          = ind(year.ge.ystr(it).and.year.le.yend(it))
    obstime       = time(indy)
    obstime@units = time@units

    var0 = tofloat(f1->mocAtlantic(indy,:,:))

    var0!0    = "time"
    var0!1    = "lev"
    var0!2    = "lat"
    var0&time = obstime 
    var0&lat  = lat
    var0&lev  = lev 

    var0@_FillValue = -9999.
    var0       = var0 * varfac
    var0@units = varunt
    var0@notes = "1 Sv = 1.e6 m3/s"
    delete(var0&time)
    var0&time  = obstime
    var0@long_name = "Atlantic Meridional Overturning Circulation (AMOC)"
 
    setfileoption("nc", "Format",  "NetCDF4")
    enstr = "en"+sprinti("%02d",ie)
    DIR   = out_dir+"/" + out_name(k)
    system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
    out_file  = DIR+"/"+out_name(k)+"."+enstr+"."+varnam+"."+time_tag(it)+".nc"
    system("rm " + out_file)
    fout      = addfile(out_file,"cw")
    vs1       = varnam
    fout->$vs1$  = var0
    delete([/fout,var0/])
  
    delete([/time,lat,year,indy,obstime,lev/])

  end do 

end do 
end do 

end
