;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;This script used to calculate and plot the zonal mean variables from CAM;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;The terms zonal and meridional are used to describe directions on a globe;;;;;;;
;;;;;;;Zonal means "along a latitudinal circle" or "in the west–east direction";;;;;;;;
;;;;;;;while meridional means "along a longitudinal circle" (a.k.a. meridian) ;;;;;;;;;
;;;;;;;or "in the north–south direction" [2];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  run_dir   = "/lcrc/group/e3sm/ac.forsyth2/E3SMv2/"
  out_dir   = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  data_dir  = "/lcrc/group/acme/ac.szhang/acme_scratch/data/CVDP_RGD"
  ensnum    = (/"en00"/)
  exp_name  = ensnum
  exp_name  = (/"v2_1.SORRM.p0.1950Control"/)
  out_name  = (/"v2_1.SORRM.p0.1950Control"/) 
  nexps     = dimsizes(exp_name)

  ystr      = (/050101/)
  yend      = (/070012/)
  time_tag  = (/sprinti("%06d",ystr)+"-"+sprinti("%06d",yend)/)
  ntags     = dimsizes(time_tag)
  grid_tag  = "1x1"

 ;define regions for eof analysis
  latS       = -90.  ;negative for southern hemisphere
  latN       =  90.  ;negative for southern hemisphere
  lonW       =  0.0
  lonE       = 360.0

  fili    = "./share_var_info_2d.txt"
  dstr    = asciiread(fili, -1, "string")
  delim   = ","
  varList = str_squeeze(str_get_field(dstr, 1, delim))
  untList = str_squeeze(str_get_field(dstr, 2, delim))
  facList = stringtofloat(str_get_field(dstr, 3, delim))
  nvars = dimsizes(varList)

  do k  = 0,nexps-1,1

   do j = 0,nvars-1,1

    vars   = varList(j)
    varunt = untList(j)
    facmod = facList(j)
    enstr  = ensnum(k)

    print("working on variable "+ vars)

    fl1      = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
    l_output = True 
    if (isfilepresent(fl1)) then 
      f1   = addfile(fl1,"r")
      if(isfilevar(f1,vars)) then 
        var0 = f1->$vars$
        if(.not.isatt(var0,"notes")) then
          var0 = var0 * facmod 
          var0@units = varunt
          var0@_FillValue = -9999.
          var0@notes = "modified: * " + facmod
        else 
          l_output = False 
        end if 
      end if 
    else if (vars.eq."PRECT") then
      v2d  = (/"PRECC","PRECL"/)
      do iv = 0,dimsizes(v2d)-1 
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then 
          var0 = f1->$vin$
        else
          var0 = var0 + f1->$vin$
        end if 
      end do 
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1/])
    else if (vars.eq."PRECST") then
      v2d  = (/"PRECSC","PRECSL"/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
        else
          var0 = var0 + f1->$vin$
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1/])
    else if (vars.eq."SWCF_SRF") then
      v2d  = (/"FSNS","FSNSC"/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
        else
          var0 = var0 - f1->$vin$
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1/])
    else if (vars.eq."LWCF_SRF") then
      v2d  = (/"FLNSC","FLNS"/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
        else
          var0 = var0 - f1->$vin$
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1/])
    else if (vars.eq."CRE_SRF") then
      v2d  = (/"FLNSC","FLNS","FSNS","FSNSC"/)
      vsg  = (/1.0,-1.0,1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "Surface cloud radiative effects"
      delete([/v2d,fl1,f1,vsg/])
    else if (vars.eq."SWCRE_SRF") then
      v2d  = (/"FSNS","FSNSC"/)
      vsg  = (/1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "Surface cloud radiative effects (SW)"
      delete([/v2d,fl1,f1,vsg/])
    else if (vars.eq."LWCRE_SRF") then
      v2d  = (/"FLNSC","FLNS"/)
      vsg  = (/1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else 
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do 
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "Surface cloud radiative effects (LW)"
      delete([/v2d,fl1,f1,vsg/])
    else if (vars.eq."CRE") then
      v2d  = (/"LWCF","SWCF"/)
      vsg  = (/1.0,1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else 
          var0 = var0 + f1->$vin$ * vsg(iv) 
        end if
      end do 
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "TOA cloud radiative effects"
      delete([/v2d,fl1,f1,vsg/])
    else if (vars.eq."SWCRE") then
      v2d  = (/"SWCF"/)
      vsg  = (/1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else 
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "TOA cloud radiative effects (SW)"
      delete([/v2d,fl1,f1,vsg/])
    else if (vars.eq."LWCRE") then
      v2d  = (/"LWCF"/)
      vsg  = (/1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv) 
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "TOA cloud radiative effects (LW)"
      delete([/v2d,fl1,f1,vsg/])
    else if (vars.eq."RESSURF") then
      v2d  = (/"FSNS","FLNS","SHFLX","LHFLX"/)
      vsg  = (/1.0,-1.0,-1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv) 
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "Surface net energy flux"
      delete([/v2d,fl1,f1,vsg/])
    else if (vars.eq."QnRad_SRF") then
      v2d  = (/"FSNS","FLNS"/)
      vsg  = (/1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv) 
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else 
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "Total surface radiative fluxes (positive down)"
      delete([/v2d,fl1,f1,vsg/])
    else if(vars.eq."QnTur_SRF") then
      v2d  = (/"LHFLX","SHFLX"/)
      vsg  = (/-1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv) 
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else 
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do 
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "Total surface turbulent fluxes (positive down)"
      delete([/v2d,fl1,f1,vsg/])
    else if(vars.eq."FLNTC") then
      fl1 = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
      if(isfilepresent(fl1)) then 
        print("FLNTC in model output:" + fl1)
        f1   = addfile(fl1,"r")
        var0 = f1->$vin$
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        delete([/fl1,f1/])
      else
        print("FLNTC not in model output:" + fl1)
        vin  = (/"FLUTC"/)
        delete(fl1)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        vtmp = f1->$vin$
        vtmp@_FillValue = -9999.
        var0       = vtmp
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        delete([/vtmp,vin,fl1,f1/])
      end if
    else if(vars.eq."FSNTC") then
      fl1 = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
      if(isfilepresent(fl1)) then
        print("FSNTC in model output:" + fl1)
        f1   = addfile(fl1,"r")
        var0 = f1->$vin$
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        delete([/fl1,f1/])
      else
        print("FSNTC not in model output:" + fl1)
        v2d  = (/"FSNTOAC"/)
        vsg  = (/1.0/)
        do iv = 0,dimsizes(v2d)-1
          vin  = v2d(iv)
          fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
          f1   = addfile(fl1,"r")
          if(iv.eq.0) then
            var0 = f1->$vin$
            var0 = var0 * vsg(iv)
          else
            var0 = var0 + f1->$vin$ * vsg(iv)
          end if
        end do
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        var0@long_name = "Total surface radiative fluxes (positive down)"
        delete([/v2d,fl1,f1,vsg/])
      end if
    else if(vars.eq."FSUTOA") then
      fl1 = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
      if(isfilepresent(fl1)) then
        print("FSUTOA in model output:" + fl1)
        f1   = addfile(fl1,"r")
        var0 = f1->$vin$
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        delete([/fl1,f1/])
      else
        print("FSUTOA not in model output:" + fl1)
        v2d  = (/"FSNTOA","SOLIN"/)
        vsg  = (/-1.0,1.0/)
        do iv = 0,dimsizes(v2d)-1
          vin  = v2d(iv)
          fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
          f1   = addfile(fl1,"r")
          if(iv.eq.0) then
            var0 = f1->$vin$
            var0 = var0 * vsg(iv)
          else
            var0 = var0 + f1->$vin$ * vsg(iv)
          end if
        end do
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        var0@long_name = "Total surface radiative fluxes (positive down)"
        delete([/v2d,fl1,f1,vsg/])
      end if
    else if(vars.eq."FSUTOAC") then
      fl1 = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
      if(isfilepresent(fl1)) then
        print("FSUTOAC in model output:" + fl1)
        f1   = addfile(fl1,"r")
        var0 = f1->$vin$
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        delete([/fl1,f1/])
      else
        print("FSUTOAC not in model output:" + fl1)
        v2d  = (/"FSNTOAC","SOLIN"/)
        vsg  = (/-1.0,1.0/)
        do iv = 0,dimsizes(v2d)-1
          vin  = v2d(iv)
          fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
          f1   = addfile(fl1,"r")
          if(iv.eq.0) then
            var0 = f1->$vin$ 
            var0 = var0 * vsg(iv)
          else
            var0 = var0 + f1->$vin$ * vsg(iv)
          end if
        end do
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        var0@long_name = "Total surface radiative fluxes (positive down)"
        delete([/v2d,fl1,f1,vsg/])
      end if
    else if(vars.eq."TGCLDIWP") then
      fl1 = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
      if(isfilepresent(fl1)) then
        print("TGCLDIWP in model output:" + fl1)
        f1   = addfile(fl1,"r")
        var0 = f1->$vin$
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        delete([/fl1,f1/])
      else
        print("TGCLDIWP not in model output:" + fl1)
        v2d  = (/"TGCLDLWP","TGCLDCWP"/)
        vsg  = (/-1.0,1.0/)
        do iv = 0,dimsizes(v2d)-1
          vin  = v2d(iv)
          fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
          if(isfilepresent(fl1)) then
            if(iv.eq.0) then
              var0 = f1->$vin$
              var0 = var0 * vsg(iv)
            else
              var0 = var0 + f1->$vin$ * vsg(iv)
            end if
          else 
            var0 = var0@_FillValue 
          end if 
        end do
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        var0@long_name = "Total surface radiative fluxes (positive down)"
        delete([/v2d,fl1,f1,vsg/])
      end if
    else if (vars.eq."LHFLX") then
      fl1 = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
      if(isfilepresent(fl1)) then 
        print("LHFLX in model output:" + fl1)
        f1   = addfile(fl1,"r")
        var0 = f1->$vin$
        var0@_FillValue = -9999.
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        delete([/fl1,f1/])
      else   
        print("LHFLX not in model output:" + fl1)
        vins  = (/"QFLX","PRECC","PRECL","PRECSC","PRECSL"/)
        delete(fl1)
        do ff = 0,dimsizes(vins)-1,1
          vin = vins(ff)
          fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
          f1   = addfile(fl1(0),"r")
          if(vin.eq."QFLX") then 
            qflx = f1->$vin$
          end if 
          if(vin.eq."PRECC") then
            precc = f1->$vin$
            if(precc@units.eq."mm/day".or.precc@units.eq."mm day~S~-1") then 
              precc = precc/ 86400. 
              precc@units = "kg/m2/s"
            end if 
          end if
          if(vin.eq."PRECL") then
            precl = f1->$vin$
            if(precl@units.eq."mm/day".or.precl@units.eq."mm day~S~-1") then
              precl = precl/ 86400.
              precl@units = "kg/m2/s"
            end if
          end if
          if(vin.eq."PRECSC") then
            precsc = f1->$vin$
            if(precsc@units.eq."mm/day".or.precsc@units.eq."mm day~S~-1") then
              precsc = precsc/ 86400.
              precsc@units = "kg/m2/s"
            end if
          end if
          if(vin.eq."PRECSL") then
            precsl = f1->$vin$
            if(precsl@units.eq."mm/day".or.precsl@units.eq."mm day~S~-1") then
              precsl = precsl/ 86400.
              precsl@units = "kg/m2/s"
            end if
          end if
        end do 
        qflx@_FillValue   = -9999.
        precc@_FillValue  = -9999.
        precl@_FillValue  = -9999.
        precsc@_FillValue = -9999.
        precsl@_FillValue = -9999.
        Lv         = 2.501e6
        Lf         = 3.337e5
        var0       = qflx
        var0       = (Lv + Lf) * qflx - Lf * (precc + precl - precsc - precsl)
        var0       = var0*facmod
        var0@units = varunt
        var0@notes = "modified: * " + facmod
        delete([/qflx,precc,precl,precsc,precsl,vin,fl1,f1/])
      end if 
    else if (vars.eq."LHFLX1") then
      vin  = (/"QFLX"/)
      fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
      f1   = addfile(fl1(0),"r")
      if(vin.eq."QFLX") then
        qflx = f1->$vin$
      else 
        print("qflx does not exist, can not calculate lhflx1")
        exit
      end if
      qflx@_FillValue   = -9999.
      Lv         = 2.501e6
      var0       = qflx
      var0       = Lv * qflx 
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/qflx,vin,fl1,f1/])
    else if (vars.eq."QnTot_SRF") then
      v2d  = (/"FSNS","FLNS","SHFLX","LHFLX"/)
      vsg  = (/1.0,-1.0,-1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "Net surface total fluxes (positive down)"
      delete([/v2d,fl1,f1,vsg/])
    else if(vars.eq."Qn_SRF") then
      v2d  = (/"FSDS","FSNS"/)
      vsg  = (/1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r") 
        if(iv.eq.0) then
          beta = f1->$vin$
          beta = where(beta.eq.0,beta@_FillValue,beta)
        else 
          beta = 1.0 - f1->$vin$/beta
        end if 
      end do 
      delete([/v2d,fl1,f1,vsg/])
      v2d  = (/"FSDS","FLNS","SHFLX","LHFLX"/)
      vsg  = (/1.0,-1.0,-1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
          var0 = var0 * (1.0 - beta)
        else 
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do 
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "Net surface total fluxes (positive down)"
      delete([/v2d,fl1,f1,vsg,beta/])
    else if (vars.eq."RESTOA") then
      v2d  = (/"FSNTOA","FLUT"/)
      vsg  = (/1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      var0@long_name = "TOA total radiative fluxes"
      delete([/v2d,fl1,f1,vsg/])
    else if(vars.eq."FSUS")then
      v2d  = (/"FSDS","FSNS"/)
      vsg  = (/1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1,vsg/])
    else if(vars.eq."FSUSC")then
      v2d  = (/"FSDSC","FSNSC"/)
      vsg  = (/1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1,vsg/])
    else if(vars.eq."FLUS")then
      v2d  = (/"FLDS","FLNS"/)
      vsg  = (/1.0,1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1,vsg/])
    else if(vars.eq."FLUSC")then
      v2d  = (/"FLDS","FLNS"/)
      vsg  = (/1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1,vsg/])
    else if(vars.eq."FLDSC")then
      v2d  = (/"FLDS","FLNS","FLNSC"/)
      vsg  = (/1.0,1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1,vsg/])
    else if (vars.eq."ETH1".or. vars.eq."ETH2".or.vars.eq."ETH12") then
      v2d   = (/"TAUX","TAUY","TS"/)
      fl0   = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+v2d(0)+"."+time_tag+".nc"
      fl1   = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+v2d(1)+"."+time_tag+".nc"
      fl2   = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+v2d(2)+"."+time_tag+".nc"
      f0    = addfile(fl0,"r")
      f1    = addfile(fl1,"r")
      f2    = addfile(fl2,"r")
      txtmp = f0->TAUX  ; zonal surface stress (N/m2)
      tytmp = f1->TAUY  ; meridional surface stress (N/m2)
      tztmp = f2->TS    ; surface temperature (K)
      tztmp = tztmp - 273.15 ; convert to C
      txtmp = txtmp     ; * -1.0 ; has converted 
      tytmp = tytmp     ; * -1.0 ; has converted 
      fcor  = coriolis_param(tofloat(f0->lat)); coriolis parm (1/s)
      cpair = 1005.0   ; heat capacity of air (J/kg/K)
      cp_sw = 3.996e3  ; specific heat salt water(J/kg/C)
      rho_sw= 1026.0   ; kg/m3
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
        xtmp  = tztmp 
        xtmp  = -cp_sw/conform(tztmp,fcor,1) * (dzdx*tytmp - dzdy*txtmp)
        xtmp@long_name = "Full Ekman heat transport (ETH) anomaly" 
        xtmp@units     = "W m~S~-2~N~"
        delete([/gradLatLon,dzdy,dzdx/])
      end if 
      if(vars.eq."ETH1") then
        gradLatLon = grad_latlon_cfd (tzclm, tzclm&lat, tzclm&lon, True, False)
        dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'     
        dzdx  = tofloat(gradLatLon[1])
        dimx  = dimsizes(tztmp)
        ny    = dimx(0)/12
        xtmp  = tztmp
        ytmp  = -cp_sw/conform(tztmp,fcor,1)
        do iy = 0,ny-1
          iy1 = iy*12
          iy2 = (iy+1)*12-1
          xtmp(iy1:iy2,:,:) = ytmp(iy1:iy2,:,:) \
                              *(dzdx(:,:,:)*tyanm(iy1:iy2,:,:) - dzdy(:,:,:)*txanm(iy1:iy2,:,:))
        end do 
        xtmp@long_name = "ETH anomaly: anomalous winds acting on clim SST gradient" 
        xtmp@units     = "W m~S~-2~N~"
        delete([/dimx,ny,gradLatLon,dzdy,dzdx,ytmp/])
      end if
      if(vars.eq."ETH2") then
        gradLatLon = grad_latlon_cfd (tzanm, tzanm&lat, tzanm&lon, True, False)
        dzdy  = tofloat(gradLatLon[0])    ; for clarity; explicitly extract variables from returned 'list'
        dzdx  = tofloat(gradLatLon[1])
        dimx  = dimsizes(tztmp)
        ny    = dimx(0)/12
        xtmp  = tztmp
        ytmp  = -cp_sw/conform(tztmp,fcor,1)
        do iy = 0,ny-1
          iy1 = iy*12
          iy2 = (iy+1)*12-1
          xtmp(iy1:iy2,:,:) = ytmp(iy1:iy2,:,:) \
                              *(dzdx(iy1:iy2,:,:)*tyclm(:,:,:) - dzdy(iy1:iy2,:,:)*txclm(:,:,:))
        end do
        xtmp@long_name = "ETH anomaly: clim winds acting on anomalous SST gradient"
        xtmp@units     = "W m~S~-2~N~"
        delete([/dimx,ny,gradLatLon,dzdy,dzdx,ytmp/])
      end if
      var0 = xtmp(:,{latS:latN},{lonW:lonE})
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/fcor,cpair,cp_sw,rho_sw,tztmp,txtmp,tytmp,tzclm,txclm,tyclm,tzanm,txanm,tyanm/])
      delete([/v2d,fl0,f0,fl1,f1,fl2,f2/])
    else if (vars.eq."OLR") then
      v2d  = (/"FSNTOA","FLNT","FSNT"/)
      vsg  = (/1.0,1.0,-1.0/)
      do iv = 0,dimsizes(v2d)-1
        vin  = v2d(iv)
        fl1  = data_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vin+"."+time_tag+".nc"
        f1   = addfile(fl1,"r")
        if(iv.eq.0) then
          var0 = f1->$vin$
          var0 = var0 * vsg(iv)
        else
          var0 = var0 + f1->$vin$ * vsg(iv)
        end if
      end do
      var0@_FillValue = -9999.
      var0       = var0*facmod
      var0@units = varunt
      var0@notes = "modified: * " + facmod
      delete([/v2d,fl1,f1,vsg/])
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

    if (l_output) then 
      setfileoption("nc", "Format",  "NetCDF4")
      out_file  = out_dir+"/"+exp_name(k)+"/"+exp_name(k)+"."+enstr+"."+vars+"."+time_tag+".nc"
      system("rm " + out_file)
      fout = addfile(out_file,"cw")
      vs1 = vars
      fout->$vs1$  = var0
      delete([/fout/]) 
    end if 
    delete([/var0/])

 end do 
end do 

end
