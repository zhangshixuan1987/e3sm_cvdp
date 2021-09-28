;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;this scripts save the setups for the color levels for the map plot ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 unit                            = varunt(jj)

 if  ( pltvarnam .eq. "WIND_STRESS" ) then
   unit                            = varunt(jj)
   s1                              = (/0.0,.01,.02,.04,.06,.08,.1,.12,.14,.16,.18,.2,.24,.26,.28/)*1e2
   s2                              = (/-.08,-.06,-.04,-.02,-.01,0,.01,.02,.04,.06,.08/)*1e2
   magm_vec                        =  10.0
   magd_vec                        =   5.0

 else if  ( pltvarnam .eq. "WIND_1000" ) then

   s1                              = (/0,0.1,0.5,1,2,3,4,5,6,7,8,9,10,11,12/)*1.0
   s2                              = (/-5,-4,-3,-2,-1,0,1,2,3,4,5/)*1.0
   magm_vec                        =  5.0
   magd_vec                        =  1.0

 else if  ( pltvarnam .eq. "WIND_700" ) then

   s1                              = (/0,1,2,4,6,8,10,11,12,13,14,15,16,18,20/)*1.0
   s2                              = (/-5,-4,-3,-2,-1,0,1,2,3,4,5/)*1.0
   magm_vec                        =  10.0
   magd_vec                        =  2.0

 else if  ( pltvarnam .eq. "WIND_500" ) then

   s1                              = (/0,1,2,4,6,8,10,12,14,16,18,20,22,24,28/)*1.0
   s2                              = (/-5,-4,-3,-2,-1,0,1,2,3,4,5/)*1.0
   magm_vec                        =  20.0
   magd_vec                        =  2.0

 else if  ( pltvarnam .eq. "WIND_200" ) then

   s1                              = (/0,1,2,4,6,8,10,12,16,20,24,28,32,36,40/)*1.0
   s2                              = (/-8,-6,-4,-2,-1,0,1,2,4,6,8/)*1.0
   magm_vec                        =  30.0
   magd_vec                        =  4.0

 else
   print("ERROR: variable does not exist or can not be processed by this script")
   exit
 end if
 end if
 end if
 end if
 end if 

