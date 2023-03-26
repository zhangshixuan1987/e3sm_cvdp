;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This script used to generate SST and Seaice ensemble forcing from CMIP6 scenario mip;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./function.ncl"

begin

  cmipnam    = (/"ScenarioMIP"/)
  exps       = "r1i1p1f1"
  scenario   = "ssp245"
  outdir     = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/CMIP6_MME"
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"
  comdir     = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/run_script/data_process/cmip6_mme/share_file"

 ;get CMIP6 model name
  model_dirs = systemfunc("cd " + topdir+ "/"+cmipnam+"; ls -d */*")
  model_name = model_dirs 
  nmodel     = dimsizes(model_name)
  delete([/model_dirs/])
  ;print(model_name)

  var_lev    = "plev"
  cmip_vnam  = (/"ua", "va", "ta", "zg", "wap", "hus"/)
  e3sm_vnam  = (/"U1000","U850", "U600", "U500", "U200", \
                 "V1000","V850", "V600", "V500", "V200", \
                 "T850", "T500", "T300", "T200", \ 
                 "Z700","Z500","Z300", "Z200",  \
                 "OMEGA500", "Q850", "Q500"/) 
  cmip_dnam  = e3sm_vnam
  cmip_dnam  = "Amon"
  nvars      = dimsizes(e3sm_vnam)

 ;time range for climo forcing 
  csym       = 202901
  ceym       = 206212
  nyrs       = ceym/100 - csym/100 + 1
  nmon       = nyrs * 12
  crange     = csym/100 + "-" + ceym/100

  do im = 0,nmodel-1,1

    do iv = 0,nvars-1,1
     varout   = e3sm_vnam(iv)

     if (isStrSubset(varout,"U")) then
       varnam   = "ua"
       pout     = toint(str_sub_str(varout,"U","0"))
     end if
     if (isStrSubset(varout,"V")) then
       varnam   = "va"
       pout     = toint(str_sub_str(varout,"V","0"))
     end if
     if (isStrSubset(varout,"T")) then
       varnam   = "ta"
       pout     = toint(str_sub_str(varout,"T","0"))
     end if
     if (isStrSubset(varout,"Q")) then
       varnam   = "hus"
       pout     = toint(str_sub_str(varout,"Q","0"))
     end if
     if (isStrSubset(varout,"OMEGA")) then
       varnam   = "wap"
       pout     = toint(str_sub_str(varout,"OMEGA","0"))
     end if
     if (isStrSubset(varout,"Z")) then
       varnam   = "zg"
       pout     = toint(str_sub_str(varout,"Z","0"))
     end if
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
     fdrs     = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+vardnm+"/" + varnam+ "/*/*")
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
          if(dimsizes(dimx).eq.3) then 
            var0   = f[:]->$varnam$(indp,:,:)
            var0!0 = "time"
            var0!1 = "lev"
            var0!2 = "cells"
          else 
            var0   = f[:]->$varnam$(indp,:,:,:)
            var0!0 = "time"
            var0!1 = "lev"
            var0!2 = "lat"
            var0!3 = "lon" 
          end if 
 
          lev  = var0&lev
          if(max(lev).gt.10000) then
            indx = ind(toint(lev).eq.(pout*100))
          else
            indx = ind(toint(lev).eq.pout)
          end if
          var = var0(:,indx,:,:)
          delete([/lev,indx,var0/])

          ;;regrid the data to target grid 
          dstFileName  = comdir + "/sample_out_grid.nc"
          srcFileName  = fls(0)
          keystring    = var_lev + "_" + scenario
          InterpMethod = "bilinear" ;"conserve" 
          vout         = regrid_to_reference_grid(var,keystring, modout,InterpMethod,srcFileName,dstFileName)
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