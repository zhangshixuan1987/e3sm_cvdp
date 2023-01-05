; Purpose: compare the pattern of EP-FLUX with reanalysis 
; Calculate the EP-flux using monthly mean model output and reanalysis 
; Note: Eliassen-Palm flux (EP-flux) is a non-linear quantity. Hence, the correct way 
; to compute time averaged EP-flux is to compute it every time step and average the results. 
; Computing EP-flux from monthly mean U, V, T quantities will result in smooth results that 
; may compare well in terms of patterns but will likely lack the detailed structure of 
; the 'correct' monthly mean EP-flux.

;;NOTE for EP-FLUXES (NCL website)
; vector quantity with nonzero components in the latitude-height plane, 
; the direction and magnitude of which determine the relative importance 
; of eddy heat flux and momentum flux.
 
; When the Eliassen-Palm flux (EPF) vector points upward, the meridional heat flux 
; dominates; when the EPF vector points in the meridional direction, the meridional 
; flux of zonal momentum dominates. The divergence of the Eliassen-Palm flux is more 
; frequently used as a diagnostic tool, as it is proportional to the eddy potential 
; vorticity flux. In the special case when the EPF divergence is zero, as for steady, 
; frictionless, linear waves, thermal wind balance is maintained in an idealized 
; zonally symmetric atmosphere through the induction of a mean meridional circulation, 
; even though the waves produce significant eddy heat and momentum fluxes.
; Reference:
; Edmon, H.J., B.J. Hoskins, and M.E. McIntyre,1980:
; Eliassen-Palm cross sections for the troposphere.
; J. Atmos. Sci., 37:2600-2616
; doi: http://dx.doi.org/10.1175/1520-0469(1980)037<2600:EPCSFT>2.0.CO;2

; Author : J. Barsugli (NOAA/PSD) and adapted by C. Smith (NOAA/PSD).
; Date   : 2010


   ; =================================================================
   print ("Start to process the EP-FLUXES")
   load "./share_info_for_3d_var.ncl"

   U1                                = vinth2p(f1->$modvars(0)$,f1->hyam,f1->hybm,pinterp,\
                                              f1->PS,intyp,f1->P0/100.0,1,False)
   V1                                = vinth2p(f1->$modvars(1)$,f1->hyam,f1->hybm,pinterp,\
                                              f1->PS,intyp,f1->P0/100.0,1,False)
   T1                                = vinth2p(f1->$modvars(2)$,f1->hyam,f1->hybm,pinterp,\
                                              f1->PS,intyp,f1->P0/100.0,1,False)

   if(compare.ne."Model_vs_OBS") then
     U2                              = vinth2p(f2->$modvars(0)$,f2->hyam,f2->hybm,pinterp,\
                                              f2->PS,intyp,f2->P0/100.0,1,False)
     V2                              = vinth2p(f2->$modvars(1)$,f2->hyam,f2->hybm,pinterp,\
                                              f2->PS,intyp,f2->P0/100.0,1,False)
     T2                              = vinth2p(f2->$modvars(2)$,f2->hyam,f2->hybm,pinterp,\
   end if

   if(compare.eq."Model_vs_OBS") then
     U2                              = int2p_n_Wrap(f2->lev,f2->$obsvars(0)$, pinterp, intyp, 1)
     V2                              = int2p_n_Wrap(f2->lev,f2->$obsvars(1)$, pinterp, intyp, 1)
     T2                              = int2p_n_Wrap(f2->lev,f2->$obsvars(2)$, pinterp, intyp, 1)
   end if

   U1@_FillValue                       = -9999.
   U2@_FillValue                       = -9999.
   V1@_FillValue                       = -9999.
   V2@_FillValue                       = -9999.
   T1@_FillValue                       = -9999.
   T2@_FillValue                       = -9999.

   U1 = where(ismissing(U2),U1@_FillValue, U1) 
   U2 = where(ismissing(U1),U2@_FillValue, U2)
   V1 = where(ismissing(V2),V1@_FillValue, V1)
   V2 = where(ismissing(V1),V2@_FillValue, V2)
   T1 = where(ismissing(T2),T1@_FillValue, T1)
   T2 = where(ismissing(T1),T2@_FillValue, T2)
   
   ;;;ep-flux 
   sf      = 5.0        ; tofloat(getenv("sc_fact_start"))
                        ; NOAA used an environment variable
   opt     = True          
   opt@magf= sf            ; make NCL attribute for use by 'epflux'

   epf1  =  epflux(U1,V1,T1,pinterp,f1->lat,opt)   
   epf2  =  epflux(U2,V2,T2,pinterp,f2->lat,opt)
   delete([/U1,U2,V1,V2,T1,T2/])
  
   Fphi1  = epf1[0]          ; extract variables from 'list' for clarity
   Fp1    = epf1[1]
   EPdiv1 = epf1[2]
   dudt1  = epf1[3]

   Fphi2  = epf2[0]          ; extract variables from 'list' for clarity
   Fp2    = epf2[1]
   EPdiv2 = epf2[2]
   dudt2  = epf2[3]
   delete([/epf1,epf2/])    

   ;;;;save the data to avoid repeated processing 
   ;======================================================================
   ;Save the data for the later use 
   ;======================================================================
    setfileoption("nc", "Format",  "NetCDF4")
    out_file1  = opath +"/"+"EP_FLUXES_"+tname+"_monthly_mean.nc"
    out_file2  = opath +"/"+"EP_FLUXES_"+cname+"_monthly_mean.nc"
    system("rm " + out_file1)
    system("rm " + out_file2)

    fout1 = addfile(out_file1,"c")
    fout2 = addfile(out_file2,"c")

    fout1->Fphi     = Fphi1
    fout2->Fphi     = Fphi2
    fout1->Fp       = Fp1
    fout2->Fp       = Fp2
    fout1->EPdiv    = EPdiv1
    fout2->EPdiv    = EPdiv2
    fout1->dudt     = dudt1
    fout2->dudt     = dudt2
   
    delete([/Fphi1,Fphi2,Fp1,Fp2,EPdiv1,EPdiv2,dudt1,dudt2,fout1,fout2/])
