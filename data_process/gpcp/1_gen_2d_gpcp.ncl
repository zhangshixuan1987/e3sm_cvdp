  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a eof plot for AAO patterns 
;          Data is vertically interpolated to pressure levels
;          1st panel: EOFs for the first three modes
;          2nd panel: time series plot
; Author : Shixuan Zhang
; Date   : Dec 06, 2020

begin

  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/Observation/GPCP/monthly/raw_data/"
  outdir    = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
  out_name  = (/"GPCP"/)
  nexps     = dimsizes(out_name)

  seasons   = (/"MON"/)
  nseas     = dimsizes(seasons)

  latS      = -90.  ;negative for southern hemisphere
  latN      =  90.  ;negative for southern hemisphere
  lonW      =  0.0
  lonE      = 360.0

  ystr      = 197901
  yend      = 201912
  time_tag  = ystr+"-"+yend
  grid_tag  = "1x1"

  vars      = "precip"
  vout      = "PRECT"
  vfac      = 1.0
  vunt      = "mm day~S~-1~N~"

 ;declear the data to be used;;;;;

  do k  = 0,nexps-1,1

   fl1  = systemfunc("ls "+data_dir+"/precip.mon.mean.nc")
   nens = dimsizes(fl1)
  ;print(fl1)

   do ie = 0,nens-1,1

    print(fl1(ie))

    f1        = addfile(fl1(ie),"r")

    year      = cd_calendar(f1->time, 1)
    indy      = ind(year.ge.ystr.and.year.le.yend)
    obstime   = f1->time(indy)
    xtmp      = f1->$vars$(indy,:,:)
    xtmp!0    = "time"
    xtmp!1    = "lat"
    xtmp!2    = "lon"
    xtmp&time = obstime 
   
    ;---Set to True if you want to skip any of these steps
    if (ie.eq.0) then
      SKIP_SRC_SCRIP_GEN = False
      SKIP_DST_SCRIP_GEN = False
      SKIP_WGT_GEN       = False
      INTERP_METHOD      = "bilinear"
      ;---Output (and input) files
      srcGridName        = "src_SCRIP.nc"
      dstGridName        = "dst_SCRIP.nc"
      wgtFileName        = out_name(k)+"_Rect.nc"
    else
      SKIP_SRC_SCRIP_GEN = True
      SKIP_DST_SCRIP_GEN = True
      SKIP_WGT_GEN       = True
    end if

    if(.not.SKIP_SRC_SCRIP_GEN) then
      ;--- Convert to a SCRIP Convention file.
      Opt                = True
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = out_name(k)+" Grid"
      Opt@Mask2D         = where(ismissing(xtmp(0,:,:)),0,1)
      rectilinear_to_SCRIP(srcGridName,xtmp&lat,xtmp&lon,Opt)
      ;---Clean up
      delete(Opt)
    end if

    if(.not.SKIP_DST_SCRIP_GEN) then
      dstFileName        = outdir+"/v2.LR.amip.ndguvt/v2.LR.amip.ndguvt.en00.TS.200801-201712.nc"
      dst_file           = addfile(dstFileName,"r")
      temp               = dst_file->TS(0,:,:)
      Opt                = True
      Opt@GridMask       = where(.not.ismissing(temp),1,0)   ; use Mask2D in NCL V6.2.1 and earlier
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Title          = "EAM 360x180 Grid"
      rectilinear_to_SCRIP(dstGridName,temp&lat,temp&lon,Opt)
      ;---Clean up
      delete([/Opt,dstFileName,dst_file,temp/])
    end if

    if(.not.SKIP_WGT_GEN) then
      Opt                = True
      Opt@WgtFileName    = wgtFileName
      Opt@InterpMethod   = INTERP_METHOD      ; patch takes longer
      Opt@ForceOverwrite = True
      Opt@PrintTimings   = True
      Opt@Debug          = True
      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFileName,Opt)
      ;---Clean up
      delete(Opt)
    end if

    Opt                = True
   ;Opt@Debug          = True
    Opt@PrintTimings   = True
    temp_regrid        = ESMF_regrid_with_weights(xtmp,wgtFileName,Opt)

    var1               = temp_regrid(:,{latS:latN},{lonW:lonE})
    var1@_FillValue = -9999.
    var1               = where(var1.le.0.0,0.0,var1)
    var1               = var1*vfac
    var1!0 = "time"
    var1!1 = "lat"
    var1!2 = "lon"
    var1&time = obstime 
   ;printVarSummary(var1)
   ;printMinMax(var1, True)
    delete([/year,indy,obstime,xtmp,temp_regrid/])

   ;======================================================================
   ;Save the data for post analysis
   ;==================================================================
    setfileoption("nc", "Format",  "NetCDF4")
    enstr     = "en"+sprinti("%02d",ie)
    DIR       = outdir+"/" + out_name(k)
    system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
    out_file  = DIR+"/"+out_name(k)+"."+enstr+"."+vout+"."+ystr+"-"+yend+".nc"
    system("rm " + out_file)
    fout = addfile(out_file,"cw")
    fout->$vout$  = var1
    delete([/fout,var1/])
    system("rm -rvf *.nc *.Log" )
  end do ; end exps

 end do 

end
