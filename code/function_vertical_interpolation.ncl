;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This scripts document the shared information for vertical interpolation;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


       ps1                                     = f1->PS(:,{latS:latN},:)
       ha1                                     = doubletofloat(f1->hyam)
       hb1                                     = doubletofloat(f1->hybm)
       p0                                      = doubletofloat(f1->P0)
       p1                                      = pres_hybrid_ccm(ps1,p0,ha1,hb1)
       p1                                      = p1/100.
       p1@units                                = "hPa"
       gw1                                     = doubletofloat(f1->gw({latS:latN}))

       if(compare.eq."Model_vs_OBS") then

         f                                     = systemfunc("ls $CPATH/*_prelev_analysis_*_"+seasons(kk)+".nc")
         f2                                    = addfile(f,"r")
         ps2                                   = -9999.0
         p2                                    = f2->$obsvars(0)$(:,:,{latS:latN},:)
         varType                               = getfilevartypes(f2,"lev")
         if (varType.eq."double") then
           p2                                  = conform(f2->$obsvars(0)$(:,:,{latS:latN},:),doubletofloat(f2->lev),1)
         else
           p2                                  = conform(f2->$obsvars(0)$(:,:,{latS:latN},:),f2->lev,1)
         end if
         p2@units                              = "hPa"
         gw2                                   = doubletofloat(f2->gw({latS:latN}))

       else

         f                                     = systemfunc("ls $CPATH/*"+seasons(kk)+"_means.nc")
         f2                                    = addfile(f,"r")
         ps2                                   = f2->PS(:,{latS:latN},:)
         ha2                                   = doubletofloat(f2->hyam)
         hb2                                   = doubletofloat(f2->hybm)
         p2                                    = pres_hybrid_ccm(ps2,p0,ha2,hb2)
         p2                                    = p2/100.
         p2@units                              = "hPa"
         gw2                                   = doubletofloat(f2->gw({latS:latN}))

       end if


