; This script takes all the metrics created by the various scripts and placed
; in metrics_orig.txt, calculates the total scores, reorganizes the data, 
; and writes out a new metrics.txt file. 

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("add_labelbar")
procedure add_labelbar(wks,plot,colors,labels)
local vph, vpw, nboxes, lbres, lbid, amres, annoid
begin
  getvalues plot                      ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  nboxes = dimsizes(colors)

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False          ; Necessary to control sizes
  lbres@vpWidthF           = 0.15 * vpw    ; labelbar width
  if (vph.eq..175) then    ; minimum height
     lbres@vpHeightF          = 0.155  
     lbres@lbLabelFontHeightF = 0.008 
  end if
  if (vph.gt..175.and.vph.lt..8601) then
     lbres@vpHeightF          = 0.85 * vph
     lbres@lbLabelFontHeightF = 0.008+(((vph-.17)/.7101)*.0075)
  end if
  if (vph.ge..8601) then
     lbres@vpHeightF          = 0.7 * vph
     lbres@lbLabelFontHeightF = 0.0105-(((vph-.8601)*10)*2)     
  end if
  lbres@lbFillColors       = colors        ; labelbar colors
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
    
  lbres@lbLabelAlignment   = "InteriorEdges"  ; center of box
  lbres@lbOrientation      = "Vertical"
  lbres@lbPerimOn          = False
  lbres@lbFillOpacityF = 0.5

  lbid = gsn_create_labelbar(wks,nboxes,labels,lbres)                                                          
  amres                  = True
  amres@amJust           = "CenterLeft"
  amres@amParallelPosF   =  0.52
  amres@amOrthogonalPosF =  0.0
  plot@annoid = gsn_add_annotation(plot,lbid,amres)
end


begin
  print("Starting: metrics_sam_psa.ncl")
  
  nclver = stringtochar(get_ncl_version())   ; check NCL version to turn off error messages
  num0 = toint(tostring(nclver(0)))    
  num1 = toint(tostring(nclver(2)))
  errmsg = True
  if (num0.le.5) then
     errmsg = False
  end if
  if (num0.eq.6) then
     if (num1.le.4) then
        errmsg = False
     else
        errmsg = True
     end if
  end if  
  if (num0.ge.7) then
     errmsg = True
  end if
  delete([/num0,num1/])

  OUTDIR = getenv("OUTDIR")
  
  nsim = numAsciiRow("namelist_byvar/namelist_trefht")    ; retrieve total number of observational + models (all namelist_byvar/namelist have same # of rows)
  na = asciiread("namelist_byvar/namelist_trefht",(/nsim/),"string")  ; (It is not done via metrics.txt as there might be a space in names.                                                                             
  blankrow = ind(na.eq."")
  if (.not.any(ismissing(blankrow))) then
     goodrows = ind(na.ne."")
     na2 = na(goodrows)
     delete(na)
     na = na2
     delete(na2)
     nsim = dimsizes(na)
  end if      
  nsim = nsim - 1    ; first listed dataset is what all others are compared to, thus, output metrics table has nsim-1 column  

  seas = (/"djf", "mam", "jja", "son", "ann", "mon"/)
  nsea = dimsizes(seas)

  mods = (/"sam","psa1","psa2"/)
  nmod = dimsizes(mods)

  vars = (/"psl","sst","trefht","prect","u10","v10","taux","tauy","shflx","lhflx", "eth", \
              "swcre","olr","cldtot","u850","v850","th850","z500","u200","v200"/)
  nvar = dimsizes(vars)

  files = "sam_psa"+"_"+vars + "_regpatt"
  files = "metrics.psl."+files
  files = files+".txt"
  do gg = 0,dimsizes(files)-1
     if (.not.fileexists(OUTDIR+files(gg))) then
        if(vars(gg).eq."sst") then 
          ftmp = str_sub_str(files(gg),"sst","ts") 
         ;print(ftmp)
          if (fileexists(OUTDIR+ftmp)) then 
             files(gg) = ftmp
          else 
            print(files(gg))
            print("1 or more metrics files missing, cannot create summary metrics tables, exiting metrics_sam_psa.ncl")
            exit
          end if  
          delete(ftmp)
        else 
          print(files(gg))
          print("1 or more metrics files missing, cannot create summary metrics tables, exiting metrics_sam_psa.ncl")
          exit
        end if 
     end if
  end do

  ch = new((/nsim,nvar/),"string")   ; hold obs/simulation names
  vcor_rms   = new((/nsim,nvar,nsea,nmod/),"string")     
  patcor_rms = new((/nsim,nvar/),"string") ; nvar metrics

  do gg = 0,dimsizes(files)-1
     nrow = numAsciiRow(OUTDIR+files(gg))
     a = asciiread(OUTDIR+files(gg),(/-1/),"string")
     
     t0 = tochar(a(3))
     sti0 = str_index_of_substr(a(4), " -",0)   ; read in individual column headers from each metrics file
     do hh = 0,dimsizes(sti0)-1
        if (hh.eq.(dimsizes(sti0)-1)) then
           ch(hh,gg) = str_strip(tostring(t0(sti0(hh):)))
        else 
           ch(hh,gg) = str_strip(tostring(t0(sti0(hh):sti0(hh+1))))
        end if
     end do
     delete([/sti0,t0/])
 
     do ii = 0,nsea-1
       do jj = 0,nmod-1
         nl = 5 + ii *nmod + jj
         test = tochar(a(nl))
         vcor_rms(:,gg,ii,jj) = str_split(tostring(test(18:))," ") 
         delete([/test/])
       end do 
     end do 

     delete(a)
  end do
;  printVarSummary(vcor_rms)

;  do gg = 0,dimsizes(files)-1        ; Individual metrics files no longer removed in case comparison
;     system("rm "+OUTDIR+files(gg))  ; is rerun. This ensures that the metrics tables get updated. 
;  end do

  names = ch(:,0)
  do gg = 0,nsim-1   ; check to see if data is observations or models by seeing if every name matches
     if (all(ch(gg,0).eq.ch(gg,1:))) then
        names(gg) = ch(gg,0)
     else
        names(gg) = "OBS "+(gg+2)
     end if
  end do
  delete(ch)

 do ix = 0,nsea-1
 do jx = 0,nmod-1
  
  patcor_rms(:,0:nvar-1) = vcor_rms(:,:,ix,jx)

  names_nchar = max(dimsizes(tochar(names)))
  spacer = ""
  do gg = 0,names_nchar
     spacer = spacer+" "
  end do
  delete(names_nchar)     
  pc_score = new(nsim,"string")
  rms_score = new(nsim,"string")
  do gg = 0,nsim-1     ; strip out pattern correlations, and calculated score for each model
     pc = new(nvar,float,9.99)
     rms = pc
     do hh = 0,nvar-1   ; nvar metrics
        n1 = str_split(patcor_rms(gg,hh),"/")
;        print(n1)
        pc(hh)  = tofloat(n1(0))   ; strip out pattern correlations. 9.99 = missing.
        rms(hh) = tofloat(n1(1))   ; strip out rms. 9.99 = missing.
        delete(n1)
     end do
     if (any(ismissing(rms))) then
        rms_score(gg) = "----"
     else
        rms_score(gg) = sprintf("%4.2f",avg(rms))
     end if
     delete(rms)

;     total_score(gg) = ""+avg(pc)
;     print("Simple average = "+avg(pc))

     pc_z = pc
     pc_z = pc_z@_FillValue
     if (any(ismissing(pc))) then
;        print("Missing Values detected")
;        print(pc)
        pc_score(gg) = "----"
     else     
        do ii = 0,nvar-1   ; use Fisher's z-transformation to translate r->z
           if (pc(ii).eq.1.0) then
              pc_z(ii) = 0.5*(log( (1+1.001) / (1-1.001) ))    ; needed when pattern correlation = 1.0
           else
              pc_z(ii) = 0.5*(log( (1+pc(ii)) / (1-pc(ii)) ))
           end if
        end do
        zavg = avg(pc_z)   ; compute average of z
        delete(pc_z)
        
        pc_score(gg) = sprintf("%4.2f",((2.71828^(2*zavg))-1)/ ((2.71828^(2*zavg))+1))  ; reverse process and convert z-avg -> r.
;        print("average of Z-tranformed correlations = "+pc_score(gg))                   ; r = (e^2Z - 1)/(e^2Z+1)  ; e = 2.71828
        delete(zavg)
     end if
     delete(pc)
  end do
  pc_score = where(pc_score.eq." nan","----",pc_score)  ; needed for when the nan's come out of the z-transform (likey due to numerous pattern correlations = 1)
  
  header = (/"","Pattern Correlations/RMS Differences   Observations vs. Model(s)",""/)
  write_table(OUTDIR+"metrics_"+mods(jx)+"_regpatt_"+seas(ix)+".txt","w",[/header/],"%s")
  head1 =""
  head2 =""
  head3 =""
  do ff = 0,nvar-1 
    head1 = head1 + str_insert("  " + str_upper(mods(jx))+ " "+str_upper(vars(ff))," ", 12) 
    head2 = head2 + str_insert("  " + "("+str_upper(seas(ix))+")", " ", 12)
    head3 = head3 + str_insert("  " + "---------"," ",12)
  end do 
  head1  = head1 + str_insert("  " + "Mean"," ", 12)
  head2  = head2 + str_insert("  " + "Score"," ", 12)
  head3  = head3 + str_insert("  " + "---------"," ", 12)
  column_header1 = spacer+head1 
  column_header2 = spacer+head2
  column_header3 = spacer+head3 
  write_table(OUTDIR+"metrics.txt","a",[/column_header1/],"%s")
  write_table(OUTDIR+"metrics.txt","a",[/column_header2/],"%s")
  write_table(OUTDIR+"metrics.txt","a",[/column_header3/],"%s")
  delete([/head1,head2,head3/]) 
 
  patcor_rms = where(patcor_rms.eq."9.99/9.99","----/----",patcor_rms)
  spacer_char = tochar(spacer)
  do gg = 0,nsim-1
     spacer_char1 = spacer_char
     mname_char = tochar(names(gg))
     dimC = dimsizes(mname_char)
     spacer_char1(:dimC-1) = mname_char
     srow = tostring(spacer_char1)
;     print(srow)
     do hh = 0,10
        n1 = str_split(patcor_rms(gg,hh),"/")
;        print("n1 = "+n1)
        if (n1(0).eq."----") then
           srow = srow+"  "+patcor_rms(gg,hh)
        else
           if (tofloat(n1(0)).ge.0) then
              srow = srow+"  "+patcor_rms(gg,hh)
           else
              srow = srow+" "+patcor_rms(gg,hh)
           end if   
        end if
        delete(n1)
     end do
     srow = srow+"  "+pc_score(gg)+"/"+rms_score(gg)     
     write_table(OUTDIR+"metrics.txt","a",[/srow/],"%s")
     delete([/spacer_char1,dimC,mname_char,srow/])
  end do
  delete([/spacer_char/])

; Create tables that are colored by value and sorted by value
; if there are less than 256 simulations+(number of observational datasets-1)
; (NCL can only create 255 tickmarks on one plot and each tickmark equals a 
;  model/obs below.)

  if (nsim.le.255) then
     names!0 = "sim"
     names&sim = ispan(0,nsim-1,1)
     patcor = new((/nsim,nvar+1/),typeof(patcor_rms))
     rms = patcor
     do gg = 0,nsim-1
        do hh = 0,nvar
           if (hh.le.nvar-1) then
              n1 = str_split(patcor_rms(gg,hh),"/")
              patcor(gg,hh) = (/n1(0)/)
              rms(gg,hh) = (/n1(1)/)
           else
              patcor(gg,hh) = (/pc_score(gg)/)
              rms(gg,hh) = (/rms_score(gg)/)
           end if
        end do
     end do
     delete([/pc_score,rms_score/])
     patcor!0 = "sim"
     patcor&sim = ispan(0,nsim-1,1)
     copy_VarCoords(patcor,rms)

     ncols = nvar+1
     nrows = nsim
     col_width  = 1./ncols
     row_width  = 1./nrows
     col_width2 = col_width/2.
     row_width2 = row_width/2.
  
     fcolors = new(dimsizes(patcor),"integer")
     colors = (/7,12,17,22,27,33,37,42,47,53,59,65/)
     cnLevels = (/0.1,0.2,0.3,0.4,0.5,0.55,0.6,0.65,0.7,0.8,0.9/)
     do gg = 0,dimsizes(cnLevels)
        if (gg.eq.0) then
           fcolors = where(patcor.lt.cnLevels(0),colors(0),fcolors)
        end if
        if (gg.ge.1.and.gg.lt.dimsizes(cnLevels)) then
           fcolors = where(patcor.lt.cnLevels(gg).and.patcor.ge.cnLevels(gg-1),colors(gg),fcolors)
        end if
        if (gg.eq.dimsizes(cnLevels)) then
           fcolors = where(patcor.ge.cnLevels(gg-1),colors(gg),fcolors)
        end if
     end do
     fcolors = where(patcor.eq."----",75,fcolors)
  
     fcolorsR = new(dimsizes(rms),"integer")
     colorsR = (/65,59,53,47,42,37,33,27,22,17,12,7/)
     cnLevelsR = (/.05,.1,.2,.3,.4,.5,.6,.7,.8,.9,1./)
     do gg = 0,dimsizes(cnLevelsR)
        if (gg.eq.0) then
           fcolorsR = where(rms.lt.cnLevelsR(0),colorsR(0),fcolorsR)
        end if
        if (gg.ge.1.and.gg.lt.dimsizes(cnLevelsR)) then
           fcolorsR = where(rms.lt.cnLevelsR(gg).and.rms.ge.cnLevelsR(gg-1),colorsR(gg),fcolorsR)
        end if
        if (gg.eq.dimsizes(cnLevelsR)) then
            fcolorsR = where(rms.ge.cnLevelsR(gg-1),colorsR(gg),fcolorsR)
        end if
     end do
     fcolorsR = where(rms.eq."----",75,fcolorsR)
;--------------------------------------------------------------------------------------------
     wks_type = "png"    ; output png  
     wks_type@wkWidth = 1500   
     wks_type@wkHeight = 1500  
     if (nsim.ge.80.and.nsim.lt.179) then
        wks_type@wkWidth = 2500    
        wks_type@wkHeight = 2500  
     end if
     if (nsim.ge.180) then
        wks_type@wkWidth = 4000    
        wks_type@wkHeight = 4000  
     end if
     fac_font = 0.65
     wks = gsn_open_wks(wks_type,OUTDIR+"table_sam_psa_regpatt")  ; send graphics to PNG file
     gsn_merge_colormaps(wks,"cmp_b2r","gsltod") 

     resb                         = True    ; resource list for blank plot that gsn_table will be overlaid on
     resb@gsnDraw                 = False
     resb@gsnFrame                = False
     resb@vpXF                    = 0.3  
     title_loc = (/.185,0.075,.185,0.05/)   ; default x/y ndc values for location of plot title and subtitle
     b_int                        = 0.0
     if (nsim.le.32) then
        resb@vpWidthF                = 0.59
        resb@vpYF                    = 0.825
        resb@vpHeightF               = nsim*0.025
        if (resb@vpHeightF.lt..175) then    ; set a minimum height
           resb@vpHeightF = .175
        end if
       resb@tmXTLabelFontHeightF    = 0.0125 *fac_font 
       resb@tmXTMajorLengthF = 0.009
     end if
     if (nsim.ge.33.and.nsim.lt.80) then
        resb@vpWidthF                = 0.59
        resb@vpYF                    = 0.865
        resb@vpHeightF               = 0.8601
        resb@tmXTLabelFontHeightF    = 0.0085 * fac_font
        resb@tmXTMajorLengthF        = 0.009
     end if
     if (nsim.ge.80.and.nsim.lt.109) then
        resb@vpWidthF                = 0.59
        resb@vpYF                    = 0.865
        resb@vpHeightF               = 0.8602
        resb@tmXTLabelFontHeightF    = 0.0065 * fac_font
        resb@tmXTMajorLengthF = 0.009
        b_int                        = .00185
     end if
     if (nsim.ge.109.and.nsim.lt.150) then
        resb@vpWidthF                = 0.425
        resb@vpYF                    = 0.865
        resb@vpHeightF               = 0.8603
        resb@tmXTLabelFontHeightF    = 0.0045 * fac_font
        resb@tmXTMajorLengthF = 0.0065
        title_loc = (/.085,0.035,.085,0.025/)
        b_int                        = .002
     end if
     if (nsim.ge.150) then
        resb@vpWidthF                = 0.25
        resb@vpYF                    = 0.865
        resb@vpHeightF               = 0.8604
        resb@tmXTLabelFontHeightF    = 0.0025 * fac_font
        resb@tmXTMajorLengthF = 0.0045
        title_loc = (/.07,0.02,.07,0.0125/)
        b_int                        = .002
     end if
     resb@tmYLMajorLengthF = resb@tmXTMajorLengthF
     resb@tmXTMajorOutwardLengthF = resb@tmXTMajorLengthF
     resb@tmYLMajorOutwardLengthF = resb@tmXTMajorLengthF
     resb@tmXTMajorLineColor = "gray55"
     resb@tmYLMajorLineColor = resb@tmXTMajorLineColor
     resb@tmXTLabelFont = 21
     resb@tmXTMode                = "Explicit"    ; Explicitly label X axis. The blank plot goes from 0 to 1, by default.
     resb@tmXTValues              = fspan(col_width2,1.-col_width2,ncols)
     ncol_labels = new(nvar+1,string)
     do ff = 0,nvar-1 
       ncol_labels(ff) = str_upper(mods(jx))+ " "+str_upper(vars(ff)) + " " + "("+str_upper(seas(ix))+")"
     end do 
     ncol_labels(nvar) = "Mean Score" 
     resb@tmXTLabels              = ncol_labels
     resb@tmXTOn                  = True
     resb@tmXUseBottom = False
     resb@tmXTLabelsOn = True
     resb@tmXBOn = False
     resb@tmXTLabelAngleF         = 70.
     resb@tmXTLabelJust           = "CenterLeft"

     resb@tmYLMode                = "Explicit"
     if (nsim.gt.1) then
        resb@tmYLValues              = fspan(row_width2,1.-row_width2,nrows)
     else
        resb@tmYLValues              = row_width2
     end if
     resb@tmYLLabelFontHeightF    = resb@tmXTLabelFontHeightF           
     resb@tmYROn                  = False
     resb@tiMainOn = False
   
     resT = True
     resT@gsLineThicknessF = 2.0
     resT@gsLineColor = resb@tmXTMajorLineColor
     resT@txFontHeightF = resb@tmXTLabelFontHeightF
     resT@gsFillOpacityF = 0.5
     resT@tfPolyDrawOrder = "PreDraw"

     polyres = True
     polyres@gsLineColor      = "gray25"
     polyres@gsLineThicknessF = 8.0
     polyres@gsLineDashPattern = 0
     polyres@tfPolyDrawOrder = "PostDraw"

     tres = True
     tres@txFontHeightF = resb@tmYLLabelFontHeightF*1.2
     tres@txJust = "CenterLeft"

     tres2 = tres
     tres2@txFontHeightF = resb@tmYLLabelFontHeightF*0.8

    ;pattern correlation
     namesF = names
     patcorF = patcor
     int_s = namesF&sim
     s_txt = ""
     ;namesF = str_upper(namesF)    ; make all model names uppercase so sqsort sorts like this: A,b,C instead of this: A,C,b
     ;sqsort(namesF)
     ;int_s = namesF&sim
     ;namesF = names(int_s)
     ;s_txt = "Namelist (Alphab.)"

     ;patcorT = patcorF(:,gg-2)
     ;sqsort(patcorT)
     ;int_s = patcorT&sim(::-1)
     ;namesF = names(int_s)
     ;delete(patcorT)
     ;s_txt = ncol_labels(gg-2)
      resb@tmYLLabels              = namesF(::-1)  ; this resource takes labels in reverse order as gsn_table
      blank = gsn_csm_blank_plot(wks,resb)
      add_labelbar(wks,blank,colors,""+decimalPlaces(cnLevels,2,True))   ; Attach labelbar
   
      getvalues blank
        "vpXF"      : vpx
        "vpYF"      : vpy  ;    Get position and size of the blank plot so we can
        "vpWidthF"  : vpw  ;    be sure to draw the table in same location.
        "vpHeightF" : vph
      end getvalues   
      x = (/vpx,vpx+vpw/)
      y = (/vpy-vph,vpy/)

      resT@gsFillColor = fcolors(int_s,:)

      if (.not.errmsg) then    ; turn off error messages output from gsn_table if NCL v6.4.0 or older
         err = NhlGetErrorObjectId()
         setvalues err
            "errPrint" : "False"
         end setvalues
      end if
      gsn_table(wks,dimsizes(patcorF),x,y,patcorF(int_s,:),resT) 
      if (.not.errmsg) then
         setvalues err
            "errPrint" : "True"
         end setvalues
      end if
      gsn_text_ndc(wks,"Pattern Correlations",resb@vpXF-title_loc(0),resb@vpYF+title_loc(1),tres)
      if (s_txt.ne."") then
         gsn_text_ndc(wks,"Sorted by: "+s_txt,resb@vpXF-title_loc(2),resb@vpYF+title_loc(3),tres2)
      end if
      draw(blank)
      frame(wks)
      delete([/namesF,patcorF,int_s/])

      ;root-mean-squre difference 
      namesF = names
      rmsF   = rms
      int_s  = namesF&sim
      s_txt  = ""
     ;namesF = str_upper(namesF)    ; make all model names uppercase so sqsort sorts like this: A,b,C instead of this: A,C,b
     ;sqsort(namesF)
     ;int_s = namesF&sim
     ;namesF = names(int_s)
     ;s_txt = "Name"
     ;rmsT = rmsF(:,gg-2)
     ;rmsT = where(rmsT.eq."----","1000",rmsT)  ; make sure values of ---- get put to bottom of sorted list 
     ;sqsort(rmsT)
     ;rmsT = where(rmsT.eq."1000","----",rmsT)  ; make sure values of ---- get put to bottom of sorted list    
     ;int_s = rmsT&sim
     ;namesF = names(int_s)
     ;delete(rmsT)
     ;s_txt = ncol_labels(gg-2)
      resb@tmYLLabels              = namesF(::-1)  ; this resource takes labels in reverse order as gsn_table
      blank = gsn_csm_blank_plot(wks,resb)
      add_labelbar(wks,blank,colorsR,""+decimalPlaces(cnLevelsR,2,True))   ; Attach labelbar
     ;dum = gsn_add_polyline(wks,blank,(/(gg-2)*.083333,.998,.998,(gg-2)*.083333,(gg-2)*.083333/),(/.002-b_int,.002-b_int,.998+b_int,.998+b_int,.002-b_int/),polyres)
     
     getvalues blank
       "vpXF"      : vpx
       "vpYF"      : vpy  ;    Get position and size of the blank plot so we can
       "vpWidthF"  : vpw  ;    be sure to draw the table in same location.
       "vpHeightF" : vph
     end getvalues
     x = (/vpx,vpx+vpw/)
     y = (/vpy-vph,vpy/)
     resT@gsFillColor = fcolorsR(int_s,:)
     if (.not.errmsg) then    ; turn off error messages output from gsn_table if NCL v6.4.0 or older
        err = NhlGetErrorObjectId()
        setvalues err
           "errPrint" : "False"
        end setvalues
     end if
     gsn_table(wks,dimsizes(rmsF),x,y,rmsF(int_s,:),resT)
     if (.not.errmsg) then
        setvalues err
           "errPrint" : "True"
        end setvalues
     end if
     gsn_text_ndc(wks,"RMS Differences",resb@vpXF-title_loc(0),resb@vpYF+title_loc(1),tres)
     if (s_txt.ne."") then
        gsn_text_ndc(wks,"Sorted by: "+s_txt,resb@vpXF-title_loc(2),resb@vpYF+title_loc(3),tres2)
     end if
     draw(blank)
     frame(wks)
     delete([/namesF,rmsF,int_s,rms/])
     delete(wks)
     fils = systemfunc("ls "+OUTDIR+"table_sam_psa_regpatt*") 
     do gg = 0,dimsizes(fils)-1
        system("convert -density 2400 -trim +repage -bordercolor white -border 20 "+fils(gg) + " " + OUTDIR+"table_sam_psa_regpatt_"+gg+".png")
     end do
     system("mv " + OUTDIR+"table_sam_psa_regpatt_0.png" + " " + OUTDIR+"metrics.table_"+mods(jx)+"_patcor_"+seas(ix)+".png")
     system("mv " + OUTDIR+"table_sam_psa_regpatt_1.png" + " " + OUTDIR+"metrics.table_"+mods(jx)+"_patrms_"+seas(ix)+".png")
     system("rm "+OUTDIR+"table_sam_psa_regpatt.*.png")
     delete(fils)
     system("rm "+OUTDIR+"table*.png")
  end if

 end do 
 end do 

 delete([/patcor_rms,names,nsim/])
 print("Finished: metrics_sam_psa.ncl")

end
