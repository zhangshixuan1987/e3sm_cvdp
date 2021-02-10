  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; Purpose: A tempolate to make a table 
; Author : Po-Lun Ma
; Date   : Jan 21, 2013
;          Apr 13, 2020 - Jian Sun changed the sign of sink terms to negative

begin

  tpath                         = getenv("TPATH")
  cpath                         = getenv("CPATH")
  case2                         = getenv("CTRL")
  case1                         = getenv("TEST")
  casedir                       = getenv("CASEDIR")
  mam42                         = getenv("CMAM4")
  mam41                         = getenv("TMAM4")

; constants used in this script   

  pi                            = 3.14159265
  rearth                        = 6.37122e6
  grav                          = 9.81
  avgod                         = 6.023e+23
  mwso4                         = 115.0
  factaa                        = 86400.0*365.0*1e-9
  factbb                        = factaa/mwso4*32.066
  factcc                        = 32.066/mwso4*1e-9

; variable name in the climo file

  vars                          = (/"bc","dst","ncl","pom","so4","soa","mom"/)
  varnames                      = (/"BC","DUST","SEASALT","POM","SO4","SOA","MOM"/)

  seas                          = (/"ANN","DJF","JJA"/)

;read in two files

  do kk = 0, dimsizes(seas)-1
 
     f                          = systemfunc("ls $CPATH/*"+seasons(kk)+"_climo.nc")
     f2                         = addfile(f,"r")
     print(" input file: "+f) 
     
     f                          = systemfunc("ls $TPATH/*"+seasons(kk)+"_climo.nc")
     f1                         = addfile(f,"r")
     print(" input file: "+f) 
  
;write out table

     do jj = 0, dimsizes(vars)-1
 
        output_file             = (casedir+"/tables/"+vars(jj)+"_"+seasons(kk)+".txt")

;MAM4

        vara                    = (/vars(jj)+"_a1",vars(jj)+"_a2",vars(jj)+"_a3",vars(jj)+"_a4"/)
        varc                    = (/vars(jj)+"_c1",vars(jj)+"_c2",vars(jj)+"_c3",vars(jj)+"_c4"/)

; mm indicates how many modes this species exist in 

        if (vars(jj) .eq. "bc" .or. vars(jj) .eq. "pom") then
           mm                   = 3
        end if
        if (vars(jj) .eq. "dst") then
           mm                   = 2
        end if
        if (vars(jj) .eq. "so4" .or. vars(jj) .eq. "ncl" .or. vars(jj) .eq. "soa") then
           mm                   = 3 
        end if
        if (vars(jj) .eq. "mom") then
           mm                   = 4
        end if

;define vara and varc

        vinta                   = new(mm,string)       ; interstitial aerosols
        vidry                   = new(mm,string)       ; dry deposition
        vigvf                   = new(mm,string)       ; gravitational dry deposition
        vitbf                   = new(mm,string)       ; turbulent dry deposition
        viwet                   = new(mm,string)       ; wet deposition
        viwis                   = new(mm,string)       ; wet deposition (incloud, stratiform)
        viwic                   = new(mm,string)       ; wet deposition (incloud, convective)
        viwbs                   = new(mm,string)       ; wet deposition (belowcloud, stratiform)
        viwbc                   = new(mm,string)       ; wet deposition (belowcloud, convective)
        viwes                   = new(mm,string)       ; wet deposition (precip evap, stratiform)
        viwec                   = new(mm,string)       ; wet deposition (precip evap, convective)
        vemis                   = new(mm,string)       ; surface emission
        vemix                   = new(mm,string)       ; elevated emission
        vgas                    = new(mm,string)       ; gas-aerosol-exchange primary column tendency, "_sfgaex1" 
        vnuc                    = "so4_a2_sfnnuc1"     ; nucleation column tendency, kg/m2/s
   
        vcba                    = new(mm,string)       ; cloud-borne aerosols
        vcdry                   = new(mm,string)       ; dry deposition
        vcgvf                   = new(mm,string)       ; gravitational dry deposition 
        vctbf                   = new(mm,string)       ; turbulent dry deposition
        vcwet                   = new(mm,string)       ; wet deposition
        vcwis                   = new(mm,string)       ; wet deposition (incloud, stratiform)
        vcwic                   = new(mm,string)       ; wet deposition (incloud, convective)
        vcwbs                   = new(mm,string)       ; wet deposition (belowcloud, stratiform)
        vcwbc                   = new(mm,string)       ; wet deposition (belowcloud, convective)
        vcwes                   = new(mm,string)       ; wet deposition (precip evap, stratiform)
        vcwec                   = new(mm,string)       ; wet deposition (precip evap, convective)
        vcaqa                   = new(mm,string)       ; aqueous phase chemistry, "AQH2SO4"
        vcaqb                   = new(mm,string)       ; aqueous phase chemistry, "AQSO4"

; choose the correct mode for some species ;

        do nm = 0, mm-1
           if (vars(jj) .eq. "dst" .and. nm .eq. 1) then
              vinta(nm)         = vara(nm+1)
              vcba(nm)          = varc(nm+1)
           else
              vinta(nm)         = vara(nm)
              vcba(nm)          = varc(nm)
           end if
           if (vars(jj) .eq. "bc" .or. vars(jj) .eq. "pom") then
              if (nm .eq. 1) then
                 vinta(nm)      = vara(nm+2)
                 vcba(nm)       = varc(nm+2)
              else
                 vinta(nm)      = vara(nm)
                 vcba(nm)       = varc(nm)
              end if
           end if
       
           vidry(nm)            = vinta(nm)+"DDF"         ; dry deposition flux at surface, kg/m2/s
           viwet(nm)            = vinta(nm)+"SFWET"       ; wet deposition flux at surface, kg/m2/s
           vemis(nm)            = "SF"+vinta(nm)          ; surface emission,  kg/m2/s
           vemix(nm)            = vinta(nm)+"_CLXF"       ; elevated emission, molec/cm2/s
           vgas(nm)             = vinta(nm)+"_sfgaex1"    ; kg/m2/s
           vigvf(nm)            = vinta(nm)+"GVF"         ; gravitational dry deposition 
           vitbf(nm)            = vinta(nm)+"TBF"         ; turbulent dry deposition
           viwis(nm)            = vinta(nm)+"SFSIS"       ; wet deposition (incloud, stratiform)
           viwic(nm)            = vinta(nm)+"SFSIC"       ; wet deposition (incloud, convective)
           viwbs(nm)            = vinta(nm)+"SFSBS"       ; wet deposition (belowcloud, stratiform)
           viwbc(nm)            = vinta(nm)+"SFSBC"       ; wet deposition (belowcloud, convective)
           viwes(nm)            = vinta(nm)+"SFSES"       ; wet deposition (precip evap, stratiform)
           viwec(nm)            = vinta(nm)+"SFSEC"       ; wet deposition (precip evap, convective)

           vcdry(nm)            = vcba(nm)+"DDF"          ; dry deposition flux at surface
           vcwet(nm)            = vcba(nm)+"SFWET"        ; wet deposition flux at surface
           vcaqa(nm)            = vcba(nm)+"AQH2SO4"      ; kg/m2/s
           vcaqb(nm)            = vcba(nm)+"AQSO4"        ; kg/m2/s
           vcgvf(nm)            = vcba(nm)+"GVF"          ; gravitational dry deposition
           vctbf(nm)            = vcba(nm)+"TBF"          ; turbulent dry deposition
           vcwis(nm)            = vcba(nm)+"SFSIS"        ; wet deposition (incloud, stratiform)
           vcwic(nm)            = vcba(nm)+"SFSIC"        ; wet deposition (incloud, convective)
           vcwbs(nm)            = vcba(nm)+"SFSBS"        ; wet deposition (belowcloud, stratiform)
           vcwbc(nm)            = vcba(nm)+"SFSBC"        ; wet deposition (belowcloud, convective)
           vcwes(nm)            = vcba(nm)+"SFSES"        ; wet deposition (precip evap, stratiform)
           vcwec(nm)            = vcba(nm)+"SFSEC"        ; wet deposition (precip evap, convective)
        end do

;read in variables from data

        tmpp1                   = f1->$vinta(0)$
        tmpp2                   = f2->$vinta(0)$
 
        ddd1                    = dimsizes(tmpp1)
        ddd2                    = dimsizes(tmpp2)
 
        vint1m                  = new((/mm,ddd1(1),ddd1(2),ddd1(3)/),float)
        vcba1m                  = new((/mm,ddd1(1),ddd1(2),ddd1(3)/),float)
        dryi1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        dryc1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        weti1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wetc1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        emis1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        emix1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        vgas1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        vaqu1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        gvfi1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        gvfc1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        tbfi1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        tbfc1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wisi1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wisc1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wici1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wicc1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wbsi1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wbsc1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wbci1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wbcc1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wesi1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wesc1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        weci1                   = new((/mm,ddd1(2),ddd1(3)/),float)
        wecc1                   = new((/mm,ddd1(2),ddd1(3)/),float)

        vint2m                  = new((/mm,ddd2(1),ddd2(2),ddd2(3)/),float)
        vcba2m                  = new((/mm,ddd2(1),ddd2(2),ddd2(3)/),float)
        dryi2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        dryc2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        weti2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wetc2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        emis2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        emix2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        vgas2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        vaqu2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        gvfi2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        gvfc2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        tbfi2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        tbfc2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wisi2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wisc2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wici2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wicc2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wbsi2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wbsc2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wbci2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wbcc2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wesi2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wesc2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        weci2                   = new((/mm,ddd2(2),ddd2(3)/),float)
        wecc2                   = new((/mm,ddd2(2),ddd2(3)/),float)

        vint1m                  = 0.0
        vcba1m                  = 0.0
        dryi1                   = 0.0
        dryc1                   = 0.0
        weti1                   = 0.0
        wetc1                   = 0.0
        emis1                   = 0.0
        emix1                   = 0.0
        vgas1                   = 0.0
        vaqu1                   = 0.0
        gvfi1                   = 0.0
        gvfc1                   = 0.0
        tbfi1                   = 0.0
        tbfc1                   = 0.0
        wisi1                   = 0.0
        wisc1                   = 0.0
        wici1                   = 0.0
        wicc1                   = 0.0
        wbsi1                   = 0.0
        wbsc1                   = 0.0
        wbci1                   = 0.0
        wbcc1                   = 0.0
        wesi1                   = 0.0
        wesc1                   = 0.0
        weci1                   = 0.0
        wecc1                   = 0.0

        vint2m                  = 0.0
        vcba2m                  = 0.0
        dryi2                   = 0.0
        dryc2                   = 0.0
        weti2                   = 0.0
        wetc2                   = 0.0
        emis2                   = 0.0
        emix2                   = 0.0
        vgas2                   = 0.0
        vaqu2                   = 0.0
        gvfi2                   = 0.0
        gvfc2                   = 0.0
        tbfi2                   = 0.0
        tbfc2                   = 0.0
        wisi2                   = 0.0
        wisc2                   = 0.0
        wici2                   = 0.0
        wicc2                   = 0.0
        wbsi2                   = 0.0
        wbsc2                   = 0.0
        wbci2                   = 0.0
        wbcc2                   = 0.0
        wesi2                   = 0.0
        wesc2                   = 0.0
        weci2                   = 0.0
        wecc2                   = 0.0

        if (vars(jj) .ne. "bc" .and. vars(jj) .ne. "pom") then
           do nm = 0, mm-1
              vint1m(nm,:,:,:)  = f1->$vinta(nm)$
              vcba1m(nm,:,:,:)  = f1->$vcba(nm)$
              dryi1(nm,:,:)     = f1->$vidry(nm)$ * -1.
              weti1(nm,:,:)     = f1->$viwet(nm)$ 
              dryc1(nm,:,:)     = f1->$vcdry(nm)$ * -1.     
              wetc1(nm,:,:)     = f1->$vcwet(nm)$
              emis1(nm,:,:)     = f1->$vemis(nm)$
              gvfi1(nm,:,:)     = f1->$vigvf(nm)$ * -1.
              gvfc1(nm,:,:)     = f1->$vcgvf(nm)$ * -1.
              tbfi1(nm,:,:)     = f1->$vitbf(nm)$ * -1.
              tbfc1(nm,:,:)     = f1->$vctbf(nm)$ * -1.
              wisi1(nm,:,:)     = f1->$viwis(nm)$
              wisc1(nm,:,:)     = f1->$vcwis(nm)$
              wici1(nm,:,:)     = f1->$viwic(nm)$
              wicc1(nm,:,:)     = f1->$vcwic(nm)$
              wbsi1(nm,:,:)     = f1->$viwbs(nm)$
              wbsc1(nm,:,:)     = f1->$vcwbs(nm)$
              wbci1(nm,:,:)     = f1->$viwbc(nm)$
              wbcc1(nm,:,:)     = f1->$vcwbc(nm)$
              wesi1(nm,:,:)     = f1->$viwes(nm)$
              wesc1(nm,:,:)     = f1->$vcwes(nm)$
              weci1(nm,:,:)     = f1->$viwec(nm)$
              wecc1(nm,:,:)     = f1->$vcwec(nm)$

              vint2m(nm,:,:,:)  = f2->$vinta(nm)$
              vcba2m(nm,:,:,:)  = f2->$vcba(nm)$
              dryi2(nm,:,:)     = f2->$vidry(nm)$ * -1.
              weti2(nm,:,:)     = f2->$viwet(nm)$
              dryc2(nm,:,:)     = f2->$vcdry(nm)$ * -1.
              wetc2(nm,:,:)     = f2->$vcwet(nm)$
              emis2(nm,:,:)     = f2->$vemis(nm)$
              gvfi2(nm,:,:)     = f2->$vigvf(nm)$ * -1.
              gvfc2(nm,:,:)     = f2->$vcgvf(nm)$ * -1.
              tbfi2(nm,:,:)     = f2->$vitbf(nm)$ * -1.
              tbfc2(nm,:,:)     = f2->$vctbf(nm)$ * -1.
              wisi2(nm,:,:)     = f2->$viwis(nm)$
              wisc2(nm,:,:)     = f2->$vcwis(nm)$
              wici2(nm,:,:)     = f2->$viwic(nm)$
              wicc2(nm,:,:)     = f2->$vcwic(nm)$
              wbsi2(nm,:,:)     = f2->$viwbs(nm)$
              wbsc2(nm,:,:)     = f2->$vcwbs(nm)$
              wbci2(nm,:,:)     = f2->$viwbc(nm)$
              wbcc2(nm,:,:)     = f2->$vcwbc(nm)$
              wesi2(nm,:,:)     = f2->$viwes(nm)$
              wesc2(nm,:,:)     = f2->$vcwes(nm)$
              weci2(nm,:,:)     = f2->$viwec(nm)$
              wecc2(nm,:,:)     = f2->$vcwec(nm)$

              if  (vinta(nm) .eq. "so4_a1" .or. \
                  vinta(nm) .eq. "so4_a2") then
                  emix1(nm,:,:) = f1->$vemix(nm)$/avgod*mwso4*10.0
                  emix2(nm,:,:) = f2->$vemix(nm)$/avgod*mwso4*10.0
              end if
              if  (vars(jj) .eq. "soa") then
                  vgas1(nm,:,:) = f1->$vgas(nm)$
                  vgas2(nm,:,:) = f2->$vgas(nm)$
              end if
              if  (vars(jj) .eq. "so4") then
                  vaqu1(nm,:,:) = f1->$vcaqa(nm)$ + f1->$vcaqb(nm)$
                  vaqu2(nm,:,:) = f2->$vcaqa(nm)$ + f2->$vcaqb(nm)$
                  vnuc1         = f1->$vnuc$
                  vnuc2         = f2->$vnuc$
                  vgas1(nm,:,:) = f1->$vgas(nm)$
                  vgas2(nm,:,:) = f2->$vgas(nm)$
              end if

              if  ( vinta(nm) .eq. "so4_a1" .or. vinta(nm) .eq. "so4_a2") then
                  emis1(nm,:,:) = emis1(nm,:,:)
                  emis2(nm,:,:) = emis2(nm,:,:)
              end if
           end do

        else                       ; if vars(jj) = bc or pom

           if (mam41 .eq. "true") then
              mma               = 3
           else
              mma               = 2
           end if
           do nm = 0, mma-1
              vint1m(nm,:,:,:)  = f1->$vinta(nm)$
              vcba1m(nm,:,:,:)  = f1->$vcba(nm)$
              dryi1(nm,:,:)     = f1->$vidry(nm)$ * -1.
              weti1(nm,:,:)     = f1->$viwet(nm)$ 
              dryc1(nm,:,:)     = f1->$vcdry(nm)$ * -1.     
              wetc1(nm,:,:)     = f1->$vcwet(nm)$
              emis1(nm,:,:)     = f1->$vemis(nm)$
              gvfi1(nm,:,:)     = f1->$vigvf(nm)$ * -1.
              gvfc1(nm,:,:)     = f1->$vcgvf(nm)$ * -1.
              tbfi1(nm,:,:)     = f1->$vitbf(nm)$ * -1.
              tbfc1(nm,:,:)     = f1->$vctbf(nm)$ * -1.
              wisi1(nm,:,:)     = f1->$viwis(nm)$
              wisc1(nm,:,:)     = f1->$vcwis(nm)$
              wici1(nm,:,:)     = f1->$viwic(nm)$
              wicc1(nm,:,:)     = f1->$vcwic(nm)$
              wbsi1(nm,:,:)     = f1->$viwbs(nm)$
              wbsc1(nm,:,:)     = f1->$vcwbs(nm)$
              wbci1(nm,:,:)     = f1->$viwbc(nm)$
              wbcc1(nm,:,:)     = f1->$vcwbc(nm)$
              wesi1(nm,:,:)     = f1->$viwes(nm)$
              wesc1(nm,:,:)     = f1->$vcwes(nm)$
              weci1(nm,:,:)     = f1->$viwec(nm)$
              wecc1(nm,:,:)     = f1->$vcwec(nm)$

              if  ( mam41 .eq. "false") then
                  emix1(0,:,:)  = f1->$vemix(0)$/avgod*12.0*10.0
              else
                  emix1(1,:,:)  = f1->$vemix(1)$/avgod*12.0*10.0
              end if
              emis1(nm,:,:)     = emis1(nm,:,:)
           end do

           if  (mam42 .eq. "true") then
               mmb              = 3
           else
               mmb              = 2
           end if
           do nm=0, mmb-1
              vint2m(nm,:,:,:)  = f2->$vinta(nm)$
              vcba2m(nm,:,:,:)  = f2->$vcba(nm)$
              dryi2(nm,:,:)     = f2->$vidry(nm)$ * -1.
              weti2(nm,:,:)     = f2->$viwet(nm)$
              dryc2(nm,:,:)     = f2->$vcdry(nm)$ * -1. 
              wetc2(nm,:,:)     = f2->$vcwet(nm)$
              emis2(nm,:,:)     = f2->$vemis(nm)$
              gvfi2(nm,:,:)     = f2->$vigvf(nm)$ * -1.
              gvfc2(nm,:,:)     = f2->$vcgvf(nm)$ * -1.
              tbfi2(nm,:,:)     = f2->$vitbf(nm)$ * -1.
              tbfc2(nm,:,:)     = f2->$vctbf(nm)$ * -1.
              wisi2(nm,:,:)     = f2->$viwis(nm)$
              wisc2(nm,:,:)     = f2->$vcwis(nm)$
              wici2(nm,:,:)     = f2->$viwic(nm)$
              wicc2(nm,:,:)     = f2->$vcwic(nm)$
              wbsi2(nm,:,:)     = f2->$viwbs(nm)$
              wbsc2(nm,:,:)     = f2->$vcwbs(nm)$
              wbci2(nm,:,:)     = f2->$viwbc(nm)$
              wbcc2(nm,:,:)     = f2->$vcwbc(nm)$
              wesi2(nm,:,:)     = f2->$viwes(nm)$
              wesc2(nm,:,:)     = f2->$vcwes(nm)$
              weci2(nm,:,:)     = f2->$viwec(nm)$
              wecc2(nm,:,:)     = f2->$vcwec(nm)$
              if  ( mam42 .eq. "false") then
                  emix2(0,:,:)  = f2->$vemix(0)$/avgod*12.0*10.0
              else
                  emix2(1,:,:)  = f2->$vemix(1)$/avgod*12.0*10.0
              end if
              emis2(nm,:,:)     = emis2(nm,:,:)
           end do
        end if

; read in the burden calculated for interstitial aerosols
        tmpname                 = "BURDEN"+varnames(jj)
        if  ( isfilevar(f1, tmpname) ) then
            bvar11              = f1->$tmpname$
        end if
        if  ( isfilevar(f2, tmpname) ) then
            bvar22              = f2->$tmpname$
        end if

; combine the interstitial and cloud-borne aerosols

        dryt1                   = dryi1+dryc1
        wett1                   = weti1+wetc1
        gvft1                   = gvfi1+gvfc1
        tbft1                   = tbfi1+tbfc1
        wist1                   = wisi1+wisc1 
        wict1                   = wici1+wicc1
        wbst1                   = wbsi1+wbsc1
        wbct1                   = wbci1+wbcc1
        west1                   = wesi1+wesc1
        wect1                   = weci1+wecc1

        dryt2                   = dryi2+dryc2
        wett2                   = weti2+wetc2
        gvft2                   = gvfi2+gvfc2
        tbft2                   = tbfi2+tbfc2
        wist2                   = wisi2+wisc2
        wict2                   = wici2+wicc2
        wbst2                   = wbsi2+wbsc2
        wbct2                   = wbci2+wbcc2
        west2                   = wesi2+wesc2
        wect2                   = weci2+wecc2

        vtot1m                  = vint1m+vcba1m
        vtot2m                  = vint2m+vcba2m

        ps1                     = f1->PS
        ha1                     = doubletofloat(f1->hyai)
        hb1                     = doubletofloat(f1->hybi)
        p0                      = doubletofloat(f1->P0)
        p1                      = pres_hybrid_ccm(ps1,p0,ha1,hb1)

        ps2                     = f2->PS
        ha2                     = doubletofloat(f2->hyai)
        hb2                     = doubletofloat(f2->hybi)
        p2                      = pres_hybrid_ccm(ps2,p0,ha2,hb2)

        delp1                   = tmpp1
        delp2                   = tmpp2
        do k = 0,ddd1(1)-1
           delp1(:,k,:,:)       = p1(:,k+1,:,:)-p1(:,k,:,:)
        end do
        do k = 0,ddd2(1)-1
           delp2(:,k,:,:)       = p2(:,k+1,:,:)-p2(:,k,:,:)
        end do

        do nm = 0, mm-1
           vtot1m(nm,:,:,:)     = vtot1m(nm,:,:,:)*delp1(0,:,:,:)/grav
           vtot2m(nm,:,:,:)     = vtot2m(nm,:,:,:)*delp2(0,:,:,:)/grav
        end do

; compute column integrated burden

        bvar1                   = dim_sum_n_Wrap(vtot1m,1)
        bvar2                   = dim_sum_n_Wrap(vtot2m,1)
      
        gw1                     = doubletofloat(f1->gw)
        gw2                     = doubletofloat(f2->gw)
      
        coo1                    = new((/ddd1(2)/),float)
        coo2                    = new((/ddd2(2)/),float)

; compute area-weighted source/sink for each grid

        do i= 0, ddd1(2)-1
           coo1(i)              = gw1(i)*(2.*pi/ddd1(3))*rearth^2.
        end do
        do i= 0, ddd1(2)-1
           bvar1(:,i,:)         = bvar1(:,i,:)*coo1(i)
           dryt1(:,i,:)         = dryt1(:,i,:)*coo1(i)
           wett1(:,i,:)         = wett1(:,i,:)*coo1(i)
           gvft1(:,i,:)         = gvft1(:,i,:)*coo1(i)
           tbft1(:,i,:)         = tbft1(:,i,:)*coo1(i)
           wist1(:,i,:)         = wist1(:,i,:)*coo1(i)
           wict1(:,i,:)         = wict1(:,i,:)*coo1(i)
           wbst1(:,i,:)         = wbst1(:,i,:)*coo1(i)
           wbct1(:,i,:)         = wbct1(:,i,:)*coo1(i)
           west1(:,i,:)         = west1(:,i,:)*coo1(i)
           wect1(:,i,:)         = wect1(:,i,:)*coo1(i)
           emis1(:,i,:)         = emis1(:,i,:)*coo1(i)
           emix1(:,i,:)         = emix1(:,i,:)*coo1(i)

           if  (vars(jj) .eq. "soa") then
               vgas1(:,i,:)     = vgas1(:,i,:)*coo1(i)
           end if
           if  (vars(jj) .eq. "so4") then
               vaqu1(:,i,:)     = vaqu1(:,i,:)*coo1(i)
               vnuc1(:,i,:)     = vnuc1(:,i,:)*coo1(i)
               vgas1(:,i,:)     = vgas1(:,i,:)*coo1(i)
           end if  
           if  ( isdefined("bvar11") ) then
               bvar11(:,i,:)    = bvar11(:,i,:)*coo1(i)
           end if
        end do

        do i = 0, ddd2(2)-1
           coo2(i)              = gw2(i)*(2.*pi/ddd2(3))*rearth^2.
        end do
        do i = 0,ddd2(2)-1
           bvar2(:,i,:)         = bvar2(:,i,:)*coo2(i)
           dryt2(:,i,:)         = dryt2(:,i,:)*coo2(i)
           wett2(:,i,:)         = wett2(:,i,:)*coo2(i)
           gvft2(:,i,:)         = gvft2(:,i,:)*coo2(i)
           tbft2(:,i,:)         = tbft2(:,i,:)*coo2(i)
           wist2(:,i,:)         = wist2(:,i,:)*coo2(i)
           wict2(:,i,:)         = wict2(:,i,:)*coo2(i)
           wbst2(:,i,:)         = wbst2(:,i,:)*coo2(i)
           wbct2(:,i,:)         = wbct2(:,i,:)*coo2(i)
           west2(:,i,:)         = west2(:,i,:)*coo2(i)
           wect2(:,i,:)         = wect2(:,i,:)*coo2(i)
           emis2(:,i,:)         = emis2(:,i,:)*coo1(i)
           emix2(:,i,:)         = emix2(:,i,:)*coo1(i)

           if  (vars(jj) .eq. "soa") then
               vgas2(:,i,:)     = vgas2(:,i,:)*coo2(i)
           end if
           if  (vars(jj) .eq. "so4") then
               vaqu2(:,i,:)     = vaqu2(:,i,:)*coo2(i)
               vnuc2(:,i,:)     = vnuc2(:,i,:)*coo2(i)
               vgas2(:,i,:)     = vgas2(:,i,:)*coo2(i)
           end if
           if  ( isdefined("bvar22") ) then
               bvar22(:,i,:)    = bvar22(:,i,:)*coo2(i)
           end if
        end do

        if  (vars(jj) .ne. "so4" .and. vars(jj) .ne. "soa") then
            outv1               = new(17+mm,float)
            outv2               = new(17+mm,float)

; change unit from kg/m2/s to Tg/yr

            outv1(1)            = sum(emis1)*factaa
            outv1(2)            = sum(emix1)*factaa
            outv1(0)            = outv1(1)+outv1(2) 

            outv2(1)            = sum(emis2)*factaa
            outv2(2)            = sum(emix1)*factaa
            outv2(0)            = outv2(1)+outv2(2) 

            outv1(4)            = sum(dryt1)*factaa
            outv1(5)            = sum(gvft1)*factaa
            outv1(6)            = sum(tbft1)*factaa
            outv1(7)            = sum(wett1)*factaa
            outv1(8)            = sum(wist1)*factaa
            outv1(9)            = sum(wict1)*factaa
            outv1(10)           = sum(wbst1)*factaa
            outv1(11)           = sum(wbct1)*factaa
            outv1(12)           = sum(west1)*factaa
            outv1(13)           = sum(wect1)*factaa
            outv1(3)            = outv1(4)+outv1(7)
            outv1(15)           = sum(bvar1)*1e-9                    ; burden
            outv1(14)           = outv1(15)/fabs(outv1(3))*365.      ; lifetime

            outv2(4)            = sum(dryt2)*factaa
            outv2(5)            = sum(gvft2)*factaa
            outv2(6)            = sum(tbft2)*factaa
            outv2(7)            = sum(wett2)*factaa
            outv2(8)            = sum(wist2)*factaa
            outv2(9)            = sum(wict2)*factaa
            outv2(10)           = sum(wbst2)*factaa
            outv2(11)           = sum(wbct2)*factaa
            outv2(12)           = sum(west2)*factaa
            outv2(13)           = sum(wect2)*factaa
            outv2(3)            = outv2(4)+outv2(7)
            outv2(15)           = sum(bvar2)*1e-9                    ; burden
            outv2(14)           = outv2(15)/fabs(outv2(3))*365.      ; lifetime

            do nm = 0,mm-1
               outv1(16+nm)     = sum(bvar1(nm,:,:))*1e-9            ; burden for each mode
               outv2(16+nm)     = sum(bvar2(nm,:,:))*1e-9    
            end do
            
            if  ( isdefined("bvar11") ) then
                outv1(16+mm)    = sum(bvar11)*1e-9
            else
                outv1(16+mm)    = -999.
            end if
            if  ( isdefined("bvar22") ) then
                outv2(16+mm)    = sum(bvar22)*1e-9
            else
                outv2(16+mm)    = -999.
            end if

        else if (vars(jj) .eq. "soa") then

            outv1               = new(18+mm,float)
            outv2               = new(18+mm,float)

            outv1(1)            = sum(emis1)*factaa
            outv1(2)            = sum(emix1)*factaa
            outv1(3)            = sum(vgas1)*factaa
            outv1(0)            = outv1(1)+outv1(2)+outv1(3)

            outv2(1)            = sum(emis2)*factaa
            outv2(2)            = sum(emix2)*factaa
            outv2(3)            = sum(vgas2)*factaa
            outv2(0)            = outv2(1)+outv2(2)+outv2(3)

            outv1(5)            = sum(dryt1)*factaa
            outv1(6)            = sum(gvft1)*factaa
            outv1(7)            = sum(tbft1)*factaa
            outv1(8)            = sum(wett1)*factaa
            outv1(9)            = sum(wist1)*factaa
            outv1(10)           = sum(wict1)*factaa
            outv1(11)           = sum(wbst1)*factaa
            outv1(12)           = sum(wbct1)*factaa
            outv1(13)           = sum(west1)*factaa
            outv1(14)           = sum(wect1)*factaa
            outv1(4)            = outv1(5)+outv1(8)
            outv1(16)           = sum(bvar1)*1e-9                    ; burden
            outv1(15)           = outv1(16)/fabs(outv1(4))*365.      ; lifetime

            outv2(5)            = sum(dryt2)*factaa
            outv2(6)            = sum(gvft2)*factaa
            outv2(7)            = sum(tbft2)*factaa
            outv2(8)            = sum(wett2)*factaa
            outv2(9)            = sum(wist2)*factaa
            outv2(10)           = sum(wict2)*factaa
            outv2(11)           = sum(wbst2)*factaa
            outv2(12)           = sum(wbct2)*factaa
            outv2(13)           = sum(west2)*factaa
            outv2(14)           = sum(wect2)*factaa
            outv2(4)            = outv2(5)+outv2(8)
            outv2(16)           = sum(bvar2)*1e-9                    ; burden
            outv2(15)           = outv2(16)/fabs(outv2(4))*365.      ; lifetime

            do nm=0,mm-1
               outv1(17+nm)     = sum(bvar1(nm,:,:))*1e-9                  ; burden for each mode
               outv2(17+nm)     = sum(bvar2(nm,:,:))*1e-9               
            end do

            if ( isdefined("bvar11") ) then
               outv1(17+mm)     = sum(bvar11)*1e-9
            else
               outv1(17+mm)     = -999.
            end if
            if ( isdefined("bvar22") ) then
               outv2(17+mm)     = sum(bvar22)*1e-9
            else
               outv2(17+mm)     = -999.
            end if

        else                                                                ; so4

            outv1               = new(20+mm,float)
            outv2               = new(20+mm,float)

            outv1(1)            = sum(emis1)*factbb
            outv1(2)            = sum(emix1)*factbb
            outv1(3)            = sum(vgas1)*factbb
            outv1(4)            = sum(vaqu1)*factbb
            outv1(5)            = sum(vnuc1)*factbb
            outv1(0)            = outv1(1)+outv1(2)+outv1(3)+outv1(4)+outv1(5)

            outv2(1)            = sum(emis2)*factbb
            outv2(2)            = sum(emix2)*factbb
            outv2(3)            = sum(vgas2)*factbb
            outv2(4)            = sum(vaqu2)*factbb
            outv2(5)            = sum(vnuc2)*factbb
            outv2(0)            = outv2(1)+outv2(2)+outv2(3)+outv2(4)+outv2(5)

            outv1(7)            = sum(dryt1)*factbb
            outv1(8)            = sum(gvft1)*factbb
            outv1(9)            = sum(tbft1)*factbb
            outv1(10)           = sum(wett1)*factbb
            outv1(11)           = sum(wist1)*factbb
            outv1(12)           = sum(wict1)*factbb
            outv1(13)           = sum(wbst1)*factbb
            outv1(14)           = sum(wbct1)*factbb
            outv1(15)           = sum(west1)*factbb
            outv1(16)           = sum(wect1)*factbb
            outv1(6)            = outv1(7)+outv1(10)
            outv1(18)           = sum(bvar1)*factcc                  ; burden
            outv1(17)           = outv1(18)/fabs(outv1(6))*365.      ; lifetime

            outv2(7)            = sum(dryt2)*factbb
            outv2(8)            = sum(gvft2)*factbb
            outv2(9)            = sum(tbft2)*factbb
            outv2(10)           = sum(wett2)*factbb
            outv2(11)           = sum(wist2)*factbb
            outv2(12)           = sum(wict2)*factbb
            outv2(13)           = sum(wbst2)*factbb
            outv2(14)           = sum(wbct2)*factbb                  
            outv2(15)           = sum(west2)*factbb
            outv2(16)           = sum(wect2)*factbb
            outv2(6)            = outv2(7)+outv2(10)
            outv2(18)           = sum(bvar2)*factcc                  ; burden
            outv2(17)           = outv2(18)/fabs(outv2(6))*365.      ; lifetime

            do nm = 0,mm-1
               outv1(19+nm)     = sum(bvar1(nm,:,:))*factcc
               outv2(19+nm)     = sum(bvar2(nm,:,:))*factcc
            end do

            if ( isdefined("bvar11") ) then
               outv1(19+mm)     = sum(bvar11)*factcc
            else
               outv1(19+mm)     = -999.
            end if
            if ( isdefined("bvar22") ) then
               outv2(19+mm)     = sum(bvar22)*factcc
            else
               outv2(19+mm)     = -999.
            end if

        end if
        end if

        outv1@_FillValue       = -999.
        outv2@_FillValue       = -999.

        if  (vars(jj) .eq. "soa") then
            vname = (/"Sources (Tg/yr)           ","  1. surface emission     ","  2. elevated emission    ","  3. condensation         ",\
                      "Sinks (Tg/yr)             ","  1. Dry_dep              ","    a. gravitational      ","    b. turbulent          ",\
                                                   "  2. Wet_dep              ","    a. incloud, strat.    ","    b. incloud, convec.   ",\
                                                                                "    c. belowcloud, strat. ","    d. belowcloud, convec.",\
                                                                                "    e. rain evap, strat.  ","    f. rain evap, convec. ",\
                      "Lifetime (days)           ",\
                      "Burden (Tg)               ","  1. accumulation         ","  2. Aitken               ","  3. coarse               ",\
                      "Burden_clear (Tg)         "/)
        end if
        if  (vars(jj) .eq. "bc" .or. vars(jj) .eq. "pom") then
            vname = (/"Sources (Tg/yr)           ","  1. surface emission     ","  2. elevated emission    ",\
                      "Sinks (Tg/yr)             ","  1. Dry_dep              ","    a. gravitational      ","    b. turbulent          ",\
                                                   "  2. Wet_dep              ","    a. incloud, strat.    ","    b. incloud, convec.   ",\
                                                                                "    c. belowcloud, strat. ","    d. belowcloud, convec.",\
                                                                                "    e. rain evap, strat.  ","    f. rain evap, convec. ",\
                      "Lifetime (days)           ",\
                      "Burden (Tg)               ","  1. accumulation         ","  2. Aitken               ","  3. primary_carbon       ",\
		      "Burden_clear (Tg)         "/)
        end if
        if  (vars(jj) .eq. "dst") then
            vname = (/"Sources (Tg/yr)           ","  1. surface emission     ","  2. elevated emission    ",\
                      "Sinks (Tg/yr)             ","  1. Dry_dep              ","    a. gravitational      ","    b. turbulent          ",\
                                                   "  2. Wet_dep              ","    a. incloud, strat.    ","    b. incloud, convec.   ",\
                                                                                "    c. belowcloud, strat. ","    d. belowcloud, convec.",\
                                                                                "    e. rain evap, strat.  ","    f. rain evap, convec. ",\
                      "Lifetime (days)           ",\
                      "Burden (Tg)               ","  1. accumulation         ","  2. coarse               ","Burden_clear (Tg)         "/)
        end if
        if  (vars(jj) .eq. "ncl") then
            vname = (/"Sources (Tg/yr)           ","  1. surface emission     ","  2. elevated emission    ",\
                      "Sinks (Tg/yr)             ","  1. Dry_dep              ","    a. gravitational      ","    b. turbulent          ",\
                                                   "  2. Wet_dep              ","    a. incloud, strat.    ","    b. incloud, convec.   ",\
                                                                                "    c. belowcloud, strat. ","    d. belowcloud, convec.",\
                                                                                "    e. rain evap, strat.  ","    f. rain evap, convec. ",\
                      "Lifetime (days)           ",\
                      "Burden (Tg)               ","  1. accumulation         ","  2. Aitken               ","  3. coarse               ",\
		      "Burden_clear (Tg)         "/)
        end if
        if  (vars(jj) .eq. "so4") then
            vname = (/"Sources (TgS/yr)          ","  1. surface emission     ","  2. elevated emission    ","  3. gas-phase prod       ",\
                                                   "  4. aq-phase prod        ","  5. nucleation           ",\
                      "Sinks (Tg/yr)             ","  1. Dry_dep              ","    a. gravitational      ","    b. turbulent          ",\
                                                   "  2. Wet_dep              ","    a. incloud, strat.    ","    b. incloud, convec.   ",\
                                                                                "    c. belowcloud, strat. ","    d. belowcloud, convec.",\
                                                                                "    e. rain evap, strat.  ","    f. rain evap, convec. ",\
                      "Lifetime (days)           ",\
                      "Burden (TgS)              ","  1. accumulation         ","  2. Aitken               ","  3. coarse               ",\
		      "Burden_clear (TgS)        "/)
        end if
        if  (vars(jj) .eq. "mom") then
            vname = (/"Sources (Tg/yr)           ","  1. surface emission     ","  2. elevated emission    ",\
                      "Sinks (Tg/yr)             ","  1. Dry_dep              ","    a. gravitational      ","    b. turbulent          ",\
                                                   "  2. Wet_dep              ","    a. incloud, strat.    ","    b. incloud, convec.   ",\
                                                                                "    c. belowcloud, strat. ","    d. belowcloud, convec.",\
                                                                                "    e. rain evap, strat.  ","    f. rain evap, convec. ",\
                      "Lifetime (days)           ",\
                      "Burden (Tg)               ","  1. accumulation         ","  2. Aitken               ","  3. coarse               ",\
		      "  4. primary_carbon       ","Burden_clear (Tg)         "/)
        end if

        spaces                   = integertochar(32)        ; space
        sp0                      = new(26,"character")
        sp0                      = spaces
        spaces0                  = chartostring(sp0)

        nchr                     = dimsizes(stringtochar(case1))-1
        if (nchr .lt. 12) then
           sp1                   = new(16-nchr,"character")
           sp1                   = spaces
           spaces1               = chartostring(sp1)
           case1a                = case1
        else
           case1b                = stringtochar(case1)
           case1a                = chartostring(case1b(:10))
           sp1                   = new(5,"character")
           sp1                   = spaces
           spaces1               = chartostring(sp1)
           delete(case1b)
        end if

        nchr                     = dimsizes(stringtochar(case2))-1
        if (nchr .lt. 12) then
           sp2                   = new(16-nchr,"character")
           sp2                   = spaces
           spaces2               = chartostring(sp2)
           case2a                = case2
        else
           sp2                   = new(5,"character")
           sp2                   = spaces
           spaces2               = chartostring(sp2)
           case2b                = stringtochar(case2)
           case2a                = chartostring(case2b(:10))
           delete(case2b)
        end if
        
        lines                    = new(dimsizes(outv1)+4,"string")
        lines(0)                 = str_upper(vars(jj))
        lines(1)                 = spaces0+spaces1+case1a+spaces2+case2a+"      difference"+"     rel diff(%)"
        do n = 0, dimsizes(outv1)-1
           if ( (outv1(n) .eq. -999.) .or. (outv2(n) .eq. -999.) ) then
              lines(n+2)         = vname(n)+sprintf("%16.3f",outv1(n))+sprintf("%16.3f",outv2(n))+ \
                                   sprintf("%16.3f",-999.)+sprintf("%16.3f",-999.)
           else
              if ( outv1(n) .eq. 0. ) then
                 lines(n+2)      = vname(n)+sprintf("%16.3f",outv1(n))+sprintf("%16.3f",outv2(n))+ \
                                   sprintf("%16.3f",(outv1(n)-outv2(n)))+ \
                                   sprintf("%16.3f",-999.)
              else
                 lines(n+2)      = vname(n)+sprintf("%16.3f",outv1(n))+sprintf("%16.3f",outv2(n))+ \
                                   sprintf("%16.3f",(outv1(n)-outv2(n)))+ \
                                   sprintf("%16.3f",((outv1(n)-outv2(n))/outv1(n)*100.))
              end if
           end if
        end do


        dashlines                = new(dimsizes(sp0)+16*4,"character")
        dashlines                = integertochar(45)
        lines(dimsizes(outv1)+2) = chartostring(dashlines)
        lines(dimsizes(outv1)+3) = spaces0

        asciiwrite(output_file,lines)
 
        delete([/coo1,coo2,outv1,outv2,sp0,sp1,sp2,lines,vname,tmpname,bvar11,bvar22/])
        delete([/vint1m,vcba1m,vtot1m,dryi1,dryc1,weti1,wetc1,emis1,emix1,vgas1,vaqu1/])
        delete([/gvfi1,gvfc1,tbfi1,tbfc1,wisi1,wisc1,wici1,wicc1,wbsi1,wbsc1,wbci1,wbcc1,wesi1,wesc1,weci1,wecc1/])
        delete([/bvar1,dryt1,wett1,gvft1,tbft1,wist1,wict1,wbst1,wbct1,west1,wect1/])
        delete([/vint2m,vcba2m,vtot2m,dryi2,dryc2,weti2,wetc2,emis2,emix2,vgas2,vaqu2/])
        delete([/gvfi2,gvfc2,tbfi2,tbfc2,wisi2,wisc2,wici2,wicc2,wbsi2,wbsc2,wbci2,wbcc2,wesi2,wesc2,weci2,wecc2/])
        delete([/bvar2,dryt2,wett2,gvft2,tbft2,wist2,wict2,wbst2,wbct2,west2,wect2/])
        delete([/vinta,vidry,viwet,vemis,vemix,vgas,vcba,vcdry,vcwet,vcaqa,vcaqb/])
        delete([/vigvf,vitbf,viwis,viwic,viwbs,viwbc,viwes,viwec/])
        delete([/vcgvf,vctbf,vcwis,vcwic,vcwbs,vcwbc,vcwes,vcwec/])

     end do  ; end of looping over variables
 
  end do  ; end of looping over seasons

end
