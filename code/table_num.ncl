  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a table 
; Author : Po-Lun Ma
; Date   : Jan 21, 2013
;          Feb 05, 2020 - Jian Sun modified to make a table for aerosol number in each mode
;                         Followed Dick's method to divide total aerosol number by global air mass
;                         The correct unit for elevated emission column tendency should be particles/cm2/s * 6.022e26
;          Jun 09, 2020 - Jian Sun added the option for MAM5

begin

  tpath                                = getenv("TPATH")
  cpath                                = getenv("CPATH")
  case2                                = getenv("CTRL")
  case1                                = getenv("TEST")
  casedir                              = getenv("CASEDIR")
  cmam                                 = getenv("CMAM")
  tmam                                 = getenv("TMAM")

; sanity check
  if (str_upper(cmam) .ne. "MAM3" .and. str_upper(cmam) .ne. "MAM4" .and. str_upper(cmam) .ne. "MAM5") then
     print("Unsupported MAM version for control case: "+cmam)
  end if
  if (str_upper(tmam) .ne. "MAM3" .and. str_upper(tmam) .ne. "MAM4" .and. str_upper(tmam) .ne. "MAM5") then
     print("Unsupported MAM version for test case: "+tmam)
  end if

; constants used in this script          

  pi                                   = 3.14159265
  rearth                               = 6.37122e6
  grav                                 = 9.80665
  avgod                                = 6.022e+23
  factaa                               = 1.e4/(avgod*1.e3)
  factbb                               = 86400.0*365.0

; variable name in the climo file

  seas                                 = (/"ANN","DJF","JJA"/)

;read in two files

  do kk = 0, dimsizes(seas)-1
 
     f                                 = systemfunc("ls $CPATH/*"+seasons(kk)+"_climo.nc")
     f2                                = addfile(f,"r")
     print(" input file: "+f) 
     
     f                                 = systemfunc("ls $TPATH/*"+seasons(kk)+"_climo.nc")
     f1                                = addfile(f,"r")
     print(" input file: "+f) 
  
     ps1                               = f1->PS
     ps11                              = ps1
     ha1                               = doubletofloat(f1->hyai)
     hb1                               = doubletofloat(f1->hybi)
     p0                                = doubletofloat(f1->P0)
     p1                                = pres_hybrid_ccm(ps1,p0,ha1,hb1)
     gw1                               = doubletofloat(f1->gw)
    
 
     ps2                               = f2->PS
     ps22                              = ps2
     ha2                               = doubletofloat(f2->hyai)
     hb2                               = doubletofloat(f2->hybi)
     p2                                = pres_hybrid_ccm(ps2,p0,ha2,hb2)
     gw2                               = doubletofloat(f2->gw)

; output file name and location

     output_mfile                      = (casedir+"/tables/num_"+seasons(kk)+".txt")

;write out table

     do ii = 0, 1

        if  ( ii .eq. 0 ) then
            vara                       = (/"num_a1","num_a2","num_a3","num_a4","num_a5"/)    ; interstitial aerosols
        else
            vara                       = (/"num_c1","num_c2","num_c3","num_c4","num_c5"/)    ; cloud-borne aerosols
        end if
        mm                             = dimsizes(vara)

; choose the correct mode for some species ;

        do nm = 0, mm-1

           vaer                        = vara(nm)
           vdry                        = vaer+"DDF"         ; dry deposition flux at surface, kg/m2/s
           vwet                        = vaer+"SFWET"       ; wet deposition flux at surface, kg/m2/s
           vemis                       = "SF"+vaer          ; surface emission,  kg/m2/s
           vemix                       = vaer+"_CLXF"       ; elevated emission, molec/cm2/s
           vgas                        = vaer+"_sfgaex1"    ; kg/m2/s
           vgvf                        = vaer+"GVF"         ; gravitational dry deposition 
           vtbf                        = vaer+"TBF"         ; turbulent dry deposition
           vwis                        = vaer+"SFSIS"       ; wet deposition (incloud, stratiform)
           vwic                        = vaer+"SFSIC"       ; wet deposition (incloud, convective)
           vwbs                        = vaer+"SFSBS"       ; wet deposition (belowcloud, stratiform)
           vwbc                        = vaer+"SFSBC"       ; wet deposition (belowcloud, convective)
           vwes                        = vaer+"SFSES"       ; wet deposition (precip evap, stratiform)
           vwec                        = vaer+"SFSEC"       ; wet deposition (precip evap, convective)
           vren                        = vaer+"_sfgaex2"    ; gas-aerosol-exchange renaming column tendency, "_sfgaex2"
           vcog                        = vaer+"_sfcoag1"    ; coagulation column tendency, "_sfcoag"
           vcs1                        = vaer+"_sfcsiz1"    ; calcsize number-adjust column source
           vcs2                        = vaer+"_sfcsiz2"    ; calcsize number-adjust column sink
           vcs3                        = vaer+"_sfcsiz3"    ; calcsize aitken-to-accum adjust column tendency, "_sfcsiz3"
           vcs4                        = vaer+"_sfcsiz4"    ; calcsize accum-to-aitken adjust column tendency, "_sfcsiz4"
           vmnu                        = vaer+"_mixnuc1"    ; dropmixnuc mixnuc column tendency, _mixnuc1
           vaqa                        = vaer+"AQH2SO4"
           vaqb                        = vaer+"AQSO4"       
           vnuc                        = vaer+"_sfnnuc1"

; output file name and location

           output_file                 = (casedir+"/tables/"+vaer+"_"+seasons(kk)+".txt")

; define empty arrays to store the variables from data

           vlist                       = [/vemis,vemix,vnuc,vaqa,vaqb,vdry,vgvf,vtbf,vwet,vwis,vwic, \
                                           vwbs,vwbc,vwes,vwec,vren,vcog,vcs1,vcs2,vcs3,vcs4,vmnu,vgas/]
           vnums                       = ListCount(vlist) 

           if  ( nm .eq. 0 ) then
               tmpp1                   = f1->$vaer$
               tmpp2                   = f2->$vaer$
               ddd1                    = dimsizes(tmpp1)
               ddd2                    = dimsizes(tmpp2)

               ammr1                   = new((/mm,ddd1(1),ddd1(2),ddd1(3)/),float)
               tend1                   = new((/mm,vnums,ddd1(2),ddd1(3)/),float)
               ammr2                   = new((/mm,ddd2(1),ddd2(2),ddd2(3)/),float)
               tend2                   = new((/mm,vnums,ddd2(2),ddd2(3)/),float)
               tend1@_FillValue        = -999.
               tend2@_FillValue        = -999.

               ammr1                   = 0.0
               tend1                   = 0.0
               ammr2                   = 0.0
               tend2                   = 0.0
           end if

           if  ( isfilevar(f1, vaer) ) then
               ammr1(nm,:,:,:)         = f1->$vaer$
           end if
           if  ( isfilevar(f2, vaer) ) then
               ammr2(nm,:,:,:)         = f2->$vaer$
           end if

           do  i = 0, vnums-1
               if  ( isfilevar(f1, vlist[i]) ) then
                   tend1(nm,i,:,:)     = (/f1->$vlist[i]$(0,:,:)/)

                   if  ( vlist[i] .eq. vdry .or. vlist[i] .eq. vgvf .or. vlist[i] .eq. vtbf ) then
                       tend1(nm,i,:,:) = -1. * tend1(nm,i,:,:)
                   end if
                   if  ( vlist[i] .eq. vemix ) then
                       tend1(nm,i,:,:) = tend1(nm,i,:,:)*factaa 
                   end if
               else
                   tend1(nm,i,:,:)     = tend1@_FillValue    
               end if
               if  ( isfilevar(f2, vlist[i]) ) then
                   tend2(nm,i,:,:)     = (/f2->$vlist[i]$(0,:,:)/)

                   if  ( vlist[i] .eq. vdry .or. vlist[i] .eq. vgvf .or. vlist[i] .eq. vtbf ) then
                       tend2(nm,i,:,:) = -1. * tend2(nm,i,:,:)
                   end if
                   if  ( vlist[i] .eq. vemix ) then
                       tend2(nm,i,:,:) = tend2(nm,i,:,:)*factaa
                   end if
               else
                   tend2(nm,i,:,:)     = tend2@_FillValue    
               end if
           end do

; calculate aerosol burdens based on mean aerosol mixing ratios

           delp1                       = tmpp1
           delp2                       = tmpp2
           do k = 0, ddd1(1)-1
              delp1(:,k,:,:)           = p1(:,k+1,:,:)-p1(:,k,:,:)
           end do
           do k = 0, ddd2(1)-1
              delp2(:,k,:,:)           = p2(:,k+1,:,:)-p2(:,k,:,:)
           end do

           ammr1(nm,:,:,:)             = ammr1(nm,:,:,:)*delp1(0,:,:,:)/grav
           ammr2(nm,:,:,:)             = ammr2(nm,:,:,:)*delp2(0,:,:,:)/grav

; compute column integrated burden

           bvar1                       = dim_sum_n_Wrap(ammr1,1)
           bvar2                       = dim_sum_n_Wrap(ammr2,1)
           
           coo1                        = new((/ddd1(2)/),float)
           coo2                        = new((/ddd2(2)/),float)

; compute area-weighted source/sink for each grid

           do i = 0, ddd1(2)-1
              coo1(i)                  = gw1(i)*(2.*pi/ddd1(3))*rearth^2.
           end do
           do i = 0, ddd1(2)-1
              bvar1(nm,i,:)            = bvar1(nm,i,:)*coo1(i)
              do k = 0, vnums-1
                 tend1(nm,k,i,:)       = tend1(nm,k,i,:)*coo1(i)
              end do
              ps11(:,i,:)              = ps1(:,i,:)*coo1(i)
           end do
           sum_airmass1                = sum(ps11)/grav*1.e6

           do i = 0, ddd2(2)-1
              coo2(i)                  = gw2(i)*(2.*pi/ddd2(3))*rearth^2.
           end do
           do i = 0, ddd2(2)-1
              bvar2(nm,i,:)            = bvar2(nm,i,:)*coo2(i)
              do k = 0, vnums-1
                 tend2(nm,k,i,:)       = tend2(nm,k,i,:)*coo2(i)
              end do
              ps22(:,i,:)              = ps2(:,i,:)*coo2(i)
           end do
           sum_airmass2                = sum(ps22)/grav *1.e6

; prepare output table
; change unit from #/m2/s to #/mg-air/yr

           outv1                       = new(vnums+4,float)
           outv2                       = new(vnums+4,float)
           outv1                       = 0.0
           outv2                       = 0.0
           outv1@_FillValue            = -999.
           outv2@_FillValue            = -999.
           if  ( nm .eq. 0 .and. ii .eq. 0 ) then
               outv11                  = new(vnums+4,float)
               outv22                  = new(vnums+4,float)
               outv11                  = 0.0
               outv22                  = 0.0
               outv11@_FillValue       = -999.
               outv22@_FillValue       = -999.
           end if

           do i = 0, vnums-1
              k                        = i + 4            ; reserve first four elements for source, sink, burden and lifetime
              outv1(k)                 = sum(tend1(nm,i,:,:))*factbb
              outv2(k)                 = sum(tend2(nm,i,:,:))*factbb
              if  ( vlist[i] .eq. vdry .or. vlist[i] .eq. vwet ) then
                  if  ( .not. ismissing(outv1(k)) ) then
                      outv1(1)         = outv1(1) + outv1(k)
                  end if
                  if  ( .not. ismissing(outv2(k)) ) then
                      outv2(1)         = outv2(1) + outv2(k)
                  end if
              end if
              if  ( vlist[i] .eq. vemis .or. vlist[i] .eq. vemix .or. \
                    vlist[i] .eq. vaqa  .or. vlist[i] .eq. vaqb  .or. \
                    vlist[i] .eq. vnuc ) then
                  if  ( .not. ismissing(outv1(k)) ) then
                      outv1(0)         = outv1(0) + outv1(k)
                  end if
                  if  ( .not. ismissing(outv2(k)) ) then
                      outv2(0)         = outv2(0) + outv2(k)
                  end if
              end if  
              if  ( vlist[i] .eq. vren .or. vlist[i] .eq. vcog .or. \
                    vlist[i] .eq. vcs1 .or. vlist[i] .eq. vcs2 .or. \
                    vlist[i] .eq. vcs3 .or. vlist[i] .eq. vcs4 .or. \
                    vlist[i] .eq. vmnu .or. vlist[i] .eq. vgas ) then
                  if  ( .not. ismissing(outv1(k)) ) then
                      if  ( outv1(k) .gt. 0. ) then
                          outv1(0)     = outv1(0) + outv1(k)
                      else
                          outv1(1)     = outv1(1) + outv1(k)
                      end if
                  end if

                  if  ( .not. ismissing(outv2(k)) ) then
                      if  ( outv2(k) .gt. 0. ) then
                          outv2(0)     = outv2(0) + outv2(k)
                      else
                          outv2(1)     = outv2(1) + outv2(k)
                      end if
                  end if
              end if  
           end do
           outv1(2)                    = sum(bvar1(nm,:,:))                  ; burden
           outv2(2)                    = sum(bvar2(nm,:,:))                  ; burden
           outv1(:)                    = outv1(:)/sum_airmass1
           outv2(:)                    = outv2(:)/sum_airmass2

           do i = 0, vnums+3
              if  ( .not. ismissing(outv1(i)) ) then
                  outv11(i)            = outv11(i) + outv1(i)
              end if
              if  ( .not. ismissing(outv2(i)) ) then
                  outv22(i)            = outv22(i) + outv2(i)
              end if
           end do

; recalculate the source and sink terms of total aerosol by summing over the individual term  
           if  ( nm .eq. mm-1 .and. ii .eq. 1 ) then
               outv11(0)               = 0. 
               outv11(1)               = 0. 
               outv22(0)               = 0. 
               outv22(1)               = 0. 
               do i = 0, vnums-1
                  k                    = i + 4
                  if  ( vlist[i] .eq. vdry .or. vlist[i] .eq. vwet ) then
                      if  ( .not. ismissing(outv11(k)) ) then
                          outv11(1)    = outv11(1) + outv11(k)
                      end if
                      if  ( .not. ismissing(outv22(k)) ) then
                          outv22(1)    = outv22(1) + outv22(k)
                      end if
                  end if
                  if  ( vlist[i] .eq. vemis .or. vlist[i] .eq. vemix .or. \
                        vlist[i] .eq. vaqa  .or. vlist[i] .eq. vaqb  .or. \
                        vlist[i] .eq. vnuc ) then
                      if  ( .not. ismissing(outv11(k)) ) then
                          outv11(0)    = outv11(0) + outv11(k)
                      end if
                      if  ( .not. ismissing(outv22(k)) ) then
                          outv22(0)    = outv22(0) + outv22(k)
                      end if
                  end if
                  if  ( vlist[i] .eq. vren .or. vlist[i] .eq. vcog .or. \
                        vlist[i] .eq. vcs1 .or. vlist[i] .eq. vcs2 .or. \
                        vlist[i] .eq. vcs3 .or. vlist[i] .eq. vcs4 .or. \
                        vlist[i] .eq. vmnu .or. vlist[i] .eq. vgas ) then
                      if  ( .not. ismissing(outv11(k)) ) then
                          if ( outv11(k) .gt. 0. ) then
                             outv11(0) = outv11(0) + outv11(k)
                          else
                             outv11(1) = outv11(1) + outv11(k)
                          end if
                      end if

                      if  ( .not. ismissing(outv22(k)) ) then
                          if ( outv22(k) .gt. 0. ) then
                             outv22(0) = outv22(0) + outv22(k)
                          else
                             outv22(1) = outv22(1) + outv22(k)
                          end if
                      end if
                  end if
               end do
           end if

; calculate the lifetime

           if  ( fabs(outv1(1)) .eq. 0. ) then 
               outv1(3)                = outv1@_FillValue                    ; lifetime
           else
               outv1(3)                = outv1(2)/fabs(outv1(1))*365.        ; lifetime
           end if
           if  ( fabs(outv2(1)) .eq. 0. ) then
               outv2(3)                = outv2@_FillValue                    ; lifetime
           else
               outv2(3)                = outv2(2)/fabs(outv2(1))*365.        ; lifetime
           end if
           if  ( fabs(outv11(1)) .eq. 0. ) then
               outv11(3)               = outv11@_FillValue                   ; lifetime
           else
               outv11(3)               = outv11(2)/fabs(outv11(1))*365.      ; lifetime
           end if
           if  ( fabs(outv22(1)) .eq. 0. ) then
               outv22(3)               = outv22@_FillValue                   ; lifetime
           else
               outv22(3)               = outv22(2)/fabs(outv22(1))*365.      ; lifetime
           end if

; write output to a table

           vname      = (/"Sources (#/mg-air/yr)     ","Sinks (#/mg-air/yr)       ","Burden (#/mg-air)         ","Lifetime (days)           ",\
                          "  1. surface emission     ","  2. elevated emission    ","  3. new part. formation  ",\
                          "  4. cloudchem (AQH2SO4)  ","  5. cloudchem (AQSO4)    ",\
                          "  6. Dry deposition       ","    a. gravitational      ","    b. turbulent          ",\
                          "  7. Wet deposition       ","    a. incloud, stratiform","    b. incloud, convective",\
                                                       "    c. belowcloud, strat. ","    d. belowcloud, convec.",\
                                                       "    e. rain evap, strat.  ","    f. rain evap, convec. ",\
                          "  8. renaming (sfgaex2)   ","  9. coagulation (sfcoag1)"," 10. calcsize (sfcsiz1)   "," 11. calcsize (sfcsiz2)   ",\
                          " 12. calcsize (sfcsiz3)   "," 13. calcsize (sfcsiz4)   "," 14. dropmixnuc (mixnuc1) "," 15. condensation-aging   "/)

           spaces                      = integertochar(32)        ; space
           sp0                         = new(26,"character")
           sp0                         = spaces
           spaces0                     = chartostring(sp0)

           nchr                        = dimsizes(stringtochar(case1))-1
           if  (nchr .lt. 12) then
               sp1                     = new(16-nchr,"character")
               sp1                     = spaces
               spaces1                 = chartostring(sp1)
               case1a                  = case1
           else
               case1b                  = stringtochar(case1)
               case1a                  = chartostring(case1b(:10))
               sp1                     = new(5,"character")
               sp1                     = spaces
               spaces1                 = chartostring(sp1)
               delete(case1b)
           end if

           nchr                        = dimsizes(stringtochar(case2))-1
           if  (nchr .lt. 12) then
               sp2                     = new(16-nchr,"character")
               sp2                     = spaces
               spaces2                 = chartostring(sp2)
               case2a                  = case2
           else
               sp2                     = new(5,"character")
               sp2                     = spaces
               spaces2                 = chartostring(sp2)
               case2b                  = stringtochar(case2)
               case2a                  = chartostring(case2b(:10))
               delete(case2b)
           end if
        
           lines                       = new(dimsizes(outv1)+4,"string")
           lines(0)                    = vaer
           lines(1)                    = spaces0+spaces1+case1a+spaces2+case2a+"      difference"+"     rel diff(%)"
           do  n = 0, dimsizes(outv1)-1
               if  ( ismissing(outv1(n)) .or. ismissing(outv2(n)) ) then
                   lines(n+2)          = vname(n)+sprintf("%16.3f",outv1(n))+sprintf("%16.3f",outv2(n))+ \
                                         sprintf("%16.3f",-999.)+sprintf("%16.3f",-999.)
               else
                  if  ( outv1(n) .eq. 0. ) then
                      lines(n+2)       = vname(n)+sprintf("%16.3f",outv1(n))+sprintf("%16.3f",outv2(n))+ \
                                         sprintf("%16.3f",(outv1(n)-outv2(n)))+ \
                                         sprintf("%16.3f",-999.)
                  else
                      lines(n+2)       = vname(n)+sprintf("%16.3f",outv1(n))+sprintf("%16.3f",outv2(n))+ \
                                         sprintf("%16.3f",(outv1(n)-outv2(n)))+ \
                                         sprintf("%16.3f",((outv1(n)-outv2(n))/outv1(n)*100.))
                  end if
               end if
           end do

           dashlines                   = new(dimsizes(sp0)+16*4,"character")
           dashlines                   = integertochar(45)
           lines(dimsizes(outv1)+2)    = chartostring(dashlines)
           lines(dimsizes(outv1)+3)    = spaces0

           asciiwrite(output_file,lines)
 
           delete([/sp0,sp1,sp2,lines,vname,vlist,vemis,vemix,vgas,vnuc,vaqa,vaqb/])
           delete([/vaer,vdry,vgvf,vtbf,vwet,vwis,vwic,vwbs,vwbc,vwes,vwec,vren,vcog,vcs3,vcs4,vmnu/])
           delete([/outv1,outv2,output_file,delp1,delp2,bvar1,bvar2,coo1,coo2/])

        end do     ; end of looping over variables

        delete([/ammr1,tend1,ammr2,tend2,tmpp1,tmpp2,ddd1,ddd2/])

     end do        ; end of looping over aerosol phase 

; write total a+c to table

     vname      = (/"Sources (#/mg-air/yr)     ","Sinks (#/mg-air/yr)       ","Burden (#/mg-air)         ","Lifetime (days)           ",\
                    "  1. surface emission     ","  2. elevated emission    ","  3. new part. formation  ",\
                    "  4. cloudchem (AQH2SO4)  ","  5. cloudchem (AQSO4)    ",\
                    "  6. Dry deposition       ","    a. gravitational      ","    b. turbulent          ",\
                    "  7. Wet deposition       ","    a. incloud, stratiform","    b. incloud, convective",\
                                                 "    c. belowcloud, strat. ","    d. belowcloud, convec.",\
                                                 "    e. rain evap, strat.  ","    f. rain evap, convec. ",\
                    "  8. renaming (sfgaex2)   ","  9. coagulation (sfcoag1)"," 10. calcsize (sfcsiz1)   "," 11. calcsize (sfcsiz2)   ",\
                    " 12. calcsize (sfcsiz3)   "," 13. calcsize (sfcsiz4)   "," 14. dropmixnuc (mixnuc1) "," 15. condensation-aging   "/)

     lines                             = new(dimsizes(outv11)+4,"string")
     lines(0)                          = "Total a+c"
     lines(1)                          = spaces0+spaces1+case1a+spaces2+case2a+"      difference"+"     rel diff(%)"
     do  n = 0, dimsizes(outv11)-1
         if  ( ismissing(outv11(n)) .or. ismissing(outv22(n)) ) then
             lines(n+2)                = vname(n)+sprintf("%16.3f",outv11(n))+sprintf("%16.3f",outv22(n))+ \
                                         sprintf("%16.3f",-999.)+sprintf("%16.3f",-999.)
         else
            if  ( outv11(n) .eq. 0. ) then
                lines(n+2)             = vname(n)+sprintf("%16.3f",outv11(n))+sprintf("%16.3f",outv22(n))+ \
                                         sprintf("%16.3f",(outv11(n)-outv22(n)))+ \
                                         sprintf("%16.3f",-999.)
            else                         
                lines(n+2)             = vname(n)+sprintf("%16.3f",outv11(n))+sprintf("%16.3f",outv22(n))+ \
                                         sprintf("%16.3f",(outv11(n)-outv22(n)))+ \
                                         sprintf("%16.3f",((outv11(n)-outv22(n))/outv11(n)*100.))
            end if                 
         end if                    
     end do 
     lines(dimsizes(outv11)+2)         = chartostring(dashlines)
     lines(dimsizes(outv11)+3)         = spaces0
           
     asciiwrite(output_mfile,lines)

     delete([/vname,outv11,outv22,spaces0,spaces1,case1a,spaces2,case2a/])
     delete([/output_mfile,lines,f,f2,f1,ps1,ha1,hb1,p0,p1,gw1,ps2,ha2,hb2,p2,gw2,ps11,ps22/])
     
  end do           ; end of looping over seasons

end
