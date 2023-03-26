undef("read_cmip6_ensemble")
function read_cmip6_ensemble(ymS:numeric,ymE:numeric,varS:string,cpath0:string,opttype:string,datanam:string)
local f1,l_flag,cmd,vn,cpath0,nens,fdir,files,indy,yymm,time,lat,lon,lev,nstim,finarr
begin

nyrs           = ymE/100 - ymS/100 + 1
nmon           = nyrs * 12 

timeR          = ispan(1,nmon,1)
timeR@units    = "months since "+(ymS/100 -1 )+ "-12-01 00:00:0.0"
timeR@comments = "no-leap"

cmd   = "ls -d " + cpath0 +"/*/Amon/"+varS+"/*/*"
fdir  = systemfunc(cmd)
nens  = dimsizes(fdir)

;;check if all file is missing 
ftmp = systemfunc("ls " + cpath0 +"/*/Amon/"+varS+"/*/*/*.nc")
if (all(ismissing(ftmp))) then
  fdir0  = systemfunc("ls -d " + cpath0 +"/*/Amon/ta/*/*")
  nens0  = dimsizes(fdir0)
  delete(fdir0)
else 
  nens0 = nens 
end if 
delete(ftmp)

;;create array to save  data
ftmp = systemfunc("ls " + cpath0 +"/*/Amon/ta/*/*/*.nc")
f0   = addfile(ftmp(0),"r")
lat  = f0->lat
lon  = f0->lon

if (opttype.eq."time_lat_lon") then
  finarr      = new((/nens0,dimsizes(timeR),dimsizes(lat),dimsizes(lon)/),"float",1.e20)
  finarr!0    = "ens"    
  finarr!1    = "time"    ; time coordinate variable assigned below
  finarr&time = timeR
  finarr!2    = "lat"
  finarr&lat  = lat
  finarr!3    = "lon"
  finarr&lon  = lon
  finarr&lat@units = "degrees_north"
  finarr&lon@units = "degrees_east"
end if

if (opttype.eq."time_lev_lat_lon") then
  finarr      = new((/nens0,dimsizes(timeR),dimsizes(f0->plev),dimsizes(lat),dimsizes(lon)/),"float",1.e20)
  finarr!0    = "ens"    ; time coordinate variable assigned below
  finarr!1    = "time"   ; time coordinate variable assigned below
  finarr&time = timeR
  finarr!2    = "lev"
  finarr&lev  = f0->plev
  finarr!3    = "lat"
  finarr&lat  = lat
  finarr!4    = "lon"
  finarr&lon  = lon
  finarr&lat@units = "degrees_north"
  finarr&lon@units = "degrees_east"
end if
delete([/ftmp,f0,lat,lon/])

do ie = 0,nens-1,1

  tmpdir = "tmp_"+datanam
  system("rm -rvf  "+tmpdir)
  system("mkdir -p  "+tmpdir)

  if(datanam.eq."cesm2.cmip6.historical".and.varS.eq."pr".and.ie.ge.10) then
    system("files=`ls " +fdir(ie)+"/*185001-201412*.nc`;ln -sf $files "+tmpdir+"/") 
  else if (datanam.eq."v1.LR.amip".and.varS.eq."hfss") then
    system("files=`ls " +fdir(ie)+"/*.nc`;ln -sf $files "+tmpdir+"/") 
    system("rm "+tmpdir+"/*187001-189412*.nc")
  else 
    system("files=`ls " +fdir(ie)+"/*.nc`;ln -sf $files "+tmpdir+"/")
  end if 
  end if 

  files = systemfunc("ls  "+tmpdir+"/*.nc")

  if (.not.all(ismissing(files))) then
    f1     = addfiles(files,"r")
    time   = f1[:]->time
   ;time   = time - 1
    yymm   = cd_calendar(time, 1)
    indy   = ind(yymm.ge.ymS.and.yymm.le.ymE)

    l_flag = (.not.all(ismissing(indy))).and.(max(yymm(indy)).eq.ymE).and.(min(yymm(indy)).eq.ymS)

    if(l_flag) then
      nstim =  dimsizes(indy)
      if(opttype.eq."time_lev_lat_lon") then 
        finarr(ie,:,:,:,:) = (/f1[:]->$varS$(indy,:,:,:)/)
      else 
        finarr(ie,:,:,:) = (/f1[:]->$varS$(indy,:,:)/)
      end if
    end if 
    delete([/time,yymm,indy,l_flag,f1/])
  end if

  delete([/files/])
  system("rm -rvf "+tmpdir)

end do

return(finarr)

end

;;;;regrid to reference grid;;;;;;;;
undef("regrid_to_reference_grid")
function regrid_to_reference_grid(finarr,finnam:string,fout:string)
local Opt, srcGridName, dstGridName, wgtFileName, INTERP_METHOD, fouarr
begin

 ;---Output (and input) files
 srcGridName        = "src_SCRIP.nc"
 dstGridName        = "dst_SCRIP.nc"
 wgtFileName        = finnam+"_rgd_weight.nc"

 if (fileexists(wgtFileName)) then 
   SKIP_SRC_SCRIP_GEN = True
   SKIP_DST_SCRIP_GEN = True
   SKIP_WGT_GEN       = True
 else 
   SKIP_SRC_SCRIP_GEN = False
   SKIP_DST_SCRIP_GEN = False
   SKIP_WGT_GEN       = False
   INTERP_METHOD      = "bilinear"
 end if 

 if(.not.SKIP_SRC_SCRIP_GEN) then
   ;--- Convert to a SCRIP Convention file.
   Opt                = True
   Opt@ForceOverwrite = True
   Opt@PrintTimings   = True
   Opt@Title          = "Reference Grid"
   Opt@Mask2D         = where(ismissing(finarr(0,0,:,:)),0,1)
   rectilinear_to_SCRIP(srcGridName,finarr&lat,finarr&lon,Opt)
   ;---Clean up
   delete(Opt)
 end if

 if(.not.SKIP_DST_SCRIP_GEN) then
   dst_file           = addfile(fout,"r")
   Opt                = True
   Opt@ForceOverwrite = True
   Opt@PrintTimings   = True
   Opt@Title          = "EAM 360x180 Grid"
   rectilinear_to_SCRIP(dstGridName,dst_file->lat,dst_file->lon,Opt)
   ;---Clean up
   delete([/Opt,dst_file/])
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
   system("rm -rvf " + srcGridName + " " + dstGridName)
 end if

 Opt                = True
;Opt@Debug          = True
 Opt@PrintTimings   = True
 fouarr             = ESMF_regrid_with_weights(finarr,wgtFileName,Opt)
 return(fouarr)

end 
