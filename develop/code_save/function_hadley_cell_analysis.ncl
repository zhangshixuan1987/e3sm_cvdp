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

begin

  compare                                    = getenv("COMPARE")
  outdir                                     = getenv("CASEDIR")
  opath                                      = getenv("DIAG_DATA_ROOT")

  tpath                                      = getenv("TPATH")
  cpath                                      = getenv("CPATH")

  tcase                                      = getenv("TEST")
  ccase                                      = getenv("CTRL")

  tname                                      = getenv("TNAME")
  cname                                      = getenv("CNAME")

  tttag                                      = getenv("TTTAG")
  cttag                                      = getenv("CTTAG")

  refplev_file                               = getenv("REF_PRE_LEV")

;define regions for plot
  latS                                       = -90.  ;negative for southern hemisphere
  latN                                       =  90.  ;negative for southern hemisphere
  pout                                       = "Global"

  pi                                         = 3.14159265
  rearth                                     = 6.37122e6
  grav                                       = 9.806
  sigma                                      = 5.67e-8 ; Stefan-Boltzmann constant

 ;define the pressure levels for cross-section plot 
  pinterp                                   = asciiread(refplev_file,-1,"float")
  pinterp@longname                          = "lev"
  pinterp@units                             = "hPa"
  intyp                                     = 2

  pi                                        = 3.14159265
  rearth                                    = 6.37122e6
  grav                                      = 9.806

;read in two files

  do ll = 0, dimsizes(pout)-1
 
      f                                     = systemfunc("ls "+tpath+"/"+tcase+"*"+tttag+".nc")
      f1                                    = addfile(f,"r")
      gw1                                   = f1->gw

      f                                     = systemfunc("ls "+cpath+"/"+ccase+"*"+cttag+".nc")
      f2                                    = addfile(f,"r")
      gw2                                   = f2->gw

     ;=================================================================
      print ("Start to process the cross-section of  selected variables ")
      load "./share_info_for_hadley_cell_var.ncl"
     ;start to calculate the stream function and velocity potential 
      um       = f1->$modvars(0)$
      vm       = f1->$modvars(1)$
      wm       = f1->$modvars(2)$
      tm       = f1->$modvars(3)$
      pm       = pres_hybrid_ccm (f1->PS,f1->P0,f1->hyam,f1->hybm)  ; Pa [kg/(m s2)]

      copy_VarCoords(um,pm)
      gridType = 1

      pvm      = pot_vort_hybrid(pm,um,vm,tm,f1->lat, gridType,  1)
      sfvpm    = uv2sfvpF (um,vm)
      sfm      = sfvpm(0,:,:,:,:)
      vpm      = sfvpm(1,:,:,:,:) 

     ;======================================================================
     ;Save the derived data for the future use
     ;======================================================================
      setfileoption("nc", "Format",  "NetCDF4")
      out_file1  = opath +"/"+"HC_analysis_"+tname+"_monthly_mean.nc"

      umi        = vinth2p(um,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      vmi        = vinth2p(vm,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)      
      wmi        = vinth2p(wm,f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      pvmi       = vinth2p(pvm[0],f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      ssmi       = vinth2p(pvm[1],f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      thmi       = vinth2p(pvm[2],f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      sfmi       = vinth2p(sfvpm(0,:,:,:,:),f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      vpmi       = vinth2p(sfvpm(1,:,:,:,:),f1->hyam,f1->hybm,pinterp,f1->PS,intyp,f1->P0/100.0,1,False)
      
      umi@units  = varunt(0)
      vmi@units  = varunt(1)
      wmi@units  = varunt(2)

      system("rm " + out_file1)
      fout1 = addfile(out_file1,"c")

      fout1->U     = umi
      fout1->V     = vmi
      fout1->OMEGA = wmi
      fout1->SS    = pvmi
      fout1->Theta = ssmi
      fout1->PV    = thmi
      fout1->SF    = sfmi
      fout1->VP    = vpmi
 
      delete([/umi,vmi,wmi,pvmi,ssmi,thmi,sfmi,vpmi,um,vm,wm,tm,pm,pvm,sfvpm,sfm,vpm/])

      if(compare.ne."Model_vs_OBS") then
        um       = f2->$modvars(0)$
        vm       = f2->$modvars(1)$
        wm       = f2->$modvars(2)$
        tm       = f2->$modvars(3)$
        pm       = pres_hybrid_ccm (f2->PS,f2->P0,f2->hyam,f2->hybm)  ; Pa [kg/(m s2)]

        copy_VarCoords(um,pm)
        gridType = 1

        pvm      = pot_vort_hybrid(pm,um,vm,tm,f2->lat, gridType,  1)
        sfvpm    = uv2sfvpF (um,vm)
        sfm      = sfvpm(0,:,:,:,:)
        vpm      = sfvpm(1,:,:,:,:)

       ;======================================================================
       ;Save the derived data for the future use
       ;======================================================================
        setfileoption("nc", "Format",  "NetCDF4")
        out_file2  = opath +"/"+"HC_analysis_"+cname+"_monthly_mean.nc"
        umi        = vinth2p(um,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        vmi        = vinth2p(vm,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        wmi        = vinth2p(wm,f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        pvmi       = vinth2p(pvm[0],f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        ssmi       = vinth2p(pvm[1],f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        thmi       = vinth2p(pvm[2],f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        sfmi       = vinth2p(sfvpm(0,:,:,:,:),f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)
        vpmi       = vinth2p(sfvpm(1,:,:,:,:),f2->hyam,f2->hybm,pinterp,f2->PS,intyp,f2->P0/100.0,1,False)

        umi@units  = varunt(0)
        vmi@units  = varunt(1)
        wmi@units  = varunt(2)

        system("rm " + out_file2)
        fout2 = addfile(out_file2,"c")

        fout2->U     = umi
        fout2->V     = vmi
        fout2->OMEGA = wmi
        fout2->SS    = pvmi
        fout2->Theta = ssmi
        fout2->PV    = thmi
        fout2->SF    = sfmi
        fout2->VP    = vpmi

        delete([/umi,vmi,wmi,pvmi,ssmi,thmi,sfmi,vpmi,um,vm,wm,tm,pm,pvm,sfvpm,sfm,vpm/])

      end if

      if(compare.eq."Model_vs_OBS") then
        setfileoption("nc", "Format",  "NetCDF4")
        out_file2  = opath +"/"+"HC_analysis_"+cname+"_monthly_mean.nc"

        um       = f2->$obsvars(0)$
        vm       = f2->$obsvars(1)$
        wm       = f2->$obsvars(2)$
        tm       = f2->$obsvars(3)$
        pm       = f2->lev
        pm       = pm * 100.0
        pm@units = "Pa"
        copy_VarCoords(um,pm)
        gridType = 1
        opt      = 0 
        pvm      = pot_vort_isobaric(pm,um,vm,tm,f2->lat, gridType, opt)
        sfvpm    = uv2sfvpF (um,vm)
        sfm      = sfvpm(0,:,:,:,:)
        vpm      = sfvpm(1,:,:,:,:)

        umi      = int2p_n_Wrap(f2->lev,um,pinterp, intyp, 1) 
        vmi      = int2p_n_Wrap(f2->lev,vm,pinterp, intyp, 1)
        wmi      = int2p_n_Wrap(f2->lev,wm,pinterp, intyp, 1)
        pvmi     = int2p_n_Wrap(f2->lev,pvm[0],pinterp, intyp, 1)              
        ssmi     = int2p_n_Wrap(f2->lev,pvm[1],pinterp, intyp, 1)
        thmi     = int2p_n_Wrap(f2->lev,pvm[2],pinterp, intyp, 1)
        sfmi     = int2p_n_Wrap(f2->lev,sfvpm(0,:,:,:,:),pinterp, intyp, 1)              
        vpmi     = int2p_n_Wrap(f2->lev,sfvpm(1,:,:,:,:),pinterp, intyp, 1)

        umi@units  = varunt(0)
        vmi@units  = varunt(1)
        wmi@units  = varunt(2)

        system("rm " + out_file2)
        fout2 = addfile(out_file2,"c")

        fout2->U     = umi
        fout2->V     = vmi
        fout2->OMEGA = wmi
        fout2->SS    = pvmi
        fout2->Theta = ssmi
        fout2->PV    = thmi
        fout2->SF    = sfmi
        fout2->VP    = vpmi

        delete([/umi,vmi,wmi,pvmi,ssmi,thmi,sfmi,vpmi,um,vm,wm,tm,pm,pvm,sfvpm,sfm,vpm/])
        
      end if

 end do
 
end
