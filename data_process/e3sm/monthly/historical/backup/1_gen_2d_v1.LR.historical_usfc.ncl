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
  scenario   = "historical" ;"ssp245";"ssp585"
  outdir     = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"
  comdir     = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/run_script/data_process/cmip6_mme/share_file"

 ;get CMIP6 model name
  model_name = (/"E3SM-Project/E3SM-1-0"/)
  nmodel     = dimsizes(model_name)
  out_name   = "v1.LR." + scenario
  exps       = (/"r1i1p1f1","r2i1p1f1","r3i1p1f1","r4i1p1f1","r5i1p1f1"/)
  ttag       = (/"v20191220","v20190729","v20190729","v20190730","v20190730"/)
  nexps      = dimsizes(exps)
 ;print(model_name)

  var_lev    = "usfc"
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

  do im = 0,nmodel-1,1

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
     modout   = out_name 

     ike = 0
     do kk = 0,nexps-1,1
       ike = kk
       print("working on " + modnam)
       cpath = topdir+"/"+cmipnam+"/" + modnam
       fdrs  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps(kk)+"/"+vardnm+"/" + varnam+ "/gr")
       fdr   = systemfunc("ls -d " + fdrs+"/"+ttag(kk))
       fls   = systemfunc("ls -1 " + fdr + "/*.nc")

       print(fls)

       if(all(isfilepresent(fls))) then

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
              delete([/lev,indx/])

              if (varout.eq."S10".or.varout.eq."U10".or.varout.eq."V10") then
                var = where(var.ge.1e3,var@_FillValue,var)
              end if 

              ;;regrid the data to target grid 
              dstFileName  = comdir + "/sample_out_grid.nc"
              srcFileName  = fls(0)
              keystring    = var_lev + "_" + scenario
              InterpMethod = "bilinear" ;"conserve" 
              vout         = regrid_to_reference_grid(var,keystring, modout,InterpMethod,srcFileName,dstFileName)

              ;output the files  
              odir = outdir + "/" + modout
              system("if ! test -d " + odir +" ; then mkdir -p " + odir + " ; fi")
              enstr     = "en"+sprinti("%02d",ike)
              out_file  = odir+"/"+modout+"."+enstr+"."+varout+"."+crange+".nc"
              system("rm " + out_file)
              if(.not.all(ismissing(vout))) then 
                setfileoption("nc", "Format",  "NetCDF4")
                fout = addfile(out_file,"c")
                fout->$varout$  = vout
                delete([/enstr,fout/])
                ike = ike + 1
              end if
              delete([/dimx,f,var,vout,srcFileName,dstFileName/])
            end if 
            delete([/var0/])
          end if  
          delete([/yymm,indp/])
         end if 
       end if 
      delete([/fls,fdr,cpath,fdrs/])
    end do 
   end do 
 end do 
end
