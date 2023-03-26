;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This script used to generate SST and Seaice ensemble forcing from CMIP6 scenario mip;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "./function.ncl"

begin

  exps       = "r1i1p1f1"
  outdir     = "/global/cscratch1/sd/zhan391/DARPA_project/cmip6_forcing_" + exps
  scenarios  = (/"ssp245","ssp585"/)
  nsce       = dimsizes(scenarios)

  e3sm_vnam  = (/"SST_cpl","ice_cov"/)
  nvars      = dimsizes(e3sm_vnam)
  crange     = (/1991,2010/)
  trange     = "2041-2060" 
  month      = ispan(1,12,1)
  nmons      = dimsizes(month)

  dstfil     = "./sst_ice_CMIP6_DECK_E3SM_1x1_c20180213.nc"

  do is = 0,nsce-1,1

    scenario = scenarios(is)
    infil    = outdir + "/out/CMIP6_delta_forcing_"+scenario+".nc"
    outfil   = outdir + "/out/sst_ice_CMIP6_DECK_E3SM_1x1_c20180213_"+scenario+".nc"
    system("cp " + dstfil + " " + outfil)
    fin      = addfile(infil,"r")
    fout     = addfile(outfil,"rw")
    utc_date = cd_calendar(fout->time, 0)
    fyear    = tointeger(utc_date(:,0))    ; Convert to integer for
    fmonth   = tointeger(utc_date(:,1))    ; use sprinti
    delete([/utc_date/])

    v01      = e3sm_vnam(0) 
    v11      = e3sm_vnam(1) 

   ;generate climatology from specified time range 
    indxx    = ind(fyear.ge.crange(0).and.fyear.le.crange(1))
    SST      = clmMonTLL(fout->$v01$(indxx,:,:))
    SEAICE   = clmMonTLL(fout->$v11$(indxx,:,:)) 
    delete([/indxx/])
   ;printVarSummary(SST)
   ;printVarSummary(SEAICE)
   ;printMinMax(SST,False)
   ;printMinMax(SEAICE,False)
   ;exit

   ;add forcing to climatology and apply consistency check 
    dsst     = fin->$v01$
    dsice    = fin->$v11$
    dsst@_FillValue  = SST@_FillValue
    dsice@_FillValue = SEAICE@_FillValue
    print(num(ismissing(dsst)) + " " + num(ismissing(dsice)))

   ;mask out missing point in forcing 
    print(num(ismissing(SST)) + " " +num(ismissing(SEAICE)))
    SST    = where(ismissing(dsst),SST@_FillValue,SST) 
    SEAICE = where(ismissing(dsice),SEAICE@_FillValue,SEAICE) 
    print(num(ismissing(SST)) + " " +num(ismissing(SEAICE)))

    print("Min/Max of delta forcing: ")
    printMinMax(dsst,False)
    printMinMax(dsice,False)

   ;apply the delta forcing
    SSTadj    = SST
    SEAICEadj = SEAICE
    SSTadj    = SST + dsst
    SEAICEadj = SEAICE + dsice 
    print("SST and SEAICE before applying forcing")
    print(min(SST)       + " " + max(SST)       + " " +avg(SST))
    print(min(SEAICE)    + " " + max(SEAICE)    + " " +avg(SEAICE)) 
    print("SST and SEAICE after applying forcing")
    print(min(SSTadj)    + " " + max(SSTadj)    + " " +avg(SSTadj))
    print(min(SEAICEadj) + " " + max(SEAICEadj) + " " +avg(SEAICEadj))

    print("")
    print("Consistency processing...")
    ; Corrections for data consistency
    ; 1) If SST < -1.8 or ice frac >= 0.9, SST = -1.8
    SST    = where(SST .le. -1.8, -1.8, SST)
    SST    = where(SEAICE .gt. 0.9, -1.8, SST)
    SSTadj = where(SSTadj .le. -1.8, -1.8, SSTadj)
    SSTadj = where(SEAICEadj .gt. 0.9, -1.8, SSTadj)

    ; 2) min ice frac is 0%, max ice_frac is 100%
    SEAICE    = where(SEAICE .lt. 0., 0., SEAICE)
    SEAICE    = where(SEAICE .gt. 1., 1., SEAICE)
    SEAICEadj = where(SEAICEadj .lt. 0., 0., SEAICEadj)
    SEAICEadj = where(SEAICEadj .gt. 1., 1., SEAICEadj)

    ; 3) Hurrell et al. (2008, J. Climate) correction to SST (if 0.15 < ice frac < 0.9)
    SST_max = 9.328*(0.729-(SEAICE/100.)^3)-1.8
    SST     = where((SEAICE .gt. 0.15) .and. (SEAICE .lt. 0.9) .and. (SST .gt. SST_max), SST_max, SST)
    delete(SST_max)
    SST_max = 9.328*(0.729-(SEAICEadj/100.)^3)-1.8
    SSTadj  = where((SEAICEadj .gt. 0.15) .and. (SEAICEadj .lt. 0.9) .and. (SSTadj .gt. SST_max), SST_max, SSTadj)
    delete(SST_max)

    ; 4) No sea ice if SST > 4.97
    SEAICE = where(SST .gt. 4.97, 0., SEAICE)
    SEAICEadj = where(SSTadj .gt. 4.97, 0., SEAICEadj)

    ; 5) Hurrell et al. (2008, J. Climate) correction to ice frac (if -1.8 < SST < 4.97)
    ice_max   = (0.729-(SST+1.8)/9.328)^(1./3.)
    SEAICE    = where( (SST .gt. -1.8) .and. (SST .lt. 4.97) .and. (SEAICE .gt. ice_max), ice_max, SEAICE )
    delete(ice_max)
    ice_max   = (0.729-(SSTadj+1.8)/9.328)^(1./3.)
    SEAICEadj = where( (SSTadj .gt. -1.8) .and. (SSTadj .lt. 4.97) .and. (SEAICEadj .gt. ice_max), ice_max, SEAICEadj )
    delete(ice_max)

    ; skip filling for missing values
    ;print((/"Filling in missing values in SST and SEAICE..."/))
    ;poisson_grid_fill(SST, True, 1, 500, 0.01, 0.6, 0)
    ;poisson_grid_fill(SSTadj, True, 1, 500, 0.01, 0.6, 0)
    ;poisson_grid_fill(SEAICE, True, 1, 500, 0.01, 0.6, 0)
    ;poisson_grid_fill(SEAICEadj, True, 1, 500, 0.01, 0.6, 0)

    print("SST and SEAICE before adjustment:")
    printMinMax(SST,False)
    printMinMax(SEAICE,False)
    print("SST and SEAICE after adjustment:")
    printMinMax(SSTadj,False)
    printMinMax(SEAICEadj,False)

    ;calculate adjusted forcing 
    dsstadj  = dsst 
    dsstadj  = SSTadj    - SST
    dsiceadj = dsice
    dsiceadj = SEAICEadj - SEAICE

   ;output file for sanity check    
    outfil1      = outdir + "/out/CMIP6_delta_forcing_"+scenario+"_adjust.nc"
    system("rm -rvf " + outfil1)
    fout1        = addfile(outfil1,"c")
    fout1->$v01$ = dsstadj
    fout1->$v11$ = dsiceadj 

    print("Forcing before adjustment:")
    printMinMax(dsst,False)
    printMinMax(dsice,False)
    print("Forcing after adjustment:")
    printMinMax(dsstadj,False)
    printMinMax(dsiceadj,False)
    
    ;;apply forcing to the SST boundary condition file 
    dsstadj  = where(ismissing(dsstadj),0.0,dsstadj)
    dsiceadj = where(ismissing(dsiceadj),0.0,dsiceadj)
    print("Origianl Forcing after removing missing value:")
    printMinMax(dsst,False)
    printMinMax(dsice,False)
    print("Adjusted Forcing after removing missing value:")
    printMinMax(dsstadj,False)
    printMinMax(dsiceadj,False)
    vout0 = fout->$v01$
    vout1 = fout->$v11$
    do it = 0,nmons-1,1
      indxx = ind(fmonth.eq.month(it))
      vout0(indxx,:,:) = vout0(indxx,:,:) + conform(vout0(indxx,:,:),dsstadj(it,:,:),(/1,2/)) 
      vout1(indxx,:,:) = vout1(indxx,:,:) + conform(vout1(indxx,:,:),dsiceadj(it,:,:),(/1,2/)) 
      delete([/indxx/])
    end do 
    fout->$v01$ = (/vout0/)
    fout->$v11$ = (/vout1/)
    delete([/dsstadj,dsiceadj,dsst,dsice,vout0,vout1/])
end do 
end
