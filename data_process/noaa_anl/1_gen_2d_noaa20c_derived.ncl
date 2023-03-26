;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This script used to generate SST and Seaice ensemble forcing from CMIP6 scenario mip;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  out_dir   = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/"
  data_dir  = "/global/cfs/cdirs/e3sm/zhan391/data/NOAA_20C/V3"
  MAP_FILE  = "/global/cfs/cdirs/e3sm/zhan391/data/regrid_maps/noaa20c_360x181_to_360x180_Rect_bilinear.nc"

  exp_name  = (/"noaa20c"/)
  out_name  = (/"NOAA_20C"/)
  nexps     = dimsizes(exp_name)
  time_tag  = "1853-2015"
  grid_tag  = "1x1"

  csym      = 185301
  ceym      = 201512
  d2r       = get_d2r("float")
  crange    = csym + "-" + ceym

  noaa_var  = (/"rlut","FLUTC","FLDS","rldsc","FSDS", \
                "FSDSC","FSUTOA","FSUTOAC","rsus","rsusc",\
                "rlus","SOLIN", "rsut","rsutc",\
                "LHFLX","SHFLX","TAUX","TAUY","TS"/)
  nobs_var = dimsizes(noaa_var)

  fili     = "./share_var_info_derived.txt"
  dstr     = asciiread(fili, -1, "string")
  delim    = ","
  varList  = str_squeeze(str_get_field(dstr, 1, delim))
  untList  = str_squeeze(str_get_field(dstr, 2, delim))
  facList  = stringtofloat(str_get_field(dstr, 3, delim))
  nvars    = dimsizes(varList)

  do ie = 0,0,1
    enstr     = "en"+sprinti("%02d",ie)
    print(enstr)

    ;read all data required to derive variables 
    do iv = 0,nobs_var-1,1

      cpath = out_dir+"/" + out_name
      fl    = cpath+"/"+out_name+"."+enstr+"."+noaa_var(iv)+"."+csym+"-"+ceym+".nc"
      if(isfilepresent(fl)) then
        f  = addfile(fl,"r")
        if (noaa_var(iv).eq."rlut") then 
          rlut = f->rlut 
        end if 
        if (noaa_var(iv).eq."FLUTC") then
          rlutcs = f->FLUTC
        end if
        if (noaa_var(iv).eq."FLDS") then
          rlds = f->FLDS
        end if
        if (noaa_var(iv).eq."rldscs") then
          rldscs = f->rldsc
        end if
        if (noaa_var(iv).eq."FSDS") then
          rsds = f->FSDS
        end if
        if (noaa_var(iv).eq."FSDSC") then
          rsdscs = f->FSDSC
        end if
        if (noaa_var(iv).eq."LHFLX") then
          lhflx = f->LHFLX
        end if
        if (noaa_var(iv).eq."SHFLX") then
          shflx = f->SHFLX
        end if
        if (noaa_var(iv).eq."rsus") then
          rsus = f->rsus
        end if
        if (noaa_var(iv).eq."rsuscs") then
          rsuscs = f->rsuscs
        end if
        if (noaa_var(iv).eq."rlus") then
          rlus = f->rlus
        end if
        if (noaa_var(iv).eq."SOLIN") then
          rsdt = f->SOLIN
        end if
        if (noaa_var(iv).eq."FSUTOA") then
          rsut = f->FSUTOA
        end if
        if (noaa_var(iv).eq."FSUTOAC") then
          rsutcs = f->FSUTOAC
        end if
        if (noaa_var(iv).eq."TS") then
          sst = f->TS
        end if
        if (noaa_var(iv).eq."TAUX") then
          taux = f->TAUX
        end if
        if (noaa_var(iv).eq."TAUY") then
          tauy = f->TAUY
        end if
      end if 
    end do 

    ;derive the rtmt first 
    rtmt = rsdt 
    rtmt = rsdt - rsut - rlut

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


     if(isdefined("var0")) then
      setfileoption("nc", "Format",  "NetCDF4")
      enstr     = "en"+sprinti("%02d",ie)
      DIR = out_dir+"/" + out_name
      system("if ! test -d " + DIR +" ; then mkdir " + DIR + " ; fi")
      out_file  = DIR+"/"+out_name+"."+enstr+"."+varout+"."+csym+"-"+ceym+".nc"
      system("rm " + out_file)
      fout = addfile(out_file,"cw")
      fout->$varout$  = var0
      delete([/fout,var0/])
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
end
