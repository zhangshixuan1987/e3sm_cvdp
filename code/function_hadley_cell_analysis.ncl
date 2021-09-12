; derive the required metrics for hadley cell
; Author : Shixuan Zhang
; Date   : Feb 22, 2021

      pinterp!0 = "lev"
      pinterp&lev = pinterp
      pinterp1 = pinterp({10:1000})
     ;======================================================================
     ;Save the derived data for the future use
     ;======================================================================
      setfileoption("nc", "Format",  "NetCDF4")
      setfileoption("nc", "Format",  "LargeFile") 
      out_file1  = opath +"/"+"HC_analysis_"+tname+"_monthly_mean.nc"
      out_file2  = opath +"/"+"HC_analysis_"+cname+"_monthly_mean.nc"
      system("rm " + out_file1)
      system("rm " + out_file2)
      fout1 = addfile(out_file1,"cw")
      fout2 = addfile(out_file2,"cw")
     
     ;=================================================================
      print ("Start to process the cross-section of  selected variables ")
      load "./share_info_for_mean_circulation_var.ncl"
     ;start to calculate the stream function and velocity potential 
      um       = f1->$modvars(0)$
      vm       = f1->$modvars(1)$
      tm       = f1->$modvars(3)$
      psm      = f1->$modvars(4)$
      pm       = pres_hybrid_ccm (f1->PS,f1->P0,f1->hyam,f1->hybm)  ; Pa [kg/(m s2)]
      pm@units = "Pa"
      copy_VarCoords(um,pm)
      wm       = omega_to_w(f1->$modvars(2)$, pm, tm) 
      copy_VarCoords(um,wm)

      if(compare.ne."Model_vs_OBS") then
        uo       = f2->$modvars(0)$
        vo       = f2->$modvars(1)$
        wo       = f2->$modvars(2)$
        to       = f2->$modvars(3)$
        pso      = f2->$modvars(4)$
        po       = pres_hybrid_ccm (f2->PS,f2->P0,f2->hyam,f2->hybm)  ; Pa [kg/(m s2)]
        po@units = "Pa"
        copy_VarCoords(uo,po)
        wo       = omega_to_w(f2->$modvars(2)$, po, to)
        copy_VarCoords(uo,wo)
      else
        uo       = f2->$obsvars(0)$
        vo       = f2->$obsvars(1)$
        to       = f2->$obsvars(3)$
        pso      = f2->$obsvars(4)$
        po       = conform(uo,f2->lev,1)
        po       = po * 100.0
        po@units = "Pa"
        copy_VarCoords(uo,po)
        wo       = omega_to_w(f2->$obsvars(2)$, po, to)
        copy_VarCoords(uo,wo)
      end if 
 
      ;;;;;interpolate model data to pressure level for plot ;;;; 
      umi        = vinth2p(um,f1->hyam,f1->hybm,pinterp1,f1->PS,intyp,f1->P0/100.0,1,False)
      vmi        = vinth2p(vm,f1->hyam,f1->hybm,pinterp1,f1->PS,intyp,f1->P0/100.0,1,False)
      wmi        = vinth2p(wm,f1->hyam,f1->hybm,pinterp1,f1->PS,intyp,f1->P0/100.0,1,False)
      
      if(compare.eq."Model_vs_OBS") then
        uoi      = int2p_n_Wrap(f2->lev,uo,pinterp1, intyp, 1)
        voi      = int2p_n_Wrap(f2->lev,vo,pinterp1, intyp, 1)
        woi      = int2p_n_Wrap(f2->lev,wo,pinterp1, intyp, 1)
      else
        uoi      = vinth2p(uo,f2->hyam,f2->hybm,pinterp1,f2->PS,intyp,f2->P0/100.0,1,False)
        voi      = vinth2p(vo,f2->hyam,f2->hybm,pinterp1,f2->PS,intyp,f2->P0/100.0,1,False)
        woi      = vinth2p(wo,f2->hyam,f2->hybm,pinterp1,f2->PS,intyp,f2->P0/100.0,1,False)
      end if 

      ;;mask out the missing values;;;;
      umi = where (ismissing(uoi), umi@_FillValue, umi)
      uoi = where (ismissing(umi), uoi@_FillValue, uoi)
      vmi = where (ismissing(voi), vmi@_FillValue, vmi)
      voi = where (ismissing(vmi), voi@_FillValue, voi)
      wmi = where (ismissing(woi), wmi@_FillValue, wmi)
      woi = where (ismissing(wmi), woi@_FillValue, woi)

      umi@units  = varunt(0)
      vmi@units  = varunt(1)
      wmi@units  = "m s~S~-1~N~" ;varunt(2)
      uoi@units  = varunt(0)
      voi@units  = varunt(1)
      woi@units  = "m s~S~-1~N~" ;varunt(2)
 
      levnew     = pinterp1*100.0
      levnew!0   = "lev"
      levnew&lev = levnew
      levnew@units = "Pa"

      ;;;derive the zonal mean for hadley cell;;;;
      umh        = dim_avg_n_Wrap(umi,3)
      vmh        = dim_avg_n_Wrap(vmi,3)
      wmh        = dim_avg_n_Wrap(wmi,3)
      uoh        = dim_avg_n_Wrap(uoi,3)
      voh        = dim_avg_n_Wrap(voi,3)
      woh        = dim_avg_n_Wrap(woi,3)
      vmi&lev    = levnew
      voi&lev    = levnew
      vmi&lev@units = "Pa"
      voi&lev@units = "Pa"
      smh        = zonal_mpsi_Wrap(vmi,vmi&lat,levnew,psm)
      soh        = zonal_mpsi_Wrap(voi,voi&lat,levnew,pso)
      smh&lev    = pinterp1
      soh&lev    = pinterp1
      smh&lev@units = "hPa"
      soh&lev@units = "hPa"
      ;;;output the variables;;;;
      fout1->U   = umh
      fout1->V   = vmh
      fout1->W   = wmh
      fout1->SF  = smh
      fout2->U   = uoh
      fout2->V   = voh
      fout2->W   = woh
      fout2->SF  = soh
      delete([/umi,vmi,uoi,voi,wmi,woi,levnew,pinterp1/])
    ; printMinMax(smh,True)
    ; printMinMax(soh,True)

     delete([/um,tm,vm,wm,psm,pm,uo,to,vo,wo,pso,po/])
     delete([/vmh,wmh,smh,voh,woh,soh,umh,uoh/])

