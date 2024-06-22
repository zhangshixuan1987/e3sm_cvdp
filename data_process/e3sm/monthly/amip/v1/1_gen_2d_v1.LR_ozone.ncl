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
  scenario   = "amip" ;"ssp245";"ssp585"
  outdir     = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD"
  topdir     = "/global/cfs/projectdirs/m3522/cmip6/CMIP6"
  comdir     = "/global/cfs/cdirs/e3sm/zhan391/e3sm_cvdp/run_script/data_process/cmip6_mme/share_file"

 ;get CMIP6 model name
  model_name = (/"E3SM-Project/E3SM-1-0"/)
  nmodel     = dimsizes(model_name)
  out_name   = "v1.LR." + scenario
  exps       = (/"r1i1p1f1","r2i1p1f1","r3i1p1f1"/)
  ttag       = (/"v20190801","v20190802","v20190917"/)
  nexps      = dimsizes(exps)
 ;print(model_name)

  var_lev    = "ozone"
  cmip_vnam  = (/"o3","o3"/)
  e3sm_vnam  = (/"TCO", "SCO"/)
  cmip_dnam  = cmip_vnam
  cmip_dnam  = "Amon"
  nvars      = dimsizes(cmip_vnam)

  gravit    = 9.80616      ; acceleration of gravity ~ m/s^2
  rgrav     = 1.0/gravit   ; reciprocal of gravit
  DUfac     = 2.687e20     ; 1 DU in molecules per m^2 (e3sm)
  avogad    = 6.02214e26   ; Avogadro's number ~ molecules/kmole
  avogadro  = avogad*1.e-3 ; Avogadro numb - molecules/mole
  mwdry     = 28.966       ; molecular weight dry air ~ kg/kmole
  N_molwgt  = 14.00674
  S_molwgt = 32.066
  ;; 1 Dobson Unit (DU) is:
  ;; 2.6867 x 10^20 molecules per meter square
  ;; 4.4615 x 10^-4 mol/m2
  ;; 2.1415 x 10^-5 kg[O3]/m2

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

     ike = 0 
     do kk = 0,nexps-1,1 
       ike = kk
       print("working on " + modnam)
       cpath = topdir+"/"+cmipnam+"/" + modnam 
       fdrs  = systemfunc("ls -d " + cpath + "/"+scenario+"/"+exps(kk)+"/"+vardnm+"/" + varnam+ "/gr")
       fdr0  = str_sub_str(fdrs,"o3","ta")
       fdr1  = str_sub_str(fdrs,"o3","ps")
       if(kk.eq.nexps-1) then 
         fd0   = systemfunc("ls -d " + fdrs+"/v20190730")
         fd1   = systemfunc("ls -d " + fdr0+"/v20190730")
       else if (kk.eq.nexps-2) then
         fd0   = systemfunc("ls -d " + fdrs+"/v20190730")
         fd1   = systemfunc("ls -d " + fdr0+"/v20190730")
       else 
         fd0   = systemfunc("ls -d " + fdrs+"/"+ttag(kk))
         fd1   = systemfunc("ls -d " + fdr0+"/"+ttag(kk))
       end if 
       end if 

       fd2   = systemfunc("ls -d " + fdr1+"/"+ttag(kk))

       print(fd0)

       fls0  = systemfunc("ls -1 " + fd0 + "/*.nc")
       fls1  = systemfunc("ls -1 " + fd1 + "/*.nc")
       fls2  = systemfunc("ls -1 " + fd2 + "/*.nc")

       if(all(isfilepresent(fls2)).and.all(isfilepresent(fls0)).and.all(isfilepresent(fls1))) then

        f0   = addfiles(fls0,"r")
        f1   = addfiles(fls1,"r")
        f2   = addfiles(fls2,"r")

        if(isfilevar(f0[0],"time").and.isfilevar(f1[0],"time").and.isfilevar(f2[0],"time")) then 

         yymm0 = cd_calendar(f0[:]->time, 1)
         indp0 = ind(yymm0.ge.csym.and.yymm0.le.ceym)
         yymm1 = cd_calendar(f1[:]->time, 1)
         indp1 = ind(yymm1.ge.csym.and.yymm1.le.ceym)
         yymm2 = cd_calendar(f2[:]->time, 1)
         indp2 = ind(yymm2.ge.csym.and.yymm2.le.ceym)
        ;print(yymm0(indp0) + " " + yymm1(indp1) + " " +yymm2(indp2))
         
         if(num(.not.ismissing(indp0)).eq.nmon.and.num(.not.ismissing(indp1)).eq.nmon.and.num(.not.ismissing(indp2)).eq.nmon) then 

          var0 = f0[:]->$varnam$(indp0,:,:,:)
          t    = f1[:]->ta(indp1,:,:,:)
          ps   = f2[:]->ps(indp2,:,:) 
          var0!0 = "time"
          var0!1 = "lev"
          var0!2 = "lat"
          var0!3 = "lon"

          t!0 = "time"
          t!1 = "lev"
          t!2 = "lat"
          t!3 = "lon"

          lat           = var0&lat
          lev           = var0&lev
         
          if(lev@units.eq."hPa")  then 
            lev           = lev * 100.0
            lev@units     = "Pa"
          end if  

          if(ps@units.eq."hPa")
            ps = ps * 100.0 
            ps@units  = "Pa"
          end if 

          ptop        = min(lev)
          pdel        = dpres_plevel(lev, ps, ptop, 0)

          if(lev(0).gt.lev(1))  then
            lev  = lev (::-1)
            t    = t(:,::-1,:,:)
            var0 = var0(:,::-1,:,:)
            pdel = pdel(:,::-1,:,:)
          end if
          var0&lev = lev
          t&lev    = lev

         ;Calculate the pressure of the tropopause.
         ;The first tropopause is defined as the lowest level at which
         ;the lapse rate decreases to 2 deg K per kilometer or less,
         ;provided also the average lapse rate between this level and
         ;all higher levels within 2 kilometers does not exceed 2 deg K.
         ;rad  = 4.0*atan(1.0)/180.0
         ;ptrp = (25000.0 - 15000.0 * (cos(lat*rad))^2) ; Pa
          t&lev= lev 
          ptrp = trop_wmo(lev,t(time|:,lat|:,lon|:,lev|:), 1, False)

          x1   = conform(pdel,lev,1)
          x2   = conform(pdel,ptrp,(/0,2,3/))

          if(varnam.eq."SCO") then
            tmsk = where(x1.lt.x2,1.0,0.0)
          else
            tmsk = where(x1.lt.x2,0.0,1.0)
          end if

          var0@FillValue = -9999.0
          var0      = where(ismissing(var0),0,var0)
          var0      = var0*pdel*rgrav*avogadro/mwdry/DUfac*1.e3
          var0      = var0*tmsk
          var       = dim_sum_n_Wrap(var0,1)
          var@units = "DU"
          var@_FillValue = -9999.
          delete([/x1,x2,var0,ps,t,ptrp,tmsk,pdel,ptop,lev,lat/])

          ;;regrid the data to target grid 
          dstFileName  = comdir + "/sample_out_grid.nc"
          srcFileName  = fls0(0)
          keystring    = var_lev + "_" + scenario
          InterpMethod = "bilinear" ;"conserve" 
          vout         = regrid_to_reference_grid(var,keystring, modout,InterpMethod,srcFileName,dstFileName)
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
           delete([/var,srcFileName,dstFileName/])
        end if  
        delete([/yymm0,indp0,yymm1,indp1,yymm2,indp2/])
       end if 
      end if 
      delete([/cpath,fls0,fls1,fls2,fd0,fd1,fd2,fdr0,fdr1,fdrs/])
    end do 
   end do ;;end of exp loop
 end do 
end
