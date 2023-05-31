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
load "./function.ncl"
begin

  cmipnam    = (/"CMIP"/)
  exps       = "r1i1p1f1"
  scenario   = "historical" ;"ssp245";"ssp585"
  outdir     = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/CMIP6_MME"
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"
  comdir     = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/data_process/cmip6_mme/share_file/"

  cmip_var   = (/"va","ps"/)
  ncmp_var   = dimsizes(cmip_var)
  cmip_dnam  = "Amon"

 ;time range for climo forcing
  csym    = 197901
  ceym    = 201412
  nyrs    = ceym/100 - csym/100 + 1
  nmon    = nyrs * 12
  crange  = csym + "-" + ceym

 ;get CMIP6 model name
  model_dirs = systemfunc("cd " + topdir+ "/"+cmipnam+"; ls -d */*")
  model_name = model_dirs
  nmodel     = dimsizes(model_name)
  delete([/model_dirs/])
 ;print(model_name)

  varList = (/"SF"/)
  untList = (/"kg s~S~-1~N~"/)
  facList = (/1.0/)
  nvars = dimsizes(varList)

  ;;get pressure level;;;;
  fera5 = "/global/cfs/cdirs/e3sm/zhan391/data/ERA5/monthly/ERA5_ens01_monthly_1979-2019_1x1.nc"
  fin   = addfile (fera5,"r")
  plev       = tofloat(fin->lev({50:1000}))
  plev!0     = "lev"
  plev&lev   = plev
  plev@units = "hPa"
  delete([/fera5,fin/])

  xind = ind (model_name.eq."E3SM-Project/E3SM-1-0" ) ;CAS/CAS-ESM2-0")

  do im = xind,xind ;0,nmodel-1,1
   
   modnam   = model_name(im)
   tmpnam   = str_split(modnam,"/")
   print("work on model " + modnam)

   if (tmpnam(0).eq."MPI-M") then
      modout = "DKRZ"+"_"+tmpnam(1)
   else
      modout   = str_sub_str(modnam,"/","_")
   end if
   delete(tmpnam)

   cpath = topdir+"/"+cmipnam+"/" + modnam
  ;fdr1  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+cmip_dnam+"/va/gn/*")
   if(modnam.eq."CAS/CAS-ESM2-0") then 
     fdr1  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+cmip_dnam+"/va/gn/v20200502")
   else if (modnam.eq."NOAA-GFDL/GFDL-CM4") then 
     fdr1  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+cmip_dnam+"/va/gr1/*")   
   else if (modnam.eq."E3SM-Project/E3SM-1-0") then
     fdr1  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+cmip_dnam+"/va/gr/v20190729")
   else
     fdr1  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+cmip_dnam+"/va/gn/*")
   end if 
   end if 
   end if 

   nens  = dimsizes(fdr1) 

   ike = 0 

   do ie = 0,nens-1,1

   ;;check if all file is missing
   fl1  = systemfunc("ls " + fdr1(ie) +"/*.nc")
   print(fl1)
   fdr0 = str_sub_str(fdr1(ie),"va","ps") 
   if (modnam.eq."E3SM-Project/E3SM-1-0") then
     fl0  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+cmip_dnam+"/ps/gr/v20190913/*.nc")
   else 
     fl0  = systemfunc("ls " + fdr0 +"/*.nc")
   end if 
   print(fl0)

   if(all(isfilepresent(fl0)).and.all(isfilepresent(fl1))) then

    f0 = addfiles(fl0,"r")
    f1 = addfiles(fl1,"r")

    yymm0 = cd_calendar(f0[:]->time, 1)
    indp0 = ind(yymm0.ge.csym.and.yymm0.le.ceym)
   ;print(yymm0(indp0))

    yymm1 = cd_calendar(f1[:]->time, 1)
    indp1 = ind(yymm1.ge.csym.and.yymm1.le.ceym)
   ;print(yymm1(indp1))

    if(num(.not.ismissing(indp0)).eq.nmon.and.num(.not.ismissing(indp1)).eq.nmon) then

      obstime       = f1[:]->time(indp1)
      obstime@units = f1[0]->time@units

      varnam = "ps"
      dim0 = dimsizes(f0[:]->$varnam$)
      if(dimsizes(dim0).eq.2) then
        var0   = f0[:]->$varnam$(indp0,:)
        var0!0 = "time"
        var0!1 = "cells"
      else
        var0   = f0[:]->$varnam$(indp0,:,:)
        var0!0 = "time"
        var0!1 = "lat"
        var0!2 = "lon"
      end if
      delete(dim0)

      varnam = "va"
      dim1 = dimsizes(f1[:]->$varnam$)
      if(dimsizes(dim1).eq.3) then
        var1   = f1[:]->$varnam$(indp1,:,:)
        var1!0 = "time"
        var1!1 = "lev"
        var1!2 = "cells"
      else
        var1   = f1[:]->$varnam$(indp1,:,:,:)
        var1!0 = "time"
        var1!1 = "lev"
        var1!2 = "lat"
        var1!3 = "lon"
      end if
      delete(dim1)

      if(.not.all(ismissing(var0)).and..not.all(ismissing(var1))) then

        var0 = where(var0.ge.1e8,var0@_FillValue,var0)
        var1 = where(var1.ge.1e3,var1@_FillValue,var1)

        if((var1&lev@units.eq."Pa") .or. (max(var1&lev).gt.10000) )  then
          var1&lev       = var1&lev*0.01
          var1&lev@units = "hPa"
        end if

        vmx              = int2p_n_Wrap(var1&lev,var1,plev,1,1)
        vmx&lev          = vmx&lev*100.0
        vmx&lev@units    = "Pa"
        if(var0@units.eq."hPa") then
          var0 = var0 * 100.0
          var0@units = "Pa"
        end if
        smh = zonal_mpsi_Wrap(vmx,vmx&lat,vmx&lev,var0)

        dstFileName  = comdir+ "/sample_out_grid.nc"
        fd   = addfile(dstFileName,"r")
        smho = linint1_n_Wrap(smh&lat,smh,False,fd->lat,0,2)
        delete([/vmx,smh,dstFileName,fd/])
        
        do iv = 0,nvars-1,1
          vars   = varList(iv)
          varout = vars
          varunt = untList(iv)
          facmod = facList(iv)
          print("working on variable "+ vars)
     
          if(vars.eq."SF") then     
            varx = smho
          end if 

          varx@_FillValue = -9999.
          varx       = varx*facmod
          varx@units = varunt
          delete(varx&time)
          varx&time  = obstime
 
          setfileoption("nc", "Format",  "NetCDF4")
          enstr = "en"+sprinti("%02d",ike)
          DIR   = outdir + "/" + scenario+"/" + modout  
          system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
          out_file  = DIR+"/"+modout+"."+scenario+"."+enstr+"."+varout+"."+crange+".nc"
          system("rm " + out_file)
          fout = addfile(out_file,"cw")
          vs1 = vars
          fout->$vs1$  = varx
          delete([/fout,varx/])
        end do 
        ike = ike + 1
        delete([/smho/])
      end if 
      delete([/obstime,var0,var1/])
   end if
   delete([/yymm0,yymm1,indp0,indp1,f0,f1/])
  end if 
  delete([/fl0,fl1,fdr0/])
 end do 
 delete([/fdr1/])
end do 

end
