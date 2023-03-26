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

  out_dir   = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/"
  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/ERA5/monthly"
  exp_name  = (/"ERA5"/)
  out_name  = (/"ERA5"/)
  nexps     = dimsizes(exp_name)
  time_tag  = "1979-2019"
  grid_tag  = "1x1"

  ystr      = 197901
  yend      = 201812

  d2r       = get_d2r("float")
  gravit    = 9.80616      ; acceleration of gravity ~ m/s^2
  rgrav     = 1.0/gravit   ; reciprocal of gravit
  DUfac     = 2.1415e-5    ; 1DU in kg/m2 

 ;define regions for eof analysis
  latS      = -90.  ;negative for southern hemisphere
  latN      =  90.  ;negative for southern hemisphere
  lonW      =  0.0
  lonE      = 360.0
 
  varList   = (/"TCO", "SCO"/)
  facList   = (/1.0, 1.0/)
  untList   = (/"DU","DU"/)
  nvars     = dimsizes(varList)

  fls       = systemfunc("ls "+data_dir+"/"+exp_name+"*"+time_tag+"_1x1.nc")
  nens      = dimsizes(fls)

  do j = 0,nvars-1,1

   vars   = varList(j)
   varunt = untList(j)
   facmod = facList(j)

   print("working on variable "+ vars)

   do k  = 0,nens-1,1

    f             = addfile(fls(k),"r")
    time          = f->time
    time          = time - 1
    year          = cd_calendar(time, 1)
    indy          = ind(year.ge.ystr.and.year.le.yend)
    obstime       = time(indy)
    obstime@units = time@units

    lev           = f->lev
    lev           = lev * 100.0
    lev@units     = "Pa"

   ;Calculate the layer thickness
    psfc = f->PS(indy,{latS:latN},{lonW:lonE})
    if(psfc@units.eq."hPa")
      psfc = psfc*100.0
      psfc@units = "Pa"
    end if 

    ptop = min(lev)
    if(lev(0).gt.lev(1)) then 
      pdel = dpres_plevel(lev, psfc, ptop, 0)
    else 
      lev1 = lev(::-1)
      pdel = dpres_plevel(lev1, psfc, ptop, 0)
      pdel = pdel(:,::-1,:,:)
      delete(lev1)
    end if 

    tmp  = f->T(indy,:,{latS:latN},{lonW:lonE})
    var0 = f->O3(indy,:,{latS:latN},{lonW:lonE})

    if(lev(0).gt.lev(1)) then
      tmp  = tmp(:,::-1,:,:)
      var0 = var0(:,::-1,:,:)
      pdel = pdel(:,::-1,:,:)
    end if 
   ;printVarSummary(pdel)
   ;print(min(pdel) + " " +max(pdel))

   ;Calculate the pressure of the tropopause.
   ;The first tropopause is defined as the lowest level at which
   ;the lapse rate decreases to 2 deg K per kilometer or less,
   ;provided also the average lapse rate between this level and
   ;all higher levels within 2 kilometers does not exceed 2 deg K.
   ;rad  = 4.0*atan(1.0)/180.0
   ;ptrp = (25000.0 - 15000.0 * (cos(f->lat({latS:latN})*rad))^2) ; Pa
    ptrp = trop_wmo(lev,tmp(time|:,lat|:,lon|:,lev|:), 1, False) 
    x1   = conform(pdel,lev,1)
    x2   = conform(pdel,ptrp,(/0,2,3/))
    if(vars.eq."SCO") then 
      tmsk = where(x1.lt.x2,1.0,0.0)
    else 
      tmsk = where(x1.lt.x2,0.0,1.0) 
    end if
    delete([/tmp,x1,x2,ptrp/])

    var0       = var0*pdel*rgrav/DUfac
    var0       = var0*tmsk
    var1       = dim_sum_n_Wrap(var0,1)
    var1       = var1*facmod
    var1@units = varunt
    var1@_FillValue = -9999.
    delete([/tmsk,var0/])
    delete([/time,year,indy/])

    setfileoption("nc", "Format",  "NetCDF4")
    enstr     = "en"+sprinti("%02d",k)
    DIR = out_dir+"/" + out_name
    system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
    out_file  = DIR+"/"+out_name+"."+enstr+"."+vars+"."+ystr+"-"+yend+".nc"
    system("rm " + out_file)
    fout = addfile(out_file,"cw")
    vs1 = vars
    fout->$vs1$  = var1

    delete([/fout,var1/])

   end do 

  end do ; end exps

end
