;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This script used to generate SST and Seaice ensemble forcing from CMIP6 scenario mip;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./function.ncl"

begin

  cmipnam    = (/"CMIP"/)
  exps       = "*"
  scenario   = "historical" ;"ssp245";"ssp585"
  outdir     = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/CESM_ENS"
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"
  comdir     = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/run_script/data_process/cmip6_mme/share_file"

 ;get CMIP6 model name
  model_dirs = systemfunc("cd " + topdir+ "/"+cmipnam+"; ls -d */*")
  inm        = ind(model_dirs.eq."NCAR/CESM2")
  model_name = model_dirs(inm)
  nmodel     = dimsizes(model_name)
  delete([/model_dirs,inm/])
 ;print(model_name)

  var_lev    = "ocnsfc"
  cmip_vnam  = (/"tos","siconc"/)
  e3sm_vnam  = (/"SST","SICONC"/)
  cmip_dnam  = (/"Omon","SImon"/)
  nvars      = dimsizes(cmip_vnam)

 ;time range for climo forcing 
  csym       = 197901
  ceym       = 201412
  nyrs       = ceym/100 - csym/100 + 1
  nmon       = nyrs * 12
  crange     = csym + "-" + ceym

  do im = 0,nmodel-1,1

    do iv = 1,nvars-1,1

     varnam   = cmip_vnam(iv)
     varout   = e3sm_vnam(iv)
     vardnm   = cmip_dnam(iv)
     modnam   = model_name(im)
     tmpnam   = str_split(modnam,"/")  
     if (tmpnam(0).eq."MPI-M") then
        modout = "DKRZ"+"_"+tmpnam(1)
     else 
        modout   = str_sub_str(modnam,"/","_")
     end if
     delete(tmpnam)

     cpath    = topdir+"/"+cmipnam+"/" + modnam 
     fdrs     = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+vardnm+"/" + varnam+ "/gn/*/")
     nens     = dimsizes(fdrs)
    
     ike = 0 
     do ie = 0,nens-1,1

      fdr  = fdrs(ie)
      strs = str_split(fdr, "/")

      if(.not.all(ismissing(strs))) then 

       print("working on " + modnam)

       fls  = systemfunc("ls -1 " + fdr + "/*.nc")

       if(.not.all(ismissing(fls))) then 

        f    = addfiles(fls,"r")
        yymm = cd_calendar(f[:]->time, 1)
        indp = ind(yymm.ge.csym.and.yymm.le.ceym)
       ;print(yymm(indp))

        if(num(.not.ismissing(indp)).eq.nmon) then 

          dimx = dimsizes(f[:]->$varnam$) 
          if(dimsizes(dimx).eq.2) then 
            var   = f[:]->$varnam$(indp,:)
            var!0 = "time"
            var!1 = "cells"
          else 
            var   = f[:]->$varnam$(indp,:,:)
            var!0 = "time"
            var!1 = "lat"
            var!2 = "lon" 
          end if 
 
          ;;regrid the data to target grid 
          dstFileName  = comdir + "/sample_out_grid.nc"
          srcFileName  = fls(0)
          InterpMethod = "bilinear";"conserve" 
          if(varout.eq."SICONC") then 
            keystring    = "seaice"
          else 
            keystring    = var_lev + "_" + scenario
          end if 
          vout = regrid_to_reference_grid(var,keystring,modout,InterpMethod,srcFileName,dstFileName)
          if(.not.all(ismissing(vout))) then 
            odir = outdir + "/" + scenario+"/" + modout  
            system("if ! test -d " + odir +" ; then mkdir -p " + odir + " ; fi")
            enstr     = "en"+sprinti("%02d",ike)
            out_file  = odir+"/"+modout+"."+scenario+"."+enstr+"."+varout+"."+crange+".nc"
            setfileoption("nc", "Format",  "NetCDF4")
            system("rm " + out_file)
            fout = addfile(out_file,"cw")
            vonm = varout
            fout->$vonm$  = vout
            delete([/enstr,vonm,fout/])
            ike = ike + 1
           end if
           delete([/dimx,f,var,srcFileName,dstFileName/])
        end if  
        delete([/yymm,indp/])
       end if 
       delete([/fls/])
     end if 
     delete([/fdr,strs/])
    end do 
    delete([/cpath,fdrs/])
   end do 
 end do 
end
