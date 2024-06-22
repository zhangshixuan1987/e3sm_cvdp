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
  scenario   = "amip" ;"ssp245";"ssp585"
  outdir     = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"
  comdir     = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/run_script/data_process/cmip6_mme/share_file"

 ;get CMIP6 model name
  model_name = (/"E3SM-Project/E3SM-1-0"/)
  nmodel     = dimsizes(model_name)
  cmip_dnam  = "Amon"

  exp_name   = "v1.LR." + scenario
  exps       = (/"r1i1p1f1","r2i1p1f1","r3i1p1f1"/)
  ttag       = (/"v20190801","v20190802","v20190917"/)
  ttps       = (/"v20190801","v20190802","v20190917"/)
  nexps      = dimsizes(exps)

 ;print(model_name)

  time_tag  = "1979-2014"
  grid_tag  = "1x1"
  ystr      = 197901
  yend      = 201412

  nyrs      = yend/100 - ystr/100 + 1
  nmon      = nyrs * 12
  crange    = yend + "-" + ystr

  seasons  = (/"MON"/)
  nseas    = dimsizes(seasons)
  d2r      = get_d2r("float")

  varout = (/"SF"/)
  varunt = (/"kg s~S~-1~N~"/)
  varfac = (/1.0/)

  ;;get pressure level;;;;
  fera5 = "/global/cfs/cdirs/e3sm/zhan391/data/ERA5/monthly/ERA5_ens01_monthly_1979-2019_1x1.nc"
  fin   = addfile (fera5,"r")
  plev       = tofloat(fin->lev({50:1000}))
  plev!0     = "lev"
  plev&lev   = plev
  plev@units = "hPa"
  delete([/fera5,fin/])

  ike = 0
  do kk = 0,nexps-1,1

    vardnm   = cmip_dnam 
    modnam   = model_name
    modout   = exp_name

    ike = kk
    print("working on " + modnam)
    cpath = topdir+"/"+cmipnam+"/" + modnam
    fdr0  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps(kk)+"/"+vardnm+"/ps/gr")
    fdr1  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps(kk)+"/"+vardnm+"/va/gr") 
    fd0   = systemfunc("ls -d " + fdr0+"/"+ttps(kk))
    fd1   = systemfunc("ls -d " + fdr1+"/"+ttag(kk))

    fl0   = systemfunc("ls -1 " + fd0 + "/*.nc")
    fl1   = systemfunc("ls -1 " + fd1 + "/*.nc")

   ; print(fl0)
   ; print(fl1)

    if(all(isfilepresent(fl0)).and.all(isfilepresent(fl1))) then

      f0 = addfiles(fl0,"r")
      f1 = addfiles(fl1,"r")

      yymm0 = cd_calendar(f0[:]->time, 1)
      indp0 = ind(yymm0.ge.ystr.and.yymm0.le.yend)
     ;print(yymm0(indp0))

      yymm1 = cd_calendar(f1[:]->time, 1)
      indp1 = ind(yymm1.ge.ystr.and.yymm1.le.yend)
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

        if(.not.all(ismissing(var0)).and..not.all(ismissing(var1))) then

          var0 = where(var0.ge.1e8,var0@_FillValue,var0)
          var1 = where(var1.ge.1e3,var1@_FillValue,var1)
       
          if((var1&lev@units.eq."Pa") .or. (max(var1&lev).gt.10000) )  then 
            var1&lev       = var1&lev*0.01
            var1&lev@units = "hPa"
          end if 
          if(var1&lev(0).gt.var1&lev(1)) then 
            var1 = var1(:,::-1,:,:) 
            var1&lev = var1&lev(::-1)
          end if 
          vmx              = int2p_n_Wrap(var1&lev,var1,plev,1,1)
          vmx&lev          = vmx&lev*100.0
          vmx&lev@units    = "Pa"
          smh = zonal_mpsi_Wrap(vmx,vmx&lat,vmx&lev,var0)

          dstFileName  = comdir+ "/sample_out_grid.nc"
          fd   = addfile(dstFileName,"r")
          smho = linint1_n_Wrap(smh&lat,smh,False,fd->lat,0,2)
          delete([/vmx,smh,dstFileName,fd/])

          smho@_FillValue = -9999.
          smho       = smho*varfac
          smho@units = varunt
          delete(smho&time)
          smho&time  = obstime
 
          setfileoption("nc", "Format",  "NetCDF4")
          enstr     = "en"+sprinti("%02d",ike)
          DIR = outdir+"/" + exp_name
          system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
          out_file  = DIR+"/"+exp_name+"."+enstr+"."+varout+"."+ystr+"-"+yend+".nc"
          system("rm " + out_file)
          fout = addfile(out_file,"cw")
          fout->$varout$  = smho
          delete([/fout,smho/])
          ike = ike + 1
       end if
       delete([/obstime,var0,var1/])
      end if 
     delete([/yymm0,yymm1,indp0,indp1,f0,f1/])
    end if 
   delete([/fl0,fl1,fdr0,fdr1/])
 end do 
end
