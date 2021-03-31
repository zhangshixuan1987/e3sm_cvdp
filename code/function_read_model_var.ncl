;;;;;This scripts used to save the code blocks for reading model variables;;;;;;;
  if ( mvarnam .eq. "PRECT" ) then
     vmsvar                           := (/"PRECC","PRECL"/)
     vmsign                           := (/1,1/)
  else if ( mvarnam .eq. "PRECST" ) then
     vmsvar                           := (/"PRECSC","PRECSL"/)
     vmsign                           := (/1,1/)
  else if ( mvarnam.eq."FLUS")then
     vmsvar                           := (/"FLNS","FLDS"/)
     vmsign                           := (/1,1/)
  else if ( mvarnam.eq."FSUS")then
     vmsvar                           := (/"FSDS","FSNS"/)
     vmsign                           := (/1,-1/)
  else if ( mvarnam.eq."FSUSC")then
     vmsvar                           := (/"FSDSC","FSNSC"/)
     vmsign                           := (/1,-1/)
  else if ( mvarnam.eq."FLDSC")then
     vmsvar                           := (/"TS","FLNSC"/)
     vmsign                           := (/1,-1/)
  else if ( mvarnam.eq."NETCF")then
     vmsvar                           := (/"LWCF","SWCF"/)
     vmsign                           := (/1,1/)
  else if ( mvarnam .eq. "SWCF_SRF" ) then
     vmsvar                           := (/"FSNS","FSNSC"/)
     vmsign                           := (/1,-1/)
  else if ( mvarnam .eq. "LWCF_SRF" ) then
     vmsvar                           := (/"FLNS","FLNSC"/)
     vmsign                           := (/-1,1/)
  else if ( mvarnam .eq. "NETCF_SRF" ) then
     vmsvar                           := (/"FSNS","FSNSC","FLNSC","FLNS"/)
     vmsign                           := (/1,-1,1,-1/)
  else if ( mvarnam .eq. "RESTOM") then
     vmsvar                           := (/"FSNT","FLNT"/)
     vmsign                           := (/1,-1/)
  else if ( mvarnam .eq. "RESTOA") then
     vmsvar                           := (/"FSNTOA","FLUT"/)
     vmsign                           := (/1,-1/)
  else if (mvarnam .eq. "NET_FLUX_SRF") then
     vmsvar                           := (/"FSNS","FLNS","SHFLX","LHFLX"/)
     vmsign                           := (/1,-1,-1,-1/)
  else if ( mvarnam .eq. "ALBEDO") then
     vmsvar                           := (/"SOLIN","FSNTOA"/)
     vmsign                           := (/1,-1/)
  else if ( mvarnam .eq. "ALBEDOC") then
     vmsvar                           := (/"SOLIN","FSNTOAC"/)
     vmsign                           := (/1,-1/)
  else if ( mvarnam .eq. "ALBEDO_SRF") then
     vmsvar                           := (/"FSDS","FSNS"/)
     vmsign                           := (/1,-1/)
  else
     vmsvar                           := (/mvarnam/)
     vmsign                           := (/1/)
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

  if(mvarnam.eq."FLDSC")then
    var1                                 = f1->$vmsvar(0)$
    var1                                 = sigma*var1^4 * vmsign(0)
    if (compare.ne."Model_vs_OBS") then
      var2                               = f2->$vmsvar(0)$
      var2                               = sigma*var2^4 * vmsign(0)
    end if
  else
    var1                                 = f1->$vmsvar(0)$
    var1                                 = var1 * vmsign(0)
    if (compare.ne."Model_vs_OBS") then
      var2                               = f2->$vmsvar(0)$
      var2                               = var2 * vmsign(0)
    end if
  end if

  if (dimsizes(vmsvar).gt.1) then

    if (mvarnam.eq."ALBEDO".or. mvarnam.eq."ALBEDOC".or. mvarnam.eq."ALBEDO_SRF")then
      tmp1                                = where(var1.eq.0,-9999.0,var1)
      tmp1@_FillValue                     = -9999.0
      var1                                =  ( tmp1 +  f1->$vmsvar(1)$ * vmsign(1) ) / tmp1
      delete([/tmp1/])
      if (compare.ne."Model_vs_OBS") then
        tmp2                              = where(var2.eq.0,-9999.0,var2)
        tmp2@_FillValue                   = -9999.0
        var2                              =  ( tmp2 +  f2->$vmsvar(1)$ * vmsign(1) ) / tmp2
        delete([/tmp2/])
      end if

    else

      do ivv = 1, dimsizes(vmsvar)-1,1
        var1                               = var1 + f1->$vmsvar(ivv)$ * vmsign(ivv)
        if (compare.ne."Model_vs_OBS") then
          var2                             = var2 + f2->$vmsvar(ivv)$ * vmsign(ivv)
        end if
      end do

   end if

  end if
