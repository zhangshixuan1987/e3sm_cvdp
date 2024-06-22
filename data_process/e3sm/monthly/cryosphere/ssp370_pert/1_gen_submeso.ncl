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

  run_dir   = "./tforce/" ;"/lcrc/group/acme/ac.dcomeau/scratch/chrys/E3SMv2_1/"
  out_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  exptag    = (/"0701"/)
  ensnum    = (/"en00"/)
  exp_name  = (/"v2_1.SORRM.ssp370_"/) + exptag + "-fismf"
  out_name  = (/"v2_1.SORRM.ssp370.fismf"/)
  nexps     = dimsizes(exp_name)
  data_tag1 = (/"2015-2100"/)
  data_tag2 = (/"2051-2100"/)

  ystr      = (/2015/)
  yend      = (/2100/)
  time_tag  = (/sprinti("%04d01",ystr)+"-"+sprinti("%04d12",yend)/)
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
 ;Southern Ocean
 ;Southern Ocean 60S
 ;Eastern Weddell Sea Shelf
 ;Eastern Weddell Sea Deep
 ;Western Weddell Sea Shelf
 ;Western Weddell Sea Deep
 ;Weddell Sea Shelf
 ;Weddell Sea Deep
 ;Bellingshausen Sea Shelf
 ;Bellingshausen Sea Deep
 ;Amundsen Sea Shelf
 ;Amundsen Sea Deep
 ;Eastern Ross Sea Shelf
 ;Eastern Ross Sea Deep
 ;Western Ross Sea Shelf
 ;Western Ross Sea Deep
 ;East Antarctic Seas Shelf
 ;East Antarctic Seas Deep

  varList = (/"thermalForcing","thermalForcing"/)
  varName = (/"thfamd","thfblg"/)
  varIreg = (/10,8/)
  untList = (/"degC","degC"/)
  facList = (/1,1/)
  nvars   = dimsizes(varList)

  do k  = 0,nexps-1,1

   fdir = systemfunc("ls -d " + run_dir + exp_name(k))
   if(.not.ismissing(fdir)) then 
 
    do it = 0, ntags-1,1

     ;data_dir = fdir + "/mpas_analysis_output/yrs"+data_tag1(it)+"/timeseries/moc/"
     ;fl1      = "mocTimeSeries_"+data_tag1(it)+".nc"
     ;fl1      = data_dir+"/" + fl1
     ;f1       = addfile(fl1,"r")

      nyrs   = yend - ystr +1 
     
      fl1 = new(nyrs,string) 
      do iy  = 0,nyrs-1
        ttag    = sprinti("%04d",iy+ystr )+"-"+sprinti("%04d",iy+ystr )
        fl1(iy) = "./tforce/" + exp_name(k)+"/AntarcticRegions_"+ttag+".nc"
      end do 
      f1       = addfiles(fl1,"r")
      ListSetType (f1, "join")        

      print("working on file: " + fl1)
       
      year  = ndtooned(f1[:]->year)
      month = ndtooned(f1[:]->month)
      time  = ndtooned(f1[:]->Time)
      year@_FillValue  = 32766
      month@_FillValue = 32766
      time@_FillValue  = -9999.0 

      indy  = ind(year.ge.ystr.and.year.le.yend)
      yy1   = tointeger(year(indy))
      mm1   = tointeger(month(indy))
      dd1   = yy1
      dd1   = 1 
      hh1   = yy1 
      hh1   = 0 
      mn1   = yy1
      mn1   = 0 
      sc1   = yy1
      sc1   = 0
      tcunt = "days since " + sprinti("%04d",yy1(0))+ "-" + sprinti("%02d",mm1(0)) + "-" + \
              sprinti("%02d",dd1(0)) + " 00:00:00"
      obstime = cd_inv_calendar(yy1,mm1,dd1,hh1,mn1,sc1,tcunt,0)
      obstime@units = tcunt 
     ;print(cd_calendar(obstime,-1))
      delete([/yy1,mm1,dd1,hh1,mn1,sc1/])

      do iv = 0,nvars-1,1
        vin  = varList(iv)
        vout = varName(iv)
        vfac = facList(iv)
        vunt = untList(iv)
        ireg = varIreg(iv)
        if(isfilevar(f1[0],vin)) then 
          vtmp   = ndtooned(f1[:]->$vin$(:,ireg,:))
          var0   = tofloat(vtmp(indy))
          regnam = f1[0]->regionNames(ireg)
          tarea  = f1[0]->totalArea(ireg)
          delete(vtmp)
        else 
          var0   = new((/dimsizes(obstime)/),float)
          var0   = -9999.
          regnam = ""
          tarea  = -9999.
        end if 

        var0!0     = "time"
        var0       = var0 * vfac
        var0@units = vunt
        var0@notes = "potential temperature minus the potential freezing temperature"
        var0@region= regnam
        var0&time  = obstime
        var0@_FillValue = -9999.
        var0@long_name = "Thermal Forcing Term Over Antarctic"

        print("Thermal forcing at " + regnam)

        setfileoption("nc","Format","NetCDF4Classic")
        enstr = ensnum(k) 
        DIR   = out_dir+"/" + out_name
        system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
        out_file = DIR+"/"+out_name+"."+enstr+"."+vout+"."+time_tag(it)+".nc"
        print("output file: " + out_file)
        system("rm " + out_file)
        fout = addfile(out_file,"c")
        fout->$vout$ = var0
        fout->area   = tarea 
        delete([/fout,var0,tarea,regnam/])
     end do 
     delete([/time,year,indy,obstime/])
   end do 
 end if 
end do 

end
