;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;This script used to process CMIP6 data ;;;;;;
;rlut   = FSNTOA - FSNT + FLNT
;rlutcs = FLUTC
;rlds   = FLDS
;rldscs = FLDS + FLNS - FLNSC
;rsds   = FSDS
;rsdscs = FSDSC
;rsus   = FSDS - FSNS
;rsuscs = FSDSC - FSNSC
;rlus   = FLDS + FLNS
;rsdt   = SOLIN
;rsut   = FSUTOA
;rsutcs = FSUTOAC
;rtmt   = FSNT - FLNT
;rtmt   = rsdt - rsut - rlut
;ta = T, ua = U, va = V, wap = OMEGA, zg = Z3, pfull = P0*hyam + PS*hybm
;hus = Q, o3 = O3, hus = Q, hur = RELHUM, clwvi = TGCLDCWP,  clw = CLDLIQ
;clivi = TGCLDIWP, cli = CLDICE, cl = CLOUD *100.0, hfss = SHFLX, hfls = LHFLX
;clt = CLDTOT * 100.0, tauv =- TAUY, tauu = -TAUX, evspsbl = QFLX, prc = PRECC * 1000.0
;prsn = (PRECSC + PRECSL) * 1000.0, pr = (PRECC  + PRECL) * 1000.0 
;huss = QREFHT, sfcWind = U10 (speed), ps = PS, ts = TS	, psl = PSL, tas = TREFHT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./function.ncl"

begin

  outdir    = "/global/cfs/cdirs/e3sm/zhan391/data/CVDP_RGD/"
  data_dir  = "/global/cfs/projectdirs/m3522/cmip6/CMIP6/CMIP/NCAR/CESM2/historical"
  exp_name  = (/"cesm2.cmip6.historical"/)
  nexps     = dimsizes(exp_name)

  ystr      = 197901
  yend      = 201412
  time_tag  = ystr+"-"+yend
  grid_tag  = "1x1"

  seasons   = (/"MON"/) 
  nseas     = dimsizes(seasons)
  d2r       = get_d2r("float")

 ;define regions for eof analysis
  latS       = -90.  ;negative for southern hemisphere
  latN       =  90.  ;negative for southern hemisphere
  lonW       =  0.0
  lonE       = 360.0

  fili    = "./share_var_info.txt"
  dstr    = asciiread(fili, -1, "string")
  delim   = ","
  varList = str_squeeze(str_get_field(dstr, 1, delim))
  untList = str_squeeze(str_get_field(dstr, 2, delim))
  facList = stringtofloat(str_get_field(dstr, 3, delim))
  nvars = dimsizes(varList)

  do k  = 0,nexps-1,1

  do j =  0,1 ;nvars-1,1

   vars   = varList(j)
   varunt = untList(j)
   facmod = facList(j)

    if(vars.eq."PSL") then
      xtmp = read_cmip6_ensemble(ystr,yend,"psl",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if(vars.eq."Z500") then
      xtmp = read_cmip6_ensemble(ystr,yend,"zg",data_dir,"time_lev_lat_lon",exp_name(k))
      lev  = xtmp&lev
      if(max(lev).gt.10000) then 
        indx = ind(lev.eq.50000)
      else
        indx = ind(lev.eq.500)
      end if 
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
      delete([/indx,lev/])
    else if (vars.eq."T850") then
      xtmp = read_cmip6_ensemble(ystr,yend,"ta",data_dir,"time_lev_lat_lon",exp_name(k))
      lev  = xtmp&lev
      if(max(lev).gt.10000) then
        indx = ind(lev.eq.85000)
      else
        indx = ind(lev.eq.850)
      end if
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
      delete([/indx,lev/])
    else if (vars.eq."U850") then
      xtmp = read_cmip6_ensemble(ystr,yend,"ua",data_dir,"time_lev_lat_lon",exp_name(k))
      lev  = xtmp&lev
      if(max(lev).gt.10000) then
        indx = ind(lev.eq.85000)
      else
        indx = ind(lev.eq.850)
      end if
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
      delete([/indx,lev/])
    else if (vars.eq."V850") then
      xtmp = read_cmip6_ensemble(ystr,yend,"va",data_dir,"time_lev_lat_lon",exp_name(k))
      lev  = xtmp&lev
      if(max(lev).gt.10000) then
        indx = ind(lev.eq.85000)
      else
        indx = ind(lev.eq.850)
      end if
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
      delete([/indx,lev/])
    else if (vars.eq."U200") then
      xtmp = read_cmip6_ensemble(ystr,yend,"ua",data_dir,"time_lev_lat_lon",exp_name(k))
      lev  = xtmp&lev
      if(max(lev).gt.10000) then
        indx = ind(lev.eq.20000)
      else
        indx = ind(lev.eq.200)
      end if
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
      delete([/indx,lev/])
    else if (vars.eq."V200") then
      xtmp = read_cmip6_ensemble(ystr,yend,"va",data_dir,"time_lev_lat_lon",exp_name(k))
      lev  = xtmp&lev
      if(max(lev).gt.10000) then
        indx = ind(lev.eq.20000)
      else
        indx = ind(lev.eq.200)
      end if
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
      delete([/indx,lev/])
    else if (vars.eq."PRECT") then
      xtmp = read_cmip6_ensemble(ystr,yend,"pr",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE}) 
      var0 = var0 * 1e-3 
    else if (vars.eq."PRECST") then
      xtmp = read_cmip6_ensemble(ystr,yend,"prsn",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0 = var0 * 1e-3
    else if (vars.eq."PRECC") then
      xtmp = read_cmip6_ensemble(ystr,yend,"prc",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0 = var0 * 1e-3
    else if (vars.eq."PSL") then
      xtmp = read_cmip6_ensemble(ystr,yend,"psl",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."PS") then
      xtmp = read_cmip6_ensemble(ystr,yend,"ps",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."TS") then
      xtmp = read_cmip6_ensemble(ystr,yend,"ts",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."TREFHT") then
      xtmp = read_cmip6_ensemble(ystr,yend,"tas",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."TMQ") then
      xtmp = read_cmip6_ensemble(ystr,yend,"prw",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."QREFHT") then
      xtmp = read_cmip6_ensemble(ystr,yend,"huss",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."TAUX") then
      xtmp = read_cmip6_ensemble(ystr,yend,"tauu",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE}) * -1.0 
    else if (vars.eq."TAUY") then
      xtmp = read_cmip6_ensemble(ystr,yend,"tauv",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE}) * -1.0 
    else if (vars.eq."CLDTOT") then
      xtmp = read_cmip6_ensemble(ystr,yend,"clt",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0 = var0 * 0.01
    else if (vars.eq."LHFLX") then
      xtmp = read_cmip6_ensemble(ystr,yend,"hfls",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."SHFLX") then
      xtmp = read_cmip6_ensemble(ystr,yend,"hfss",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."QFLX") then
      xtmp = read_cmip6_ensemble(ystr,yend,"evspsbl",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."TGCLDIWP") then 
      xtmp = read_cmip6_ensemble(ystr,yend,"clivi",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."TGCLDCWP") then
      xtmp = read_cmip6_ensemble(ystr,yend,"clwvi",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."TGCLDLWP") then
      xtmp = read_cmip6_ensemble(ystr,yend,"clwvi",data_dir,"time_lat_lon",exp_name(k))
      iwp  = read_cmip6_ensemble(ystr,yend,"clivi",data_dir,"time_lat_lon",exp_name(k))
      xtmp = xtmp - iwp 
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."O3") then
      xtmp = read_cmip6_ensemble(ystr,yend,"o3",data_dir,"time_lev_lat_lon",exp_name(k))
      var0 = xtmp(:,:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."OMEGA500") then
      xtmp = read_cmip6_ensemble(ystr,yend,"wap",data_dir,"time_lev_lat_lon",exp_name(k))
      lev  = xtmp&lev
      if(max(lev).gt.10000) then
        indx = ind(lev.eq.50000)
      else
        indx = ind(lev.eq.500)
      end if
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
      delete([/indx,lev/])
    else if (vars.eq."FSNS") then
      rsds   = read_cmip6_ensemble(ystr,yend,"rsds",data_dir,"time_lat_lon",exp_name(k))
      rsus   = read_cmip6_ensemble(ystr,yend,"rsus",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsds
      xtmp   = (rsds - rsus) 
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface radiative fluxes (SW) at full-sky (downward - upward)"
      delete([/rsds,rsus/])
    else if (vars.eq."FSNSC") then
      rsdscs = read_cmip6_ensemble(ystr,yend,"rsdscs",data_dir,"time_lat_lon",exp_name(k))
      rsuscs = read_cmip6_ensemble(ystr,yend,"rsuscs",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsdscs
      xtmp   = (rsdscs - rsuscs)
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface radiative fluxes (SW) at clear-sky (downward - upward)"
      delete([/rsdscs,rsuscs/])
    else if (vars.eq."FLNS") then
      rlds   = read_cmip6_ensemble(ystr,yend,"rlds",data_dir,"time_lat_lon",exp_name(k))
      rlus   = read_cmip6_ensemble(ystr,yend,"rlus",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rlds
      xtmp   = (rlus - rlds) 
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface radiative fluxes (LW) at full-sky (downward - upward)"
      delete([/rlds,rlus/])
    else if (vars.eq."FLNSC") then
      rldscs = read_cmip6_ensemble(ystr,yend,"rldscs",data_dir,"time_lat_lon",exp_name(k))
      rlus   = read_cmip6_ensemble(ystr,yend,"rlus",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rldscs 
      xtmp   = (rlus - rldscs)
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface radiative fluxes (LW) at clear-sky (downward - upward)"
      delete([/rldscs,rlus/])
    else if (vars.eq."SWCRE_SRF") then
      rsds   = read_cmip6_ensemble(ystr,yend,"rsds",data_dir,"time_lat_lon",exp_name(k))
      rsdscs = read_cmip6_ensemble(ystr,yend,"rsdscs",data_dir,"time_lat_lon",exp_name(k))
      rsus   = read_cmip6_ensemble(ystr,yend,"rsus",data_dir,"time_lat_lon",exp_name(k))
      rsuscs = read_cmip6_ensemble(ystr,yend,"rsuscs",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsds
      xtmp   = (rsds - rsus) - (rsdscs - rsuscs) 
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface cloud radiative effects (SW) (downward - upward)"
      delete([/rsds,rsdscs,rsus,rsuscs/])
    else if (vars.eq."LWCRE_SRF") then
      rlds   = read_cmip6_ensemble(ystr,yend,"rlds",data_dir,"time_lat_lon",exp_name(k))
      rldscs = read_cmip6_ensemble(ystr,yend,"rldscs",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rlds 
      xtmp   = rlds - rldscs
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface cloud radiative effects (LW) (downward - upward)" 
      delete([/rlds,rldscs/])
    else if (vars.eq."CRE_SRF") then
      rsds   = read_cmip6_ensemble(ystr,yend,"rsds",data_dir,"time_lat_lon",exp_name(k))
      rsdscs = read_cmip6_ensemble(ystr,yend,"rsdscs",data_dir,"time_lat_lon",exp_name(k))
      rsus   = read_cmip6_ensemble(ystr,yend,"rsus",data_dir,"time_lat_lon",exp_name(k))
      rsuscs = read_cmip6_ensemble(ystr,yend,"rsuscs",data_dir,"time_lat_lon",exp_name(k))
      rlds   = read_cmip6_ensemble(ystr,yend,"rlds",data_dir,"time_lat_lon",exp_name(k))
      rldscs = read_cmip6_ensemble(ystr,yend,"rldscs",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsds
      xtmp   = (rsds - rsus) - (rsdscs - rsuscs) \
              + (rlds - rldscs)
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Surface cloud radiative effects (downward - upward)"
      delete([/rsds,rsdscs,rsus,rsuscs,rlds,rldscs/])
    else if (vars.eq."CRE") then
      ;LWCF = - (flutc - flut)
      ;SWCF = (fsntoa - fsntoac)
      ;fsutoac = solin - fsntoac
      ;fsntoac = rsdt - rsutcs
      ;fsntoa  = rsut
      ;flutc   = rlutcs
      ;flut    = FSNTOA - FSNT + FLNT
      rsdt   = read_cmip6_ensemble(ystr,yend,"rsdt",data_dir,"time_lat_lon",exp_name(k))
      rsut   = read_cmip6_ensemble(ystr,yend,"rsut",data_dir,"time_lat_lon",exp_name(k))
      rsutcs = read_cmip6_ensemble(ystr,yend,"rsutcs",data_dir,"time_lat_lon",exp_name(k))
      rlut   = read_cmip6_ensemble(ystr,yend,"rlut",data_dir,"time_lat_lon",exp_name(k))
      rlutcs = read_cmip6_ensemble(ystr,yend,"rlutcs",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsut
      xtmp   = (rsdt - rsut) - (rsdt - rsutcs) \
              + (rlut - rlutcs)
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "TOA cloud radiative effects  (upward - downward)"
      delete([/rsdt,rsut,rsutcs,rlut,rlutcs/])
    else if (vars.eq."SWCRE") then
      rsdt   = read_cmip6_ensemble(ystr,yend,"rsdt",data_dir,"time_lat_lon",exp_name(k))
      rsut   = read_cmip6_ensemble(ystr,yend,"rsut",data_dir,"time_lat_lon",exp_name(k))
      rsutcs = read_cmip6_ensemble(ystr,yend,"rsutcs",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsut
      xtmp   = (rsdt - rsut) - (rsdt - rsutcs)
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "TOA cloud radiative effects (SW)"
      delete([/rsdt,rsut,rsutcs/])
    else if (vars.eq."LWCRE") then
      rlut   = read_cmip6_ensemble(ystr,yend,"rlut",data_dir,"time_lat_lon",exp_name(k))
      rlutcs = read_cmip6_ensemble(ystr,yend,"rlutcs",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rlut 
      xtmp   = rlut - rlutcs 
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "TOA cloud radiative effects (LW)"
      delete([/rlut,rlutcs/])
    else if (vars.eq."RESSURF") then
      rsds   = read_cmip6_ensemble(ystr,yend,"rsds",data_dir,"time_lat_lon",exp_name(k))
      rsus   = read_cmip6_ensemble(ystr,yend,"rsus",data_dir,"time_lat_lon",exp_name(k))
      rlds   = read_cmip6_ensemble(ystr,yend,"rlds",data_dir,"time_lat_lon",exp_name(k))
      rlus   = read_cmip6_ensemble(ystr,yend,"rlus",data_dir,"time_lat_lon",exp_name(k))
      lhflx  = read_cmip6_ensemble(ystr,yend,"hfls",data_dir,"time_lat_lon",exp_name(k)) 
      shflx  = read_cmip6_ensemble(ystr,yend,"hfss",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsds
      xtmp   = (rsds - rsus) + (rlds - rlus)\
              - lhflx - shflx 
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      delete([/rsds,rsus,rldx,rlus,lhflx,shflx/])
    else if (vars.eq."QnRad_SRF") then
      rsds   = read_cmip6_ensemble(ystr,yend,"rsds",data_dir,"time_lat_lon",exp_name(k))
      rsus   = read_cmip6_ensemble(ystr,yend,"rsus",data_dir,"time_lat_lon",exp_name(k))
      rlds   = read_cmip6_ensemble(ystr,yend,"rlds",data_dir,"time_lat_lon",exp_name(k))
      rlus   = read_cmip6_ensemble(ystr,yend,"rlus",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsds
      xtmp   = (rsds - rsus) + (rlds - rlus) 
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Total surface radiative fluxes (positive down)"
      delete([/rsds,rsus,rlds,rlus/])
    else if(vars.eq."QnTur_SRF") then
      lhflx  = read_cmip6_ensemble(ystr,yend,"hfls",data_dir,"time_lat_lon",exp_name(k))
      shflx  = read_cmip6_ensemble(ystr,yend,"hfss",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = lhflx
      xtmp   = -lhflx - shflx 
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Total surface turbulent fluxes (positive down)"
      delete([/lhflx,shflx/])
    else if (vars.eq."QnTot_SRF") then
      rsds   = read_cmip6_ensemble(ystr,yend,"rsds",data_dir,"time_lat_lon",exp_name(k))
      rsus   = read_cmip6_ensemble(ystr,yend,"rsus",data_dir,"time_lat_lon",exp_name(k))
      rlds   = read_cmip6_ensemble(ystr,yend,"rlds",data_dir,"time_lat_lon",exp_name(k))
      rlus   = read_cmip6_ensemble(ystr,yend,"rlus",data_dir,"time_lat_lon",exp_name(k))
      lhflx  = read_cmip6_ensemble(ystr,yend,"hfls",data_dir,"time_lat_lon",exp_name(k))
      shflx  = read_cmip6_ensemble(ystr,yend,"hfss",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsds
      xtmp   = (rsds - rsus) + (rlds - rlus)\
              - lhflx - shflx
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Net surface total fluxes (positive down)"
      delete([/rsds,rsus,rlds,rlus,lhflx,shflx/])
    else if(vars.eq."Qn_SRF") then
      rsds   = read_cmip6_ensemble(ystr,yend,"rsds",data_dir,"time_lat_lon",exp_name(k))
      rsus   = read_cmip6_ensemble(ystr,yend,"rsus",data_dir,"time_lat_lon",exp_name(k))
      rlds   = read_cmip6_ensemble(ystr,yend,"rlds",data_dir,"time_lat_lon",exp_name(k))
      rlus   = read_cmip6_ensemble(ystr,yend,"rlus",data_dir,"time_lat_lon",exp_name(k))
      lhflx  = read_cmip6_ensemble(ystr,yend,"hfls",data_dir,"time_lat_lon",exp_name(k))
      shflx  = read_cmip6_ensemble(ystr,yend,"hfss",data_dir,"time_lat_lon",exp_name(k))
      beta   = rsds 
      beta   = where(rsds.eq.0,beta@_FillValue,beta)
      beta   = rsus/beta
      xtmp   = rsds 
      xtmp   = (1.0 - beta) * rsds + rlds - rlus \
              - lhflx - shflx
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Net surface total fluxes (positive down)"
      delete([/rsds,rsus,rlds,rlus,lhflx,shflx,beta/])
    else if (vars.eq."RESTOA") then
      xtmp = read_cmip6_ensemble(ystr,yend,"rtmt",data_dir,"time_lat_lon",exp_name(k))
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
    else if (vars.eq."S10") then
      ua   = read_cmip6_ensemble(ystr,yend,"ua",data_dir,"time_lev_lat_lon",exp_name(k))
      va   = read_cmip6_ensemble(ystr,yend,"va",data_dir,"time_lev_lat_lon",exp_name(k))
      xtmp = ua
      xtmp = sqrt(ua*ua + va*va) 
      lev  = ua&lev
      indx = maxind(lev)
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
     ;xtmp = read_cmip6_ensemble(ystr,yend,"sfcWind",data_dir,"time_lat_lon",exp_name(k))
     ;var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      delete([/ua,va,indx,lev/])
    else if (vars.eq."U10") then
      xtmp = read_cmip6_ensemble(ystr,yend,"ua",data_dir,"time_lev_lat_lon",exp_name(k))
      lev  = xtmp&lev
      indx = maxind(lev)
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
      delete([/indx,lev/])
    else if (vars.eq."V10") then
      xtmp = read_cmip6_ensemble(ystr,yend,"va",data_dir,"time_lev_lat_lon",exp_name(k))
      lev  = xtmp&lev
      indx = maxind(lev)
      var0 = xtmp(:,:,indx,{latS:latN},{lonW:lonE})
      delete([/indx,lev/])
    else if (vars.eq."ETH1".or. vars.eq."ETH2".or.vars.eq."ETH12") then
      sst  = read_cmip6_ensemble(ystr,yend,"ts",data_dir,"time_lat_lon",exp_name(k))
      taux = read_cmip6_ensemble(ystr,yend,"tauu",data_dir,"time_lat_lon",exp_name(k))
      tauy = read_cmip6_ensemble(ystr,yend,"tauv",data_dir,"time_lat_lon",exp_name(k))
      xtmp = sst 
      dimx = dimsizes(xtmp)
      nens = dimx(0)
      do ii = 0,nens-1,1
        fcor  = coriolis_param(tofloat(sst&lat)); coriolis parm (1/s)
        cpair = 1005.0   ; heat capacity of air (J/kg/K)
        cp_sw = 3.996e3  ; specific heat salt water(J/kg/C)
        rho_sw= 1026.0   ; kg/m3
        tztmp = sst(ii,:,:,:)    ; surface temperature (K)
        tztmp = tztmp - 273.15 ; convert to C
        txtmp = taux(ii,:,:,:)  ; zonal surface stress (N/m2)
        tytmp = tauy(ii,:,:,:)  ; meridional surface stress (N/m2)
        tzclm = clmMonTLL (tztmp)
        txclm = clmMonTLL (txtmp)
        tyclm = clmMonTLL (tytmp)
        tzanm = calcMonAnomTLL(tztmp,tzclm)
        txanm = calcMonAnomTLL(txtmp,txclm)
        tyanm = calcMonAnomTLL(tytmp,tyclm)
        if(vars.eq."ETH12") then
          gradLatLon = grad_latlon_cfd (tztmp, tztmp&lat, tztmp&lon, True, False)
          dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'
          dzdx  = tofloat(gradLatLon[1])
          xtmp(ii,:,:,:)  = -cp_sw/conform(tztmp,fcor,1) * (dzdx*tytmp - dzdy*txtmp) 
          xtmp@long_name = "Full Ekman heat transport (ETH) anomaly"
          xtmp@units     = "W m~S~-2~N~"
          delete([/gradLatLon,dzdy,dzdx/])
        end if
        if(vars.eq."ETH1") then
          gradLatLon = grad_latlon_cfd (tzclm, tzclm&lat, tzclm&lon, True, False)
          dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'
          dzdx  = tofloat(gradLatLon[1])
          dimx1 = dimsizes(tztmp)
          ny    = dimx1(0)/12
          ytmp  = -cp_sw/conform(tztmp,fcor,1)
          do iy = 0,ny-1
            iy1 = iy*12
            iy2 = (iy+1)*12-1
            xtmp(ii,iy1:iy2,:,:) = ytmp(iy1:iy2,:,:) \
                                  *(dzdx(:,:,:)*tyanm(iy1:iy2,:,:) - dzdy(:,:,:)*txanm(iy1:iy2,:,:))
          end do
          xtmp@long_name = "ETH anomaly: anomalous winds acting on clim SST gradient"
          xtmp@units     = "W m~S~-2~N~"
          delete([/dimx1,ny,gradLatLon,dzdy,dzdx,ytmp/])
        end if
        if(vars.eq."ETH2") then
          gradLatLon = grad_latlon_cfd (tzanm, tzanm&lat, tzanm&lon, True, False)
          dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'
          dzdx  = tofloat(gradLatLon[1])
          dimx1 = dimsizes(tztmp)
          ny    = dimx1(0)/12
          ytmp  = -cp_sw/conform(tztmp,fcor,1)
          do iy = 0,ny-1
            iy1 = iy*12
            iy2 = (iy+1)*12-1
             xtmp(ii,iy1:iy2,:,:) = ytmp(iy1:iy2,:,:) \
                                *(dzdx(iy1:iy2,:,:)*tyclm(:,:,:) - dzdy(iy1:iy2,:,:)*txclm(:,:,:))
          end do
          xtmp@long_name = "ETH anomaly: clim winds acting on anomalous SST gradient"
          xtmp@units     = "W m~S~-2~N~"
          delete([/dimx1,ny,gradLatLon,dzdy,dzdx,ytmp/])
        end if
      end do 
      var0 = xtmp(:,:,{latS:latN},{lonW:lonE})
      delete([/fcor,cpair,cp_sw,rho_sw,tztmp,txtmp,tytmp,tzclm,txclm,tyclm,tzanm,txanm,tyanm/])
      delete([/sst,taux,tauy,dimx/])
    else if (vars.eq."FLDSC") then
      rldscs = read_cmip6_ensemble(ystr,yend,"rldscs",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rldscs
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Downward longwave radiative (clear-sky) effects at surface"
      delete([/rldscs/])
    else if (vars.eq."FLDS") then
      rlds   = read_cmip6_ensemble(ystr,yend,"rlds",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rlds
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Downward longwave radiative effects at surface"
      delete([/rlds/])
    else if (vars.eq."FSDSC") then
      rsdscs = read_cmip6_ensemble(ystr,yend,"rsdscs",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsdscs
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Downward shortwave radiative (clear-sky) effects at surface"
      delete([/rsdscs/])
    else if (vars.eq."FSDS") then
      rsds   = read_cmip6_ensemble(ystr,yend,"rsds",data_dir,"time_lat_lon",exp_name(k))
      xtmp   = rsds
      var0   = xtmp(:,:,{latS:latN},{lonW:lonE})
      var0@long_name = "Downward shortwave radiative effects at surface"
      delete([/rsds/])
    else if (vars.eq."VP470") then
     lev = f1->lev
     if(max(lev).gt.10000) then
       lev       = lev / 100.0
       lev@units = "hPa"
       lev&lev   = lev
     end if
     wgt_dp   = dpres_plevel_Wrap(lev, f1->PS/100.0, min(lev), 0)
     sfvp     = uv2sfvpF(f1->U,f1->V)
     vp       = f1->U
     vp       = (/sfvp(1,:,:,:,:)/)
     vp&lev   = lev
     vp@units = "kg s~S~-1~N~"
     xtmp     = dim_avg_wgt_n_Wrap(vp(:,{700:400},:,:),wgt_dp({700:400}),1,1)
     var0     = xtmp(indy,{latS:latN},{lonW:lonE})
     delete([/wgt_dp,lev,sfvp,vp/])
    else if (vars.eq."VP920") then
     lev = f1->lev
     if(max(lev).gt.10000) then
       lev       = lev / 100.0
       lev@units = "hPa"
       lev&lev   = lev
     end if
     wgt_dp   = dpres_plevel_Wrap(lev, f1->PS/100.0, min(lev), 0)
     sfvp     = uv2sfvpF(f1->U,f1->V)
     vp       = f1->U
     vp       = (/sfvp(1,:,:,:,:)/)
     vp&lev   = lev
     vp@units = "kg s~S~-1~N~"
     xtmp     = dim_avg_wgt_n_Wrap(vp(:,{900:200},:,:),wgt_dp({900:200}),1,1)
     var0     = xtmp(indy,{latS:latN},{lonW:lonE})
     delete([/wgt_dp,lev,sfvp,vp/])
    else if (vars.eq."SF470") then
     lev = f1->lev
     if(max(lev).gt.10000) then
       lev       = lev / 100.0
       lev@units = "hPa"
       lev&lev   = lev
     end if
     wgt_dp   = dpres_plevel_Wrap(lev, f1->PS/100.0, min(lev), 0)
     sfvp     = uv2sfvpF(f1->U,f1->V)
     sf       = f1->U
     sf       = (/sfvp(0,:,:,:,:)/)
     sf&lev   = lev
     sf@units = "kg s~S~-1~N~"
     xtmp     = dim_avg_wgt_n_Wrap(sf(:,{700:400},:,:),wgt_dp({700:400}),1,1)
     var0     = xtmp(indy,{latS:latN},{lonW:lonE})
     delete([/wgt_dp,lev,sfvp,sf/])
    else if (vars.eq."SF920") then
     lev = f1->lev
     if(max(lev).gt.10000) then
       lev       = lev / 100.0
       lev@units = "hPa"
       lev&lev   = lev
     end if
     wgt_dp   = dpres_plevel_Wrap(lev, f1->PS/100.0, min(lev), 0)
     sfvp     = uv2sfvpF(f1->U,f1->V)
     sf       = f1->U
     sf       = (/sfvp(0,:,:,:,:)/)
     sf&lev   = lev
     sf@units = "kg s~S~-1~N~"
     xtmp     = dim_avg_wgt_n_Wrap(sf(:,{900:200},:,:),wgt_dp({900:200}),1,1)
     var0     = xtmp(indy,{latS:latN},{lonW:lonE})
     delete([/wgt_dp,lev,sfvp,sf/])
    else
      print("Variable " + vars + " does not in the CMIP6 pool, please check")
      exit
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

    dstFileName  = outdir+ "v2.LR.historical.en00.TREFHT.197901-201412.nc"
    vout = regrid_to_reference_grid(var0,exp_name,dstFileName) 
    printVarSummary(vout)

    dimx = dimsizes(vout)
    ike = 0 
    do iie = 0,dimx(0)-1,1

      vou1 = vout(iie,:,:,:)
      vou1            = vou1*facmod
      vou1@units      = varunt

     ;printVarSummary(vou1)
     ;printMinMax(vou1, True)
      setfileoption("nc", "Format",  "NetCDF4")

      if(.not.all(ismissing(vou1))) then 
        enstr     = "en"+sprinti("%02d",ike)
        out_file  = outdir+exp_name(k)+"."+enstr+"."+vars+"."+ystr+"-"+yend+".nc"
        system("rm " + out_file)
        fout = addfile(out_file,"cw")
        fout->$vars$  = vou1
        delete([/enstr,fout,vou1/])
        ike = ike + 1
      end if 

    end do 
    delete([/dimx,var0,vout,xtmp/])

   end do 

  end do 

end
