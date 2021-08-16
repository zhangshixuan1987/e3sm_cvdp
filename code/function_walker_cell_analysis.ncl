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
      out_file1  = opath +"/"+"WC_analysis_"+tname+"_monthly_mean.nc"
      out_file2  = opath +"/"+"WC_analysis_"+cname+"_monthly_mean.nc"
      system("rm " + out_file1)
      system("rm " + out_file2)
      fout1 = addfile(out_file1,"cw")
      fout2 = addfile(out_file2,"cw")
     
     ;=================================================================
      print ("Start to process the cross-section of  selected variables ")
      load "./share_info_for_mean_circulation_var.ncl"
     ;start to calculate the stream function and velocity potential 
      gwm      = f1->gw
      um       = f1->$modvars(0)$
      vm       = f1->$modvars(1)$
      tm       = f1->$modvars(3)$
      psm      = f1->$modvars(4)$
      pm       = pres_hybrid_ccm (f1->PS,f1->P0,f1->hyam,f1->hybm)  ; Pa [kg/(m s2)]
      pm@units = "Pa"
      copy_VarCoords(um,pm)
      wm       = omega_to_w(f1->$modvars(2)$, pm, tm) 
      copy_VarCoords(um,wm)
      sfvpm    = uv2sfvpF (um,vm)
      sfm      = um
      sfm      = (/sfvpm(0,:,:,:,:)/)
      delete([/sfvpm/])

      if(compare.ne."Model_vs_OBS") then
        gwo      = f2->gw
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
        sfvpo    = uv2sfvpF (uo,vo)
        sfo      = uo
        sfo      = (/sfvpo(0,:,:,:,:)/)
        delete([/sfvpo/])
      else
        gwo      = f2->gw
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
        sfvpo    = uv2sfvpF (uo,vo)
        sfo      = uo
        sfo      = (/sfvpo(0,:,:,:,:)/)
        delete([/sfvpo/])
      end if 
       
      ;;;;;interpolate model data to pressure level for plot ;;;; 
      umi        = vinth2p(um,f1->hyam,f1->hybm,pinterp1,f1->PS,intyp,f1->P0/100.0,1,False)
      vmi        = vinth2p(vm,f1->hyam,f1->hybm,pinterp1,f1->PS,intyp,f1->P0/100.0,1,False)
      wmi        = vinth2p(wm,f1->hyam,f1->hybm,pinterp1,f1->PS,intyp,f1->P0/100.0,1,False)
      sfmi       = vinth2p(sfm,f1->hyam,f1->hybm,pinterp1,f1->PS,intyp,f1->P0/100.0,1,False)

      if(compare.eq."Model_vs_OBS") then
        uoi      = int2p_n_Wrap(f2->lev,uo,pinterp1, intyp, 1)
        voi      = int2p_n_Wrap(f2->lev,vo,pinterp1, intyp, 1)
        woi      = int2p_n_Wrap(f2->lev,wo,pinterp1, intyp, 1)
        sfoi     = int2p_n_Wrap(f2->lev,sfo,pinterp1, intyp, 1)
      else
        uoi      = vinth2p(uo,f2->hyam,f2->hybm,pinterp1,f2->PS,intyp,f2->P0/100.0,1,False)
        voi      = vinth2p(vo,f2->hyam,f2->hybm,pinterp1,f2->PS,intyp,f2->P0/100.0,1,False)
        woi      = vinth2p(wo,f2->hyam,f2->hybm,pinterp1,f2->PS,intyp,f2->P0/100.0,1,False)
        sfoi     = vinth2p(sfo,f2->hyam,f2->hybm,pinterp1,f2->PS,intyp,f2->P0/100.0,1,False)
      end if 

      umi@units  = varunt(0)
      vmi@units  = varunt(1)
      wmi@units  = "m s~S~-1~N~" ;varunt(2)
      sfmi@units = "Pa"
      uoi@units  = varunt(0)
      voi@units  = varunt(1)
      woi@units  = "m s~S~-1~N~" ;varunt(2)
      sfoi@units = "Pa"

      ;;;derive the Meridional mean for waker cell;;;;
      umh        = dim_avg_wgt_n_Wrap(umi,gw1,1, 2)
      vmh        = dim_avg_wgt_n_Wrap(vmi,gw1,1, 2)
      wmh        = dim_avg_wgt_n_Wrap(wmi,gw1,1,2)
      smh        = dim_avg_wgt_n_Wrap(sfmi,gw1,1,2)
      uoh        = dim_avg_wgt_n_Wrap(uoi,gw2,1,2)
      voh        = dim_avg_wgt_n_Wrap(voi,gw2,1,2)
      woh        = dim_avg_wgt_n_Wrap(woi,gw2,1,2)
      soh        = dim_avg_wgt_n_Wrap(sfoi,gw2,1,2)
      ;;;output the variables;;;;
      fout1->U   = umh
      fout1->V   = vmh
      fout1->W   = wmh
      fout1->SF  = smh
      fout2->U   = uoh
      fout2->V   = voh
      fout2->W   = woh
      fout2->SF  = soh
      delete([/umi,vmi,uoi,voi,wmi,woi,sfmi,sfoi,pinterp1/])
    ; printMinMax(smh,True)
    ; printMinMax(soh,True)

     delete([/um,tm,vm,wm,psm,pm,uo,to,vo,wo,pso,po/])
     delete([/vmh,wmh,smh,voh,woh,soh,umh,uoh/])

