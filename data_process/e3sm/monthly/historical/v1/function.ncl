;;;;regrid to reference grid;;;;;;;;
undef("regrid_to_reference_grid")
function regrid_to_reference_grid(finarr,key:string,finnam:string,InterpMethod:string,fin:string,fout:string)
local Opt, outdir, finarr, InterpMethod, key, fin, fout, srcGridName, dstGridName, wgtFileName, fouarr,vout,fi,fo
begin

 ;---Output (and input) files
 outdir             = "wgt_file"
 system("if ! test -d " + outdir +" ; then mkdir " + outdir + " ; fi")

 srcGridName        = "src_SCRIP_"+key+".nc"
 dstGridName        = "dst_SCRIP_"+key+".nc"
 wgtFileName        = outdir+"/"+finnam+"_"+key+"_rgd_weight.nc"

 fi   = addfile(fin,"r")
 fo   = addfile(fout,"r")
 vout = fo->TS(0,:,:) 

  dimtmp = dimsizes(finarr)
  if(dimsizes(dimtmp).eq.2)then
   vmsk = finarr(0,:)
  else if(dimsizes(dimtmp).eq.3)then
   vmsk = finarr(0,:,:)
  else if(dimsizes(dimtmp).eq.4)then
   vmsk = finarr(0,0,:,:)
  else
   vmsk = finarr(0,0,0,:,:)
  end if
  end if
  end if

  if(dimsizes(dimtmp).gt.2)then
   vmsk!0 = "lat"
   vmsk!1 = "lon"
   lat    = vmsk&lat
   lon    = vmsk&lon
  else 
   if (isfilevar(fi, "lat")) then
     lat = fi->lat                 ; source grid
   else if (isfilevar(fi, "latitude")) then
     lat = fi->latitude            ; source grid
   else if (isfilevar(fi, "nav_lat")) then
     lat = fi->nav_lat             ; source grid
   end if
   end if
   end if
   if (isfilevar(fi, "lon")) then
     lon = fi->lon
   else if (isfilevar(fi, "longitude")) then
     lon = fi->longitude
   else if (isfilevar(fi, "nav_lon")) then
     lon = fi->nav_lon
   end if
   end if
   end if
  end if 

 system("rm -rvf " + wgtFileName)

 if (fileexists(wgtFileName)) then 
   SKIP_WGT_GEN       = True
 else 
   SKIP_WGT_GEN       = False
   INTERP_METHOD      = "bilinear"
 end if 

 if (.not.SKIP_WGT_GEN) then
   Opt                 = True            ; Regridding optioins
   Opt@SrcFileName     = srcGridName
   Opt@DstFileName     = dstGridName
   Opt@WgtFileName     = wgtFileName
   Opt@InterpMethod    = InterpMethod    ; patch takes longer
   Opt@ForceOverwrite  = True
   Opt@Debug           = True
   Opt@PrintTimings    = True

   Opt@SrcInputFileName= fin 
   Opt@SrcGridMask     = where(ismissing(vmsk),0,1)
   Opt@SrcGridLat      = lat                 ; source grid
   Opt@SrcGridLon      = lon

   if (isfilevar(fi, "vertices_latitude")) then
     Opt@SrcGridCornerLat= fi->vertices_latitude
   else if (isfilevar(fi, "bounds_nav_lat")) then
     Opt@SrcGridCornerLat= fi->bounds_nav_lat
   else if (isfilevar(fi, "bounds_lat")) then
     Opt@SrcGridCornerLat= fi->bounds_lat
   end if
   end if
   end if

   if (isfilevar(fi, "vertices_longitude")) then
     Opt@SrcGridCornerLon= fi->vertices_longitude
   else if (isfilevar(fi, "bounds_nav_lon")) then
     Opt@SrcGridCornerLon= fi->bounds_nav_lon
   else if (isfilevar(fi, "bounds_lon")) then
     Opt@SrcGridCornerLon= fi->bounds_lon
   end if
   end if
   end if

   Opt@DstGridLat      = fo->lat
   Opt@DstGridLon      = fo->lon
   Opt@DstInputFileName= fout 
   Opt@DstGridMask     = where(ismissing(vout),0,1) 

   fouarr = ESMF_regrid(finarr,Opt)
   system("rm -rvf " + srcGridName + " " + dstGridName)
   delete([/Opt,dimtmp/])
 else 
   Opt                = True
  ;Opt@Debug          = True
   Opt@PrintTimings   = True
   fouarr             = ESMF_regrid_with_weights(finarr,wgtFileName,Opt)
   delete([/Opt/])
end if

if (isStrSubset(finnam,"AWI")) then 
  ff = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
  lsdata = ff->LSMASK
  lsm = landsea_mask(lsdata,fo->lat,fo->lon)
 ;lsm is a 2D array that can be used directly in mask
  fouarr = mask(fouarr,lsm.ge.1,False)   
end if 

delete([/fi,fo,vout,vmsk,lat,lon/])

return(fouarr)

end 
