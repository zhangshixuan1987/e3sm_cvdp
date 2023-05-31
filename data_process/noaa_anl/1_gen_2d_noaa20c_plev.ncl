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
  latS      = -90.  ;negative for southern hemisphere
  latN      =  90.  ;negative for southern hemisphere
  lonW      =  0.0
  lonE      = 360.0

  fili      = "./share_var_info_plev.txt"
  dstr      = asciiread(fili, -1, "string")
  delim     = ","
  varList   = str_squeeze(str_get_field(dstr, 1, delim))
  untList   = str_squeeze(str_get_field(dstr, 2, delim))
  facList   = stringtofloat(str_get_field(dstr, 3, delim))
  nvars     = dimsizes(varList)

  do k  = 0,nexps-1,1

   fl1   = systemfunc("ls "+data_dir+"/"+exp_name(k)+"*prelev*.nc")
   nens  = dimsizes(fl1)

   do ie = 0,nens-1,1

    print(fl1(ie))
    f1 = addfile(fl1(ie),"r")

    do j = 0,nvars-1,1

    varout = varList(j)
    varunt = untList(j)
    facmod = facList(j)

    print("working on variable "+ varout)
    if (isStrSubset(varout,"U")) then
      varnam   = "uwnd"
      pout     = toint(str_sub_str(varout,"U","0"))
    end if
    if (isStrSubset(varout,"V")) then
      varnam   = "vwnd"
      pout     = toint(str_sub_str(varout,"V","0"))
    end if
    if (isStrSubset(varout,"T")) then
      varnam   = "air"
      pout     = toint(str_sub_str(varout,"T","0"))
    end if
    if (isStrSubset(varout,"RH")) then
      varnam   = "rhum"
      pout     = toint(str_sub_str(varout,"Q","0"))
    end if
    if (isStrSubset(varout,"Q")) then
      varnam   = "shum"
      pout     = toint(str_sub_str(varout,"Q","0"))
    end if
    if (isStrSubset(varout,"OMEGA")) then
      varnam   = "omega"
      pout     = toint(str_sub_str(varout,"OMEGA","0"))
    end if
    if (isStrSubset(varout,"Z")) then
      varnam   = "hgt"
      pout     = toint(str_sub_str(varout,"Z","0"))
    end if

    lat  = f1->lat
    lon  = f1->lon
    lev  = f1->level
    time = f1->time

    year          = cd_calendar(time, 1) 
    indy          = ind(year.ge.ystr.and.year.le.yend)
    obstime       = time(indy)
    obstime@units = time@units
    print(pout)
    xtmp = f1->$varnam$
    if(max(lev).gt.10000) then
      indx = ind(lev.eq.pout*100)
    else
      indx = ind(lev.eq.pout)
    end if

    var0 = xtmp(indy,indx,{latS:latN},{lonW:lonE})
    delete([/indx,lev/])

    var0@_FillValue = -9999.
    var0            = var0*facmod
    var0@units      = varunt

    delete(var0&time)
    var0&time  = obstime

    delete([/xtmp,time,year,indy,obstime/])

    setfileoption("nc", "Format",  "NetCDF4")
    enstr     = "en"+sprinti("%02d",ie)
    DIR = out_dir+"/" + out_name
    system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
    out_file  = DIR+"/"+out_name(k)+"."+enstr+"."+varout+"."+ystr+"-"+yend+".nc"
    system("rm " + out_file)
    fout = addfile(out_file,"cw")
    fout->$varout$  = var0
    delete([/fout,var0/])
 
    ;regrid data to e3sm grid 
    system ("ncremap  -m " + MAP_FILE + " " + out_file + " " + out_file+".tmp") 
    system ("mv " + out_file+".tmp" + " " + out_file)

  end do 

 end do 

end do 

end
