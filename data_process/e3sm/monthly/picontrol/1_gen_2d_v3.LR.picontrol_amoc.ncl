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
  data_dir  = "/lcrc/group/e3sm/ac.golaz/E3SMv3_dev"
  exp_name  = (/"20230224.v3atm_v21.piControl.chrysalis"/)
  out_name  = (/"v3.LR.piControl"/)
  nexps     = dimsizes(exp_name)

  data_tag1 = (/"0001-0300"/)
  data_tag2 = (/"0201-0300"/)

  time_tag  = (/"000101-020012"/)
  ystr      = (/000101/)
  yend      = (/020012/)

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

   datdir = data_dir+"/"+exp_name(k)+"/post/analysis/mpas_analysis"
  ;fl1    = "ts_"+data_tag1(it)+"_climo_"+data_tag2(it)+"/timeseries/moc/mocTimeSeries_"+data_tag1(it)+".nc"
  ;nens   = dimsizes(fl1)

   nens  = 1
   nyr   = yend/100 - ystr/100  +1 
   fl1   = new(nyr,string)
   do iy = 0,nyr-1
     dtag = sprinti("%04d",iy+ystr/100) + "-" + sprinti("%04d",iy+ystr/100) 
     fl1(iy) = datdir+"/" + "ts_"+data_tag1(it)+"_climo_"+data_tag2(it)+"/timeseries/moc/mocTimeSeries_"+dtag+".nc"
   end do 

   do ie = 0,nens-1,1

    f1   = addfiles(fl1,"r")
    lat  = f1[0]->lat
    lev  = f1[0]->depth
    time = f1[:]->Time

    yymm = yyyymm_time(ystr/100,yend/100,"integer")
    year = yymm/100
    month= yymm - (yymm/100)*100
    day  = month 
    day  = 15
    hh   = month 
    mn   = month
    sc   = month 
    hh   = 0 
    mn   = 0
    sc   = 0

    time_unt = "months since " + ystr+"-01-01  00:00:0.0" 
    obstime  = cd_inv_calendar(year,month,day,hh,mn,sc,time_unt, 0)
    delete([/yymm,year,month,day,hh,mn,sc,hh,mn,sc/])

    var0 = tofloat(f1[:]->mocAtlantic(:,:,:))
    var0!0 = "time"
    var0!1 = "lev"
    var0!2 = "lat"
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
  
    delete([/time,lat,obstime,lev/])

  end do 

end do 
end do 

end
