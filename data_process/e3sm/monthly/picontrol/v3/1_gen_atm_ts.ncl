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

  run_dir   = "/lcrc/group/e3sm2/ac.golaz/E3SMv3/"
  out_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  data_dir  = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  tfreq     = "10yr"

  ensnum    = (/"en00"/)
  exp_name  = (/"v3.LR.piControl"/)
  out_name  = (/"v3.LR.piControl"/)
  nexps     = dimsizes(exp_name)

  ystr      = (/000101/)
  yend      = (/050012/)
  time_tag  = (/sprinti("%06d",ystr)+"-"+sprinti("%06d",yend)/)
  ntags     = dimsizes(time_tag)
  grid_tag  = "1x1"

  data_tag1 = (/"0001-0500"/)
  data_tag2 = (/"0451-0500"/)

 ;define regions for eof analysis
  latS     = -90.  ;negative for southern hemisphere
  latN     =  90.  ;negative for southern hemisphere
  lonW     =  0.0
  lonE     = 360.0

  varList = (/"FSNTOA","FLUT","FSNT","FLNT","FSNS","FLNS","SHFLX","QFLX","TAUX","TAUY",\
              "PRECC","PRECL","PRECSC","PRECSL","TS","TREFHT","CLDTOT","CLDHGH","CLDMED",\
              "CLDLOW"/)
  nvars   = dimsizes(varList)

  do k  = 0,nexps-1,1

   fdir = systemfunc("ls -d " + run_dir + exp_name(k))

   if(.not.ismissing(fdir)) then 
 
   do iv = 0,nvars-1,1
     vout = varList(iv) +"_ts"
     vin1 = varList(iv)
     do it = 0, ntags-1,1
      data_dir = fdir + "/post/atm/glb/ts/monthly/"+tfreq
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
        ttmp   = (/sprinti("%06d",yy1)+"_"+sprinti("%06d",yy2)/) 
        fl1(ff)= data_dir+"/" +vin1+"_"+ttmp+".nc"
      end do
     ;print("working on file: " + fl1)
      f1       = addfiles(fl1,"r")
      time     = f1[:]->time
      mdate    = cd_calendar(time,-1)
      indy     = ind(mdate.ge.ystr.and.mdate.le.yend)
      obstime  = time(indy)
      obstime@units = time@units
      var1      = tofloat(f1[:]->$vin1$(indy,0))
      var1!0    = "time"
      var1&time = obstime 

      setfileoption("nc", "Format",  "NetCDF4")
      enstr = ensnum(k) 
      DIR   = out_dir+"/" + out_name
      system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
      out_file = DIR+"/"+out_name+"."+enstr+"."+vout+"."+time_tag(it)+".nc"
      print("output file: " + out_file)
      system("rm " + out_file)
      fout = addfile(out_file,"cw")
      fout->$vout$ = var1
      delete([/fout,var1/])
      delete([/yy1,yy2,ttmp,time,f1,fl1/])
      delete([/mdate,indy,obstime/])
     end do 
    end do
 end if 
end do 

end
