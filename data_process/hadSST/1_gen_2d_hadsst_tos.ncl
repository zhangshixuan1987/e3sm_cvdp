  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  load "./function.ncl"

; Purpose: A tempolate to make a eof plot for AAO patterns 
;          Data is vertically interpolated to pressure levels
;          1st panel: EOFs for the first three modes
;          2nd panel: time series plot
; Author : Shixuan Zhang
; Date   : Dec 06, 2020

begin

  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data"
  outdir    = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
  comdir    = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/data_process/cmip6_mme/share_file"

  expname   = (/"HadSST"/)
  nexps     = dimsizes(expname)
  tobs_tag  = "1870-2020"

  yyyy      = 1870
  ystr      = 187001
  yend      = 201912
  crange    = ystr+"-"+yend
  grid_tag  = "1x1"

  vars      = "sst"
  varo      = "TS"
  vfac      = 1.0
  vunt      = "~S~o~N~C"

 ;declear the data to be used;;;;;

  do k  = 0,nexps-1,1

   fls  = systemfunc("ls "+data_dir+"/"+expname(k)+"/HadISST_sst.nc")
   nens = dimsizes(fls)
  ;print(fls)

   ike = 0 
   do ie = 0,nens-1,1

    f       = addfile(fls(ie),"r")
    year     = cd_calendar(f->time, 1) 
    indy     = ind(year.ge.ystr.and.year.le.yend)
    obstime  = f->time(indy)
   ;print(cd_calendar(obstime,1))

    var = f->$vars$(indy,:,:)
    printVarSummary(var)
    var@_FillValue = -9999.

    var       = var*vfac
    var       = var + 273.15 
    var@units = "K"
    var       = where(var.le.100.0,var@_FillValue,var)
    printMinMax(var,False)

    ttmp       = ispan(0,dimsizes(obstime)-1,1)
    ttmp@units = "months since "+yyyy+"-01-01 00:00:00"
    var&time  = ttmp

   ;printVarSummary(var)
   ;printMinMax(var, True)
    delete([/ttmp,year,indy/])

    ;;regrid the data to target grid
    dstFileName  = comdir + "/sample_out_grid.nc"
    srcFileName  = fls(0)
    keystring    = "hadsst"
    InterpMethod = "bilinear" ;"conserve"

    vout = regrid_to_reference_grid(var,keystring, expname,InterpMethod,srcFileName,dstFileName)

    vout = where(vout.le.100.0,vout@_FillValue,vout)
    printMinMax(vout,False)

    if(.not.all(ismissing(vout))) then
      odir = outdir + "/" + expname
      system("if ! test -d " + odir +" ; then mkdir -p " + odir + " ; fi")
      enstr     = "en"+sprinti("%02d",ike)
      out_file  = odir+"/"+expname+"."+enstr+"."+varo+"."+crange+".nc"
      setfileoption("nc", "Format",  "NetCDF4")
      system("rm " + out_file)
      fout = addfile(out_file,"cw")
      vonm = varo
      fout->$vonm$  = vout
      delete([/enstr,vonm,fout/])
      ike = ike + 1
     end if

  end do ; end exps

 end do 

end
