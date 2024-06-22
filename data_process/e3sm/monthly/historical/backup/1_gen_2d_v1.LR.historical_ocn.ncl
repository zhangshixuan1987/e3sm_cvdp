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
  nexps      = dimsizes(exps)
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

    do iv = 0,nvars-1,1

     varnam   = cmip_vnam(iv)
     varout   = e3sm_vnam(iv)
     vardnm   = cmip_dnam(iv)
     modnam   = model_name(im)
     modout   = out_name

     if(varnam.eq."tos") then 
       ttag       = (/"v20190826","v20190830","v20190827","v20190909","v20190918"/)
     else
       ttag       = (/"v20190805","v20190805","v20190805","v20190806","v20190806"/)
     end if 

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

        f    = addfiles(fls,"r")
        yymm = cd_calendar(f[:]->time, 1)
        indp = ind(yymm.ge.csym.and.yymm.le.ceym)


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
 
          var@_FillValue = -9999.
          var = where (var.ge.1e20,var@_FillValue,var)

          ;;regrid the data to target grid 
          dstFileName  = comdir + "/sample_out_grid.nc"
          srcFileName  = fls(0)
          InterpMethod = "bilinear" ;"conserve" 
          keystring    = var_lev + "_" + scenario
          vout         = regrid_to_reference_grid(var,keystring,modout,InterpMethod,srcFileName,dstFileName)

          if(.not.all(ismissing(vout))) then 
            odir = outdir + "/" + modout 
            system("if ! test -d " + odir +" ; then mkdir -p " + odir + " ; fi")
            enstr     = "en"+sprinti("%02d",ike)
            out_file  = odir+"/"+modout+"."+enstr+"."+varout+"."+crange+".nc"
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
        delete([/fls,yymm,indp/])
     end if 
     delete([/fdr,cpath,fdrs/])
    end do 
   end do 
 end do 
end
