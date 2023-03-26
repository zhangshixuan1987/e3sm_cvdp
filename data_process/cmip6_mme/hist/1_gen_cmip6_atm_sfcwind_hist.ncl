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
  exps       = "r1i1p1f1"
  scenario   = "historical" ;"ssp245";"ssp585"
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
  e3sm_vnam  = (/"U10", "V10"/)
  cmip_dnam  = e3sm_vnam
  cmip_dnam  = "Amon"
  nvars      = dimsizes(e3sm_vnam)

 ;time range for climo forcing 
  csym       = 197901
  ceym       = 201412
  nyrs       = ceym/100 - csym/100 + 1
  nmon       = nyrs * 12
  crange     = csym + "-" + ceym

 ;indll = ind(model_name.eq."CAS/CAS-ESM2-0")
 ;do im = indll,indll 

  indll = ind(model_name.eq."E3SM-Project/E3SM-1-1") ;INM/INM-CM5-0")
  do im = indll,indll
  ;do im = 0,nmodel-1,1

    do iv = 0,nvars-1,1

     varout   = e3sm_vnam(iv)

     if (varout.eq."U10") then
       varnam   = "ua"
       var10    = "uas"
       pout     = 1000
     end if

     if (varout.eq."V10") then
       varnam   = "va"
       var10    = "vas"
       pout     = 1000
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
     if(model_name(im).eq."CAS/CAS-ESM2-0") then
       exp0   = "r3i1p1f1"
       tflg   = "v20200502"
       fxdrs  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exp0+"/"+vardnm+"/" + var10+ "/*/"+tflg)
       print(fxdrs)
     else 
       fxdrs  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+vardnm+"/" + var10+ "/*/*")
     end if 

     if(all(ismissing(fxdrs))) then 

     if(model_name(im).eq."CAS/CAS-ESM2-0") then
       exp0   = "r3i1p1f1"
       tflg   = "v20200502"
       fdrs   = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exp0+"/"+vardnm+"/" + varnam + "/*/"+tflg)
     else
       fdrs   = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps+"/"+vardnm+"/" + varnam + "/*/*")
     end if
     nens     = dimsizes(fdrs)
    
     ike = 0 
     do ie = 0,nens-1,1

      fdr  = fdrs(ie)
      strs = str_split(fdr, "/")

      if(.not.all(ismissing(strs))) then 

       print("working on " + modnam)

       fls  = systemfunc("ls -1 " + fdr + "/*.nc")

       if(.not.all(ismissing(fls))) then 
    
        f = addfiles(fls,"r")

        if (isfilevar(f[0],"time").and.isfilevar(f[0],varnam)) then 

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

            if(.not.all(ismissing(var0))) then 
              lev  = var0&lev
              if(max(lev).gt.10000) then
                indx = ind(toint(lev).eq.(pout*100))
              else
                indx = ind(toint(lev).eq.pout)
              end if

              var = var0(:,indx,:,:)
              var = where(var.ge.1e3,var@_FillValue,var)
              delete([/lev,indx/])

              ;;regrid the data to target grid 
              dstFileName  = comdir + "/sample_out_grid.nc"
              srcFileName  = fls(0)
              keystring    = var_lev + "_" + scenario
              InterpMethod = "bilinear" ;"conserve" 
              vout         = regrid_to_reference_grid(var,keystring, modout,InterpMethod,srcFileName,dstFileName)

              ft  = addfile(dstFileName,"r")
              lms = ft->LANDFRAC
              vout = mask(vout, (lms.le.0.1), True)
              delete([/ft,lms/])

              ;output the files  
              odir = outdir + "/" + scenario+"/" + modout
              system("if ! test -d " + odir +" ; then mkdir -p " + odir + " ; fi")
              enstr     = "en"+sprinti("%02d",ike)
              out_file  = odir+"/"+modout+"."+scenario+"."+enstr+"."+varout+"."+crange+".nc"
              system("rm " + out_file)
              if(.not.all(ismissing(vout))) then 
                setfileoption("nc", "Format",  "NetCDF4")
                fout = addfile(out_file,"c")
                vonm = varout
                fout->$vonm$  = vout
                delete([/enstr,vonm,fout/])
                ike = ike + 1
              end if
              delete([/dimx,f,var,vout,srcFileName,dstFileName/])
            end if 
            delete([/var0/])
          end if  
          delete([/yymm,indp/])
         end if 
       end if 
       delete([/fls/])
      end if 
      delete([/fdr,strs/])
    end do 
    delete([/cpath,fdrs/])
   end if 
   delete(fxdrs)
   end do 
 end do 
end