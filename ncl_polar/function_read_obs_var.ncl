;;;;This script saved the shared code to get the observational data;;;;;;

  if (isfilevar(f2, ovarnam)) then
    var2                            = f2->$ovarnam$

  else if (ovarnam.eq."slhf") then

    if (isfilevar(f2, "ie")) then
      var2                          = f2->ie
      var2                          = var2 * 2.5e6 
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if

  else if (ovarnam.eq."sshf") then

    if (isfilevar(f2, "ishf")) then
      var2                          = f2->ishf
      var2                          = var2
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if

  else if (ovarnam.eq."si10") then

    if (isfilevar(f2, "u10").and.isfilevar(f2, "v10")) then
      var2                          = f2->u10
      var2                          = wind_speed(f2->u10,f2->v10)
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if

  else if (ovarnam.eq."FLUT") then
    ;rlut = ttr (TOA Outgoing Longwave Radiation)
    if (isfilevar(f2, "ttr")) then
      var2                          = f2->ttr
      var2                          = var2 * -1.0
    else if (isfilevar(f2, "rlut")) then
      var2                          = f2->rlut
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FLUTC") then
    ;rlutc = ttrc (Clear-sky TOA Outgoing Longwave Radiation )
    if (isfilevar(f2, "ttrc")) then
      var2                          = f2->ttrc
      var2                          = var2 * -1.0
    else if (isfilevar(f2, "rlutc"))
      var2                          = f2->rlutc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSUTOA") then
    ;rsut (TOA Outgoing Shortwave Radiation) 
    ;    = tisr (TOA incident solar radiation)
    ;    - tsr (Top net solar radiation)
    if (isfilevar(f2, "tisr").and.isfilevar(f2, "tsr")) then
      var2                          = f2->tisr
      var2                          = f2->tisr - f2->tsr 
    else if (isfilevar(f2, "rsut"))
      var2                          = f2->rsut
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSUTOAC") then
    ;rsutc (Clear-sky TOA Outgoing Shortwave Radiation)
    ;    = tisr (TOA incident solar radiation)
    ;    - tsrc (Clear-sky Top net solar radiation)
    if (isfilevar(f2, "tisr").and.isfilevar(f2, "tsrc")) then
      var2                          = f2->tisr
      var2                          = f2->tisr - f2->tsrc
    else if (isfilevar(f2, "rsutc"))
      var2                          = f2->rsutc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FLNS") then
    ;; rlus (Surface Downwelling Longwave Radiation) 
    ;;  = strd (Surface thermal radiation downwards) 
    ;;  - str (Surface net thermal radiation)
    ;; rlds = strd (Surface thermal radiation downwards)
    if (isfilevar(f2, "str") ) then
      var2                          = - f2->str
    else if (isfilevar(f2, "rlus").and.isfilevar(f2, "rlds"))then
      var2                          = f2->rlus
      var2                          = f2->rlus - f2->rlds
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FLNSC") then
   ;; rlusc (Clear-sky Surface Downwelling Longwave Radiation)
   ;; rldsc (Clear-sky )
    if (isfilevar(f2, "strc") ) then
      var2                          = -f2->strc
    else if (isfilevar(f2, "rlusc").and.isfilevar(f2, "rldsc"))then
      var2                          = f2->rlusc
      var2                          = f2->rlusc - f2->rldsc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSNTOA") then

    ; rsdt = tisr (TOA Incident Shortwave Radiation)
    ; rsut (TOA Outgoing Shortwave Radiation) = tisr - tsr (Top net solar radiation)
    ; FSNTOA  = rsdt - rsut  
    if (isfilevar(f2, "tsr") ) then
      var2                          = f2->tsr
    else if (isfilevar(f2, "rsdt").and.isfilevar(f2, "rsut")) then
      var2                          = f2->rsdt
      var2                          = f2->rsdt - f2->rsut
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSNTOAC") then

    if (isfilevar(f2, "tsrc")) then
      var2                          = f2->tsrc
    else if (isfilevar(f2, "rsdt").and.isfilevar(f2, "rsutc")) then
      var2                          = f2->rsdt
      var2                          = f2->rsdt - f2->rsutc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FLDS") then
    ;; rlds = strd (Surface thermal radiation downwards)
    if (isfilevar(f2, "strd")) then
      var2                          = f2->strd
    else if (isfilevar(f2, "rlds")) then
      var2                          = f2->rlds
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FLDSC") then
    ;; rldsc = strd (Surface thermal radiation downwards)
    if (isfilevar(f2, "strdc")) then
      var2                          = f2->strdc
    else if (isfilevar(f2, "rldsc")) then
      var2                          = f2->rldsc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FLUS") then
    ;; rlus (Surface Downwelling Longwave Radiation)
    ;;  = strd (Surface thermal radiation downwards)
    ;;  - str (Surface net thermal radiation)
    if (isfilevar(f2, "strd")) then
      var2                          = f2->strd
      var2                          = f2->strd - f2->str
    else if (isfilevar(f2, "rlus")) then
      var2                          = f2->rlus
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FLUSC") then
    ;; rlusc (Surface Downwelling Longwave Radiation)
    ;;  = strd (Surface thermal radiation downwards)
    ;;  - str (Surface net thermal radiation)
    if (isfilevar(f2, "strdc")) then
      var2                          = f2->strdc
      var2                          = f2->strdc - f2->strc
    else if (isfilevar(f2, "rlusc")) then
      var2                          = f2->rlusc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FLNT") then
   ;;ERA5 reanalysis ignore the small downward long-wave (non-solar)
   ;;(i.e. the dowanwelling longwave fluxes at TOP is zero), thus,
   ;;TTR represents the negative of outgoing longwave radiation
    if (isfilevar(f2, "ttr")) then
      var2                          = f2->ttr
      var2                          = var2 * (-1.0)
    else if (isfilevar(f2, "rlut")) then
      var2                          = f2->rlut
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FLNTC") then
    if (isfilevar(f2, "ttrc")) then
      var2                          = f2->ttrc
      var2                          = var2 * (-1.0)
    else if (isfilevar(f2, "rlutc").and.isfilevar(f2, "rldtc")) then
      var2                          = f2->rlutc
      var2                          = f2->rlutc - f2->rldtc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSNS") then
    ;; rsds = ssrd (Surface Downwelling Shortwave Radiation)
    ;; rsus (Surface Upwelling Shortwave Radiation)
    ;;      = ssrd (Surface solar radiation downwards)
    ;;      - ssr (Surface net solar radiation)
    if (isfilevar(f2, "ssr")) then
      var2                          = f2->ssr
    else if (isfilevar(f2, "rsus").and.isfilevar(f2, "rsds")) then
      var2                          = f2->rsds
      var2                          = f2->rsds - f2->rsus
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSNSC") then
    if (isfilevar(f2, "ssrc")) then
      var2                          = f2->ssrc
    else if (isfilevar(f2, "rsusc").and.isfilevar(f2, "rsdsc")) then
      var2                          = f2->rsdsc
      var2                          = f2->rsdsc - f2->rsusc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSDS") then
    ;; rsds = ssrd (Surface Downwelling Shortwave Radiation)
    if (isfilevar(f2, "ssrd")) then
      var2                          = f2->ssrd
    else if (isfilevar(f2, "rsds")) then
      var2                          = f2->rsds
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSDSC") then
    ;; rsdsc = ssrdc (Clear-sky Surface Downwelling Shortwave Radiation)
    if (isfilevar(f2, "ssrdc")) then
      var2                          = f2->ssrdc
    else if (isfilevar(f2, "rsdsc")) then
      var2                          = f2->rsdsc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSUS") then
    ;; rsus = (surface_upwelling_shortwave_flux_in_air)
    ;;    ssrd (Surface Downwelling Shortwave Radiation)
    ;;   -ssr (surface_net_downward_shortwave_flux)
    if (isfilevar(f2, "ssrd").and.isfilevar(f2, "ssr")) then
      var2                          = f2->ssrd
      var2                          = f2->ssrd - f2->ssr
    else if (isfilevar(f2, "rsus")) then
      var2                          = f2->rsus
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."FSUSC") then
    ;; rsusc = (surface_upwelling_shortwave_flux_in_air)
    ;;     ssrdc (Surface Downwelling Shortwave Radiation)
    ;;   - ssrc (surface_net_downward_shortwave_flux)
    if (isfilevar(f2, "ssrdc").and.isfilevar(f2, "ssrc")) then
      var2                          = f2->ssrdc
      var2                          = f2->ssrdc - f2->ssrc
    else if (isfilevar(f2, "rsus")) then
      var2                          = f2->rsusc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."SWCF") then
    ;SWCF: FSNTOA - FSNTOAC
    ;SWCF: (tsr) - (tsrc)
    ;SWCF: (rsdt - rsut) - (rsdtc - rsutc)
    if (isfilevar(f2, "tsr").and.isfilevar(f2, "tsrc")) then
      var2                          = f2->tsr
      var2                          = f2->tsr - f2->tsrc
    else if (isfilevar(f2, "rsut").and.isfilevar(f2, "rsutc").and.\
             isfilevar(f2, "rsdt")) then
      var2                          = f2->rsut    
      var2                          = (f2->rsdt - f2->rsut) - (f2->rsdt - f2->rsutc)
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."LWCF") then
    ;LWCF: FLNT - FLNTC 
    ;LWCF: (-ttr) - (-ttrc)
    ;LWCF: (rlut - rldt) - (rlutc - rldtc)
    if (isfilevar(f2, "ttr").and.isfilevar(f2, "ttrc")) then
      var2                          = f2->ttrc
      var2                          = f2->ttr - f2->ttrc
    else if (isfilevar(f2, "rlut").and.isfilevar(f2, "rlutc")) then
      var2                          = f2->rlut 
      var2                          = -f2->rlut  +  f2->rlutc
    else
      print(ovarnam + " does not exist, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."NETCF") then

    if (isfilevar(f2, "tsr").and.isfilevar(f2, "tsrc").and.\
        isfilevar(f2, "ttr").and.isfilevar(f2, "ttrc")) then
      var2                          = f2->ttr
      var2                          = (f2->ttr - f2->ttrc) + (f2->tsr - f2->tsrc)
    else if (isfilevar(f2, "rsut").and.isfilevar(f2, "rsutc").and.\
             isfilevar(f2, "rsdt").and.isfilevar(f2, "rlut").and.\
             isfilevar(f2, "rlutc")) then
      var2                          = f2->rsut
      var2                          = (f2->rsdt - f2->rsut) - (f2->rsdt - f2->rsutc) - (f2->rlut - f2->rlutc)
    else
      print(ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."SWCF_SRF") then
    ; SWCF_SRF: (fsns - fsnsc)
    ; SWCF_SRF: (ssr - ssrc)  
    ; SWCF_SRF: (rsds - rsuc) - (rsdsc - rsusc)
    if (isfilevar(f2, "ssr").and.isfilevar(f2, "ssrc")) then
      var2                          = f2->ssr
      var2                          = f2->ssr - f2->ssrc
    else if (isfilevar(f2, "rsds").and.isfilevar(f2, "rsus").and. \
             isfilevar(f2, "rsdsc").and.isfilevar(f2, "rsusc")) then
      var2                          = f2->rsds
      var2                          = (f2->rsds - f2->rsus) - (f2->rsdsc - f2->rsusc)
    else
      print(ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."LWCF_SRF") then
    ; LWCF_SRF: - (flns - flnsc)
    ; LWCF_SRF: - (str - strc)
    ; LWCF_SRF: (rlusc - rldsc) - (rlus - rlds)
    if (isfilevar(f2, "str").and.isfilevar(f2, "strc")) then
      var2                          = f2->str
      var2                          = f2->str - f2->strc
    else if (isfilevar(f2, "rlds").and.isfilevar(f2, "rlus").and.\
             isfilevar(f2, "rldsc").and.isfilevar(f2, "rlusc")) then
      var2                          = f2->rlds
      var2                          = -(f2->rlus - f2->rlds) + (f2->rlusc - f2->rldsc)
    else
      print(ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."NETCF_SRF") then
    ;NETCF_SRF: fsns - fsnsc + flnsc - flns
    ;NETCF_SRF: ssr  - ssrc  + strc - str
    ;NETCF_SRF: (rsds - rsus) - (rsdsc - rsusc) + (rlusc - rldsc) - (rlus - rlds) 
    if (isfilevar(f2, "ssr").and.isfilevar(f2, "ssrc").and.\
        isfilevar(f2, "str").and.isfilevar(f2, "strc")) then
      var2                          =  f2->ssr
      var2                          = (f2->ssr - f2->ssrc)+(-f2->str + f2->strc)
    else if (isfilevar(f2, "rsds").and.isfilevar(f2, "rsus").and. \
             isfilevar(f2, "rsusc").and.isfilevar(f2, "rsdsc").and. \
             isfilevar(f2, "rlus").and.isfilevar(f2,  "rlds").and. \
             isfilevar(f2, "rlusc").and.isfilevar(f2, "rldsc")) then
      var2                          = f2->rlds
      var2                          = (f2->rsds - f2->rsus) - (f2->rsdsc - f2->rsusc) \
                                    - (f2->rlus - f2->rlds) + (f2->rlusc - f2->rldsc)
    else
      print(ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."NET_FLUX_SRF") then
    ;net fluxes at surface: fsns - flns - lhflx - shflx
    ;net fluxes at surface: rsds - rsus + (rlds - rlus) - hfls - hfss
    ;net fluxes at surface: ssrd - (ssrd-ssr) + strd - (strd-str) - (- slhf) - (-sshf)
    ;                      = ssr + str + slhf + sshf 
    if (isfilevar(f2, "ssr").and.isfilevar(f2, "str").and. \
        isfilevar(f2, "slhf").and.isfilevar(f2, "sshf")) then
      var2                          = f2->ssr
      var2                          = f2->ssr + f2->str + f2->slhf + f2->sshf

    else if (isfilevar(f2, "rsds").and.isfilevar(f2, "rsus").and.   \
             isfilevar(f2, "rlds").and.isfilevar(f2, "rlus").and. \
             isfilevar(f2, "lhtfl").and.isfilevar(f2, "shtfl")) then
      var2                          = f2->rsds
      var2                          = (f2->rsds - f2->rsus) + (f2->rlds - f2->rlus) \
                                     - (f2->lhtfl + f2->shtfl) 
    else
      print(ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."RESSURF") then
   ;;ERA5 reanalysis ignore the small downward long-wave (non-solar)
   ;;(i.e. the dowanwelling longwave fluxes at TOP is zero), thus,
   ;;TTR represents the negative of outgoing longwave radiation
   ;;RESTOM = FSNT - FLNT  = TSR - (-TTR) = TSR + TTR
   ;;       = (rsdt - rsut) - (rlut - rldt)
    if (isfilevar(f2, "ssr").and.isfilevar(f2, "str").and. \
        isfilevar(f2, "slhf").and.isfilevar(f2, "sshf")) then

      lvap = 2.501e6
      lice = 3.337e5
      lsub = lvap + lice ; sublimation
      tmp1                          = -lsub * f2->mer - \
                                       lice * ( f2->mcpr + f2->mlspr \
                                              - f2->mcsr  - f2->mlssr )
      var2                          = f2->ssr
      var2                          = f2->ssr + f2->str \
                                      + f2->sshf - 86400*tmp1
      delete([/tmp1/])

    else if (isfilevar(f2, "rsds").and.isfilevar(f2, "rsus").and.   \
             isfilevar(f2, "rlds").and.isfilevar(f2, "rlus").and. \
             isfilevar(f2, "lhtfl").and.isfilevar(f2, "shtfl") ) then 
      var2                          = f2->rsds
      var2                          = (f2->rsds - f2->rsus) + (f2->rlds - f2->rlus) \
                                    - (f2->lhtfl + f2->shtfl)
    else
      print( ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."RESTOM") then

   ;;ERA5 reanalysis ignore the small downward long-wave (non-solar) 
   ;;(i.e. the dowanwelling longwave fluxes at TOP is zero), thus, 
   ;;TTR represents the negative of outgoing longwave radiation 
   ;;RESTOM = FSNT - FLNT  = TSR - (-TTR) = TSR + TTR
   ;;       = (rsdt - rsut) - (rlut - rldt) 
    if (isfilevar(f2, "ttr") .and. isfilevar(f2, "tsr") ) then
      var2                          = f2->ttr
      var2                          = f2->ttr + f2->tsr
    else if (isfilevar(f2, "rsdt") .and. isfilevar(f2, "rsut") .and. isfilevar(f2, "rlut") )
      var2                          = f2->rsdt
      var2                          = (f2->rsdt - f2->rsut) - f2->rlut
    else
      print( ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."RESTOA") then
   ;; same as RSTOM
    if (isfilevar(f2, "ttr").and.isfilevar(f2, "tsr")) then
      var2                          = f2->ttr
      var2                          = f2->ttr + f2->tsr
    else if (isfilevar(f2, "rsdt") .and. isfilevar(f2, "rsut") .and. isfilevar(f2, "rlut") )
      var2                          = f2->rsdt
      var2                          = (f2->rsdt - f2->rsut) - f2->rlut
    else
      print(ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."ALBEDOC") then
   ;; ALBEDOC: (SOLIN - FSNTOAC) / SOLIN
   ;; AlBEDOC: rsutc/rsdt = (tisr-tsrc)/ tisr 
    if (isfilevar(f2, "tisr").and.isfilevar(f2, "tsrc")) then
      var2                          = f2->tisr
      tmp2                          = where(var2.eq.0.0,-9999.0,var2)
      tmp2@_FillValue               = -9999.9
      var2                          = (tmp2 - f2->tsrc) / tmp2
      delete([/tmp2/])
    else if (isfilevar(f2, "rsdt").and.isfilevar(f2, "rsutc")) then
      var2                          = f2->rsdt
      tmp2                          = where(var2.eq.0.0,-9999.0,var2)
      tmp2@_FillValue               = -9999.9
      var2                          = f2->rsutc / tmp2
      delete([/tmp2/])
    else
      print(ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."ALBEDO") then
   ;; ALBEDO: (SOLIN - FSNTOA) / SOLIN
   ;; AlBEDO: rsut/rsdt = (tisr-tsr)/ tisr
    if (isfilevar(f2, "tisr").and.isfilevar(f2, "tsr")) then
      var2                          = f2->tisr
      tmp2                          = where(var2.eq.0.0,-9999.0,var2)
      tmp2@_FillValue               = -9999.9
      var2                          = (tmp2 - f2->tsr) / tmp2
      delete([/tmp2/]) 
    else if (isfilevar(f2, "rsdt").and.isfilevar(f2, "rsut")) then
      var2                          = f2->rsdt
      tmp2                          = where(var2.eq.0.0,-9999.0,var2)
      tmp2@_FillValue               = -9999.9
      var2                          = (f2->rsut) / tmp2
      delete([/tmp2/])
    else
      print(ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else if (ovarnam.eq."ALBEDO_SRF") then
   ;; ALBEDO_SRF: (FSDS - FSNS) / FSDS
   ;; AlBEDO_SRF: rsus/rsds = (ssrd-ssr)/ ssrd
    if (isfilevar(f2, "ssrd").and.isfilevar(f2, "ssr")) then
      var2                          = f2->ssrd
      tmp2                          = where(var2.eq.0.0,-9999.0,var2)
      tmp2@_FillValue               = -9999.9
      var2                          = (tmp2 - f2->ssr) / tmp2
      delete([/tmp2/])
    else if (isfilevar(f2, "rsds").and.isfilevar(f2, "rsus")) then
      var2                          = f2->rsds
      tmp2                          = where(var2.eq.0.0,-9999.0,var2)
      tmp2@_FillValue               = -9999.9
      var2                          = f2->rsus / tmp2
      delete([/tmp2/])
    else
      print(ovarnam + " does not exist in the file, using missing values" )
      var2                          = var1
      var2                          = -9999.0
    end if
    end if

  else

    print(ovarnam + " does not exist in the file, using missing values" )
    var2                            = var1
    var2                            = -9999.0

  end if 

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if

  end if
  
  end if 

  end if 

  end if 
  
  end if 
 
  end if 
