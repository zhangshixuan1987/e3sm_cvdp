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

  run_dir   = "/lcrc/group/e3sm2/ac.xzheng/E3SMv3_dev/"
  out_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  data_dir  = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  ensnum    = (/"en00"/)
  exp_name  = (/"20231105.v3b01.piControl.chrysalis"/)
  out_name  = (/"v3b02-ECE3r2.piControl"/)
  nexps     = dimsizes(exp_name)

  data_tag1 = (/"0001-0300"/)
  data_tag2 = (/"0251-0300"/)

  ystr      = (/000101/)
  yend      = (/030012/)
  time_tag  = (/sprinti("%06d",ystr)+"-"+sprinti("%06d",yend)/)
  ntags     = dimsizes(time_tag)
  grid_tag  = "1x1"

 ;define regions for eof analysis
  latS     = -90.  ;negative for southern hemisphere
  latN     =  90.  ;negative for southern hemisphere
  lonW     =  0.0
  lonE     = 360.0

  varList = (/"AMOC","AMOC26"/)
  untList = (/"Sv","Sv"/)
  facList = (/1,1/)
  nvars   = dimsizes(varList)

  do k  = 0,nexps-1,1

   fdir = systemfunc("ls -d " + run_dir + exp_name(k))
   if(.not.ismissing(fdir)) then 
 
    do it = 0, ntags-1,1

      data_dir = fdir + "/post/analysis/mpas_analysis"
      fl1      = "ts_"+data_tag1(it)+"_climo_"+data_tag2(it)+"/timeseries/moc/mocTimeSeries_"+data_tag1(it)+".nc"
      fl1      = data_dir+"/" + fl1
      f1       = addfile(fl1,"r")

      print("working on file: " + fl1)

      year     = f1->year
      month    = f1->month
      time     = f1->Time

      ys1   = toint(str_get_cols(sprinti("%06d",ystr),0,3))
      ye1   = toint(str_get_cols(sprinti("%06d",yend),0,3))
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

      obstime = cd_inv_calendar(yy1,mm1,dd1,hh1,mn1,sc1,f1->Time@units,0)
      obstime@units = time@units
     ;print(cd_calendar(obstime,-1))
      delete([/yy1,mm1,dd1,hh1,mn1,sc1/])
   
      do iv = 0,nvars-1,1
        vout = varList(iv)
        vfac = facList(iv)
        vunt = untList(iv)
        if (vout.eq."AMOC") then 
          vin = "mocAtlantic" 
          if(isfilevar(f1,vin)) then 
            lat   = f1->lat
            lev   = f1->depth
            var0  = tofloat(f1->$vin$(indy,:,:))
          else 
            lat   = fspan(-90,90,181)
            lev   = fspan(0,5500,61)
            lat@units = "degree north"
            lev@units = "meters"
            lat!0 = "lat"
            lev!0 = "depth"
            lat&lat   = lat 
            lev&depth = lev
            var0   = new((/dimsizes(obstime),dimsizes(lev),dimsizes(lat)/),float)
            var0   = -9999.
          end if 
          var0!0   = "time"
          var0!1   = "lev"
          var0!2   = "lat"
          var0&lat = lat
          var0&lev = lev
          var0@_FillValue = -9999.
          var0       = var0 * vfac
          var0@units = vunt
          var0@notes = "1 Sv = 1.e6 m3/s"
          var0&time  = obstime
          var0@long_name = "Atlantic Meridional Overturning Circulation (AMOC)"
          delete([/lat,lev/])
        else if(vout.eq."AMOC26") then 
          vin = "mocAtlantic26"
          if(isfilevar(f1,vin)) then
            var0   = tofloat(f1->$vin$(indy))
          else 
            var0   = new((/dimsizes(obstime)/),float)
            var0   = -9999.
          end if 
          var0!0 = "time"
          var0@_FillValue = -9999.
          var0       = var0 * vfac
          var0@units = vunt
          var0@notes = "1 Sv = 1.e6 m3/s"
          var0&time  = obstime
          var0@long_name = "Atlantic Meridional Overturning Circulation (AMOC) at 26.5N"
        else
          print("diagnostics do not exsit ...")
          exit
        end if
        end if 
      
        setfileoption("nc", "Format",  "NetCDF4")
        enstr = ensnum(k) 
        DIR   = out_dir+"/" + out_name
        system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
        out_file = DIR+"/"+out_name+"."+enstr+"."+vout+"."+time_tag(it)+".nc"
        print("output file: " + out_file)
        system("rm " + out_file)
        fout = addfile(out_file,"cw")
        fout->$vout$ = var0
        delete([/fout,var0/])
     end do 
     delete([/time,year,indy,obstime/])
   end do 
 end if 
end do 

end
