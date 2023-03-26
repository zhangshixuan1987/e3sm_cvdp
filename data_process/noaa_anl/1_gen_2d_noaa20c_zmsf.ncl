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

  out_dir   = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/"
  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/NOAA_20C/V3"
  MAP_FILE  = "/global/cfs/cdirs/e3sm/zhan391/data/regrid_maps/noaa20c_360x181_to_360x180_Rect_bilinear.nc"
  comdir    = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/run_script/data_process/cmip6_mme/share_file"

  exp_name  = (/"noaa20c"/)
  out_name  = (/"NOAA_20C"/)
  nexps     = dimsizes(exp_name)
  time_tag  = "1853-2015"
  grid_tag  = "1x1"

  obs_vnam  = (/"air","hgt", "omega", "rhum", "shum", "uwnd", "vwnd"/)
  ystr      = 185301
  yend      = 201512
  d2r       = get_d2r("float")

 ;define regions for eof analysis
  latS     = -90.  ;negative for southern hemisphere
  latN     =  90.  ;negative for southern hemisphere
  lonW     =  0.0
  lonE     = 360.0

  varList = (/"SF"/)
  untList = (/"kg s~S~-1~N~"/)
  facList = (/1.0/)
  nvars = dimsizes(varList)

  ;;get pressure level;;;;
  fera5 = "/global/cfs/cdirs/e3sm/zhan391/data/ERA5/monthly/ERA5_ens01_monthly_1979-2019_1x1.nc"
  fin   = addfile (fera5,"r")
  plev       = tofloat(fin->lev({1000:50}))
  plev!0     = "lev"
  plev&lev   = plev
  plev@units = "hPa"
  delete([/fera5,fin/])

  do k  = 0,nexps-1,1

   fl0   = systemfunc("ls "+data_dir+"/"+exp_name(k)+"*siglev*.nc")
   fl1   = systemfunc("ls "+data_dir+"/"+exp_name(k)+"*prelev*.nc")
   nens  = dimsizes(fl1)

   do ie = 0,nens-1,1

    print(fl1(ie))

    f0 = addfile(fl0(ie),"r")
    f1 = addfile(fl1(ie),"r")

    lat  = f1->lat
    lon  = f1->lon


    time0 = f0->time
    year0 = cd_calendar(time0, 1) 
    indy0 = ind(year0.ge.ystr.and.year0.le.yend)

    time1 = f1->time
    year1 = cd_calendar(time1, 1)        
    indy1 = ind(year1.ge.ystr.and.year1.le.yend)

    obstime       = time1(indy1)
    obstime@units = time1@units

    psm  = f0->psfc(indy0,{latS:latN},{lonW:lonE})
    if(psm@units.eq."hPa".or.psm@units.eq."milibar") then
      psm = psm * 100.0
      psm@units = "Pa"
    end if

    vmi   = f1->vwnd(indy1,:,{latS:latN},{lonW:lonE})
    vmi!0 = "time"
    vmi!1 = "lev"
    vmi!2 = "lat"
    vmi!3 = "lon"

    lev = vmi&lev
    if(lev@units.eq."Pa".or.max(lev).gt.10000) then
       lev = lev / 100.0 
       lev@units = "hPa"
       vmi&lev   = lev 
    end if 
    vmx              = int2p_n_Wrap(vmi&lev,vmi,plev,1,1)
    vmx!1            = "lev"
    vmx&lev          = vmx&lev*100.0
    vmx&lev@units    = "Pa"

    if(vmx&lev(0).gt.vmx&lev(1)) then
      smh = zonal_mpsi_Wrap(vmx(:,::-1,:,:),vmx&lat,vmx&lev(::-1),psm)
    else
      smh = zonal_mpsi_Wrap(vmx,vmx&lat,vmx&lev,psm)
    end if 

    dstFileName  = comdir+ "/sample_out_grid.nc"
    fd   = addfile(dstFileName,"r")
    smho = linint1_n_Wrap(smh&lat,smh,False,fd->lat,0,2)
    delete([/smh,dstFileName,fd,lev,vmx/])

    varout = varList(0)
    varunt = untList(0)
    varfac = facList(0)
    print("working on variable "+ varout)
     
    smho@_FillValue = -9999.
    smho       = smho*varfac
    smho@units = varunt
    delete(smho&time)
    smho&time  = obstime

    setfileoption("nc", "Format",  "NetCDF4")
    enstr     = "en"+sprinti("%02d",ie)
    DIR = out_dir+"/" + out_name
    system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
    out_file  = DIR+"/"+out_name(k)+"."+enstr+"."+varout+"."+ystr+"-"+yend+".nc"
    system("rm " + out_file)
    fout = addfile(out_file,"cw")
    fout->$varout$  = smho
    delete([/fout,obstime,smho,lat,lon,indy0,indy1,vmi,psm,time0,time1,year0,year1/])

  end do 

end do 

end
