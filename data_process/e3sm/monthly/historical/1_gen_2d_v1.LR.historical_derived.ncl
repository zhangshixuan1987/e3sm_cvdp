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

  fili     = "./cmip_derived_var_info.txt"
  dstr     = asciiread(fili, -1, "string")
  delim    = ","
  varList  = str_squeeze(str_get_field(dstr, 1, delim))
  untList  = str_squeeze(str_get_field(dstr, 2, delim))
  facList  = stringtofloat(str_get_field(dstr, 3, delim))
  nvars    = dimsizes(varList)
  var_lev  = "sfc"
  
  cmip_var = (/"rlut","FLUTC","FLDS","rldscs","FSDS", \
               "FSDSC","FSUTOA","FSUTOAC","rsus","rsuscs",\
               "rlus","SOLIN", "rsut","rsutcs","rtmt",\
               "LHFLX","SHFLX","TAUX","TAUY","TS"/)
  ncmp_var = dimsizes(cmip_var)

 ;time range for climo forcing 
  csym    = 197901
  ceym    = 201412
  nyrs    = ceym/100 - csym/100 + 1
  nmon    = nyrs * 12
  crange  = csym + "-" + ceym

  do im = 0,nmodel-1,1

   modout = out_name 
   cpath  = outdir 

   do ie = 0,10,1
    enstr     = "en"+sprinti("%02d",ie)
    print(enstr)
   ;read all cmip6 data required to derive variables 
    do iv = 0,ncmp_var-1,1
      fl = cpath+"/"+modout+ "/"+modout+"."+enstr+"."+cmip_var(iv)+"."+crange+".nc"
     ;print(fl)

      if(isfilepresent(fl)) then
        f  = addfile(fl,"r")
        if (cmip_var(iv).eq."rlut") then 
          rlut = f->rlut 
        end if 
        if (cmip_var(iv).eq."FLUTC") then
          rlutcs = f->FLUTC
        end if
        if (cmip_var(iv).eq."FLDS") then
          rlds = f->FLDS
        end if
        if (cmip_var(iv).eq."rldscs") then
          rldscs = f->rldscs
        end if
        if (cmip_var(iv).eq."FSDS") then
          rsds = f->FSDS
        end if
        if (cmip_var(iv).eq."FSDSC") then
          rsdscs = f->FSDSC
        end if
        if (cmip_var(iv).eq."LHFLX") then
          lhflx = f->LHFLX
        end if
        if (cmip_var(iv).eq."SHFLX") then
          shflx = f->SHFLX
        end if
        if (cmip_var(iv).eq."rsus") then
          rsus = f->rsus
        end if
        if (cmip_var(iv).eq."rsuscs") then
          rsuscs = f->rsuscs
        end if
        if (cmip_var(iv).eq."rlus") then
          rlus = f->rlus
        end if
        if (cmip_var(iv).eq."SOLIN") then
          rsdt = f->SOLIN
        end if
        if (cmip_var(iv).eq."FSUTOA") then
          rsut = f->FSUTOA
        end if
        if (cmip_var(iv).eq."FSUTOAC") then
          rsutcs = f->FSUTOAC
        end if
        if (cmip_var(iv).eq."rtmt") then
          rtmt = f->rtmt
        end if
        if (cmip_var(iv).eq."TS") then
          sst = f->TS
        end if
        if (cmip_var(iv).eq."TAUX") then
          taux = f->TAUX
        end if
        if (cmip_var(iv).eq."TAUY") then
          tauy = f->TAUY
        end if
      end if 
    end do 

    do iv = 0,nvars-1,1

     varnam = varList(iv)
     varout = varList(iv)

     if (varnam.eq."OLR") then
       if(isvar("rlut")) then
        var0 = rlut
        var0@long_name = "TOA outgoing longwave radiative fluxes (SW) at full-sky (downward - upward)"
       end if
     end if
          
     if (varnam.eq."FSNS") then
       if(isvar("rsds").and.isvar("rsus")) then
        var0 = rsds 
        var0 = (rsds - rsus) 
        var0@long_name = "Surface radiative fluxes (SW) at full-sky (downward - upward)"
       end if 
     end if 

     if (varnam.eq."FSNSC") then
       if(isvar("rsdscs").and.isvar("rsuscs")) then
         var0 = rsdscs
         var0 = (rsdscs - rsuscs)
         var0@long_name = "Surface radiative fluxes (SW) at clear-sky (downward - upward)"
       end if
     end if

     if (varnam.eq."FLNS") then
       if(isvar("rlds").and.isvar("rlus")) then
         var0 = rlds
         var0 = (rlus - rlds)
         var0@long_name = "Surface radiative fluxes (LW) at full-sky (downward - upward)"
       end if
     end if

     if (varnam.eq."FLDSC") then
       if(isvar("rldscs")) then 
        var0 = rldscs 
        var0@long_name = "Downward longwave radiative (clear-sky) effects at surface"
       end if
     end if

     if (varnam.eq."FLNSC") then
       if(isvar("rldscs").and.isvar("rluscs")) then
         var0 = rldscs
         var0 = (rlus - rldscs)
         var0@long_name = "Surface radiative fluxes (LW) at clear-sky (downward - upward)"
       end if 
     end if 

     if (varnam.eq."SWCRE_SRF") then
       if(isvar("rsds").and.isvar("rsus").and.isvar("rsuscs").and.isvar("rsuscs")) then
        var0 = rsds
        var0 = (rsds - rsus) - (rsdscs - rsuscs)
        var0@long_name = "Surface cloud radiative effects (SW) (downward - upward)"
       end if 
     end if

     if (varnam.eq."LWCRE_SRF") then
       if(isvar("rlds").and.isvar("rldscs")) then
         var0 = rlds
         var0 = rlds - rldscs 
         var0@long_name = "Surface cloud radiative effects (LW) (downward - upward)"
       end if 
     end if

     if (varnam.eq."CRE_SRF") then
       if(isvar("rsds").and.isvar("rsdscs").and.isvar("rsus") \
          .and.isvar("rsuscs").and.isvar("rlds").and.isvar("rldscs")) then
         var0 = rsds
         var0 = (rsds - rsus) - (rsdscs - rsuscs) + (rlds - rldscs) 
         var0@long_name = "Surface cloud radiative effects (downward - upward)" 
       end if 
     end if

     if (varnam.eq."CRE") then
       if( isvar("rsut") .and. isvar("rsdt") .and. isvar("rsutcs") \
           .and. isvar("rlut") .and. isvar("rlutcs")) then 
         var0 = rsut 
         var0 = rsut - (rsdt - rsutcs) + (rlut - rlutcs) 
         var0@long_name = "TOA cloud radiative effects  (upward - downward)" 
       end if 
     end if

     if (varnam.eq."SWCRE") then
       if (isvar("rsut").and.isvar("rsdt").and.isvar("rsutcs")) then 
         var0 = rsut
         var0 = (rsdt - rsut) - (rsdt - rsutcs) 
         var0@long_name = "TOA cloud radiative effects (SW)"  
       end if 
     end if

     if (varnam.eq."LWCRE") then
       if (isvar("rlut").and.isvar("rlutcs")) then
         var0 = rlut
         var0 = rlut - rlutcs
         var0@long_name = "TOA cloud radiative effects (LW)"
       end if 
     end if 

     if (varnam.eq."QnRad_SRF") then
       if (isvar("rlds").and.isvar("rlus").and.isvar("rsus").and.isvar("rsds")) then
         var0 = rsds
         var0 = (rsds - rsus) + (rlds - rlus) 
         var0@long_name = "Total surface radiative fluxes (positive down)"
       end if 
     end if 

     if (varnam.eq."QnTot_SRF") then
       if (isvar("rlds").and.isvar("rlus").and.isvar("rsus").and.isvar("rsds") \
           .and. isvar("shflx").and.isvar("lhflx")) then
         var0 =  rsds
         var0 = (rsds - rsus) + (rlds - rlus) - lhflx - shflx 
         var0@long_name = "Net surface total fluxes (positive down)"
       end if 
     end if 

     if(varnam.eq."QnTur_SRF") then
       if(isvar("shflx").and.isvar("lhflx")) then
         var0 = lhflx
         var0 = -lhflx - shflx 
         var0@long_name = "Total surface turbulent fluxes (positive down)"
       end if 
     end if 
     
     if (varnam.eq."RESTOA") then
       if(isvar("rtmt")) then 
         var0 = rtmt 
         var0@long_name = "net radiative fluxes at top of atmosphere"
       end if 
     end if 
     
     if(varnam.eq."Qn_SRF") then
       if( isvar("rsds").and.isvar("rsus").and.isvar("rlds").and.isvar("rlus")\
           .and. isvar("lhflx") .and. isvar("shflx") ) then 
         beta   = rsds
         beta   = where(rsds.eq.0,beta@_FillValue,beta)
         beta   = rsus/beta 
         var0   = rsds
         var0   = (1.0 - beta) * rsds + rlds - rlus - lhflx - shflx
       end if 
     end if 
     
     if (varnam.eq."ETH1".or. varnam.eq."ETH2".or.varnam.eq."ETH12") then
      if( isvar("sst").and.isvar("taux").and.isvar("tauy")) then  
       fcor  = coriolis_param(tofloat(sst&lat));
       cpair = 1005.0   ; heat capacity of air (J/kg/K)
       cp_sw = 3.996e3  ; specific heat salt water(J/kg/C)
       rho_sw= 1026.0   ; kg/m3
       tztmp = sst      ; surface temperature (K)
       tztmp = tztmp - 273.15 ; convert to C
       txtmp = taux     ; zonal surface stress (N/m2)
       tytmp = tauy     ; meridional surface stress (N/m2)
       tzclm = clmMonTLL (tztmp)
       txclm = clmMonTLL (txtmp)
       tyclm = clmMonTLL (tytmp)
       tzanm = calcMonAnomTLL(tztmp,tzclm)
       txanm = calcMonAnomTLL(txtmp,txclm)
       tyanm = calcMonAnomTLL(tytmp,tyclm)
       var0  = sst
       if(varnam.eq."ETH12") then
         gradLatLon = grad_latlon_cfd (tztmp, tztmp&lat, tztmp&lon, True, False)
         dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'
         dzdx  = tofloat(gradLatLon[1])
         var0  = -cp_sw/conform(tztmp,fcor,1) * (dzdx*tytmp - dzdy*txtmp)
         var0@long_name = "Full Ekman heat transport (ETH) anomaly"
         var0@units     = "W m~S~-2~N~"
         delete([/gradLatLon,dzdy,dzdx/])
       end if 
       
       if(varnam.eq."ETH1") then
         gradLatLon = grad_latlon_cfd (tzclm, tzclm&lat, tzclm&lon, True, False) 
         dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'
         dzdx  = tofloat(gradLatLon[1])
         dimx1 = dimsizes(tztmp)
         ny    = dimx1(0)/12
         ytmp  = -cp_sw/conform(tztmp,fcor,1)
         do iy = 0,ny-1
            iy1 = iy*12
            iy2 = (iy+1)*12-1
            var0(iy1:iy2,:,:) = ytmp(iy1:iy2,:,:) \
                                *(dzdx(:,:,:)*tyanm(iy1:iy2,:,:) - dzdy(:,:,:)*txanm(iy1:iy2,:,:))
         end do
         var0@long_name = "ETH anomaly: anomalous winds acting on clim SST gradient"
         var0@units     = "W m~S~-2~N~"
         delete([/dimx1,ny,gradLatLon,dzdy,dzdx,ytmp/])
       end if 
   
       if(varnam.eq."ETH2") then
         gradLatLon = grad_latlon_cfd (tzanm, tzanm&lat, tzanm&lon, True, False)
         dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'
         dzdx  = tofloat(gradLatLon[1])
         dimx1 = dimsizes(tztmp)
         ny    = dimx1(0)/12
         ytmp  = -cp_sw/conform(tztmp,fcor,1)
         do iy = 0,ny-1
           iy1 = iy*12
           iy2 = (iy+1)*12-1
           var0(iy1:iy2,:,:) = ytmp(iy1:iy2,:,:) \
                               *(dzdx(iy1:iy2,:,:)*tyclm(:,:,:) - dzdy(iy1:iy2,:,:)*txclm(:,:,:))
         end do
         var0@long_name = "ETH anomaly: clim winds acting on anomalous SST gradient"
         var0@units     = "W m~S~-2~N~"
         delete([/dimx1,ny,gradLatLon,dzdy,dzdx,ytmp/])
         delete([/fcor,cpair,cp_sw,rho_sw,tztmp,txtmp,tytmp,tzclm,txclm,tyclm,tzanm,txanm,tyanm/])
       end if 
      end if 
     end if 

     out_file  = cpath+"/"+modout+ "/"+modout+"."+enstr+"."+varout+"."+crange+".nc"
     system("rm " + out_file)
     
     if(isdefined("var0")) then 
       setfileoption("nc", "Format",  "NetCDF4")
       fout = addfile(out_file,"c")
       vonm = varout
       fout->$vonm$  = var0
       delete([/vonm,var0/]) 
     end if 
    end do 
    if(isvar("rlut")) then 
      delete(rlut)
    end if 
    if(isvar("rlutcs")) then 
      delete(rlutcs)
    end if
    if(isvar("rlds")) then 
      delete(rlds)
    end if
    if(isvar("rldscs")) then 
      delete(rldscs)
    end if
    if(isvar("rsds")) then
      delete(rsds)
    end if
    if(isvar("rsdscs")) then
      delete(rsdscs)
    end if
    if(isvar("rsus")) then
      delete(rsus)
    end if
    if(isvar("rsuscs")) then
      delete(rsuscs)
    end if
    if(isvar("rlus")) then
      delete(rlus)
    end if
    if(isvar("rsdt")) then
      delete(rsdt)
    end if
    if(isvar("rsut")) then
      delete(rsut)
    end if
    if(isvar("rsutcs")) then
      delete(rsutcs)
    end if
    if(isvar("rtmt")) then
      delete(rtmt)
    end if
    if(isvar("sst")) then
      delete(sst)
    end if
    if(isvar("taux")) then
      delete(taux)
    end if
    if(isvar("tauy")) then
      delete(tauy)
    end if
    if(isvar("lhflx")) then
      delete(lhflx)
    end if
    if(isvar("shflx")) then
      delete(shflx)
    end if
  end do 
end do ; end of ensemble 
end
