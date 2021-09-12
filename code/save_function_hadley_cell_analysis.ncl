  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a 4-panel lat-height plot
;          Data is vertically interpolated to pressure levels
;          1st panel: experiment 1
;          2nd panel: experiment 2
;          3rd panel: absolute difference (exp1-exp2)
;          4th panel: relative difference (exp1-exp2)/exp2
; Author : Shixuan Zhang
; Date   : Feb 22, 2021

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
      load "./share_info_for_hadley_cell_var.ncl"
     ;start to calculate the stream function and velocity potential 
      um       = f1->$modvars(0)$
      vm       = f1->$modvars(1)$
      tm       = f1->$modvars(3)$
      psm      = f2->$modvars(4)$
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
        pso      = f2->$modvars(4)$
        po       = conform(uo,f2->lev,1)
        po       = po * 100.0
        po@units = "Pa"
        copy_VarCoords(uo,wo)
        wo       = omega_to_w(f2->$modvars(2)$, po, to)
        copy_VarCoords(uo,wo)
      end if 
 
      ;;;;;interpolate model data to pressure level for plot ;;;; 
      umi        = vinth2p(um,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      vmi        = vinth2p(vm,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      wmi        = vinth2p(wm,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      
      if(compare.eq."Model_vs_OBS") then
        uoi      = int2p_n_Wrap(f2->lev,uo,pinterp, intyp, 1)
        voi      = int2p_n_Wrap(f2->lev,vo,pinterp, intyp, 1)
        woi      = int2p_n_Wrap(f2->lev,wo,pinterp, intyp, 1)
      else
        uoi      = vinth2p(uo,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        voi      = vinth2p(vo,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        woi      = vinth2p(wo,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
      end if 

      umi@units  = varunt(0)
      vmi@units  = varunt(1)
      wmi@units  = varunt(2)
      uoi@units  = varunt(0)
      voi@units  = varunt(1)
      woi@units  = varunt(2)
      
      levnew     = pinterp*100.0
      levnew!0   = "lev"
      levnew&lev = levnew
      levnew@units = "Pa"
      ;;;derive the zonal mean for hadley cell;;;;
      vmh        = dim_avg_n_Wrap(vmi,3)
      wmh        = dim_avg_n_Wrap(wmi,3)
      smh        = zonal_mpsi_Wrap(vmi,vmi&lat,levnew,psm)
      voh        = dim_avg_n_Wrap(voi,3)
      woh        = dim_avg_n_Wrap(woi,3)
      soh        = zonal_mpsi_Wrap(voi,voi&lat,levnew,pso)
    
      ;;;output the variables;;;;
      fout1->V   = vmh
      fout1->W   = wmh
      fout1->SF  = smh
      fout2->V   = voh
      fout2->W   = woh
      fout2->SF  = soh
      delete([/umi,vmi,uoi,voi,wmi,woi,levnew,pinterp/])
    ; printMinMax(smh,True)
    ; printMinMax(soh,True)

     ;start to process the stream function and velocity potential 
      uvmsg = 1e+36
      sfm = new(dimsizes(um), float, uvmsg)
      vpm = new(dimsizes(um), float, uvmsg)
      sfo = new(dimsizes(uo), float, uvmsg)
      vpo = new(dimsizes(uo), float, uvmsg)
     ; printMinMax(sfm,True)
     ; printMinMax(vpm,True)

      uv2sfvpf (um,vm, sfm,vpm)
      uv2sfvpf (uo,vo, sfo,vpo) 

      copy_VarCoords(um,sfm)
      copy_VarCoords(um,vpm)
      copy_VarCoords(uo,sfo)
      copy_VarCoords(uo,vpo)

      sfmi       = vinth2p(sfm,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      vpmi       = vinth2p(vpm,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)

      if(compare.eq."Model_vs_OBS") then
        sfoi     = int2p_n_Wrap(f2->lev,sfo,pinterp, intyp, 1)
        vpoi     = int2p_n_Wrap(f2->lev,vpo,pinterp, intyp, 1)
      else
        sfoi     = vinth2p(sfm,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        vpoi     = vinth2p(vpm,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
      end if

      fout1->SF    = sfmi
      fout1->VP    = vpmi
      fout2->SF    = sfoi
      fout2->VP    = vpoi
      delete([/sfm,vpm,sfo,vpo,sfmi,vpmi,sfoi,vpoi/])

      exit

      ;;;derive potential vorticity;;;;;; 
      gridType   = 1
      pvm        = pot_vort_hybrid(pm,um,vm,tm,f1->lat, gridType,  1)

      if(compare.eq."Model_vs_OBS") then
        pvo        = pot_vort_hybrid(po,uo,vo,to,f2->lat, gridType,  1)
      else
        pvo        = pot_vort_isobaric(po,uo,vo,to,f2->lat, gridType,  1)
      end if 

      pvmi       = vinth2p(pvm[0],f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      ssmi       = vinth2p(pvm[1],f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      thmi       = vinth2p(pvm[2],f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)

      if(compare.eq."Model_vs_OBS") then
        pvoi     = int2p_n_Wrap(f2->lev,pvm[0],pinterp, intyp, 1)
        ssoi     = int2p_n_Wrap(f2->lev,pvm[1],pinterp, intyp, 1)
        thoi     = int2p_n_Wrap(f2->lev,pvm[2],pinterp, intyp, 1)
      else
        pvoi     = vinth2p(pvm[0],f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
        ssoi     = vinth2p(pvm[1],f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
        thoi     = vinth2p(pvm[2],f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      end if
 
      fout1->SS    = pvmi
      fout1->Theta = ssmi
      fout1->PV    = thmi
      fout2->SS    = pvoi
      fout2->Theta = ssoi
      fout2->PV    = thoi
     
      delete([/pvm,pvo,pvmi,ssmi,thmi,pvoi,ssoi,thoi/])
