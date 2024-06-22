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
  data_dir  = "/lcrc/group/e3sm/ac.xzheng/E3SMv3_dev"
  exp_name  = (/"20230622.v3alpha02.piControl.chrysalis"/)
  out_name  = (/"v3alpha2.LR.piControl"/)
  nexps     = dimsizes(exp_name)

  data_tag1 = (/"0001-0350"/)
  data_tag2 = (/"0301-0350"/)

  time_tag  = (/"000101-035012"/)
  ystr      = (/000101/)
  yend      = (/035012/)

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

    nens   = 1
    nyr    = toint(yend)/100 - toint(ystr)/100  +1 
    fl1    = new(nyr,string)
    datdir = data_dir+"/"+exp_name(k)+"/post/analysis/mpas_analysis"
    do iy = 0,nyr-1
      dtag = sprinti("%04d",iy+toint(ystr)/100) + "-" + sprinti("%04d",iy+toint(ystr)/100) 
      fl1(iy) = datdir+"/" + "ts_"+data_tag1(it)+"_climo_"+data_tag2(it)+"/timeseries/moc/mocTimeSeries_"+dtag+".nc"
    end do 

   do ie = 0,nens-1,1

    f1    = addfiles(fl1,"r")
    ListSetType(f1, "join")       ; join

    lat   = f1[0]->lat
    lev   = f1[0]->depth
    time  = reshape(f1[:]->Time,(/nyr*12/))
    time@units = f1[0]->Time@units

    yy1   = reshape(f1[:]->year,(/nyr*12/))
    mm1   = reshape(f1[:]->month,(/nyr*12/))
    dd1   = yy1
    dd1   = 1
    hh1   = yy1
    hh1   = 0
    mn1   = yy1
    mn1   = 0
    sc1   = yy1
    sc1   = 0 

    obstime = cd_inv_calendar(yy1,mm1,dd1,hh1,mn1,sc1,time@units,0)
   ;print(cd_calendar(obstime,-1))
    delete([/yy1,mm1,dd1,hh1,mn1,sc1/]) 

    vtmp      = f1[:]->mocAtlantic
    var0      = reshape(vtmp,(/nyr*12,dimsizes(lev),dimsizes(lat)/))
    var0!0    = "time"
    var0!1    = "lev"
    var0!2    = "lat"
    var0&time = obstime 
    var0&lat  = lat
    var0&lev  = lev 
    var0@units= vtmp@units

    var0@_FillValue = -9999.
    var0       = var0 * varfac
    var0@units = varunt
    var0@notes = "1 Sv = 1.e6 m3/s"
    var0&time  = obstime
    var0@long_name = "Atlantic Meridional Overturning Circulation (AMOC)"
 
    setfileoption("nc", "Format",  "NetCDF4")
    enstr = "en"+sprinti("%02d",ie)
    DIR   = out_dir+"/" + out_name(k)
    system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
    out_file  = DIR+"/"+out_name(k)+"."+enstr+"."+varnam+"."+time_tag(it)+".nc"
    system("rm -rvf " + out_file)
    fout      = addfile(out_file,"cw")
    vs1       = varnam
    fout->$vs1$  = var0
    delete([/fout,var0/])
  
    delete([/time,lat,obstime,lev/])

  end do 

end do 
end do 

end
