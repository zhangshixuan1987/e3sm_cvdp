  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a table 
; Author : Po-Lun Ma
; Date   : Jan 21, 2013
;          Feb 04, 2020 - Jian Sun modified to make a table for individual aerosol in each mode

begin

  tpath                                       = getenv("TPATH")
  cpath                                       = getenv("CPATH")
  case2                                       = getenv("CTRL")
  case1                                       = getenv("TEST")
  casedir                                     = getenv("CASEDIR")
  mam42                                       = getenv("CMAM4")
  mam41                                       = getenv("TMAM4")

; constants used in this script                 

  pi                                          = 3.14159265
  rearth                                      = 6.37122e6
  grav                                        = 9.80665
  avgod                                       = 6.022e+23
  mwso4                                       = 115.0
  factaa                                      = mwso4*10.0/avgod        ; convert molec/cm2/s to kg/m2/s
  factaaa                                     = 12.0*10.0/avgod         ; convert molec/cm2/s to kg/m2/s
  factbb                                      = 86400.0*365.0*1e-9      ; convert kg/s to Tg/yr
  factcc                                      = factbb/mwso4*32.066     ; convert kg/s to TgS/yr
  factdd                                      = 32.066/mwso4*1e-9       ; convert kg to TgS

; variable name in the climo file

  vars                                        = (/"bc","dst","ncl","pom","so4","soa","mom"/)
  varnames                                    = (/"BC","DUST","SEASALT","POM","SO4","SOA","MOM"/)

  seas                                        = (/"ANN","DJF","JJA"/)

;read in two files

  do kk = 0, dimsizes(seas)-1
 
     f                                        = systemfunc("ls $CPATH/*"+seasons(kk)+"_climo.nc")
     f2                                       = addfile(f,"r")
     print(" input file: "+f) 
     
     f                                        = systemfunc("ls $TPATH/*"+seasons(kk)+"_climo.nc")
     f1                                       = addfile(f,"r")
     print(" input file: "+f) 
  
     ps1                                      = f1->PS
     ha1                                      = doubletofloat(f1->hyai)
     hb1                                      = doubletofloat(f1->hybi)
     p0                                       = doubletofloat(f1->P0)
     p1                                       = pres_hybrid_ccm(ps1,p0,ha1,hb1)
     gw1                                      = doubletofloat(f1->gw)
     
     ps2                                      = f2->PS
     ha2                                      = doubletofloat(f2->hyai)
     hb2                                      = doubletofloat(f2->hybi)
     p2                                       = pres_hybrid_ccm(ps2,p0,ha2,hb2)
     gw2                                      = doubletofloat(f2->gw)
 
;write out table

     do jj = 0, dimsizes(vars)-1

        do ii = 0, 1

;MAM4

           if  ( ii .eq. 0 ) then
               vara                           = (/vars(jj)+"_a1",vars(jj)+"_a2",vars(jj)+"_a3",vars(jj)+"_a4"/)    ; interstitial aerosols
           else
               vara                           = (/vars(jj)+"_c1",vars(jj)+"_c2",vars(jj)+"_c3",vars(jj)+"_c4"/)    ; cloud-borne aerosols
           end if

; mm indicates how many modes this species exist in 

           if  (vars(jj) .eq. "bc" .or. vars(jj) .eq. "pom") then
               mm                             = 3
           end if
           if  (vars(jj) .eq. "dst") then
               mm                             = 2
           end if
           if  (vars(jj) .eq. "so4" .or. vars(jj) .eq. "ncl" .or. vars(jj) .eq. "soa") then
               mm                             = 3 
           end if
           if  (vars(jj) .eq. "mom") then
               mm                             = 4
           end if

; choose the correct mode for some species ;

           do nm = 0, mm-1

              if  (vars(jj) .eq. "dst" .and. nm .eq. 1) then
                  vaer                        = vara(nm+1)         ; aerosol_mode name, read "_a3"
              else
                  vaer                        = vara(nm)
              end if
              if  (vars(jj) .eq. "bc" .or. vars(jj) .eq. "pom") then
                  if  (nm .eq. 1) then
                      vaer                    = vara(nm+2)         ; aerosol_mode name, read "_a4"
                  else
                      vaer                    = vara(nm)
                  end if
              end if
              vdry                            = vaer+"DDF"         ; dry deposition flux at surface, kg/m2/s
              vwet                            = vaer+"SFWET"       ; wet deposition flux at surface, kg/m2/s
              vemis                           = "SF"+vaer          ; surface emission,  kg/m2/s
              vemix                           = vaer+"_CLXF"       ; elevated emission, molec/cm2/s
              vgas                            = vaer+"_sfgaex1"    ; kg/m2/s
              vgvf                            = vaer+"GVF"         ; gravitational dry deposition 
              vtbf                            = vaer+"TBF"         ; turbulent dry deposition
              vwis                            = vaer+"SFSIS"       ; wet deposition (incloud, stratiform)
              vwic                            = vaer+"SFSIC"       ; wet deposition (incloud, convective)
              vwbs                            = vaer+"SFSBS"       ; wet deposition (belowcloud, stratiform)
              vwbc                            = vaer+"SFSBC"       ; wet deposition (belowcloud, convective)
              vwes                            = vaer+"SFSES"       ; wet deposition (precip evap, stratiform)
              vwec                            = vaer+"SFSEC"       ; wet deposition (precip evap, convective)
              vren                            = vaer+"_sfgaex2"    ; gas-aerosol-exchange renaming column tendency, "_sfgaex2"
              vcog                            = vaer+"_sfcoag1"    ; coagulation column tendency, "_sfcoag"
              vcs3                            = vaer+"_sfcsiz3"    ; calcsize aitken-to-accum adjust column tendency, "_sfcsiz3"
              vcs4                            = vaer+"_sfcsiz4"    ; calcsize accum-to-aitken adjust column tendency, "_sfcsiz4"
              vmnu                            = vaer+"_mixnuc1"    ; dropmixnuc mixnuc column tendency, _mixnuc1
              vaqa                            = vaer+"AQH2SO4"
              vaqb                            = vaer+"AQSO4"       
              vnuc                            = vaer+"_sfnnuc1"

; output file name and location

              output_file                     = (casedir+"/tables/"+vaer+"_"+seasons(kk)+".txt")

; define empty arrays to store the variables from data

              tmpp1                           = f1->$vaer$
              tmpp2                           = f2->$vaer$
              ddd1                            = dimsizes(tmpp1)
              ddd2                            = dimsizes(tmpp2)

              if  ( vaer .eq. vars(jj)+"_a3" ) then
                  vwes_a1                     = str_sub_str(vwes,vars(jj)+"_a3",vars(jj)+"_a1")
                  vwec_a1                     = str_sub_str(vwec,vars(jj)+"_a3",vars(jj)+"_a1")
                  vwes_a2                     = str_sub_str(vwes,vars(jj)+"_a3",vars(jj)+"_a2")
                  vwec_a2                     = str_sub_str(vwec,vars(jj)+"_a3",vars(jj)+"_a2")
                  vwes_a3                     = str_sub_str(vwes,vars(jj)+"_a3",vars(jj)+"_a3")
                  vwec_a3                     = str_sub_str(vwec,vars(jj)+"_a3",vars(jj)+"_a3")
                  vwes_a4                     = str_sub_str(vwes,vars(jj)+"_a3",vars(jj)+"_a4")
                  vwec_a4                     = str_sub_str(vwec,vars(jj)+"_a3",vars(jj)+"_a4")
                  vwes_c1                     = str_sub_str(vwes,vars(jj)+"_a3",vars(jj)+"_c1")
                  vwec_c1                     = str_sub_str(vwec,vars(jj)+"_a3",vars(jj)+"_c1")
                  vwes_c2                     = str_sub_str(vwes,vars(jj)+"_a3",vars(jj)+"_c2")
                  vwec_c2                     = str_sub_str(vwec,vars(jj)+"_a3",vars(jj)+"_c2")
                  vwes_c3                     = str_sub_str(vwes,vars(jj)+"_a3",vars(jj)+"_c3")
                  vwec_c3                     = str_sub_str(vwec,vars(jj)+"_a3",vars(jj)+"_c3")
                  vwes_c4                     = str_sub_str(vwes,vars(jj)+"_a3",vars(jj)+"_c4")
                  vwec_c4                     = str_sub_str(vwec,vars(jj)+"_a3",vars(jj)+"_c4")
                  vlist                       = [/vemis,vemix,vnuc,vaqa,vaqb,vdry,vgvf,vtbf,vwet,vwis, \
                                                  vwic,vwbs,vwbc,vwes_a1,vwec_a1,vwes_a2,vwec_a2,vwes_a3,\
						  vwec_a3,vwes_a4,vwec_a4,vwes_c1,vwec_c1,vwes_c2,vwec_c2,\
             					  vwes_c3,vwec_c3,vwes_c4,vwec_c4,vren,vcog,vcs3,vcs4,vmnu,vgas/]
              else
                  vlist                       = [/vemis,vemix,vnuc,vaqa,vaqb,vdry,vgvf,vtbf,vwet,vwis, \
                                                  vwic,vwbs,vwbc,vren,vcog,vcs3,vcs4,vmnu,vgas/]
              end if
              vnums                           = ListCount(vlist) 

              ammr1                           = new((/ddd1(1),ddd1(2),ddd1(3)/),float)
              tend1                           = new((/vnums,ddd1(2),ddd1(3)/),float)
              ammr2                           = new((/ddd2(1),ddd2(2),ddd2(3)/),float)
              tend2                           = new((/vnums,ddd2(2),ddd2(3)/),float)
              tend1@_FillValue                = -999.
              tend2@_FillValue                = -999.

              ammr1                           = 0.0
              tend1                           = 0.0
              ammr2                           = 0.0
              tend2                           = 0.0

              ammr1(:,:,:)                    = f1->$vaer$(0,:,:,:)
              ammr2(:,:,:)                    = f2->$vaer$(0,:,:,:)

              do  i = 0, vnums-1
                  if  ( isfilevar(f1, vlist[i]) ) then
                      tend1(i,:,:)            = (/f1->$vlist[i]$(0,:,:)/)

                      if  ( vlist[i] .eq. vdry .or. vlist[i] .eq. vgvf .or. vlist[i] .eq. vtbf ) then
                          tend1(i,:,:)        = -1. * tend1(i,:,:)    ; make dry deposition as sink
                      end if
                      if  ( vlist[i] .eq. vemix ) then
                          if  (vars(jj) .eq. "bc" .or. vars(jj) .eq. "pom") then
                              tend1(i,:,:)        = tend1(i,:,:)*factaaa   ; convert molec/cm2/s to kg/m2/s
                          else
                              tend1(i,:,:)        = tend1(i,:,:)*factaa    ; convert molec/cm2/s to kg/m2/s
  			  end if
                      end if
                  else
                      tend1(i,:,:)            = tend1@_FillValue
                  end if

                  if  ( isfilevar(f2, vlist[i]) ) then
                      tend2(i,:,:)            = (/f2->$vlist[i]$(0,:,:)/)

                      if  ( vlist[i] .eq. vdry .or. vlist[i] .eq. vgvf .or. vlist[i] .eq. vtbf ) then
                          tend2(i,:,:)        = -1. * tend2(i,:,:)    ; make dry deposition as sink
                      end if
                      if  ( vlist[i] .eq. vemix ) then
                          if  (vars(jj) .eq. "bc" .or. vars(jj) .eq. "pom") then
                              tend2(i,:,:)        = tend2(i,:,:)*factaaa   ; convert molec/cm2/s to kg/m2/s
			  else
                              tend2(i,:,:)        = tend2(i,:,:)*factaa    ; convert molec/cm2/s to kg/m2/s
  			  end if
                      end if
                  else
                      tend2(i,:,:)            = tend2@_FillValue
                  end if
              end do

; calculate aerosol burdens based on mean aerosol mixing ratios

              delp1                           = tmpp1
              delp2                           = tmpp2
              do k = 0, ddd1(1)-1
                 delp1(:,k,:,:)               = p1(:,k+1,:,:)-p1(:,k,:,:)
              end do
              do k = 0, ddd2(1)-1
                 delp2(:,k,:,:)               = p2(:,k+1,:,:)-p2(:,k,:,:)
              end do

              ammr1(:,:,:)                    = ammr1(:,:,:)*delp1(0,:,:,:)/grav
              ammr2(:,:,:)                    = ammr2(:,:,:)*delp2(0,:,:,:)/grav

; compute column integrated burden

              bvar1                           = dim_sum_n_Wrap(ammr1,0)
              bvar2                           = dim_sum_n_Wrap(ammr2,0)
              
              coo1                            = new((/ddd1(2)/),float)
              coo2                            = new((/ddd2(2)/),float)

; compute area-weighted source/sink for each grid

              do i = 0, ddd1(2)-1
                 coo1(i)                      = gw1(i)*(2.*pi/ddd1(3))*(rearth^2.)
              end do
              do i = 0, ddd1(2)-1
                 bvar1(i,:)                   = bvar1(i,:)*coo1(i)
                 do k = 0, vnums-1
                    tend1(k,i,:)              = tend1(k,i,:)*coo1(i)
                 end do
              end do
 
              do i = 0, ddd2(2)-1
                 coo2(i)                      = gw2(i)*(2.*pi/ddd2(3))*(rearth^2.)
              end do
              do i = 0, ddd2(2)-1
                 bvar2(i,:)                   = bvar2(i,:)*coo2(i)
                 do k = 0, vnums-1
                    tend2(k,i,:)              = tend2(k,i,:)*coo2(i)
                 end do
              end do

; prepare output table
; change unit from kg/m2/s to Tg/yr or TgS/yr

              outv1                           = new(vnums+4,float)
              outv2                           = new(vnums+4,float)
              outv1                           = 0.0
              outv2                           = 0.0
              outv1@_FillValue                = -999.
              outv2@_FillValue                = -999.

              do i = 0, vnums-1
                 k                            = i + 4                    ; reserve first four elements for source, sink, burden and lifetime
                 if  ( vars(jj) .eq. "so4" ) then
                     outv1(k)                 = sum(tend1(i,:,:))*factcc   ; convert kg/s to TgS/yr
                     outv2(k)                 = sum(tend2(i,:,:))*factcc   ; convert kg/s to TgS/yr
                 else
                     outv1(k)                 = sum(tend1(i,:,:))*factbb   ; convert kg/s to Tg/yr
                     outv2(k)                 = sum(tend2(i,:,:))*factbb   ; convert kg/s to Tg/yr
                 end if
                 if  ( vlist[i] .eq. vdry .or. vlist[i] .eq. vwet ) then
                     if  ( .not. ismissing(outv1(k)) ) then
                         if  (outv1(k) .gt. 0.) then
                             outv1(0)         = outv1(0) + outv1(k)
                         else
                             outv1(1)         = outv1(1) + outv1(k)
                         end if
                     end if
                     if  ( .not. ismissing(outv2(k)) ) then
                         if  (outv1(k) .gt. 0.) then
                             outv2(0)         = outv2(0) + outv2(k)
                         else
                             outv2(1)         = outv2(1) + outv2(k)
                         end if
                     end if
                 end if
                 if  ( vlist[i] .eq. vemis .or. vlist[i] .eq. vemix .or. \
                       vlist[i] .eq. vaqa  .or. vlist[i] .eq. vaqb  .or. \
                       vlist[i] .eq. vnuc ) then
                     if  ( .not. ismissing(outv1(k)) ) then
                         outv1(0)             = outv1(0) + outv1(k)
                     end if
                     if  ( .not. ismissing(outv2(k)) ) then
                         outv2(0)             = outv2(0) + outv2(k)
                     end if
                 end if  
                 if  ( vlist[i] .eq. vren .or. vlist[i] .eq. vcog .or. \
                       vlist[i] .eq. vcs3 .or. vlist[i] .eq. vcs4 .or. \
                       vlist[i] .eq. vmnu .or. vlist[i] .eq. vgas ) then
                     if  ( .not. ismissing(outv1(k)) ) then
                         if  ( outv1(k) .gt. 0. ) then
                             outv1(0)         = outv1(0) + outv1(k)
                         else
                             outv1(1)         = outv1(1) + outv1(k)
                         end if
                     end if

                     if  ( .not. ismissing(outv2(k)) ) then
                         if  ( outv2(k) .gt. 0. ) then
                             outv2(0)         = outv2(0) + outv2(k)
                         else
                             outv2(1)         = outv2(1) + outv2(k)
                         end if
                     end if
                 end if  
              end do
              if  ( vars(jj) .eq. "so4" ) then
                  outv1(2)                    = sum(bvar1(:,:))*factdd             ; burden, convert kg to TgS
                  outv1(3)                    = outv1(2)/fabs(outv1(1))*365.       ; lifetime
                  outv2(2)                    = sum(bvar2(:,:))*factdd             ; burden, convert kg to TgS
                  outv2(3)                    = outv2(2)/fabs(outv2(1))*365.       ; lifetime
              else
                  outv1(2)                    = sum(bvar1(:,:))*1e-9               ; burden, convert kg to Tg
                  outv1(3)                    = outv1(2)/fabs(outv1(1))*365.       ; lifetime
                  outv2(2)                    = sum(bvar2(:,:))*1e-9               ; burden, convert kg to Tg
                  outv2(3)                    = outv2(2)/fabs(outv2(1))*365.       ; lifetime
              end if
 
; write output to a table

              if  ( vars(jj) .eq. "so4" ) then
                  if  ( vaer .eq. vars(jj)+"_a3" ) then
                      vname = (/"Sources (TgS/yr)              ","Sinks (TgS/yr)                ","Burden (TgS)                  ",\
                                "Lifetime (days)               ",\
                                "  1. surface emission         ","  2. elevated emission        ","  3. new part. formation      ",\
                                "  4. cloudchem (AQH2SO4)      ","  5. cloudchem (AQSO4)        ",\
                                "  6. Dry deposition           ","    a. gravitational          ","    b. turbulent              ",\
                                "  7. Wet deposition           ","    a. incloud, stratiform    ","    b. incloud, convective    ",\
                                                                 "    c. belowcloud, strat.     ","    d. belowcloud, convec.    ",\
                                                                 "    e. _a1 rain evap., strat. ","    f. _a1 rain evap., convec.",\
                                                                 "    g. _a2 rain evap., strat. ","    h. _a2 rain evap., convec.",\
                                                                 "    i. _a3 rain evap., strat. ","    j. _a3 rain evap., convec.",\
                                                                 "    k. _a4 rain evap., strat. ","    l. _a4 rain evap., convec.",\
                                                                 "    m. _c1 rain evap., strat. ","    n. _c1 rain evap., convec.",\
                                                                 "    o. _c2 rain evap., strat. ","    p. _c2 rain evap., convec.",\
                                                                 "    q. _c3 rain evap., strat. ","    r. _c3 rain evap., convec.",\
                                                                 "    s. _c4 rain evap., strat. ","    t. _c4 rain evap., convec.",\
                                "  8. renaming (sfgaex2)       ","  9. coagulation (sfcoag1)    "," 10. calcsize (sfcsiz3)       ",\
                                " 11. calcsize (sfcsiz4)       "," 12. dropmixnuc (mixnuc1)     "," 13. condensation-aging       "/)
                  else
                      vname = (/"Sources (TgS/yr)              ","Sinks (TgS/yr)                ","Burden (TgS)                  ",\
                                "Lifetime (days)               ",\
                                "  1. surface emission         ","  2. elevated emission        ","  3. new part. formation      ",\
                                "  4. cloudchem (AQH2SO4)      ","  5. cloudchem (AQSO4)        ",\
                                "  6. Dry deposition           ","    a. gravitational          ","    b. turbulent              ",\
                                "  7. Wet deposition           ","    a. incloud, stratiform    ","    b. incloud, convective    ",\
                                                                 "    c. belowcloud, strat.     ","    d. belowcloud, convec.    ",\
                                "  8. renaming (sfgaex2)       ","  9. coagulation (sfcoag1)    "," 10. calcsize (sfcsiz3)       ",\
                                " 11. calcsize (sfcsiz4)       "," 12. dropmixnuc (mixnuc1)     "," 13. condensation-aging       "/)
		  end if
              else
                  if  ( vaer .eq. vars(jj)+"_a3" ) then
                      vname = (/"Sources (Tg/yr)               ","Sinks (Tg/yr)                 ","Burden (Tg)                   ",\
                                "Lifetime (days)               ",\
                                "  1. surface emission         ","  2. elevated emission        ","  3. new part. formation      ",\
                                "  4. cloudchem (AQH2SO4)      ","  5. cloudchem (AQSO4)        ",\
                                "  6. Dry deposition           ","    a. gravitational          ","    b. turbulent              ",\
                                "  7. Wet deposition           ","    a. incloud, stratiform    ","    b. incloud, convective    ",\
                                                                 "    c. belowcloud, strat.     ","    d. belowcloud, convec.    ",\
                                                                 "    e. _a1 rain evap., strat. ","    f. _a1 rain evap., convec.",\
                                                                 "    g. _a2 rain evap., strat. ","    h. _a2 rain evap., convec.",\
                                                                 "    i. _a3 rain evap., strat. ","    j. _a3 rain evap., convec.",\
                                                                 "    k. _a4 rain evap., strat. ","    l. _a4 rain evap., convec.",\
                                                                 "    m. _c1 rain evap., strat. ","    n. _c1 rain evap., convec.",\
                                                                 "    o. _c2 rain evap., strat. ","    p. _c2 rain evap., convec.",\
                                                                 "    q. _c3 rain evap., strat. ","    r. _c3 rain evap., convec.",\
                                                                 "    s. _c4 rain evap., strat. ","    t. _c4 rain evap., convec.",\
                                "  8. renaming (sfgaex2)       ","  9. coagulation (sfcoag1)    "," 10. calcsize (sfcsiz3)       ",\
                                " 11. calcsize (sfcsiz4)       "," 12. dropmixnuc (mixnuc1)     "," 13. condensation-aging       "/)
                  else
                      vname = (/"Sources (Tg/yr)               ","Sinks (Tg/yr)                 ","Burden (Tg)                   ",\
                                "Lifetime (days)               ",\
                                "  1. surface emission         ","  2. elevated emission        ","  3. new part. formation      ",\
                                "  4. cloudchem (AQH2SO4)      ","  5. cloudchem (AQSO4)        ",\
                                "  6. Dry deposition           ","    a. gravitational          ","    b. turbulent              ",\
                                "  7. Wet deposition           ","    a. incloud, stratiform    ","    b. incloud, convective    ",\
                                                                 "    c. belowcloud, strat.     ","    d. belowcloud, convec.    ",\
                                "  8. renaming (sfgaex2)       ","  9. coagulation (sfcoag1)    "," 10. calcsize (sfcsiz3)       ",\
                                " 11. calcsize (sfcsiz4)       "," 12. dropmixnuc (mixnuc1)     "," 13. condensation-aging       "/)
                  end if
              end if

              spaces                          = integertochar(32)        ; space
              sp0                             = new(30,"character")
              sp0                             = spaces
              spaces0                         = chartostring(sp0)

              nchr                            = dimsizes(stringtochar(case1))-1
              if  (nchr .lt. 12) then
                  sp1                         = new(16-nchr,"character")
                  sp1                         = spaces
                  spaces1                     = chartostring(sp1)
                  case1a                      = case1
              else
                  case1b                      = stringtochar(case1)
                  case1a                      = chartostring(case1b(:10))
                  sp1                         = new(5,"character")
                  sp1                         = spaces
                  spaces1                     = chartostring(sp1)
                  delete(case1b)
              end if

              nchr                            = dimsizes(stringtochar(case2))-1
              if  (nchr .lt. 12) then
                  sp2                         = new(16-nchr,"character")
                  sp2                         = spaces
                  spaces2                     = chartostring(sp2)
                  case2a                      = case2
              else
                  sp2                         = new(5,"character")
                  sp2                         = spaces
                  spaces2                     = chartostring(sp2)
                  case2b                      = stringtochar(case2)
                  case2a                      = chartostring(case2b(:10))
                  delete(case2b)
              end if
        
              lines                           = new(dimsizes(outv1)+4,"string")
              lines(0)                        = vaer
              lines(1)                        = spaces0+spaces1+case1a+spaces2+case2a+"      difference"+"     rel diff(%)"
              do  n = 0, dimsizes(outv1)-1
                  if  ( ismissing(outv1(n)) .or. ismissing(outv2(n)) ) then
                      lines(n+2)              = vname(n)+sprintf("%16.3f",outv1(n))+sprintf("%16.3f",outv2(n))+ \
                                                sprintf("%16.3f",-999.)+sprintf("%16.3f",-999.)
                  else
                      if  ( outv1(n) .eq. 0. ) then
                          lines(n+2)          = vname(n)+sprintf("%16.3f",outv1(n))+sprintf("%16.3f",outv2(n))+ \
                                                sprintf("%16.3f",(outv1(n)-outv2(n)))+ \
                                                sprintf("%16.3f",-999.)
                      else
                          lines(n+2)          = vname(n)+sprintf("%16.3f",outv1(n))+sprintf("%16.3f",outv2(n))+ \
                                                sprintf("%16.3f",(outv1(n)-outv2(n)))+ \
                                                sprintf("%16.3f",((outv1(n)-outv2(n))/outv1(n)*100.))
                      end if
                  end if
              end do

              dashlines                       = new(dimsizes(sp0)+16*4,"character")
              dashlines                       = integertochar(45)
              lines(dimsizes(outv1)+2)        = chartostring(dashlines)
              lines(dimsizes(outv1)+3)        = spaces0

              asciiwrite(output_file,lines)
 
              delete([/sp0,sp1,sp2,case1a,case2a,spaces0,lines,dashlines,vname,vlist,vemis,vemix,vgas,vnuc,vaqa,vaqb/])
              delete([/vaer,vdry,vgvf,vtbf,vwet,vwis,vwic,vwbs,vwbc,vwes,vwec,vren,vcog,vcs3,vcs4,vmnu/])
              delete([/output_file,tmpp1,tmpp2,ddd1,ddd2,delp1,delp2,bvar1,bvar2,coo1,coo2/])
              delete([/ammr1,tend1,ammr2,tend2,outv1,outv2/])

           end do  ; end of looping over modes for a species

        end do     ; end of looping over aerosol phase

     end do        ; end of looping over variables

     delete([/f,f2,f1,ps1,ha1,hb1,p0,p1,gw1,ps2,ha2,hb2,p2,gw2/])
     
  end do           ; end of looping over seasons

end
