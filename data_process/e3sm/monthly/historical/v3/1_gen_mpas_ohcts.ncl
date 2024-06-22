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

  run_dir   = "/lcrc/group/e3sm2/ac.wlin/E3SMv3/"
  out_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  data_dir  = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  tfreq     = "5yr"
  ensnum    = (/"en00","en01","en02"/)
  exptag    = (/"0051","0101","0151"/)
  exp_name  = (/"v3.LR.historical_"/) + exptag
  out_name  = (/"v3.LR.historical"/)
  nexps     = dimsizes(exp_name)

  ystr      = (/185001/)
  yend      = (/201412/)
  time_tag  = (/sprinti("%06d",ystr)+"-"+sprinti("%06d",yend)/)
  ntags     = dimsizes(time_tag)
  grid_tag  = "1x1"

  data_tag1 = (/"1850-2014"/)
  data_tag2 = (/"1985-2014"/)

 ;define regions for eof analysis
  latS     = -90.  ;negative for southern hemisphere
  latN     =  90.  ;negative for southern hemisphere
  lonW     =  0.0
  lonE     = 360.0

  varList = (/"OHC_ts"/)
  untList = (/"J"/)
  facList = (/1/)
  nvars   = dimsizes(varList)

  do k  = 0,nexps-1,1

   fdir = systemfunc("ls -d " + run_dir + exp_name(k))

   if(.not.ismissing(fdir)) then 
 
    do it = 0, ntags-1,1

      data_dir = fdir + "/post/ocn/glb/ts/monthly/"+tfreq
      ys1      = toint(str_get_cols(sprinti("%06d",ystr),0,3))
      ye1      = toint(str_get_cols(sprinti("%06d",yend),0,3))
      if(tfreq.eq."5yr") then
        nyint    = (ye1-ys1)/5  +1
      else
        nyint    = (ye1-ys1)/10 +1
      end if
      fl1 = new(nyint,string)
      do ff  = 0,nyint-1,1
        if(tfreq.eq."5yr") then
          if ((ys1+(ff+1)*5-1).gt.ye1) then
            yy1    = (ys1 + ff*5)*100+1
            yy2    = ye1*100+12
          else
            yy1    = (ys1 + ff*5)*100+1
            yy2    = (ys1 + (ff+1)*5-1)*100+12
          end if
        else
          if ((ys1+(ff+1)*10-1).gt.ye1) then
            yy1    = (ys1 + ff*10)*100+1
            yy2    = ye1*100+12
          else
            yy1    = (ys1 + ff*10)*100+1
            yy2    = (ys1 + (ff+1)*10-1)*100+12
          end if
        end if
        ttmp   = (/sprinti("%06d",yy1)+"-"+sprinti("%06d",yy2)/)
        fl1(ff)= data_dir+"/" +"mpaso.glb."+ttmp+".nc"
      end do
     ;print("working on file: " + fl1)
      f1       = addfiles(fl1,"r")
      time     = f1[:]->time
      mdate    = cd_calendar(time,-1)
      indy     = ind(mdate.ge.ystr.and.mdate.le.yend)
      obstime  = time(indy)
      obstime@units = time@units
     ;print(cd_calendar(obstime,-1))
      do iv = 0,nvars-1,1
        vout = varList(iv)
        vfac = facList(iv)
        vunt = untList(iv)
        if(vout.eq."OHC_ts") then 
          vin1 = "ohc"
          vin2 = "volume"
        end if 
        var1 = tofloat(f1[:]->$vin1$(indy))
        var2 = tofloat(f1[:]->$vin2$(indy))
        var1!0    = "time"
        var1&time = obstime 
        var2!0    = "time"
        var2&time = obstime

        setfileoption("nc", "Format",  "NetCDF4")
        enstr = ensnum(k) 
        DIR   = out_dir+"/" + out_name
        system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
        out_file = DIR+"/"+out_name+"."+enstr+"."+vout+"."+time_tag(it)+".nc"
        print("output file: " + out_file)
        system("rm " + out_file)
        fout = addfile(out_file,"cw")
        fout->$vout$ = var1
        fout->volume = var2
        delete([/fout,var1,var2/])
      end do 
      delete([/yy1,yy2,ttmp,time,f1,fl1/])
      delete([/mdate,indy,obstime/])
   end do 
 end if 
end do 

end
