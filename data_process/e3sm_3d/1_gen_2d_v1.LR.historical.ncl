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
  data_dir  = "/global/cfs/projectdirs/m3522/cmip6/CMIP6/CMIP/E3SM-Project/E3SM-1-0/historical"
  exp_name  = (/"v1.LR.historical"/)
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

  do j =  0,nvars-1,1 

   vars   = varList(j)
   varunt = untList(j)
   facmod = facList(j)

    if(vars.eq."U") then
      xtmp = read_cmip6_ensemble(ystr,yend,"ua",data_dir,"time_lev_lat_lon",exp_name(k))
      var0 = xtmp(:,:,:,{latS:latN},{lonW:lonE}) 
    else if(vars.eq."T") then
      xtmp = read_cmip6_ensemble(ystr,yend,"ta",data_dir,"time_lev_lat_lon",exp_name(k))
      var0 = xtmp(:,:,:,{latS:latN},{lonW:lonE}) 
    else if (vars.eq."Q") then
      xtmp = read_cmip6_ensemble(ystr,yend,"hus",data_dir,"time_lev_lat_lon",exp_name(k))
      var0 = xtmp(:,:,:,{latS:latN},{lonW:lonE}) 
    else
      print("Variable " + vars + " does not in the CMIP6 pool, please check")
      exit
    end if
    end if
    end if

    dimx = dimsizes(var0)
    ike  = 0 
    do iie = 0,dimx(0)-1,1
      vou1       = var0(iie,:,:,:,:)
      vou1       = vou1*facmod
      vou1@units = varunt
      setfileoption("nc", "Format",  "NetCDF4")
      if(.not.all(ismissing(vou1))) then 
        dstFileName = outdir+ "v2.LR.historical.en00.TREFHT.197901-201412.nc"
        vout = regrid_to_reference_grid(vou1,exp_name,dstFileName)
        vavg = clmMonTLLL(vout)
        enstr    = "en"+sprinti("%02d",ike)
        out_file = outdir+exp_name(k)+"."+enstr+"."+vars+"."+ystr+"-"+yend+".nc"
        system("rm " + out_file)
        fout = addfile(out_file,"cw")
        fout->$vars$  = vavg
        delete([/enstr,fout,vou1,vavg,vout/])
        ike = ike + 1
      end if 
    end do 

    delete([/dimx,var0,xtmp/])

   end do 

  end do 

end
