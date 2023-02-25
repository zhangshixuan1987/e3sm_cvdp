; Create all CVDP-LE web pages.
;
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: webpage.ncl")

  OUTDIR      = getenv("OUTDIR") 
  VERSION     = getenv("VERSION")
  CLIMO_SYEAR = getenv("CLIMO_SYEAR")
  CLIMO_EYEAR = getenv("CLIMO_EYEAR")
  OBS         = getenv("OBS")

  quote = str_get_dq()
;----------------------------------------------------------------------------
;--   Create metrics webpages
;----------------------------------------------------------------------------
  if (isfilepresent2(OUTDIR+"metrics.txt")) then
     txt = new(500,"string")  
     quote = str_get_dq()
  
     txt(0) = "<HTML><HEAD><TITLE>Climate Variability Diagnostics Package</TITLE><STYLE>"
     txt(1) = "body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
     txt(2) = "img.title {width:990; height:105; align:left}"
     txt(3) = "p.subtitle1 {font-size:15pt; color:gray}"
     txt(4) = "p.subtitle {font-size:20pt; color:black; text-align:center; font-weight:bold}"
     txt(5) = "p.btext {font-size:12pt; text-align:left}"
     txt(6) = "p.btext2 {font-size:9pt; text-align:left}"
     txt(7) = "td {text-align:center; font-size:12pt}"
     txt(8) = "td.s1 {text-align:left; font-size:11pt}"
     txt(9) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}"
     txt(10) = "</STYLE></HEAD><BODY>"
     txt(11) = "<img class=title src="+quote+"cas_cvdp-le.png"+quote+" alt="+quote+"CVDP-LE logo"+quote+">"
     txt(12)= "<TABLE width='990' border=0 cellpadding=6>"
     txt(13) = "<tr><td width='350'><p class=btext><a href="+quote+"index.html"+quote+">Back to Diagnostics Plots</a></p></td>"
     txt(14) = "<td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left><p class=subtitle1>Metrics Table</p>" 
     
     z = asciiread(OUTDIR+"metrics.txt",(/-1/),"string")
     nlines = dimsizes(z)
     txt(24) = "<PRE>"
     do gg = 0,nlines-1
        txt(25+gg) = z(gg)
     end do
     txt(25+nlines) = "</PRE>"
     txt(25+nlines+1) = "<p class=btext><a href="+quote+"namelist_obs"+quote+">Observations Used</a></p>"
     txt(25+nlines+2) = "Created "+systemfunc("date")
     txt(25+nlines+3) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  
     tt = ind(.not.ismissing(txt))
     txt2 = txt(:tt(dimsizes(tt)-1)+1)
     txt2 = where(ismissing(txt2),"",txt2)
     asciiwrite(OUTDIR+"metrics.html",txt2)
     delete([/txt,txt2,tt,z/])
  end if 
  if (isfilepresent2(OUTDIR+"metrics_EM.txt")) then
     txt = new(500,"string")  
     quote = str_get_dq()
  
     txt(0) = "<HTML><HEAD><TITLE>Climate Variability Diagnostics Package</TITLE><STYLE>"
     txt(1) = "body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
     txt(2) = "img.title {width:990; height:105; align:left}"
     txt(3) = "p.subtitle1 {font-size:15pt; color:gray}"
     txt(4) = "p.subtitle {font-size:20pt; color:black; text-align:center; font-weight:bold}"
     txt(5) = "p.btext {font-size:12pt; text-align:left}"
     txt(6) = "p.btext2 {font-size:9pt; text-align:left}"
     txt(7) = "td {text-align:center; font-size:12pt}"
     txt(8) = "td.s1 {text-align:left; font-size:11pt}"
     txt(9) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}"
     txt(10) = "</STYLE></HEAD><BODY>"
     txt(11) = "<img class=title src="+quote+"cas_cvdp-le.png"+quote+" alt="+quote+"CVDP-LE logo"+quote+">"
     txt(12)= "<TABLE width='990' border=0 cellpadding=6>"
     txt(13) = "<tr><td width='350'><p class=btext><a href="+quote+"index.html"+quote+">Back to Diagnostics Plots</a></p></td>"
     txt(14) = "<td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left><p class=subtitle1>Metrics Table</p>" 
     
     z := asciiread(OUTDIR+"metrics_EM.txt",(/-1/),"string")
     nlines = dimsizes(z)
     txt(24) = "<PRE>"
     do gg = 0,nlines-1
        txt(25+gg) = z(gg)
     end do
     txt(25+nlines) = "</PRE>"
     txt(25+nlines+1) = "<p class=btext><a href="+quote+"namelist_obs"+quote+">Observations Used</a></p>"
     txt(25+nlines+2) = "Created "+systemfunc("date")
     txt(25+nlines+3) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  
     tt = ind(.not.ismissing(txt))
     txt2 = txt(:tt(dimsizes(tt)-1)+1)
     txt2 = where(ismissing(txt2),"",txt2)
     asciiwrite(OUTDIR+"metrics_EM.html",txt2)
     delete([/txt,txt2,tt,z/])
  end if 

  txt := new(500,"string")  
  txt(0) = "<HTML><HEAD><TITLE>Climate Variability Diagnostics Package</TITLE><STYLE>"
  txt(1) = "body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
  txt(2) = "img.title {width:990; height:105; align:left}"
  txt(3) = "p.subtitle1 {font-size:20pt; color:darkgray}"
  txt(4) = "p.subtitle {font-size:20pt; color:black; text-align:center; font-weight:bold}"
  txt(5) = "p.btext {font-size:12pt; text-align:left}"
  txt(6) = "p.btext2 {font-size:9pt; text-align:left}"
  txt(7) = "td {text-align:center; font-size:12pt}"
  txt(8) = "td.s1 {text-align:left; font-size:11pt}"
  txt(9) = "td.tablehdr {text-align:center; font-size:17pt}"
  txt(10) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}"
  txt(11) = "</STYLE></HEAD><BODY>"
  txt(12) = "<img class="+quote+"img-fluid"+quote+" src="+quote+"cas_cvdp-le.png"+quote+" alt="+quote+"CVDP-LE logo"+quote+">"
  txt(13)= "<TABLE width='990' border=0 cellpadding=6>"
  txt(14) = "<tr><td width='30'><p class=btext>Go to:</p></td><td class=s1 width='380'><a href="+quote+"http://dx.doi.org/10.5065/h7c7-f961"+quote+">User's Guide</a><br><a href="+quote+"index.html"+quote+">Diagnostics Plots</a><br><hr>"

  txt(27) = "<p class=btext><a href="+quote+"namelist_obs"+quote+">Observations Used</a></p>"
  txt(28) = "<p class=btext><a href="+quote+"metrics.txt"+quote+">Individual Metrics (ascii table)</a></p>"
  txt(29) = "<p class=btext><a href="+quote+"metrics_EM.txt"+quote+">Ensemble Metrics (ascii table)</a></p>"
  txt(30) = "Created "+systemfunc("date")
  txt(31) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"

  ncol_labels = (/"ENSO TAS (DJF~S~+1~N~)","ENSO PSL (DJF~S~+1~N~)", \
                  "El Nin~H-13V2F35~D~FV-2H3F21~o Hovmo~H-14V2F35~H~FV-2H3~ller",\
                  "La Nin~H-13V2F35~D~FV-2H3F21~a Hovmo~H-14V2F35~H~FV-2H3~ller", \
                  "SAM (NDJFMA)","SAM (MJJASO)","PSA1 (NDJFMA)","PSA1 (MJJASO)", \
                  "PSA2 (NDJFMA)","PSA2 (MJJASO)", "TPDV(Monthly)", "SO (NDJFMA)", "SO (MJJASO)", \
                  "SST std dev (Ann)","PR std dev (Ann)","Mean Score"/)

  sort_txt2 = (/"Namelist (Default)","Namelist (Alphabetically)","ENSO TAS","ENSO PSL",\
                "El Ni&ntilde;o Hovm&ouml;ller","La Ni&ntilde;a Hovm&ouml;ller",\
                "SAM (cold)","SAM (warm)","PSA1 (cold)","PSA1 (warm)", \
                "PSA2 (cold)","PSA2 (warm)", "TPDV (Monthly)","SO (cold)","SO (warm)",\
                "SST std dev","PR std dev","Mean Score"/)

  imcreate = False
  if (isfilepresent2(OUTDIR+"metrics.table_1.gif")) then  ; create sorted individual run metrics table pages
     imcreate = True
     sort_txt = (/"<a href="+quote+"metrics.table_0.html"+quote+">Namelist (default)</a> | ",\
                  "<a href="+quote+"metrics.table_1.html"+quote+">Namelist (Alphabetically)</a> | ",\
                  "<a href="+quote+"metrics.table_2.html"+quote+">ENSO TAS</a> | ",\
                  "<a href="+quote+"metrics.table_3.html"+quote+">ENSO PSL</a> | ", \
                  "<a href="+quote+"metrics.table_4.html"+quote+">El Ni&ntilde;o Hovm&ouml;ller</a><br>",\
                  "<a href="+quote+"metrics.table_5.html"+quote+">La Ni&ntilde;a Hovm&ouml;ller</a> | ",\
                  "<a href="+quote+"metrics.table_6.html"+quote+">SAM (NDJFMA)</a> | ",\
                  "<a href="+quote+"metrics.table_7.html"+quote+">SAM (MJJASO)</a> | ", \
                  "<a href="+quote+"metrics.table_8.html"+quote+">PSA1 (NDJFMA)</a> | ",\
                  "<a href="+quote+"metrics.table_9.html"+quote+">PSA1 (MJJASO)</a> | ",\
                  "<a href="+quote+"metrics.table_10.html"+quote+">PSA2 (NDJFMA)</a> | ",\
                  "<a href="+quote+"metrics.table_11.html"+quote+">PSA2 (MJJASO)</a> | ",\
                  "<a href="+quote+"metrics.table_12.html"+quote+">TPDV (Monthly)</a> | ",\
                  "<a href="+quote+"metrics.table_13.html"+quote+">SO (NDJFMA)</a> | ",\
                  "<a href="+quote+"metrics.table_14.html"+quote+">SO (MJJASO)</a> | ",\
                  "<a href="+quote+"metrics.table_15.html"+quote+">SST std dev</a> | ", \
                  "<a href="+quote+"metrics.table_16.html"+quote+">PR std dev</a> | ",\
                  "<a href="+quote+"metrics.table_17.html"+quote+">Mean Score</a>"/)

     sort_txtA = (/"<a href="+quote+"metrics.table_18.html"+quote+">Namelist (default)</a> | ",\
                   "<a href="+quote+"metrics.table_19.html"+quote+">Namelist (Alphabetically)</a> | ",\
                   "<a href="+quote+"metrics.table_20.html"+quote+">ENSO TAS</a> | ",\
                   "<a href="+quote+"metrics.table_21.html"+quote+">ENSO PSL</a> | ", \
                   "<a href="+quote+"metrics.table_22.html"+quote+">El Ni&ntilde;o Hovm&ouml;ller</a><br>",\
                   "<a href="+quote+"metrics.table_23.html"+quote+">La Ni&ntilde;a Hovm&ouml;ller</a> | ",\
                   "<a href="+quote+"metrics.table_24.html"+quote+">SAM (NDJFMA)</a> | ",\
                   "<a href="+quote+"metrics.table_25.html"+quote+">SAM (MJJASO)</a> | ", \
                   "<a href="+quote+"metrics.table_26.html"+quote+">PSA1 (NDJFMA)</a> | ",\
                   "<a href="+quote+"metrics.table_27.html"+quote+">PSA1 (MJJASO)</a> | ",\
                   "<a href="+quote+"metrics.table_28.html"+quote+">PSA2 (NDJFMA)</a> | ",\
                   "<a href="+quote+"metrics.table_29.html"+quote+">PSA2 (MJJASO)</a> | ",\
                   "<a href="+quote+"metrics.table_30.html"+quote+">TPDV (Monthly)</a> | ",\
                   "<a href="+quote+"metrics.table_31.html"+quote+">SO (NDJFMA)</a> | ",\
                   "<a href="+quote+"metrics.table_32.html"+quote+">SO (MJJASO)</a> | ",\
                   "<a href="+quote+"metrics.table_33.html"+quote+">SST std dev</a> | ",\
                   "<a href="+quote+"metrics.table_34.html"+quote+">PR std dev</a> | ",\
                   "<a href="+quote+"metrics.table_35.html"+quote+">Mean Score</a>"/)

     strarr = new(18,string)
     strarr = " | "
     strarr(17) = " "
     do gg = 0,17    ; Individual Pattern Correlation

           txt(15) = "Metrics Graphics: <a href="+quote+"metrics.ensemble.pc.html"+quote+">Correlations</a> | <a href="+quote+"metrics.ensemble.rms.html"+quote+">RMS</a><br>"
           txt(16) = "Ensemble Metrics Tables: <a href="+quote+"metrics.table_"+gg+"E.html"+quote+">Correlations</a> | <a href="+quote+"metrics.table_"+(gg+18)+"E.html"+quote+">RMS</a><br>"
           txt(17) = "Individual Metrics Tables: <b>Correlations</b> | <a href="+quote+"metrics.table_"+(gg+18)+".html"+quote+">RMS</a></td>"   
           txt(18) = "<td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
           sort_txtT = sort_txt
           sort_txtT(gg) = "<b>"+sort_txt2(gg)+"</b>"+strarr(gg)
           txt(24) = "<p class=subtitle1><b>Pattern Correlation Metrics (Individual)</b></p>"
           txt(25) = "<TABLE width='900' border=0 cellpadding=16><tr><td width=50><b>Sort By:</b></td><td>"+str_concat(sort_txtT)+"</td></tr></table>" 
           txt(26) = "<img width=980 src="+quote+"metrics.table_"+gg+".gif"+quote+" />"
           tt = ind(.not.ismissing(txt))
           txt2 = txt(:tt(dimsizes(tt)-1)+1)
           txt2 = where(ismissing(txt2),"",txt2)
           asciiwrite(OUTDIR+"metrics.table_"+gg+".html",txt2)
           delete([/txt2,tt,sort_txtT/])
     end do

     
     do gg = 0,17    ; Individual RMS
           txt(15) = "Metrics Graphics: <a href="+quote+"metrics.ensemble.pc.html"+quote+">Correlations</a> | <a href="+quote+"metrics.ensemble.rms.html"+quote+">RMS</a><br>"
           txt(16) = "Ensemble Metrics Tables: <a href="+quote+"metrics.table_"+gg+"E.html"+quote+">Correlations</a> | <a href="+quote+"metrics.table_"+(gg+18)+"E.html"+quote+">RMS</a><br>"
           txt(17) = "Individual Metrics Tables: <a href="+quote+"metrics.table_"+(gg)+".html"+quote+">Correlations</a> | <b>RMS</b></td>"   
           txt(18) = "<td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
           sort_txtT = sort_txtA
           sort_txtT(gg) = "<b>"+sort_txt2(gg)+"</b>"+strarr(gg)
           txt(24) = "<p class=subtitle1><b>RMS Metrics (Individual)</b></p>"
           txt(25) = "<TABLE width='900' border=0 cellpadding=16><tr><td width=50><b>Sort By:</b></td><td>"+str_concat(sort_txtT)+"</td></tr></table>"
           txt(26) = "<img width=980 src="+quote+"metrics.table_"+(gg+18)+".gif"+quote+" />"
           tt = ind(.not.ismissing(txt))
           txt2 = txt(:tt(dimsizes(tt)-1)+1)
           txt2 = where(ismissing(txt2),"",txt2)
           asciiwrite(OUTDIR+"metrics.table_"+(gg+18)+".html",txt2)
           delete([/txt2,tt/])
     end do
  end if
  if (isfilepresent2(OUTDIR+"metrics.table_1E.gif")) then  ; create sorted ensemble metrics table pages
     sort_txt = (/"<a href="+quote+"metrics.table_0E.html"+quote+">Namelist (default)</a> | ",\
                  "<a href="+quote+"metrics.table_1E.html"+quote+">Namelist (Alphabetically)</a> | ",\
                  "<a href="+quote+"metrics.table_2E.html"+quote+">ENSO TAS</a> | ",\
                  "<a href="+quote+"metrics.table_3E.html"+quote+">ENSO PSL</a> | ", \
                  "<a href="+quote+"metrics.table_4E.html"+quote+">El Ni&ntilde;o Hovm&ouml;ller</a><br>",\
                  "<a href="+quote+"metrics.table_5E.html"+quote+">La Ni&ntilde;a Hovm&ouml;ller</a> | ",\
                  "<a href="+quote+"metrics.table_6E.html"+quote+">SAM (NDJFMA)</a> | ",\
                  "<a href="+quote+"metrics.table_7E.html"+quote+">SAM (MJJASO)</a> | ", \
                  "<a href="+quote+"metrics.table_8E.html"+quote+">PSA1 (NDJFMA)</a> | ",\
                  "<a href="+quote+"metrics.table_9E.html"+quote+">PSA1 (MJJASO)</a> | ",\
                  "<a href="+quote+"metrics.table_10E.html"+quote+">PSA2 (NDJFMA)</a> | ",\
                  "<a href="+quote+"metrics.table_11E.html"+quote+">PSA2 (MJJASO)</a> | ",\
                  "<a href="+quote+"metrics.table_12E.html"+quote+">TPDV (Monthly)</a> | ",\
                  "<a href="+quote+"metrics.table_13E.html"+quote+">SO (NDJFMA)</a> | ",\
                  "<a href="+quote+"metrics.table_14E.html"+quote+">SO (MJJASO)</a> | ",\
                  "<a href="+quote+"metrics.table_15E.html"+quote+">SST std dev</a> | ", \
                  "<a href="+quote+"metrics.table_16E.html"+quote+">PR std dev</a> | ",\
                  "<a href="+quote+"metrics.table_17E.html"+quote+">Mean Score</a>"/)

     sort_txtA = (/"<a href="+quote+"metrics.table_18E.html"+quote+">Namelist (default)</a> | ",\
                   "<a href="+quote+"metrics.table_19E.html"+quote+">Namelist (Alphabetically)</a> | ",\
                   "<a href="+quote+"metrics.table_20E.html"+quote+">ENSO TAS</a> | ",\
                   "<a href="+quote+"metrics.table_21E.html"+quote+">ENSO PSL</a> | ", \
                   "<a href="+quote+"metrics.table_22E.html"+quote+">El Ni&ntilde;o Hovm&ouml;ller</a><br>",\
                   "<a href="+quote+"metrics.table_23E.html"+quote+">La Ni&ntilde;a Hovm&ouml;ller</a> | ",\
                   "<a href="+quote+"metrics.table_24E.html"+quote+">SAM (NDJFMA)</a> | ",\
                   "<a href="+quote+"metrics.table_25E.html"+quote+">SAM (MJJASO)</a> | ", \
                   "<a href="+quote+"metrics.table_26E.html"+quote+">PSA1 (NDJFMA)</a> | ",\
                   "<a href="+quote+"metrics.table_27E.html"+quote+">PSA1 (MJJASO)</a> | ",\
                   "<a href="+quote+"metrics.table_28E.html"+quote+">PSA2 (NDJFMA)</a> | ",\
                   "<a href="+quote+"metrics.table_29E.html"+quote+">PSA2 (MJJASO)</a> | ",\
                   "<a href="+quote+"metrics.table_30E.html"+quote+">TPDV (Monthly)</a> | ",\
                   "<a href="+quote+"metrics.table_31E.html"+quote+">SO (NDJFMA)</a> | ",\
                   "<a href="+quote+"metrics.table_32E.html"+quote+">SO (MJJASO)</a> | ",\
                   "<a href="+quote+"metrics.table_33E.html"+quote+">SST std dev</a> | ",\
                   "<a href="+quote+"metrics.table_34E.html"+quote+">PR std dev</a> | ",\
                   "<a href="+quote+"metrics.table_35E.html"+quote+">Mean Score</a>"/)

     strarr = new(18,string)
     strarr = " | "
     strarr(17) = " "

     do gg = 0,17     ; Ensemble Mean Pattern Correlation Table
        txt(15) = "Metrics Graphics: <a href="+quote+"metrics.ensemble.pc.html"+quote+">Correlations</a> | <a href="+quote+"metrics.ensemble.rms.html"+quote+">RMS</a><br>"
        txt(16) = "Ensemble Metrics Tables: <b>Correlations</b> | <a href="+quote+"metrics.table_"+(gg+18)+"E.html"+quote+">RMS</a><br>"
        if (imcreate) then
           txt(17) = "Individual Metrics Tables: <a href="+quote+"metrics.table_"+(gg)+".html"+quote+">Correlations</a> | <a href="+quote+"metrics.table_"+(gg+18)+".html"+quote+">RMS</a></td>"
        else
           txt(17) = "<a href="+quote+"metrics.html"+quote+">Individual Metrics Table</a></td>" 
        end if
        txt(18) = "<td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
        sort_txtT = sort_txt
        sort_txtT(gg) = "<b>"+sort_txt2(gg)+"</b>"+strarr(gg)
        txt(24) = "<p class=subtitle1><b>Pattern Correlation Metrics (Ensembles)</b></p>"
        txt(25) = "<TABLE width='900' border=0 cellpadding=16><tr><td width=50><b>Sort By:</b></td><td>"+str_concat(sort_txtT)+"</td></tr></table>" 
        txt(26) = "<img width=980 src="+quote+"metrics.table_"+gg+"E.gif"+quote+" />"
        tt = ind(.not.ismissing(txt))
        txt2 = txt(:tt(dimsizes(tt)-1)+1)
        txt2 = where(ismissing(txt2),"",txt2)
        asciiwrite(OUTDIR+"metrics.table_"+gg+"E.html",txt2)
        delete([/txt2,tt,sort_txtT/])
     end do

     
     do gg = 0,17    ; Ensemble Mean RMS
        txt(15) = "Metrics Graphics: <a href="+quote+"metrics.ensemble.pc.html"+quote+">Correlations</a> | <a href="+quote+"metrics.ensemble.rms.html"+quote+">RMS</a><br>"
        txt(16) = "Ensemble Metrics Tables: <a href="+quote+"metrics.table_"+gg+"E.html"+quote+">Correlations</a> | <b>RMS</b><br>"
        if (imcreate) then
           txt(17) = "Individual Metrics Tables: <a href="+quote+"metrics.table_"+(gg)+".html"+quote+">Correlations</a> | <a href="+quote+"metrics.table_"+(gg+18)+".html"+quote+">RMS</a></td>"   
        else
           txt(17) = "<a href="+quote+"metrics.html"+quote+">Individual Metrics Table</a></td>" 
        end if
        txt(18) = "<td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
        sort_txtT = sort_txtA
        sort_txtT(gg) = "<b>"+sort_txt2(gg)+"</b>"+strarr(gg)
        txt(24) = "<p class=subtitle1><b>RMS Metrics (Ensembles)</b></p>"
        txt(25) = "<TABLE width='900' border=0 cellpadding=16><tr><td width=50><b>Sort By:</b></td><td>"+str_concat(sort_txtT)+"</td></tr></table>"
        txt(26) = "<img width=980 src="+quote+"metrics.table_"+(gg+18)+"E.gif"+quote+" />"
        tt = ind(.not.ismissing(txt))
        txt2 = txt(:tt(dimsizes(tt)-1)+1)
        txt2 = where(ismissing(txt2),"",txt2)
        asciiwrite(OUTDIR+"metrics.table_"+(gg+18)+"E.html",txt2)
        delete([/txt2,tt/])
     end do

     if (imcreate) then
        txt(17) = "Individual Metrics Tables: <a href="+quote+"metrics.table_0.html"+quote+">Correlations</a> | <a href="+quote+"metrics.table_14.html"+quote+">RMS</a></td>"
     else
        txt(17) = "<a href="+quote+"metrics.html"+quote+">Individual Metrics Table</a></td>"
     end if
     txt(15) = "Metrics Graphics: <b>Correlations</b> | <a href="+quote+"metrics.ensemble.rms.html"+quote+">RMS</a><br>"
     txt(16) = "Ensemble Metrics Tables: <a href="+quote+"metrics.table_0E.html"+quote+">Correlations</a> | <a href="+quote+"metrics.table_14E.html"+quote+">RMS</a><br>"
     txt(18) = "<td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
     txt(24) = "<p class=subtitle1><b>Pattern Correlation Graphics</b></p>"
     txt(25) = ""
     txt(26) = "<img width=980 src="+quote+"ensemble_metrics_pc.gif"+quote+" />"
     tt = ind(.not.ismissing(txt))
     txt2 = txt(:tt(dimsizes(tt)-1)+1)
     txt2 = where(ismissing(txt2),"",txt2)
     asciiwrite(OUTDIR+"metrics.ensemble.pc.html",txt2)

     txt(15) = "Metrics Graphics: <a href="+quote+"metrics.ensemble.pc.html"+quote+">Correlation</a> | <b>RMS</b><br>"
     txt(16) = "Ensemble Metrics Tables: <a href="+quote+"metrics.table_0E.html"+quote+">Correlations</a> | <a href="+quote+"metrics.table_14E.html"+quote+">RMS</a><br>"
     txt(18) = "<td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
     txt(24) = "<p class=subtitle1><b>RMS Graphics</b></p>"
     txt(25) = ""
     txt(26) = "<img width=980 src="+quote+"ensemble_metrics_rms.gif"+quote+" />"
     tt = ind(.not.ismissing(txt))
     txt2 = txt(:tt(dimsizes(tt)-1)+1)
     txt2 = where(ismissing(txt2),"",txt2)
     asciiwrite(OUTDIR+"metrics.ensemble.rms.html",txt2)
     delete([/txt,strarr,tt,txt2/])
  end if 
;-----------------------------------------------------------------------------------
; Create index.html and index2.html
;
  txt := new(10000,"string")
  
  txt(0) = "<html><head><title>Climate Variability Diagnostics Package for Large Ensembles</title>"
  txt(1) = "<link rel="+quote+"stylesheet"+quote+" href="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"+quote+" integrity="+quote+"sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"+quote+" crossorigin="+quote+"anonymous"+quote+">"
  txt(2) = "<script src="+quote+"https://code.jquery.com/jquery-3.3.1.slim.min.js"+quote+" integrity="+quote+"sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
  txt(3) = "<script src="+quote+"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"+quote+" integrity="+quote+"sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
  txt(4) = "<script src="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"+quote+" integrity="+quote+"sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"

  txt(11) = "<STYLE>body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
  txt(12) = "img.title {width:990; height:105; align:left}"
  txt(13) = "p.subtitle {font-size:20pt; color:black; text-align:center; font-weight:bold}"
  txt(14) = "p.btext {font-size:11pt; text-align:left}"
  txt(15) = "font.s1 {font-size:13.5pt; text-align:left}"
  txt(17) = "td {text-align:center; font-size:12pt}"
  txt(18) = "td.s1 {text-align:left; font-size:11pt}"
  txt(19) = "td.s2 {border-bottom: 4px double darkgray}"
  txt(20) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}"
  txt(21) = "</style></head>"

  txt(30) = "<body>"
  txt(31) = "<div class="+quote+"container"+quote+">"
	 txt(32) = "<div class="+quote+"row"+quote+">"
		txt(33) = "<img class="+quote+"img-fluid"+quote+" src="+quote+"cas_cvdp-le.png"+quote+" alt="+quote+"CVDP-LE logo"+quote+">"
  txt(34) = "</div>"

  txt(40) = "<div class="+quote+"row"+quote+">"
		txt(41) = "<div class="+quote+"col"+quote+">"
		txt(42) = "<table class="+quote+"table my-0"+quote+">"
		txt(43) = "<tr>"
		txt(44) = "<td class="+quote+"text-left"+quote+">"
		txt(45) = "<ul class="+quote+"list-inline my-0"+quote+">"
		txt(46) = "<li class="+quote+"list-inline-item"+quote+"><a href="+quote+"http://dx.doi.org/10.5065/h7c7-f961"+quote+">User's Guide</a></li><br>"
  
  if (isfilepresent2(OUTDIR+"metrics.ensemble.pc.html")) then   ; both metrics.ensemble.pc.html and metrics.table_0E.html should be present
     atxt = "<li class="+quote+"list-inline-item"+quote+">Metrics: <a href="+quote+"metrics.ensemble.pc.html"+quote+">Graphics</a> | <a href="+quote+"metrics.table_0E.html"+quote+">Ensemble Tables</a> | "
  else
     if (isfilepresent2(OUTDIR+"metrics_EM.html")) then
        atxt = "<li class="+quote+"list-inline-item"+quote+">Metrics: <a href="+quote+"metrics_EM.html"+quote+">Ensemble Table</a> | "
     else
        atxt = ""
     end if
  end if
  if (isfilepresent2(OUTDIR+"metrics.table_0.html")) then
     btxt = "<a href="+quote+"metrics.table_0.html"+quote+">Individual Tables</a></li><br>"
  else
     if (isfilepresent2(OUTDIR+"metrics.html")) then
        btxt = "<a href="+quote+"metrics.html"+quote+">Individual Table</a></li><br>"
     else
        btxt = ""
     end if
  end if
  if (atxt.eq."".and.btxt.eq."") then
     txt(48) = "Metrics Unavailable<br>"
  else
     txt(48) = atxt+btxt
  end if

;  if (isfilepresent2(OUTDIR+"metrics.ensemble.pc.html")) then
;     txt(48) = "<li class="+quote+"list-inline-item"+quote+">Metrics: <a href="+quote+"metrics.ensemble.pc.html"+quote+">Graphics</a> | <a href="+quote+"metrics.table_0E.html"+quote+">Ensemble Tables</a> | <a href="+quote+"metrics.table_0.html"+quote+">Individual Tables</a></li><br>"
;  else
;     if (isfilepresent2(OUTDIR+"metrics.txt")) then
;        txt(48) = "<li class="+quote+"list-inline-item"+quote+">Metrics: <a href="+quote+"metrics.txt"+quote+">Individual</a> |  <a href="+quote+"metrics_EM.txt"+quote+">Ensemble</a></li><br>"
;     end if
;  end if
		txt(49) = "<li class="+quote+"list-inline-item"+quote+">Namelists: <a href="+quote+"namelist_obs.html"+quote+">Input</a> | <a href="+quote+"namelist_msftmz.html"+quote+">Derived</a></li>"
		txt(67) = "<li class="+quote+"list-inline-item"+quote+">Created: "+systemfunc("date")+"<br>CVDP-LE Version "+VERSION+"</li>"
  txt(68) = "<li class="+quote+"list-inline-item"+quote+"><b>Ensemble Summary</b> | <a href="+quote+"index2.html"+quote+">Individual Members</a></li>"
		txt(70) = "</ul></td>"
		txt(83) = "</tr>"
		txt(84) = "</table>"
		txt(85) = "</div>"
		txt(86) = "<div class="+quote+"col align-self-center"+quote+">"
		txt(87) = "<h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2>"
		txt(88) = "</div>"
	 txt(89) = "</div>"

  txt(100) = "<div class="+quote+"row"+quote+">"
  txt(101) = "<div class="+quote+"col"+quote+">"
  txt(102) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(103) = "<h3 class="+quote+"display-6"+quote+">Climatological Averages</h3>"

  txt(110) = "<tr class="+quote+"d-flex"+quote+">"
  txt(111) = "<td class="+quote+"col"+quote+"><b>SST</b></td>"
  txt(112) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialmean_djf.summary.png","DJF")+"</td>"
  txt(113) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialmean_jfm.summary.png","JFM")+"</td>"
  txt(114) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialmean_mam.summary.png","MAM")+"</td>"
  txt(115) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialmean_jja.summary.png","JJA")+"</td>"
  txt(116) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialmean_jas.summary.png","JAS")+"</td>"
  txt(117) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialmean_son.summary.png","SON")+"</td>"
  txt(118) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialmean_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(119) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialmean_mjjaso.summary.png","MJJASO")+"</td>"
  txt(120) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialmean_ann.summary.png","ANN")+"</td>"
  txt(121) = "</tr>"

  txt(122) = "<tr class="+quote+"d-flex"+quote+">"
  txt(123) = "<td class="+quote+"col"+quote+"><b>TAS</b></td>"
  txt(124) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialmean_djf.summary.png","DJF")+"</td>"
  txt(125) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialmean_jfm.summary.png","JFM")+"</td>"
  txt(126) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialmean_mam.summary.png","MAM")+"</td>"
  txt(127) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialmean_jja.summary.png","JJA")+"</td>"
  txt(128) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialmean_jas.summary.png","JAS")+"</td>"
  txt(129) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialmean_son.summary.png","SON")+"</td>"
  txt(130) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialmean_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(131) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialmean_mjjaso.summary.png","MJJASO")+"</td>"
  txt(132) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialmean_ann.summary.png","ANN")+"</td>"
  txt(133) = "</tr>"

  txt(134) = "<tr class="+quote+"d-flex"+quote+">"
  txt(135) = "<td class="+quote+"col"+quote+"><b>PSL</b></td>"
  txt(136) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialmean_djf.summary.png","DJF")+"</td>"
  txt(137) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialmean_jfm.summary.png","JFM")+"</td>"
  txt(138) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialmean_mam.summary.png","MAM")+"</td>"
  txt(139) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialmean_jja.summary.png","JJA")+"</td>"
  txt(140) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialmean_jas.summary.png","JAS")+"</td>"
  txt(141) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialmean_son.summary.png","SON")+"</td>"
  txt(142) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialmean_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(143) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialmean_mjjaso.summary.png","MJJASO")+"</td>"
  txt(144) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialmean_ann.summary.png","ANN")+"</td>"
  txt(145) = "</tr>"

  txt(146) = "<tr class="+quote+"d-flex"+quote+">"
  txt(147) = "<td class="+quote+"col"+quote+"><b>PR</b></td>"
  txt(148) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialmean_djf.summary.png","DJF")+"</td>"
  txt(149) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialmean_jfm.summary.png","JFM")+"</td>"
  txt(150) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialmean_mam.summary.png","MAM")+"</td>"
  txt(151) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialmean_jja.summary.png","JJA")+"</td>"
  txt(152) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialmean_jas.summary.png","JAS")+"</td>"
  txt(153) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialmean_son.summary.png","SON")+"</td>"
  txt(154) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialmean_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(155) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialmean_mjjaso.summary.png","MJJASO")+"</td>"
  txt(156) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialmean_ann.summary.png","ANN")+"</td>"
  txt(157) = "</tr>"


  txt(162) = "<tr class="+quote+"d-flex"+quote+">"
  txt(163) = "<td class="+quote+"col"+quote+"><b>SIC NH</b></td>"
  txt(164) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialmean_djf.summary.png","DJF")+"</td>"
  txt(165) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialmean_jfm.summary.png","JFM")+"</td>"
  txt(166) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialmean_mam.summary.png","MAM")+"</td>"
  txt(167) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialmean_jja.summary.png","JJA")+"</td>"
  txt(168) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialmean_jas.summary.png","JAS")+"</td>"
  txt(169) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialmean_son.summary.png","SON")+"</td>"
  txt(170) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialmean_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(171) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialmean_mjjaso.summary.png","MJJASO")+"</td>"
  txt(172) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialmean_ann.summary.png","ANN")+"</td>"
  txt(173) = "</tr>"

  txt(174) = "<tr class="+quote+"d-flex"+quote+">"
  txt(175) = "<td class="+quote+"col"+quote+"><b>SIC SH</b></td>"
  txt(176) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialmean_djf.summary.png","DJF")+"</td>"
  txt(177) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialmean_jfm.summary.png","JFM")+"</td>"
  txt(178) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialmean_mam.summary.png","MAM")+"</td>"
  txt(179) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialmean_jja.summary.png","JJA")+"</td>"
  txt(180) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialmean_jas.summary.png","JAS")+"</td>"
  txt(181) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialmean_son.summary.png","SON")+"</td>"
  txt(182) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialmean_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(183) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialmean_mjjaso.summary.png","MJJASO")+"</td>"
  txt(184) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialmean_ann.summary.png","ANN")+"</td>"
  txt(185) = "</tr></table></div></div>"

  txt(306) = "<div class="+quote+"row"+quote+">"
  txt(307) = "<div class="+quote+"col"+quote+">"
  txt(308) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(309) = "<h3 class="+quote+"display-6"+quote+">Standard Deviations</h3>"

  txt(316) = "<tr class="+quote+"d-flex"+quote+">"
  txt(317) = "<td class="+quote+"col"+quote+"><b>SST</b></td>"
  txt(318) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialstddev_djf.summary.png","DJF")+"</td>"
  txt(319) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialstddev_jfm.summary.png","JFM")+"</td>"
  txt(320) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialstddev_mam.summary.png","MAM")+"</td>"
  txt(321) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialstddev_jja.summary.png","JJA")+"</td>"
  txt(322) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialstddev_jas.summary.png","JAS")+"</td>"
  txt(323) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialstddev_son.summary.png","SON")+"</td>"
  txt(324) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialstddev_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(325) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialstddev_mjjaso.summary.png","MJJASO")+"</td>"
  txt(326) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_spatialstddev_ann.summary.png","ANN")+"</td>"
  txt(327) = "</tr>"

  txt(328) = "<tr class="+quote+"d-flex"+quote+">"
  txt(329) = "<td class="+quote+"col"+quote+"><b>TAS</b></td>"
  txt(330) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialstddev_djf.summary.png","DJF")+"</td>"
  txt(331) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialstddev_jfm.summary.png","JFM")+"</td>" 
  txt(332) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialstddev_mam.summary.png","MAM")+"</td>"
  txt(333) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialstddev_jja.summary.png","JJA")+"</td>"
  txt(334) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialstddev_jas.summary.png","JAS")+"</td>"
  txt(335) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialstddev_son.summary.png","SON")+"</td>"
  txt(336) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialstddev_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(337) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialstddev_mjjaso.summary.png","MJJASO")+"</td>"
  txt(338) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_spatialstddev_ann.summary.png","ANN")+"</td>"
  txt(339) = "</tr>"

  txt(340) = "<tr class="+quote+"d-flex"+quote+">"
  txt(341) = "<td class="+quote+"col"+quote+"><b>PSL</b></td>"
  txt(342) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialstddev_djf.summary.png","DJF")+"</td>"
  txt(343) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialstddev_jfm.summary.png","JFM")+"</td>"
  txt(344) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialstddev_mam.summary.png","MAM")+"</td>"
  txt(345) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialstddev_jja.summary.png","JJA")+"</td>"
  txt(346) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialstddev_jas.summary.png","JAS")+"</td>"
  txt(347) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialstddev_son.summary.png","SON")+"</td>"
  txt(348) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialstddev_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(349) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialstddev_mjjaso.summary.png","MJJASO")+"</td>"
  txt(350) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_spatialstddev_ann.summary.png","ANN")+"</td>"
  txt(351) = "</tr>"

  txt(352) = "<tr class="+quote+"d-flex"+quote+">"
  txt(353) = "<td class="+quote+"col"+quote+"><b>PR</b></td>"
  txt(354) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialstddev_djf.summary.png","DJF")+"</td>"
  txt(355) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialstddev_jfm.summary.png","JFM")+"</td>"
  txt(356) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialstddev_mam.summary.png","MAM")+"</td>"
  txt(357) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialstddev_jja.summary.png","JJA")+"</td>"
  txt(358) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialstddev_jas.summary.png","JAS")+"</td>"
  txt(359) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialstddev_son.summary.png","SON")+"</td>"
  txt(360) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialstddev_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(361) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialstddev_mjjaso.summary.png","MJJASO")+"</td>"
  txt(362) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_spatialstddev_ann.summary.png","ANN")+"</td>"
  txt(363) = "</tr>"

  txt(364) = "<tr class="+quote+"d-flex"+quote+">"
  txt(365) = "<td class="+quote+"col"+quote+"><b>SIC NH</b></td>"
  txt(366) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialstddev_djf.summary.png","DJF")+"</td>"
  txt(367) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialstddev_jfm.summary.png","JFM")+"</td>"
  txt(368) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialstddev_mam.summary.png","MAM")+"</td>"
  txt(369) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialstddev_jja.summary.png","JJA")+"</td>"
  txt(370) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialstddev_jas.summary.png","JAS")+"</td>"
  txt(371) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialstddev_son.summary.png","SON")+"</td>"
  txt(372) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialstddev_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(373) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialstddev_mjjaso.summary.png","MJJASO")+"</td>"
  txt(374) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_spatialstddev_ann.summary.png","ANN")+"</td>"
  txt(375) = "</tr>"

  txt(376) = "<tr class="+quote+"d-flex"+quote+">"
  txt(377) = "<td class="+quote+"col"+quote+"><b>SIC SH</b></td>"
  txt(378) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialstddev_djf.summary.png","DJF")+"</td>"
  txt(379) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialstddev_jfm.summary.png","JFM")+"</td>"
  txt(380) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialstddev_mam.summary.png","MAM")+"</td>"
  txt(381) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialstddev_jja.summary.png","JJA")+"</td>"
  txt(382) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialstddev_jas.summary.png","JAS")+"</td>"
  txt(383) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialstddev_son.summary.png","SON")+"</td>"
  txt(384) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialstddev_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(385) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialstddev_mjjaso.summary.png","MJJASO")+"</td>"
  txt(386) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_spatialstddev_ann.summary.png","ANN")+"</td>"
  txt(387) = "</tr></table></div></div>"



  txt(508) = "<div class="+quote+"row"+quote+">"
  txt(509) = "<div class="+quote+"col"+quote+">"
  txt(510) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(511) = "<h3 class="+quote+"display-6"+quote+">Climate Trend Maps</h3>"

  txt(518) = "<tr class="+quote+"d-flex"+quote+">"
  txt(519) = "<td class="+quote+"col"+quote+"><b>SST</b></td>"
  txt(520) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_trends_djf.summary.png","DJF")+"</td>"
  txt(521) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_trends_jfm.summary.png","JFM")+"</td>"
  txt(522) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_trends_mam.summary.png","MAM")+"</td>"
  txt(523) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_trends_jja.summary.png","JJA")+"</td>"
  txt(524) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_trends_jas.summary.png","JAS")+"</td>"
  txt(525) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_trends_son.summary.png","SON")+"</td>"
  txt(526) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_trends_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(527) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_trends_mjjaso.summary.png","MJJASO")+"</td>"
  txt(528) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_trends_ann.summary.png","ANN")+"</td>"
  txt(529) = "</tr>"

  txt(530) = "<tr class="+quote+"d-flex"+quote+">"
  txt(531) = "<td class="+quote+"col"+quote+"><b>TAS</b></td>"
  txt(532) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_trends_djf.summary.png","DJF")+"</td>"
  txt(533) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_trends_jfm.summary.png","JFM")+"</td>"
  txt(534) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_trends_mam.summary.png","MAM")+"</td>"
  txt(535) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_trends_jja.summary.png","JJA")+"</td>"
  txt(536) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_trends_jas.summary.png","JAS")+"</td>"
  txt(537) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_trends_son.summary.png","SON")+"</td>"
  txt(538) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_trends_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(539) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_trends_mjjaso.summary.png","MJJASO")+"</td>"
  txt(540) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_trends_ann.summary.png","ANN")+"</td>"
  txt(541) = "</tr>"

  txt(542) = "<tr class="+quote+"d-flex"+quote+">"
  txt(543) = "<td class="+quote+"col"+quote+"><b>PSL</b></td>"
  txt(544) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_trends_djf.summary.png","DJF")+"</td>"
  txt(545) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_trends_jfm.summary.png","JFM")+"</td>"
  txt(546) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_trends_mam.summary.png","MAM")+"</td>"
  txt(547) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_trends_jja.summary.png","JJA")+"</td>"
  txt(548) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_trends_jas.summary.png","JAS")+"</td>"
  txt(549) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_trends_son.summary.png","SON")+"</td>"
  txt(550) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_trends_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(551) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_trends_mjjaso.summary.png","MJJASO")+"</td>"
  txt(552) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"psl_trends_ann.summary.png","ANN")+"</td>"
  txt(553) = "</tr>"

  txt(554) = "<tr class="+quote+"d-flex"+quote+">"
  txt(555) = "<td class="+quote+"col"+quote+"><b>PR</b></td>"
  txt(556) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_trends_djf.summary.png","DJF")+"</td>"
  txt(557) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_trends_jfm.summary.png","JFM")+"</td>"
  txt(558) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_trends_mam.summary.png","MAM")+"</td>"
  txt(559) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_trends_jja.summary.png","JJA")+"</td>"
  txt(560) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_trends_jas.summary.png","JAS")+"</td>"
  txt(561) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_trends_son.summary.png","SON")+"</td>"
  txt(562) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_trends_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(563) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_trends_mjjaso.summary.png","MJJASO")+"</td>"
  txt(564) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_trends_ann.summary.png","ANN")+"</td>"
  txt(565) = "</tr>"

  txt(566) = "<tr class="+quote+"d-flex"+quote+">"
  txt(567) = "<td class="+quote+"col"+quote+"><b>SIC NH</b></td>"
  txt(568) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_trends_djf.summary.png","DJF")+"</td>"
  txt(569) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_trends_jfm.summary.png","JFM")+"</td>"
  txt(570) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_trends_mam.summary.png","MAM")+"</td>"
  txt(571) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_trends_jja.summary.png","JJA")+"</td>"
  txt(572) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_trends_jas.summary.png","JAS")+"</td>"
  txt(573) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_trends_son.summary.png","SON")+"</td>"
  txt(574) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_trends_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(575) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_trends_mjjaso.summary.png","MJJASO")+"</td>"
  txt(576) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_nh_trends_ann.summary.png","ANN")+"</td>"
  txt(577) = "</tr>"

  txt(578) = "<tr class="+quote+"d-flex"+quote+">"
  txt(579) = "<td class="+quote+"col"+quote+"><b>SIC SH</b></td>"
  txt(580) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_trends_djf.summary.png","DJF")+"</td>"
  txt(581) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_trends_jfm.summary.png","JFM")+"</td>"
  txt(582) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_trends_mam.summary.png","MAM")+"</td>"
  txt(583) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_trends_jja.summary.png","JJA")+"</td>"
  txt(584) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_trends_jas.summary.png","JAS")+"</td>"
  txt(585) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_trends_son.summary.png","SON")+"</td>"
  txt(586) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_trends_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(587) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_trends_mjjaso.summary.png","MJJASO")+"</td>"
  txt(588) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"siconc_sh_trends_ann.summary.png","ANN")+"</td>"
  txt(589) = "</tr></table></div></div>"

  txt(1009) = "<div class="+quote+"row"+quote+">"
  txt(1010) = "<div class="+quote+"col"+quote+">"
  txt(1011) = "<table class="+quote+"table table-bordered"+quote+">"
  txt(1012) = "<h3 class="+quote+"display-6"+quote+">Coupled Modes of Variability</h3>"
  txt(1013) = "<tr>"
  txt(1014) = "<td rowspan=7><b>ENSO</b></td>"
  
  txt(1015) = "<td rowspan=4>Spatial Composites</td>"
  txt(1016) = "<td>El Ni&ntilde;o - La Ni&ntilde;a<br>SST/TAS/PSL<br>"
  txt(1017) = table_link_setup(OUTDIR,"nino34.spatialcomp.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(1018) = table_link_setup(OUTDIR,"nino34.spatialcomp.summary.son0.png","SON<sup>0</sup>")+" "
  txt(1019) = table_link_setup(OUTDIR,"nino34.spatialcomp.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(1020) = table_link_setup(OUTDIR,"nino34.spatialcomp.summary.mam1.png","MAM<sup>1</sup>")+"</td>"
  txt(1025) = "<td>El Ni&ntilde;o - La Ni&ntilde;a<br>PR<br>"
  txt(1026) = table_link_setup(OUTDIR,"nino34.spatialcomp.pr.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(1027) = table_link_setup(OUTDIR,"nino34.spatialcomp.pr.summary.son0.png","SON<sup>0</sup>")+" "
  txt(1028) = table_link_setup(OUTDIR,"nino34.spatialcomp.pr.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(1029) = table_link_setup(OUTDIR,"nino34.spatialcomp.pr.summary.mam1.png","MAM<sup>1</sup>")+"</td></tr>"

  txt(1036) = "<td>El Ni&ntilde;o SST/TAS/PSL<br>"
  txt(1037) = table_link_setup(OUTDIR,"nino34.spatialcomp.elnino.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(1038) = table_link_setup(OUTDIR,"nino34.spatialcomp.elnino.summary.son0.png","SON<sup>0</sup>")+" "
  txt(1039) = table_link_setup(OUTDIR,"nino34.spatialcomp.elnino.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(1040) = table_link_setup(OUTDIR,"nino34.spatialcomp.elnino.summary.mam1.png","MAM<sup>1</sup>")+"</td>"
  txt(1045) = "<td>El Ni&ntilde;o PR<br>"
  txt(1046) = table_link_setup(OUTDIR,"nino34.spatialcomp.elnino.pr.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(1047) = table_link_setup(OUTDIR,"nino34.spatialcomp.elnino.pr.summary.son0.png","SON<sup>0</sup>")+" "
  txt(1048) = table_link_setup(OUTDIR,"nino34.spatialcomp.elnino.pr.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(1049) = table_link_setup(OUTDIR,"nino34.spatialcomp.elnino.pr.summary.mam1.png","MAM<sup>1</sup>")+"</td></tr>"

  txt(1056) = "<td>La Ni&ntilde;a SST/TAS/PSL<br>"
  txt(1057) = table_link_setup(OUTDIR,"nino34.spatialcomp.lanina.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(1058) = table_link_setup(OUTDIR,"nino34.spatialcomp.lanina.summary.son0.png","SON<sup>0</sup>")+" "
  txt(1059) = table_link_setup(OUTDIR,"nino34.spatialcomp.lanina.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(1060) = table_link_setup(OUTDIR,"nino34.spatialcomp.lanina.summary.mam1.png","MAM<sup>1</sup>")+"</td>"
  txt(1065) = "<td>La Ni&ntilde;a PR<br>"
  txt(1066) = table_link_setup(OUTDIR,"nino34.spatialcomp.lanina.pr.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(1067) = table_link_setup(OUTDIR,"nino34.spatialcomp.lanina.pr.summary.son0.png","SON<sup>0</sup>")+" "
  txt(1068) = table_link_setup(OUTDIR,"nino34.spatialcomp.lanina.pr.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(1069) = table_link_setup(OUTDIR,"nino34.spatialcomp.lanina.pr.summary.mam1.png","MAM<sup>1</sup>")+"</td></tr>"

  txt(1105) = "<tr>"
  txt(1106) = "<td>"+table_link_setup(OUTDIR,"nino34.hov.elnino.summary.png","El Ni&ntilde;o Hovm&ouml;ller")+"</td>"
  txt(1107) = "<td>"+table_link_setup(OUTDIR,"nino34.hov.lanina.summary.png","La Ni&ntilde;a Hovm&ouml;ller")+"</td></tr>"

  txt(1155) = "<tr><td rowspan=3>Ni&ntilde;o3.4</td>"
  txt(1156) = "<td>"+table_link_setup(OUTDIR,"nino34.timeseries.summary.png","Timeseries")+"</td>"
  txt(1157) = "<td>"+table_link_setup(OUTDIR,"nino34.monstddev.summary.png","Monthly Std. Dev.")+"</td>"
  txt(1158) = "<tr><td>"+table_link_setup(OUTDIR,"nino34.powspec.summary.png","Power Spectra")+"</td>"
  txt(1159) = "<td>"+table_link_setup(OUTDIR,"nino34.wavelet.summary.png","Wavelet")+"</td></tr>"
  txt(1160) = "<tr><td>"+table_link_setup(OUTDIR,"nino34.autocor.summary.png","Autocorrelation")+"</td>"
  txt(1161) = "<td>"+table_link_setup(OUTDIR,"nino34_runstddev.timeseries.summary.png","Running Standard Deviation")+"</td></tr>"

  txt(1205) = "<tr><td rowspan=2><b>AMV</b></td>"
  txt(1206) = "<td>Regr: "
  txt(1207) = table_link_setup(OUTDIR,"amv.summary.png","SST")+" "
  txt(1208) = table_link_setup(OUTDIR,"amv.tassstreg.summary.png","TAS")+" "
  txt(1209) = table_link_setup(OUTDIR,"amv.prreg.summary.png","PR")+"</td>"
  txt(1215) = "<td>"+table_link_setup(OUTDIR,"amv_timeseries_mon.summary.png","Timeseries")+"</td>"
  txt(1225) = "<td rowspan=2>"+table_link_setup(OUTDIR,"amv.powspec.summary.png","Power Spectra")+"</td></tr>"


  txt(1256) = "<tr><td>Regr LP: "
  txt(1257) = table_link_setup(OUTDIR,"amv.lp.summary.png","SST")+" "
  txt(1258) = table_link_setup(OUTDIR,"amv.lp.tassstreg.summary.png","TAS")+" "
  txt(1259) = table_link_setup(OUTDIR,"amv.lp.prreg.summary.png","PR")+"</td>"
  txt(1265) = "<td>"+table_link_setup(OUTDIR,"amv_timeseries_lowpass_mon.summary.png","Timeseries")+"</td></tr>"

  txt(1305) = "<tr><td rowspan=2><b>AMV'</b></td>"
  txt(1306) = "<td>Regr: "
  txt(1307) = table_link_setup(OUTDIR,"amv.prime.summary.png","SST")+" "
  txt(1308) = table_link_setup(OUTDIR,"amv.prime.tassstreg.summary.png","TAS")+" "
  txt(1309) = table_link_setup(OUTDIR,"amv.prime.prreg.summary.png","PR")+"</td>"
  txt(1310) = "<td>"+table_link_setup(OUTDIR,"amv_prime_timeseries_mon.summary.png","Timeseries")+"</td>"
  txt(1321) = "<td rowspan=2>"+table_link_setup(OUTDIR,"amv.prime.powspec.summary.png","Power Spectra")+"</td></tr>"

  txt(1332) = "<tr><td>Regr LP: "
  txt(1333) = table_link_setup(OUTDIR,"amv.lp.prime.summary.png","SST")+" "
  txt(1334) = table_link_setup(OUTDIR,"amv.lp.prime.tassstreg.summary.png","TAS")+" "
  txt(1335) = table_link_setup(OUTDIR,"amv.lp.prime.prreg.summary.png","PR")+"</td>"
  txt(1340) = "<td>"+table_link_setup(OUTDIR,"amv_prime_timeseries_lowpass_mon.summary.png","Timeseries")+"</td></tr>"


  txt(1405) = "<tr><td><b>PDV</b></td>"
  txt(1406) = "<td>Regr: "
  txt(1407) = table_link_setup(OUTDIR,"pdv.summary.png","SST")+" "
  txt(1408) = table_link_setup(OUTDIR,"pdv.tassstreg.summary.png","TAS")+" "
  txt(1409) = table_link_setup(OUTDIR,"pdv.prreg.summary.png","PR")+"</td>"
  txt(1410) = "<td>"+table_link_setup(OUTDIR,"pdv_timeseries_mon.summary.png","Timeseries")+"</td>"
  txt(1411) = "<td>"+table_link_setup(OUTDIR,"pdv.powspec.summary.png","Power Spectra")+"</td></tr>"
  txt(1455) = "<tr><td><b>PDV'</b></td>"
  txt(1456) = "<td>Regr: "
  txt(1457) = table_link_setup(OUTDIR,"pdv.prime.summary.png","SST")+" "
  txt(1458) = table_link_setup(OUTDIR,"pdv.prime.tassstreg.summary.png","TAS")+" "
  txt(1459) = table_link_setup(OUTDIR,"pdv.prime.prreg.summary.png","PR")+"</td>"
  txt(1460) = "<td>"+table_link_setup(OUTDIR,"pdv_prime_timeseries_mon.summary.png","Timeseries")+"</td>"
  txt(1461) = "<td>"+table_link_setup(OUTDIR,"pdv.prime.powspec.summary.png","Power Spectra")+"</td></tr>"
  txt(1462) = "</td></tr>"


  txt(1495) = "<tr><td><b>TPDV</b></td>"
  txt(1496) = "<td>Regr: "
  txt(1497) = table_link_setup(OUTDIR,"tpdv.summary.png","SST")+" "
  txt(1498) = table_link_setup(OUTDIR,"tpdv.tassstreg.summary.png","TAS")+" "
  txt(1499) = table_link_setup(OUTDIR,"tpdv.prreg.summary.png","PR")+"</td>"
  txt(1500) = "<td>"+table_link_setup(OUTDIR,"tpdv_timeseries_mon.summary.png","Timeseries")+"</td>"
  txt(1501) = "<td>"+table_link_setup(OUTDIR,"tpdv.powspec.summary.png","Power Spectra")+"</td></tr>"
  txt(1502) = "</td></tr>"

  txt(1535) = "<tr><td rowspan=3><b>AMOC</b></td>"
  txt(1536) = "<td>"+table_link_setup(OUTDIR,"amoc.mean.ann.summary.png","Means")+"</td>"
  txt(1537) = "<td>"+table_link_setup(OUTDIR,"amoc.stddev.ann.summary.png","Standard Deviations")+"</td>"
  txt(1538) = "<td>"+table_link_setup(OUTDIR,"amoc.pattern.ann.summary.png","Patterns")+"</td></tr>"
  txt(1539) = "<tr><td>"+table_link_setup(OUTDIR,"amoc.timeseries.ann.summary.png","Timeseries")+"</td>"
  txt(1540) = "<td colspan=2>"+table_link_setup(OUTDIR,"amoc.tassstreg.ann.summary.png","SST/TAS Regressions")+"</td></tr>"
  txt(1541) = "<tr><td>"+table_link_setup(OUTDIR,"amoc.powspec.summary.png","Spectra")+"</td>"
  txt(1542) = "<td colspan=2>"+table_link_setup(OUTDIR,"amoc_amv.leadlag.ann.summary.png","AMV/AMOC Lag Correlations")+"</td></tr>"
  txt(1543) = "</table></div></div>"

  txt(1585) = "<div class="+quote+"row"+quote+">"
  txt(1586) = "<div class="+quote+"col"+quote+">"
  txt(1587) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(1588) = "<h3 class="+quote+"display-6"+quote+">Atmospheric Modes of Variability</h3>"

  txt(1596) = "<tr><td rowspan=2><b>SO</b></td>"
  txt(1597) = "<td>Patterns</td>"
  txt(1598) = "<td>"+table_link_setup(OUTDIR,"so_pattern_djf.summary.png","DJF")+"</td>"
  txt(1599) = "<td>"+table_link_setup(OUTDIR,"so_pattern_jfm.summary.png","JFM")+"</td>"
  txt(1600) = "<td>"+table_link_setup(OUTDIR,"so_pattern_mam.summary.png","MAM")+"</td>"
  txt(1601) = "<td>"+table_link_setup(OUTDIR,"so_pattern_jja.summary.png","JJA")+"</td>"
  txt(1602) = "<td>"+table_link_setup(OUTDIR,"so_pattern_jas.summary.png","JAS")+"</td>"
  txt(1603) = "<td>"+table_link_setup(OUTDIR,"so_pattern_son.summary.png","SON")+"</td>"
  txt(1604) = "<td>"+table_link_setup(OUTDIR,"so_pattern_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1605) = "<td>"+table_link_setup(OUTDIR,"so_pattern_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1606) = "<td>"+table_link_setup(OUTDIR,"so_pattern_ann.summary.png","ANN")+"</td></tr>"
  txt(1607) = "<td>Timeseries</td>"
  txt(1610) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_djf.summary.png","DJF")+"</td>"
  txt(1611) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_jfm.summary.png","JFM")+"</td>"
  txt(1612) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_mam.summary.png","MAM")+"</td>"
  txt(1613) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_jja.summary.png","JJA")+"</td>"
  txt(1614) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_jas.summary.png","JAS")+"</td>"
  txt(1615) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_son.summary.png","SON")+"</td>"
  txt(1616) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1617) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1618) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_ann.summary.png","ANN")+"</td></tr>"

  txt(1620) = "<tr><td rowspan=2><b>NAM</b></td>"
  txt(1621) = "<td>Patterns</td>"
  txt(1622) = "<td>"+table_link_setup(OUTDIR,"nam_pattern_djf.summary.png","DJF")+"</td>"
  txt(1623) = "<td>"+table_link_setup(OUTDIR,"nam_pattern_jfm.summary.png","JFM")+"</td>"
  txt(1624) = "<td>"+table_link_setup(OUTDIR,"nam_pattern_mam.summary.png","MAM")+"</td>"
  txt(1625) = "<td>"+table_link_setup(OUTDIR,"nam_pattern_jja.summary.png","JJA")+"</td>"
  txt(1626) = "<td>"+table_link_setup(OUTDIR,"nam_pattern_jas.summary.png","JAS")+"</td>"
  txt(1627) = "<td>"+table_link_setup(OUTDIR,"nam_pattern_son.summary.png","SON")+"</td>"
  txt(1628) = "<td>"+table_link_setup(OUTDIR,"nam_pattern_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1629) = "<td>"+table_link_setup(OUTDIR,"nam_pattern_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1630) = "<td>"+table_link_setup(OUTDIR,"nam_pattern_ann.summary.png","ANN")+"</td></tr>"
  txt(1631) = "<td>Timeseries</td>"
  txt(1634) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_djf.summary.png","DJF")+"</td>"
  txt(1635) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_jfm.summary.png","JFM")+"</td>"
  txt(1636) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_mam.summary.png","MAM")+"</td>"
  txt(1637) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_jja.summary.png","JJA")+"</td>"
  txt(1638) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_jas.summary.png","JAS")+"</td>"
  txt(1639) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_son.summary.png","SON")+"</td>"
  txt(1640) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1641) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1642) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_ann.summary.png","ANN")+"</td></tr>"

  txt(1644) = "<tr><td rowspan=2><b>NAO</b></td>"
  txt(1645) = "<td>Patterns</td>"
  txt(1646) = "<td>"+table_link_setup(OUTDIR,"nao_pattern_djf.summary.png","DJF")+"</td>"
  txt(1647) = "<td>"+table_link_setup(OUTDIR,"nao_pattern_jfm.summary.png","JFM")+"</td>"
  txt(1648) = "<td>"+table_link_setup(OUTDIR,"nao_pattern_mam.summary.png","MAM")+"</td>"
  txt(1649) = "<td>"+table_link_setup(OUTDIR,"nao_pattern_jja.summary.png","JJA")+"</td>"
  txt(1650) = "<td>"+table_link_setup(OUTDIR,"nao_pattern_jas.summary.png","JAS")+"</td>"
  txt(1651) = "<td>"+table_link_setup(OUTDIR,"nao_pattern_son.summary.png","SON")+"</td>"
  txt(1652) = "<td>"+table_link_setup(OUTDIR,"nao_pattern_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1653) = "<td>"+table_link_setup(OUTDIR,"nao_pattern_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1654) = "<td>"+table_link_setup(OUTDIR,"nao_pattern_ann.summary.png","ANN")+"</td></tr>"
  txt(1655) = "<td>Timeseries</td>"
  txt(1658) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_djf.summary.png","DJF")+"</td>"
  txt(1659) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_jfm.summary.png","JFM")+"</td>"
  txt(1660) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_mam.summary.png","MAM")+"</td>"
  txt(1661) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_jja.summary.png","JJA")+"</td>"
  txt(1662) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_jas.summary.png","JAS")+"</td>"
  txt(1663) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_son.summary.png","SON")+"</td>"
  txt(1664) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1665) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1666) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_ann.summary.png","ANN")+"</td></tr>"

  txt(1668) = "<tr><td rowspan=2><b>SAM</b></td>"
  txt(1669) = "<td>Patterns</td>"
  txt(1670) = "<td>"+table_link_setup(OUTDIR,"sam_pattern_djf.summary.png","DJF")+"</td>"
  txt(1671) = "<td>"+table_link_setup(OUTDIR,"sam_pattern_jfm.summary.png","JFM")+"</td>"
  txt(1672) = "<td>"+table_link_setup(OUTDIR,"sam_pattern_mam.summary.png","MAM")+"</td>"
  txt(1673) = "<td>"+table_link_setup(OUTDIR,"sam_pattern_jja.summary.png","JJA")+"</td>"
  txt(1674) = "<td>"+table_link_setup(OUTDIR,"sam_pattern_jas.summary.png","JAS")+"</td>"
  txt(1675) = "<td>"+table_link_setup(OUTDIR,"sam_pattern_son.summary.png","SON")+"</td>"
  txt(1676) = "<td>"+table_link_setup(OUTDIR,"sam_pattern_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1677) = "<td>"+table_link_setup(OUTDIR,"sam_pattern_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1678) = "<td>"+table_link_setup(OUTDIR,"sam_pattern_ann.summary.png","ANN")+"</td></tr>"
  txt(1679) = "<td>Timeseries</td>"
  txt(1682) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_djf.summary.png","DJF")+"</td>"
  txt(1683) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_jfm.summary.png","JFM")+"</td>"
  txt(1684) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_mam.summary.png","MAM")+"</td>"
  txt(1685) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_jja.summary.png","JJA")+"</td>"
  txt(1686) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_jas.summary.png","JAS")+"</td>"
  txt(1687) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_son.summary.png","SON")+"</td>"
  txt(1688) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1689) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1690) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_ann.summary.png","ANN")+"</td></tr>"

  txt(1692) = "<tr><td rowspan=2><b>PNA</b></td>"
  txt(1693) = "<td>Patterns</td>"
  txt(1694) = "<td>"+table_link_setup(OUTDIR,"pna_pattern_djf.summary.png","DJF")+"</td>"
  txt(1695) = "<td>"+table_link_setup(OUTDIR,"pna_pattern_jfm.summary.png","JFM")+"</td>"
  txt(1696) = "<td>"+table_link_setup(OUTDIR,"pna_pattern_mam.summary.png","MAM")+"</td>"
  txt(1697) = "<td>"+table_link_setup(OUTDIR,"pna_pattern_jja.summary.png","JJA")+"</td>"
  txt(1698) = "<td>"+table_link_setup(OUTDIR,"pna_pattern_jas.summary.png","JAS")+"</td>"
  txt(1699) = "<td>"+table_link_setup(OUTDIR,"pna_pattern_son.summary.png","SON")+"</td>"
  txt(1700) = "<td>"+table_link_setup(OUTDIR,"pna_pattern_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1701) = "<td>"+table_link_setup(OUTDIR,"pna_pattern_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1702) = "<td>"+table_link_setup(OUTDIR,"pna_pattern_ann.summary.png","ANN")+"</td></tr>"
  txt(1703) = "<td>Timeseries</td>"
  txt(1706) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_djf.summary.png","DJF")+"</td>"
  txt(1708) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_jfm.summary.png","JFM")+"</td>"
  txt(1709) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_mam.summary.png","MAM")+"</td>"
  txt(1710) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_jja.summary.png","JJA")+"</td>"
  txt(1711) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_jas.summary.png","JAS")+"</td>"
  txt(1712) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_son.summary.png","SON")+"</td>"
  txt(1713) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1714) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1715) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_ann.summary.png","ANN")+"</td></tr>"

  txt(1727) = "<tr><td rowspan=2><b>NPO</b></td>"
  txt(1728) = "<td>Patterns</td>"
  txt(1729) = "<td>"+table_link_setup(OUTDIR,"npo_pattern_djf.summary.png","DJF")+"</td>"
  txt(1730) = "<td>"+table_link_setup(OUTDIR,"npo_pattern_jfm.summary.png","JFM")+"</td>"
  txt(1731) = "<td>"+table_link_setup(OUTDIR,"npo_pattern_mam.summary.png","MAM")+"</td>"
  txt(1732) = "<td>"+table_link_setup(OUTDIR,"npo_pattern_jja.summary.png","JJA")+"</td>"
  txt(1733) = "<td>"+table_link_setup(OUTDIR,"npo_pattern_jas.summary.png","JAS")+"</td>"
  txt(1734) = "<td>"+table_link_setup(OUTDIR,"npo_pattern_son.summary.png","SON")+"</td>"
  txt(1735) = "<td>"+table_link_setup(OUTDIR,"npo_pattern_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1736) = "<td>"+table_link_setup(OUTDIR,"npo_pattern_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1737) = "<td>"+table_link_setup(OUTDIR,"npo_pattern_ann.summary.png","ANN")+"</td></tr>"
  txt(1738) = "<td>Timeseries</td>"
  txt(1743) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_djf.summary.png","DJF")+"</td>"
  txt(1744) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_jfm.summary.png","JFM")+"</td>"
  txt(1745) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_mam.summary.png","MAM")+"</td>"
  txt(1746) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_jja.summary.png","JJA")+"</td>"
  txt(1747) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_jas.summary.png","JAS")+"</td>"
  txt(1748) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_son.summary.png","SON")+"</td>"
  txt(1749) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1750) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1751) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_ann.summary.png","ANN")+"</td></tr>"

  txt(1753) = "<tr><td rowspan=2><b>PSA1</b></td>"
  txt(1754) = "<td>Patterns</td>"
  txt(1755) = "<td>"+table_link_setup(OUTDIR,"psa1_pattern_djf.summary.png","DJF")+"</td>"
  txt(1756) = "<td>"+table_link_setup(OUTDIR,"psa1_pattern_jfm.summary.png","JFM")+"</td>"
  txt(1757) = "<td>"+table_link_setup(OUTDIR,"psa1_pattern_mam.summary.png","MAM")+"</td>"
  txt(1758) = "<td>"+table_link_setup(OUTDIR,"psa1_pattern_jja.summary.png","JJA")+"</td>"
  txt(1759) = "<td>"+table_link_setup(OUTDIR,"psa1_pattern_jas.summary.png","JAS")+"</td>"
  txt(1760) = "<td>"+table_link_setup(OUTDIR,"psa1_pattern_son.summary.png","SON")+"</td>"
  txt(1761) = "<td>"+table_link_setup(OUTDIR,"psa1_pattern_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1762) = "<td>"+table_link_setup(OUTDIR,"psa1_pattern_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1763) = "<td>"+table_link_setup(OUTDIR,"psa1_pattern_ann.summary.png","ANN")+"</td></tr>"
  txt(1764) = "<td>Timeseries</td>"
  txt(1767) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_djf.summary.png","DJF")+"</td>"
  txt(1768) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_jfm.summary.png","JFM")+"</td>"
  txt(1769) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_mam.summary.png","MAM")+"</td>"
  txt(1770) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_jja.summary.png","JJA")+"</td>"
  txt(1771) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_jas.summary.png","JAS")+"</td>"
  txt(1772) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_son.summary.png","SON")+"</td>"
  txt(1773) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1774) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1775) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_ann.summary.png","ANN")+"</td></tr>"

  txt(1777) = "<tr><td rowspan=2><b>PSA2</b></td>"
  txt(1778) = "<td>Patterns</td>"
  txt(1779) = "<td>"+table_link_setup(OUTDIR,"psa2_pattern_djf.summary.png","DJF")+"</td>"
  txt(1780) = "<td>"+table_link_setup(OUTDIR,"psa2_pattern_jfm.summary.png","JFM")+"</td>"
  txt(1781) = "<td>"+table_link_setup(OUTDIR,"psa2_pattern_mam.summary.png","MAM")+"</td>"
  txt(1782) = "<td>"+table_link_setup(OUTDIR,"psa2_pattern_jja.summary.png","JJA")+"</td>"
  txt(1783) = "<td>"+table_link_setup(OUTDIR,"psa2_pattern_jas.summary.png","JAS")+"</td>"
  txt(1784) = "<td>"+table_link_setup(OUTDIR,"psa2_pattern_son.summary.png","SON")+"</td>"
  txt(1785) = "<td>"+table_link_setup(OUTDIR,"psa2_pattern_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1786) = "<td>"+table_link_setup(OUTDIR,"psa2_pattern_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1788) = "<td>"+table_link_setup(OUTDIR,"psa2_pattern_ann.summary.png","ANN")+"</td></tr>"
  txt(1789) = "<td>Timeseries</td>"
  txt(1792) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_djf.summary.png","DJF")+"</td>"
  txt(1793) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_jfm.summary.png","JFM")+"</td>"
  txt(1794) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_mam.summary.png","MAM")+"</td>"
  txt(1795) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_jja.summary.png","JJA")+"</td>"
  txt(1796) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_jas.summary.png","JAS")+"</td>"
  txt(1797) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_son.summary.png","SON")+"</td>"
  txt(1798) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1799) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1800) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_ann.summary.png","ANN")+"</td></tr>"

  txt(1802) = "<tr><td rowspan=2><b>SST(EOF1)</b></td>"
  txt(1803) = "<td>Patterns</td>"
  txt(1804) = "<td>"+table_link_setup(OUTDIR,"ssteof1_pattern_djf.summary.png","DJF")+"</td>"
  txt(1805) = "<td>"+table_link_setup(OUTDIR,"ssteof1_pattern_jfm.summary.png","JFM")+"</td>"
  txt(1806) = "<td>"+table_link_setup(OUTDIR,"ssteof1_pattern_mam.summary.png","MAM")+"</td>"
  txt(1807) = "<td>"+table_link_setup(OUTDIR,"ssteof1_pattern_jja.summary.png","JJA")+"</td>"
  txt(1808) = "<td>"+table_link_setup(OUTDIR,"ssteof1_pattern_jas.summary.png","JAS")+"</td>"
  txt(1809) = "<td>"+table_link_setup(OUTDIR,"ssteof1_pattern_son.summary.png","SON")+"</td>"
  txt(1810) = "<td>"+table_link_setup(OUTDIR,"ssteof1_pattern_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1811) = "<td>"+table_link_setup(OUTDIR,"ssteof1_pattern_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1812) = "<td>"+table_link_setup(OUTDIR,"ssteof1_pattern_ann.summary.png","ANN")+"</td></tr>"
  txt(1813) = "<td>Timeseries</td>"
  txt(1815) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_djf.summary.png","DJF")+"</td>"
  txt(1816) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_jfm.summary.png","JFM")+"</td>"
  txt(1817) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_mam.summary.png","MAM")+"</td>"
  txt(1818) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_jja.summary.png","JJA")+"</td>"
  txt(1819) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_jas.summary.png","JAS")+"</td>"
  txt(1820) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_son.summary.png","SON")+"</td>"
  txt(1821) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(1822) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_mjjaso.summary.png","MJJASO")+"</td>"
  txt(1823) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_ann.summary.png","ANN")+"</td></tr>"
  txt(3500) = "</table>"

  txt(3600) = "<div class="+quote+"row"+quote+">"
  txt(3601) = "<div class="+quote+"col"+quote+">"
  txt(3602) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(3603) = "<h3 class="+quote+"display-6"+quote+">Southern Polar Timeseries</h3>"

  txt(3610) = "<tr class="+quote+"d-flex"+quote+">"
  txt(3611) = "<td class="+quote+"col"+quote+"><b>SST</b></td>"
  txt(3612) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_djf.summary.png","DJF")+"</td>"
  txt(3613) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_jfm.summary.png","JFM")+"</td>"
  txt(3614) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_mam.summary.png","MAM")+"</td>"
  txt(3615) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_jja.summary.png","JJA")+"</td>"
  txt(3616) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_jas.summary.png","JAS")+"</td>"
  txt(3617) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_son.summary.png","SON")+"</td>"
  txt(3618) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(3619) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_mjjaso.summary.png","MJJASO")+"</td>"
  txt(3620) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_ann.summary.png","ANN")+"</td>"
  txt(3621) = "</tr>"

  txt(3622) = "<tr class="+quote+"d-flex"+quote+">"
  txt(3623) = "<td class="+quote+"col"+quote+"><b>TAS</b></td>"
  txt(3624) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_djf.summary.png","DJF")+"</td>"
  txt(3625) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_jfm.summary.png","JFM")+"</td>"
  txt(3626) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_mam.summary.png","MAM")+"</td>"
  txt(3627) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_jja.summary.png","JJA")+"</td>"
  txt(3628) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_jas.summary.png","JAS")+"</td>"
  txt(3629) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_son.summary.png","SON")+"</td>"
  txt(3630) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(3631) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_mjjaso.summary.png","MJJASO")+"</td>"
  txt(3632) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_ann.summary.png","ANN")+"</td>"
  txt(3633) = "</tr>"

  txt(3644) = "<tr class="+quote+"d-flex"+quote+">"
  txt(3645) = "<td class="+quote+"col"+quote+"><b>PR</b></td>"
  txt(3646) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_djf.summary.png","DJF")+"</td>"
  txt(3647) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_jfm.summary.png","JFM")+"</td>"
  txt(3648) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_mam.summary.png","MAM")+"</td>"
  txt(3649) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_jja.summary.png","JJA")+"</td>"
  txt(3650) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_jas.summary.png","JAS")+"</td>"
  txt(3651) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_son.summary.png","SON")+"</td>"
  txt(3652) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(3653) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_mjjaso.summary.png","MJJASO")+"</td>"
  txt(3654) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_ann.summary.png","ANN")+"</td>"
  txt(3655) = "</tr>"
  txt(3656) = "<tr class="+quote+"d-flex"+quote+">"
  txt(3657) = "<td class="+quote+"col"+quote+"><b>PR<br>(land-only)</b></td>"
  txt(3658) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_djf.summary.png","DJF")+"</td>"
  txt(3659) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_jfm.summary.png","JFM")+"</td>"
  txt(3660) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_mam.summary.png","MAM")+"</td>"
  txt(3661) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_jja.summary.png","JJA")+"</td>"
  txt(3662) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_jas.summary.png","JAS")+"</td>"
  txt(3663) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_son.summary.png","SON")+"</td>"
  txt(3664) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(3665) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_mjjaso.summary.png","MJJASO")+"</td>"
  txt(3666) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_ann.summary.png","ANN")+"</td>"
  txt(3667) = "</tr>"
  txt(3685) = "</tr></table></div></div>"

  txt(4000) = "<div class="+quote+"row"+quote+">"
  txt(4001) = "<div class="+quote+"col"+quote+">"
  txt(4002) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(4003) = "<h3 class="+quote+"display-6"+quote+">Regional Timeseries</h3>"
  txt(4004) = "<tr class="+quote+"d-flex"+quote+">"
  txt(4005) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"atlantic_meridional_mode.timeseries.summary.png","Atlantic SST Meridional Mode")+"</td>"
  txt(4006) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"atlantic_nino.timeseries.summary.png","Atlantic Ni&ntilde;o SST")+"</td>"
  txt(4007) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"north_atlantic.timeseries.summary.png","North Atlantic SST")+"</td>"
  txt(4008) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"north_tropical_atlantic.timeseries.summary.png","Tropical North Atlantic SST")+"</td>"
  txt(4009) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"south_tropical_atlantic.timeseries.summary.png","Tropical South Atlantic SST")+"</td></tr>"
  txt(4010) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino12.timeseries.summary.png","ni&ntilde;o1+2 SST")+"</td>"
  txt(4017) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino3.timeseries.summary.png","ni&ntilde;o3 SST")+"</td>"
  txt(4018) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino34.timeseries.summary.png","ni&ntilde;o3.4 SST")+"</td>"
  txt(4019) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino4.timeseries.summary.png","ni&ntilde;o4 SST")+"</td></tr>"
  txt(4020) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"north_pacific_index_ndjfma.summary.png","North Pacific PSL Index (NPI)")+"</td>"
  txt(4021) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"north_pacific_meridional_mode.timeseries.summary.png","North Pacific SST Meridional Mode")+"</td>"
  txt(4022) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"south_pacific_meridional_mode.timeseries.summary.png","South Pacific SST Meridional Mode")+"</td></tr>"
  txt(4023) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"indian_ocean_dipole.timeseries.summary.png","Indian Ocean SST Dipole")+"</td>"
  txt(4024) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tropical_indian_ocean.timeseries.summary.png","Tropical Indian Ocean SST")+"</td>"
  txt(4025) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"southern_ocean.timeseries.summary.png","Southern Ocean SST")+"</td></tr>"
  txt(4026) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"scnino34.timeseries.summary.png","Cumulative ni&ntilde;o3.4 SST")+"</td>"
  txt(4027) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino_el_nmon.timeseries.summary.png","El ni&ntilde;o events")+"</td>"
  txt(4028) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino_la_nmon.timeseries.summary.png","La ni&ntilde;a events")+"</td>"
  txt(4029) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino_elmla_nmon.timeseries.summary.png","El ni&ntilde;o - La ni&ntilde;a events")+"</td></tr>"
  txt(4030) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sam_ns_nmon.timeseries.summary.png","SAM(+) events")+"</td>"
  txt(4031) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sam_ns_nmon.timeseries.summary.png","SAM(-) events")+"</td>"
  txt(4032) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sam_psmns_nmon.timeseries.summary.png","SAM(+) - SAM(-) events")+"</td></tr>"
  txt(4033) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"asl_ps_nmon.timeseries.summary.png","ASL(+) events")+"</td>"
  txt(4034) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"asl_ns_nmon.timeseries.summary.png","ASL(-) events")+"</td>"
  txt(4035) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"asl_psmns_nmon.timeseries.summary.png","ASL(+) - ASL(-) events")+"</td></tr>"
  txt(4036) = "</table></div></div>"

  txt(4100) = "<div class="+quote+"row"+quote+">"
  txt(4101) = "<div class="+quote+"col"+quote+">"
  txt(4102) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(4103) = "<h3 class="+quote+"display-6"+quote+">Sea Ice Extent Timeseries</h3>"
  txt(4105) = "<tr><td rowspan=2><b>NH</b></td>"
  txt(4106) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_djf.summary.png","DJF")+"</td>"
  txt(4107) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_jfm.summary.png","JFM")+"</td>"
  txt(4108) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_mam.summary.png","MAM")+"</td>"
  txt(4109) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_jja.summary.png","JJA")+"</td>"
  txt(4110) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_jas.summary.png","JAS")+"</td>"
  txt(4111) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_son.summary.png","SON")+"</td>"
  txt(4112) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(4113) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_mjjaso.summary.png","MJJASO")+"</td>"
  txt(4114) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_ann.summary.png","ANN")+"</td></tr>"
  txt(4118) = "<tr><td>"+table_link_setup(OUTDIR,"siconc_nh_extent_feb.summary.png","Feb")+"</td>"
  txt(4119) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_mar.summary.png","Mar")+"</td>"
  txt(4120) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_sep.summary.png","Sep")+"</td>"
  txt(4121) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_oct.summary.png","Oct")+"</td>"
  txt(4122) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_mon.summary.png","Monthly")+"</td>"
  txt(4123) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_anom_mon.summary.png","Monthly Anomalies")+"</td>"
  txt(4124) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent.climo.summary.png","Climatology")+"</td>"
  txt(4125) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent.clim1.summary.png","N/A")+"</td>"
  txt(4126) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent.clim2.summary.png","N/A")+"</td></tr>"
  txt(4127) = "<tr><td rowspan=2><b>SH</b></td>"
  txt(4128) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_djf.summary.png","DJF")+"</td>"
  txt(4129) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_jfm.summary.png","JFM")+"</td>"
  txt(4130) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_mam.summary.png","MAM")+"</td>"
  txt(4131) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_jja.summary.png","JJA")+"</td>"
  txt(4132) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_jas.summary.png","JAS")+"</td>"
  txt(4133) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_son.summary.png","SON")+"</td>"
  txt(4134) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_ndjfma.summary.png","NDJFMA")+"</td>"
  txt(4135) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_mjjaso.summary.png","MJJASO")+"</td>"
  txt(4136) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_ann.summary.png","ANN")+"</td></tr>"
  txt(4140) = "<tr><td>"+table_link_setup(OUTDIR,"siconc_sh_extent_feb.summary.png","Feb")+"</td>"
  txt(4141) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_mar.summary.png","Mar")+"</td>"
  txt(4142) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_sep.summary.png","Sep")+"</td>"
  txt(4143) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_oct.summary.png","Oct")+"</td>"
  txt(4144) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_mon.summary.png","Monthly")+"</td>"
  txt(4145) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_anom_mon.summary.png","Monthly Anomalies")+"</td>"
  txt(4147) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent.climo.summary.png","Climatology")+"</td>"
  txt(4148) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent.clim1.summary.png","N/A")+"</td>"
  txt(4149) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent.clim2.summary.png","N/A")+"</td></tr>"
  txt(4150) = "</table></div></div>"

  txt(4209) = "<div class="+quote+"row"+quote+">"
  txt(4210) = "<div class="+quote+"col"+quote+">"
  txt(4211) = "<table class="+quote+"table table-bordered"+quote+">"
  txt(4212) = "<h3 class="+quote+"display-6"+quote+">Regional Modes of Variability</h3>"
  txt(4213) = "<tr>"

  txt(4214) = "<td rowspan=7><b>SAM(Mashall)</b></td>"
  txt(4215) = "<td rowspan=4>Spatial Composites</td>"
  txt(4216) = "<td>SAM(+) - SAM(-)<br>SST/TAS/PSL<br>"
  txt(4217) = table_link_setup(OUTDIR,"samind.spatialcomp.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4218) = table_link_setup(OUTDIR,"samind.spatialcomp.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4219) = table_link_setup(OUTDIR,"samind.spatialcomp.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4220) = table_link_setup(OUTDIR,"samind.spatialcomp.summary.mam1.png","MAM<sup>1</sup>")+"</td>"
  txt(4225) = "<td>SAM(+) - SAM(-)<br>PR<br>"
  txt(4226) = table_link_setup(OUTDIR,"samind.spatialcomp.pr.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4227) = table_link_setup(OUTDIR,"samind.spatialcomp.pr.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4228) = table_link_setup(OUTDIR,"samind.spatialcomp.pr.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4229) = table_link_setup(OUTDIR,"samind.spatialcomp.pr.summary.mam1.png","MAM<sup>1</sup>")+"</td></tr>"

  txt(4236) = "<td>SAM(+) SST/TAS/PSL<br>"
  txt(4237) = table_link_setup(OUTDIR,"samind.spatialcomp.psam.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4238) = table_link_setup(OUTDIR,"samind.spatialcomp.psam.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4239) = table_link_setup(OUTDIR,"samind.spatialcomp.psam.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4240) = table_link_setup(OUTDIR,"samind.spatialcomp.psam.summary.mam1.png","MAM<sup>1</sup>")+"</td>"
  txt(4245) = "<td>SAM(+) PR<br>"
  txt(4246) = table_link_setup(OUTDIR,"samind.spatialcomp.psam.pr.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4247) = table_link_setup(OUTDIR,"samind.spatialcomp.psam.pr.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4248) = table_link_setup(OUTDIR,"samind.spatialcomp.psam.pr.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4249) = table_link_setup(OUTDIR,"samind.spatialcomp.psam.pr.summary.mam1.png","MAM<sup>1</sup>")+"</td></tr>"

  txt(4256) = "<td>SAM(-) SST/TAS/PSL<br>"
  txt(4257) = table_link_setup(OUTDIR,"samind.spatialcomp.nsam.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4258) = table_link_setup(OUTDIR,"samind.spatialcomp.nsam.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4259) = table_link_setup(OUTDIR,"samind.spatialcomp.nsam.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4260) = table_link_setup(OUTDIR,"samind.spatialcomp.nsam.summary.mam1.png","MAM<sup>1</sup>")+"</td>"
  txt(4265) = "<td>SAM(-) PR<br>"
  txt(4266) = table_link_setup(OUTDIR,"samind.spatialcomp.nsam.pr.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4267) = table_link_setup(OUTDIR,"samind.spatialcomp.nsam.pr.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4268) = table_link_setup(OUTDIR,"samind.spatialcomp.nsam.pr.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4269) = table_link_setup(OUTDIR,"samind.spatialcomp.nsam.pr.summary.mam1.png","MAM<sup>1</sup>")+"</td></tr>"

  txt(4305) = "<tr>"
  txt(4306) = "<td>"+table_link_setup(OUTDIR,"samind.hov.psam.summary.png","SAM(+) Hovm&ouml;ller")+"</td>"
  txt(4307) = "<td>"+table_link_setup(OUTDIR,"samind.hov.nsam.summary.png","SAM(-) Hovm&ouml;ller")+"</td></tr>"

  txt(4355) = "<tr><td rowspan=3>SAM index</td>"
  txt(4356) = "<td>"+table_link_setup(OUTDIR,"samind.timeseries.summary.png","Timeseries")+"</td>"
  txt(4357) = "<td>"+table_link_setup(OUTDIR,"samind.monstddev.summary.png","Monthly Std. Dev.")+"</td>"
  txt(4358) = "<tr><td>"+table_link_setup(OUTDIR,"samind.powspec.summary.png","Power Spectra")+"</td>"
  txt(4359) = "<td>"+table_link_setup(OUTDIR,"samind.wavelet.summary.png","Wavelet")+"</td></tr>"
  txt(4360) = "<tr><td>"+table_link_setup(OUTDIR,"samind.autocor.summary.png","Autocorrelation")+"</td>"
  txt(4361) = "<td>"+table_link_setup(OUTDIR,"scsamind.timeseries.summary.png","Cumulative SAM index")+"</td></tr>"

  txt(4413) = "<tr>"
  txt(4414) = "<td rowspan=7><b>ASL(Hosking)</b></td>"
  txt(4415) = "<td rowspan=4>Spatial Composites</td>"
  txt(4416) = "<td>ASL(+) - ASL(-)<br>SST/TAS/PSL<br>"
  txt(4417) = table_link_setup(OUTDIR,"aslind.spatialcomp.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4418) = table_link_setup(OUTDIR,"aslind.spatialcomp.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4419) = table_link_setup(OUTDIR,"aslind.spatialcomp.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4420) = table_link_setup(OUTDIR,"aslind.spatialcomp.summary.mam1.png","MAM<sup>1</sup>")+"</td>"
  txt(4425) = "<td>ASL(+) - ASL(-)<br>PR<br>"
  txt(4426) = table_link_setup(OUTDIR,"aslind.spatialcomp.pr.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4427) = table_link_setup(OUTDIR,"aslind.spatialcomp.pr.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4428) = table_link_setup(OUTDIR,"aslind.spatialcomp.pr.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4429) = table_link_setup(OUTDIR,"aslind.spatialcomp.pr.summary.mam1.png","MAM<sup>1</sup>")+"</td></tr>"

  txt(4436) = "<td>ASL(+) SST/TAS/PSL<br>"
  txt(4437) = table_link_setup(OUTDIR,"aslind.spatialcomp.pasl.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4438) = table_link_setup(OUTDIR,"aslind.spatialcomp.pasl.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4439) = table_link_setup(OUTDIR,"aslind.spatialcomp.pasl.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4440) = table_link_setup(OUTDIR,"aslind.spatialcomp.pasl.summary.mam1.png","MAM<sup>1</sup>")+"</td>"
  txt(4445) = "<td>ASL(+) PR<br>"
  txt(4446) = table_link_setup(OUTDIR,"aslind.spatialcomp.pasl.pr.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4447) = table_link_setup(OUTDIR,"aslind.spatialcomp.pasl.pr.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4448) = table_link_setup(OUTDIR,"aslind.spatialcomp.pasl.pr.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4449) = table_link_setup(OUTDIR,"aslind.spatialcomp.pasl.pr.summary.mam1.png","MAM<sup>1</sup>")+"</td></tr>"

  txt(4456) = "<td>ASL(-) SST/TAS/PSL<br>"
  txt(4457) = table_link_setup(OUTDIR,"aslind.spatialcomp.nasl.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4458) = table_link_setup(OUTDIR,"aslind.spatialcomp.nasl.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4459) = table_link_setup(OUTDIR,"aslind.spatialcomp.nasl.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4460) = table_link_setup(OUTDIR,"aslind.spatialcomp.nasl.summary.mam1.png","MAM<sup>1</sup>")+"</td>"
  txt(4465) = "<td>ASL(-) PR<br>"
  txt(4466) = table_link_setup(OUTDIR,"aslind.spatialcomp.nasl.pr.summary.jja0.png","JJA<sup>0</sup>")+" "
  txt(4467) = table_link_setup(OUTDIR,"aslind.spatialcomp.nasl.pr.summary.son0.png","SON<sup>0</sup>")+" "
  txt(4468) = table_link_setup(OUTDIR,"aslind.spatialcomp.nasl.pr.summary.djf1.png","DJF<sup>1</sup>")+" "
  txt(4469) = table_link_setup(OUTDIR,"aslind.spatialcomp.nasl.pr.summary.mam1.png","MAM<sup>1</sup>")+"</td></tr>"

  txt(4505) = "<tr>"
  txt(4506) = "<td>"+table_link_setup(OUTDIR,"aslind.hov.pasl.summary.png","ASL(+) Hovm&ouml;ller")+"</td>"
  txt(4507) = "<td>"+table_link_setup(OUTDIR,"aslind.hov.nasl.summary.png","ASL(-) Hovm&ouml;ller")+"</td></tr>"

  txt(4555) = "<tr><td rowspan=3>ASL index</td>"
  txt(4556) = "<td>"+table_link_setup(OUTDIR,"aslind.timeseries.summary.png","Timeseries")+"</td>"
  txt(4557) = "<td>"+table_link_setup(OUTDIR,"aslind.monstddev.summary.png","Monthly Std. Dev.")+"</td>"
  txt(4558) = "<tr><td>"+table_link_setup(OUTDIR,"aslind.powspec.summary.png","Power Spectra")+"</td>"
  txt(4559) = "<td>"+table_link_setup(OUTDIR,"aslind.wavelet.summary.png","Wavelet")+"</td></tr>"
  txt(4560) = "<tr><td>"+table_link_setup(OUTDIR,"aslind.autocor.summary.png","Autocorrelation")+"</td>"
  txt(4561) = "<td>"+table_link_setup(OUTDIR,"scaslind.timeseries.summary.png","Cumulative ASL index")+"</td></tr>"
  txt(4562) = "</table></div></div>"
  txt(4600) = "</div></body></html>"

  
  tt = ind(.not.ismissing(txt))
  txt2 = txt(:tt(dimsizes(tt)-1)+1)
  tt2 = ind(.not.ismissing(txt2))
  txt3 = txt2(tt2)
  asciiwrite(OUTDIR+"index.html",txt3)
;----------------------------------------------------------------------------
  txt := new(30000,"string")
  
  txt(0) = "<html><head><title>Climate Variability Diagnostics Package</title>"
  txt(1) = "<link rel="+quote+"stylesheet"+quote+" href="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"+quote+" integrity="+quote+"sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"+quote+" crossorigin="+quote+"anonymous"+quote+">"
  txt(2) = "<script src="+quote+"https://code.jquery.com/jquery-3.3.1.slim.min.js"+quote+" integrity="+quote+"sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
  txt(3) = "<script src="+quote+"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"+quote+" integrity="+quote+"sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
  txt(4) = "<script src="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"+quote+" integrity="+quote+"sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"

  txt(11) = "<STYLE>body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
  txt(12) = "img.title {width:990; height:105; align:left}"
  txt(13) = "p.subtitle {font-size:20pt; color:black; text-align:center; font-weight:bold}"
  txt(14) = "p.btext {font-size:11pt; text-align:left}"
  txt(15) = "font.s1 {font-size:13.5pt; text-align:left}"
  txt(17) = "td {text-align:center; font-size:12pt}"
  txt(18) = "td.s1 {text-align:left; font-size:11pt}"
  txt(19) = "td.s2 {border-bottom: 4px double darkgray}"
  txt(20) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}"
  txt(21) = "</style></head>"

  txt(30) = "<body>"
  txt(31) = "<div class="+quote+"container"+quote+">"
	 txt(32) = "<div class="+quote+"row"+quote+">"
		txt(33) = "<img class="+quote+"img-fluid"+quote+" src="+quote+"cas_cvdp-le.png"+quote+" alt="+quote+"CVDP-LE logo"+quote+">"
  txt(34) = "</div>"

  txt(40) = "<div class="+quote+"row"+quote+">"
		txt(41) = "<div class="+quote+"col"+quote+">"
		txt(42) = "<table class="+quote+"table my-0"+quote+">"
		txt(43) = "<tr>"
		txt(44) = "<td class="+quote+"text-left"+quote+">"
		txt(45) = "<ul class="+quote+"list-inline my-0"+quote+">"
		txt(46) = "<li class="+quote+"list-inline-item"+quote+"><a href="+quote+"http://dx.doi.org/10.5065/h7c7-f961"+quote+">User's Guide</a></li><br>"
  txt(48) = atxt+btxt
		txt(49) = "<li class="+quote+"list-inline-item"+quote+">Namelists: <a href="+quote+"namelist_obs.html"+quote+">Input</a> | <a href="+quote+"namelist_msftmz.html"+quote+">Derived</a></li>"		
		txt(67) = "<li class="+quote+"list-inline-item"+quote+">Created: "+systemfunc("date")+"<br>CVDP-LE Version "+VERSION+"</li>"
  txt(68) = "<li class="+quote+"list-inline-item"+quote+"><a href="+quote+"index.html"+quote+">Ensemble Summary</a> | <b>Individual Members</b></li>"
		txt(69) = "</ul></td>"
		txt(83) = "</tr>"
		txt(84) = "</table>"
		txt(85) = "</div>"
		txt(86) = "<div class="+quote+"col align-self-center"+quote+">"
		txt(87) = "<h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2>"
		txt(88) = "</div>"
	 txt(89) = "</div>"

  txt(100) = "<div class="+quote+"row"+quote+">"
  txt(101) = "<div class="+quote+"col"+quote+">"
  txt(102) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(103) = "<h3 class="+quote+"display-6"+quote+">Climatological Averages</h3>"
  txt(104) = "<tr class="+quote+"d-flex"+quote+">"
  txt(105) = "<td class="+quote+"col"+quote+"><b>SST</b></td>"

  txt(110) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialmean_djf.indmem.png")) then
     txt(111) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_mean_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_mean_djf"+quote+">DJF</a>" 
     txt(112) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_mean_djf"+quote+">"
     txt(113) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(114) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_djf.indmem.png","Indiv")+"</li>"
     txt(115) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_djf.indmemdiff.png","Bias")+"</li>"
     txt(117) = "</ul></div></td>"
  else
     txt(117) = "DJF</td>"
  end if

  txt(120) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialmean_jfm.indmem.png")) then
     txt(121) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_mean_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_mean_jfm"+quote+">JFM</a>" 
     txt(122) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_mean_jfm"+quote+">"
     txt(123) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(124) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_jfm.indmem.png","Indiv")+"</li>"
     txt(125) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_jfm.indmemdiff.png","Bias")+"</li>"
     txt(127) = "</ul></div></td>"
  else
     txt(127) = "JFM</td>"
  end if

  txt(130) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialmean_mam.indmem.png")) then
     txt(131) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_mean_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_mean_mam"+quote+">MAM</a>" 
     txt(132) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_mean_mam"+quote+">"
     txt(133) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(134) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_mam.indmem.png","Indiv")+"</li>"
     txt(135) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_mam.indmemdiff.png","Bias")+"</li>"
     txt(137) = "</ul></div></td>"
  else
     txt(137) = "MAM</td>"
  end if

  txt(140) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialmean_jja.indmem.png")) then
     txt(141) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_mean_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_mean_jja"+quote+">JJA</a>" 
     txt(142) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_mean_jja"+quote+">"
     txt(143) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(144) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_jja.indmem.png","Indiv")+"</li>"
     txt(145) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_jja.indmemdiff.png","Bias")+"</li>"
     txt(147) = "</ul></div></td>"
  else
     txt(147) = "JJA</td>"
  end if

  txt(150) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialmean_jas.indmem.png")) then
     txt(151) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_mean_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_mean_jas"+quote+">JAS</a>" 
     txt(152) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_mean_jas"+quote+">"
     txt(153) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(154) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_jas.indmem.png","Indiv")+"</li>"
     txt(155) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_jas.indmemdiff.png","Bias")+"</li>"
     txt(157) = "</ul></div></td>"
  else
     txt(157) = "JAS</td>"
  end if

  txt(160) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialmean_son.indmem.png")) then
     txt(161) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_mean_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_mean_son"+quote+">SON</a>" 
     txt(162) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_mean_son"+quote+">"
     txt(163) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(164) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_son.indmem.png","Indiv")+"</li>"
     txt(165) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_son.indmemdiff.png","Bias")+"</li>"
     txt(167) = "</ul></div></td>"
  else
     txt(167) = "SON</td>"
  end if

  txt(170) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialmean_ndjfma.indmem.png")) then
     txt(171) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_mean_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_mean_ndjfma"+quote+">NDJFMA</a>"
     txt(172) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_mean_ndjfma"+quote+">"
     txt(173) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(174) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_ndjfma.indmem.png","Indiv")+"</li>"
     txt(175) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(177) = "</ul></div></td>"
  else
     txt(177) = "NDJFMA</td>"
  end if

  txt(180) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialmean_mjjaso.indmem.png")) then
     txt(181) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_mean_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_mean_mjjaso"+quote+">MJJASO</a>"
     txt(182) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_mean_mjjaso"+quote+">"
     txt(183) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(184) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_mjjaso.indmem.png","Indiv")+"</li>"
     txt(185) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(187) = "</ul></div></td>"
  else
     txt(187) = "MJJASO</td>"
  end if

  txt(190) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialmean_ann.indmem.png")) then
     txt(191) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_mean_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_mean_ann"+quote+">ANN</a>" 
     txt(192) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_mean_ann"+quote+">"
     txt(193) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(194) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_ann.indmem.png","Indiv")+"</li>"
     txt(195) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialmean_ann.indmemdiff.png","Bias")+"</li>"
     txt(197) = "</ul></div></td>"
  else
     txt(197) = "ANN</td>"
  end if
  txt(198) = "</tr>"

  txt(224) = "<tr class="+quote+"d-flex"+quote+">"
  txt(225) = "<td class="+quote+"col"+quote+"><b>TAS</b></td>"

  txt(230) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialmean_djf.indmem.png")) then
     txt(231) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_mean_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_mean_djf"+quote+">DJF</a>" 
     txt(232) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_mean_djf"+quote+">"
     txt(233) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(234) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_djf.indmem.png","Indiv")+"</li>"
     txt(235) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_djf.indmemdiff.png","Bias")+"</li>"
     txt(237) = "</ul></div></td>"
  else
     txt(237) = "DJF</td>"
  end if

  txt(240) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialmean_jfm.indmem.png")) then
     txt(241) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_mean_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_mean_jfm"+quote+">JFM</a>" 
     txt(242) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_mean_jfm"+quote+">"
     txt(243) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(244) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_jfm.indmem.png","Indiv")+"</li>"
     txt(245) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_jfm.indmemdiff.png","Bias")+"</li>"
     txt(247) = "</ul></div></td>"
  else
     txt(247) = "JFM</td>"
  end if

  txt(250) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialmean_mam.indmem.png")) then
     txt(251) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_mean_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_mean_mam"+quote+">MAM</a>" 
     txt(252) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_mean_mam"+quote+">"
     txt(253) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(254) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_mam.indmem.png","Indiv")+"</li>"
     txt(255) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_mam.indmemdiff.png","Bias")+"</li>"
     txt(257) = "</ul></div></td>"
  else
     txt(257) = "MAM</td>"
  end if

  txt(260) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialmean_jja.indmem.png")) then
     txt(261) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_mean_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_mean_jja"+quote+">JJA</a>" 
     txt(262) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_mean_jja"+quote+">"
     txt(263) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(264) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_jja.indmem.png","Indiv")+"</li>"
     txt(265) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_jja.indmemdiff.png","Bias")+"</li>"
     txt(267) = "</ul></div></td>"
  else
     txt(267) = "JJA</td>"
  end if

  txt(270) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialmean_jas.indmem.png")) then
     txt(271) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_mean_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_mean_jas"+quote+">JAS</a>" 
     txt(272) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_mean_jas"+quote+">"
     txt(273) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(274) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_jas.indmem.png","Indiv")+"</li>"
     txt(275) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_jas.indmemdiff.png","Bias")+"</li>"
     txt(277) = "</ul></div></td>"
  else
     txt(277) = "JAS</td>"
  end if

  txt(280) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialmean_son.indmem.png")) then
     txt(281) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_mean_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_mean_son"+quote+">SON</a>" 
     txt(282) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_mean_son"+quote+">"
     txt(283) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(284) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_son.indmem.png","Indiv")+"</li>"
     txt(285) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_son.indmemdiff.png","Bias")+"</li>"
     txt(287) = "</ul></div></td>"
  else
     txt(287) = "SON</td>"
  end if

  txt(290) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialmean_ndjfma.indmem.png")) then
     txt(291) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_mean_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_mean_ndjfma"+quote+">NDJFMA</a>"
     txt(292) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_mean_ndjfma"+quote+">"
     txt(293) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(294) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_ndjfma.indmem.png","Indiv")+"</li>"
     txt(295) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(297) = "</ul></div></td>"
  else
     txt(297) = "NDJFMA</td>"
  end if

  txt(300) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialmean_mjjaso.indmem.png")) then
     txt(301) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_mean_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_mean_mjjaso"+quote+">MJJASO</a>"
     txt(302) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_mean_mjjaso"+quote+">"
     txt(303) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(304) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_mjjaso.indmem.png","Indiv")+"</li>"
     txt(305) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(307) = "</ul></div></td>"
  else
     txt(307) = "MJJASO</td>"
  end if


  txt(310) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialmean_ann.indmem.png")) then
     txt(311) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_mean_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_mean_ann"+quote+">ANN</a>" 
     txt(312) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_mean_ann"+quote+">"
     txt(313) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(314) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_ann.indmem.png","Indiv")+"</li>"
     txt(315) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialmean_ann.indmemdiff.png","Bias")+"</li>"
     txt(317) = "</ul></div></td>"
  else
     txt(317) = "ANN</td>"
  end if
  txt(318) = "</tr>"

  txt(344) = "<tr class="+quote+"d-flex"+quote+">"
  txt(345) = "<td class="+quote+"col"+quote+"><b>PSL</b></td>"

  txt(350) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialmean_djf.indmem.png")) then
     txt(351) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_mean_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_mean_djf"+quote+">DJF</a>" 
     txt(352) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_mean_djf"+quote+">"
     txt(353) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(354) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_djf.indmem.png","Indiv")+"</li>"
     txt(355) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_djf.indmemdiff.png","Bias")+"</li>"
     txt(357) = "</ul></div></td>"
  else
     txt(357) = "DJF</td>"
  end if

  txt(360) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialmean_jfm.indmem.png")) then
     txt(361) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_mean_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_mean_jfm"+quote+">JFM</a>" 
     txt(362) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_mean_jfm"+quote+">"
     txt(363) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(364) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_jfm.indmem.png","Indiv")+"</li>"
     txt(365) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_jfm.indmemdiff.png","Bias")+"</li>"
     txt(367) = "</ul></div></td>"
  else
     txt(367) = "JFM</td>"
  end if

  txt(370) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialmean_mam.indmem.png")) then
     txt(371) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_mean_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_mean_mam"+quote+">MAM</a>" 
     txt(372) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_mean_mam"+quote+">"
     txt(373) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(374) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_mam.indmem.png","Indiv")+"</li>"
     txt(375) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_mam.indmemdiff.png","Bias")+"</li>"
     txt(377) = "</ul></div></td>"
  else
     txt(377) = "MAM</td>"
  end if

  txt(380) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialmean_jja.indmem.png")) then
     txt(381) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_mean_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_mean_jja"+quote+">JJA</a>" 
     txt(382) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_mean_jja"+quote+">"
     txt(383) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(384) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_jja.indmem.png","Indiv")+"</li>"
     txt(385) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_jja.indmemdiff.png","Bias")+"</li>"
     txt(387) = "</ul></div></td>"
  else
     txt(387) = "JJA</td>"
  end if

  txt(390) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialmean_jas.indmem.png")) then
     txt(391) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_mean_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_mean_jas"+quote+">JAS</a>" 
     txt(392) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_mean_jas"+quote+">"
     txt(393) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(394) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_jas.indmem.png","Indiv")+"</li>"
     txt(395) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_jas.indmemdiff.png","Bias")+"</li>"
     txt(397) = "</ul></div></td>"
  else
     txt(397) = "JAS</td>"
  end if

  txt(400) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialmean_son.indmem.png")) then
     txt(401) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_mean_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_mean_son"+quote+">SON</a>" 
     txt(402) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_mean_son"+quote+">"
     txt(403) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(404) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_son.indmem.png","Indiv")+"</li>"
     txt(405) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_son.indmemdiff.png","Bias")+"</li>"
     txt(407) = "</ul></div></td>"
  else
     txt(407) = "SON</td>"
  end if

  txt(410) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialmean_ndjfma.indmem.png")) then
     txt(411) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_mean_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_mean_ndjfma"+quote+">NDJFMA</a>"
     txt(412) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_mean_ndjfma"+quote+">"
     txt(413) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(414) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_ndjfma.indmem.png","Indiv")+"</li>"
     txt(415) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(417) = "</ul></div></td>"
  else
     txt(417) = "NDJFMA</td>"
  end if

  txt(420) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialmean_mjjaso.indmem.png")) then
     txt(421) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_mean_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_mean_mjjaso"+quote+">MJJASO</a>"
     txt(422) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_mean_mjjaso"+quote+">"
     txt(423) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(424) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_mjjaso.indmem.png","Indiv")+"</li>"
     txt(425) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(427) = "</ul></div></td>"
  else
     txt(427) = "MJJASO</td>"
  end if

  txt(430) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialmean_ann.indmem.png")) then
     txt(431) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_mean_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_mean_ann"+quote+">ANN</a>" 
     txt(432) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_mean_ann"+quote+">"
     txt(433) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(434) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_ann.indmem.png","Indiv")+"</li>"
     txt(435) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialmean_ann.indmemdiff.png","Bias")+"</li>"
     txt(437) = "</ul></div></td>"
  else
     txt(437) = "ANN</td>"
  end if
  txt(438) = "</tr>"

  txt(464) = "<tr class="+quote+"d-flex"+quote+">"
  txt(465) = "<td class="+quote+"col"+quote+"><b>PR</b></td>"

  txt(470) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialmean_djf.indmem.png")) then
     txt(471) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_mean_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_mean_djf"+quote+">DJF</a>" 
     txt(472) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_mean_djf"+quote+">"
     txt(473) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(474) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_djf.indmem.png","Indiv")+"</li>"
     txt(475) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_djf.indmemdiff.png","Bias")+"</li>"
     txt(477) = "</ul></div></td>"
  else
     txt(477) = "DJF</td>"
  end if

  txt(480) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialmean_jfm.indmem.png")) then
     txt(481) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_mean_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_mean_jfm"+quote+">JFM</a>" 
     txt(482) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_mean_jfm"+quote+">"
     txt(483) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(484) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_jfm.indmem.png","Indiv")+"</li>"
     txt(485) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_jfm.indmemdiff.png","Bias")+"</li>"
     txt(487) = "</ul></div></td>"
  else
     txt(487) = "JFM</td>"
  end if

  txt(490) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialmean_mam.indmem.png")) then
     txt(491) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_mean_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_mean_mam"+quote+">MAM</a>" 
     txt(492) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_mean_mam"+quote+">"
     txt(493) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(494) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_mam.indmem.png","Indiv")+"</li>"
     txt(495) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_mam.indmemdiff.png","Bias")+"</li>"
     txt(497) = "</ul></div></td>"
  else
     txt(497) = "MAM</td>"
  end if

  txt(500) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialmean_jja.indmem.png")) then
     txt(501) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_mean_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_mean_jja"+quote+">JJA</a>" 
     txt(502) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_mean_jja"+quote+">"
     txt(503) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(504) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_jja.indmem.png","Indiv")+"</li>"
     txt(505) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_jja.indmemdiff.png","Bias")+"</li>"
     txt(507) = "</ul></div></td>"
  else
     txt(507) = "JJA</td>"
  end if

  txt(510) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialmean_jas.indmem.png")) then
     txt(511) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_mean_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_mean_jas"+quote+">JAS</a>" 
     txt(512) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_mean_jas"+quote+">"
     txt(513) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(514) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_jas.indmem.png","Indiv")+"</li>"
     txt(515) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_jas.indmemdiff.png","Bias")+"</li>"
     txt(517) = "</ul></div></td>"
  else
     txt(517) = "JAS</td>"
  end if

  txt(520) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialmean_son.indmem.png")) then
     txt(521) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_mean_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_mean_son"+quote+">SON</a>" 
     txt(522) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_mean_son"+quote+">"
     txt(523) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(524) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_son.indmem.png","Indiv")+"</li>"
     txt(525) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_son.indmemdiff.png","Bias")+"</li>"
     txt(527) = "</ul></div></td>"
  else
     txt(527) = "SON</td>"
  end if

  txt(530) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialmean_ndjfma.indmem.png")) then
     txt(531) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_mean_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_mean_ndjfma"+quote+">NDJFMA</a>"
     txt(532) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_mean_ndjfma"+quote+">"
     txt(533) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(534) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_ndjfma.indmem.png","Indiv")+"</li>"
     txt(535) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(537) = "</ul></div></td>"
  else
     txt(537) = "NDJFMA</td>"
  end if

  txt(540) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialmean_mjjaso.indmem.png")) then
     txt(541) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_mean_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_mean_mjjaso"+quote+">MJJASO</a>"
     txt(542) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_mean_mjjaso"+quote+">"
     txt(543) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(544) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_mjjaso.indmem.png","Indiv")+"</li>"
     txt(545) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(547) = "</ul></div></td>"
  else
     txt(547) = "MJJASO</td>"
  end if

  txt(550) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialmean_ann.indmem.png")) then
     txt(551) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_mean_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_mean_ann"+quote+">ANN</a>" 
     txt(552) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_mean_ann"+quote+">"
     txt(553) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(554) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_ann.indmem.png","Indiv")+"</li>"
     txt(555) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialmean_ann.indmemdiff.png","Bias")+"</li>"
     txt(557) = "</ul></div></td>"
  else
     txt(557) = "ANN</td>"
  end if
  txt(558) = "</tr>"


  txt(597) = "<tr class="+quote+"d-flex"+quote+">"
  txt(598) = "<td class="+quote+"col"+quote+"><b>SIC NH</b></td>"

  txt(600) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialmean_djf.indmem.png")) then
     txt(601) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_mean_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_mean_djf"+quote+">DJF</a>" 
     txt(602) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_mean_djf"+quote+">"
     txt(603) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(604) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_djf.indmem.png","Indiv")+"</li>"
     txt(605) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_djf.indmemdiff.png","Bias")+"</li>"
     txt(607) = "</ul></div></td>"
  else
     txt(607) = "DJF</td>"
  end if

  txt(610) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialmean_jfm.indmem.png")) then
     txt(611) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_mean_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_mean_jfm"+quote+">JFM</a>" 
     txt(612) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_mean_jfm"+quote+">"
     txt(613) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(614) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_jfm.indmem.png","Indiv")+"</li>"
     txt(615) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_jfm.indmemdiff.png","Bias")+"</li>"
     txt(617) = "</ul></div></td>"
  else
     txt(617) = "JFM</td>"
  end if

  txt(620) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialmean_mam.indmem.png")) then
     txt(621) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_mean_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_mean_mam"+quote+">MAM</a>" 
     txt(622) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_mean_mam"+quote+">"
     txt(623) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(624) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_mam.indmem.png","Indiv")+"</li>"
     txt(625) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_mam.indmemdiff.png","Bias")+"</li>"
     txt(627) = "</ul></div></td>"
  else
     txt(627) = "MAM</td>"
  end if

  txt(630) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialmean_jja.indmem.png")) then
     txt(631) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_mean_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_mean_jja"+quote+">JJA</a>" 
     txt(632) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_mean_jja"+quote+">"
     txt(633) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(634) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_jja.indmem.png","Indiv")+"</li>"
     txt(635) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_jja.indmemdiff.png","Bias")+"</li>"
     txt(637) = "</ul></div></td>"
  else
     txt(637) = "JJA</td>"
  end if

  txt(640) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialmean_jas.indmem.png")) then
     txt(641) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_mean_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_mean_jas"+quote+">JAS</a>" 
     txt(642) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_mean_jas"+quote+">"
     txt(643) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(644) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_jas.indmem.png","Indiv")+"</li>"
     txt(645) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_jas.indmemdiff.png","Bias")+"</li>"
     txt(647) = "</ul></div></td>"
  else
     txt(647) = "JAS</td>"
  end if

  txt(650) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialmean_son.indmem.png")) then
     txt(651) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_mean_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_mean_son"+quote+">SON</a>" 
     txt(652) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_mean_son"+quote+">"
     txt(653) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(654) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_son.indmem.png","Indiv")+"</li>"
     txt(655) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_son.indmemdiff.png","Bias")+"</li>"
     txt(657) = "</ul></div></td>"
  else
     txt(657) = "SON</td>"
  end if

  txt(660) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialmean_ndjfma.indmem.png")) then
     txt(661) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_mean_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_mean_ndjfma"+quote+">NDJFMA</a>"
     txt(662) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_mean_ndjfma"+quote+">"
     txt(663) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(664) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_ndjfma.indmem.png","Indiv")+"</li>"
     txt(665) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(667) = "</ul></div></td>"
  else
     txt(667) = "NDJFMA</td>"
  end if

  txt(670) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialmean_mjjaso.indmem.png")) then
     txt(671) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_mean_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_mean_mjjaso"+quote+">MJJASO</a>"
     txt(672) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_mean_mjjaso"+quote+">"
     txt(673) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(674) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_mjjaso.indmem.png","Indiv")+"</li>"
     txt(675) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(677) = "</ul></div></td>"
  else
     txt(677) = "MJJASO</td>"
  end if

  txt(680) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialmean_ann.indmem.png")) then
     txt(681) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_mean_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_mean_ann"+quote+">ANN</a>" 
     txt(682) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_mean_ann"+quote+">"
     txt(683) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(684) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_ann.indmem.png","Indiv")+"</li>"
     txt(685) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialmean_ann.indmemdiff.png","Bias")+"</li>"
     txt(687) = "</ul></div></td>"
  else
     txt(687) = "ANN</td>"
  end if
  txt(688) = "</tr>"

  txt(714) = "<tr class="+quote+"d-flex"+quote+">"
  txt(715) = "<td class="+quote+"col"+quote+"><b>SIC SH</b></td>"

  txt(720) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialmean_djf.indmem.png")) then
     txt(721) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_mean_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_mean_djf"+quote+">DJF</a>" 
     txt(722) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_mean_djf"+quote+">"
     txt(723) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(724) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_djf.indmem.png","Indiv")+"</li>"
     txt(725) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_djf.indmemdiff.png","Bias")+"</li>"
     txt(727) = "</ul></div></td>"
  else
     txt(727) = "DJF</td>"
  end if

  txt(730) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialmean_jfm.indmem.png")) then
     txt(731) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_mean_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_mean_jfm"+quote+">JFM</a>" 
     txt(732) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_mean_jfm"+quote+">"
     txt(733) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(734) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_jfm.indmem.png","Indiv")+"</li>"
     txt(735) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_jfm.indmemdiff.png","Bias")+"</li>"
     txt(737) = "</ul></div></td>"
  else
     txt(737) = "JFM</td>"
  end if

  txt(740) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialmean_mam.indmem.png")) then
     txt(741) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_mean_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_mean_mam"+quote+">MAM</a>" 
     txt(742) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_mean_mam"+quote+">"
     txt(743) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(744) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_mam.indmem.png","Indiv")+"</li>"
     txt(745) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_mam.indmemdiff.png","Bias")+"</li>"
     txt(747) = "</ul></div></td>"
  else
     txt(747) = "MAM</td>"
  end if

  txt(750) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialmean_jja.indmem.png")) then
     txt(751) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_mean_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_mean_jja"+quote+">JJA</a>" 
     txt(752) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_mean_jja"+quote+">"
     txt(753) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(754) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_jja.indmem.png","Indiv")+"</li>"
     txt(755) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_jja.indmemdiff.png","Bias")+"</li>"
     txt(757) = "</ul></div></td>"
  else
     txt(757) = "JJA</td>"
  end if

  txt(760) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialmean_jas.indmem.png")) then
     txt(761) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_mean_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_mean_jas"+quote+">JAS</a>" 
     txt(762) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_mean_jas"+quote+">"
     txt(763) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(764) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_jas.indmem.png","Indiv")+"</li>"
     txt(765) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_jas.indmemdiff.png","Bias")+"</li>"
     txt(767) = "</ul></div></td>"
  else
     txt(767) = "JAS</td>"
  end if

  txt(770) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialmean_son.indmem.png")) then
     txt(771) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_mean_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_mean_son"+quote+">SON</a>" 
     txt(772) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_mean_son"+quote+">"
     txt(773) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(774) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_son.indmem.png","Indiv")+"</li>"
     txt(775) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_son.indmemdiff.png","Bias")+"</li>"
     txt(777) = "</ul></div></td>"
  else
     txt(777) = "SON</td>"
  end if

  txt(780) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialmean_ndjfma.indmem.png")) then
     txt(781) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_mean_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_mean_ndjfma"+quote+">NDJFMA</a>"
     txt(782) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_mean_ndjfma"+quote+">"
     txt(783) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(784) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_ndjfma.indmem.png","Indiv")+"</li>"
     txt(785) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(787) = "</ul></div></td>"
  else
     txt(787) = "NDJFMA</td>"
  end if

  txt(790) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialmean_mjjaso.indmem.png")) then
     txt(791) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_mean_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_mean_mjjaso"+quote+">MJJASO</a>"
     txt(792) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_mean_mjjaso"+quote+">"
     txt(793) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(794) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_mjjaso.indmem.png","Indiv")+"</li>"
     txt(795) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(797) = "</ul></div></td>"
  else
     txt(797) = "MJJASO</td>"
  end if

  txt(800) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialmean_ann.indmem.png")) then
     txt(801) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_mean_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_mean_ann"+quote+">ANN</a>" 
     txt(802) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_mean_ann"+quote+">"
     txt(803) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(804) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_ann.indmem.png","Indiv")+"</li>"
     txt(805) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialmean_ann.indmemdiff.png","Bias")+"</li>"
     txt(807) = "</ul></div></td>"
  else
     txt(807) = "ANN</td>"
  end if
  txt(808) = "</tr>"
  txt(810) = "</table></div></div>"

  txt(1100) = "<div class="+quote+"row"+quote+">"
  txt(1101) = "<div class="+quote+"col"+quote+">"
  txt(1102) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(1103) = "<h3 class="+quote+"display-6"+quote+">Standard Deviations</h3>"
  txt(1104) = "<tr class="+quote+"d-flex"+quote+">"
  txt(1105) = "<td class="+quote+"col"+quote+"><b>SST</b></td>"

  txt(1110) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialstddev_djf.indmem.png")) then
     txt(1111) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_stddev_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_stddev_djf"+quote+">DJF</a>" 
     txt(1112) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_stddev_djf"+quote+">"
     txt(1113) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1114) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_djf.indmem.png","Indiv")+"</li>"
     txt(1115) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_djf.indmemdiff.png","Bias")+"</li>"
     txt(1117) = "</ul></div></td>"
  else
     txt(1117) = "DJF</td>"
  end if

  txt(1120) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialstddev_jfm.indmem.png")) then
     txt(1121) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_stddev_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_stddev_jfm"+quote+">JFM</a>" 
     txt(1122) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_stddev_jfm"+quote+">"
     txt(1123) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1124) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_jfm.indmem.png","Indiv")+"</li>"
     txt(1125) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_jfm.indmemdiff.png","Bias")+"</li>"
     txt(1127) = "</ul></div></td>"
  else
     txt(1127) = "JFM</td>"
  end if

  txt(1130) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialstddev_mam.indmem.png")) then
     txt(1131) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_stddev_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_stddev_mam"+quote+">MAM</a>" 
     txt(1132) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_stddev_mam"+quote+">"
     txt(1133) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1134) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_mam.indmem.png","Indiv")+"</li>"
     txt(1135) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_mam.indmemdiff.png","Bias")+"</li>"
     txt(1137) = "</ul></div></td>"
  else
     txt(1137) = "MAM</td>"
  end if

  txt(1140) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialstddev_jja.indmem.png")) then
     txt(1141) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_stddev_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_stddev_jja"+quote+">JJA</a>" 
     txt(1142) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_stddev_jja"+quote+">"
     txt(1143) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1144) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_jja.indmem.png","Indiv")+"</li>"
     txt(1145) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_jja.indmemdiff.png","Bias")+"</li>"
     txt(1147) = "</ul></div></td>"
  else
     txt(1147) = "JJA</td>"
  end if

  txt(1150) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialstddev_jas.indmem.png")) then
     txt(1151) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_stddev_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_stddev_jas"+quote+">JAS</a>" 
     txt(1152) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_stddev_jas"+quote+">"
     txt(1153) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1154) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_jas.indmem.png","Indiv")+"</li>"
     txt(1155) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_jas.indmemdiff.png","Bias")+"</li>"
     txt(1157) = "</ul></div></td>"
  else
     txt(1157) = "JAS</td>"
  end if

  txt(1160) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialstddev_son.indmem.png")) then
     txt(1161) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_stddev_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_stddev_son"+quote+">SON</a>" 
     txt(1162) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_stddev_son"+quote+">"
     txt(1163) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1164) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_son.indmem.png","Indiv")+"</li>"
     txt(1165) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_son.indmemdiff.png","Bias")+"</li>"
     txt(1167) = "</ul></div></td>"
  else
     txt(1167) = "SON</td>"
  end if

  txt(1170) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialstddev_ndjfma.indmem.png")) then
     txt(1171) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_stddev_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_stddev_ndjfma"+quote+">NDJFMA</a>"
     txt(1172) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_stddev_ndjfma"+quote+">"
     txt(1173) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1174) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_ndjfma.indmem.png","Indiv")+"</li>"
     txt(1175) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(1177) = "</ul></div></td>"
  else
     txt(1177) = "NDJFMA</td>"
  end if

  txt(1180) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialstddev_mjjaso.indmem.png")) then
     txt(1181) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_stddev_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_stddev_mjjaso"+quote+">MJJASO</a>"
     txt(1182) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_stddev_mjjaso"+quote+">"
     txt(1183) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1184) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_mjjaso.indmem.png","Indiv")+"</li>"
     txt(1185) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(1187) = "</ul></div></td>"
  else
     txt(1187) = "MJJASO</td>"
  end if

  txt(1190) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_spatialstddev_ann.indmem.png")) then
     txt(1191) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_stddev_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_stddev_ann"+quote+">ANN</a>" 
     txt(1192) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_stddev_ann"+quote+">"
     txt(1193) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1194) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_ann.indmem.png","Indiv")+"</li>"
     txt(1195) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_spatialstddev_ann.indmemdiff.png","Bias")+"</li>"
     txt(1197) = "</ul></div></td>"
  else
     txt(1197) = "ANN</td>"
  end if
  txt(1198) = "</tr>"


  txt(1224) = "<tr class="+quote+"d-flex"+quote+">"
  txt(1225) = "<td class="+quote+"col"+quote+"><b>TAS</b></td>"

  txt(1230) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialstddev_djf.indmem.png")) then
     txt(1231) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_stddev_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_stddev_djf"+quote+">DJF</a>" 
     txt(1232) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_stddev_djf"+quote+">"
     txt(1233) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1234) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_djf.indmem.png","Indiv")+"</li>"
     txt(1235) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_djf.indmemdiff.png","Bias")+"</li>"
     txt(1237) = "</ul></div></td>"
  else
     txt(1237) = "DJF</td>"
  end if

  txt(1240) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialstddev_jfm.indmem.png")) then
     txt(1241) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_stddev_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_stddev_jfm"+quote+">JFM</a>" 
     txt(1242) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_stddev_jfm"+quote+">"
     txt(1243) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1244) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_jfm.indmem.png","Indiv")+"</li>"
     txt(1245) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_jfm.indmemdiff.png","Bias")+"</li>"
     txt(1247) = "</ul></div></td>"
  else
     txt(1247) = "JFM</td>"
  end if

  txt(1250) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialstddev_mam.indmem.png")) then
     txt(1251) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_stddev_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_stddev_mam"+quote+">MAM</a>" 
     txt(1252) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_stddev_mam"+quote+">"
     txt(1253) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1254) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_mam.indmem.png","Indiv")+"</li>"
     txt(1255) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_mam.indmemdiff.png","Bias")+"</li>"
     txt(1257) = "</ul></div></td>"
  else
     txt(1257) = "MAM</td>"
  end if

  txt(1260) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialstddev_jja.indmem.png")) then
     txt(1261) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_stddev_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_stddev_jja"+quote+">JJA</a>" 
     txt(1262) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_stddev_jja"+quote+">"
     txt(1263) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1264) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_jja.indmem.png","Indiv")+"</li>"
     txt(1265) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_jja.indmemdiff.png","Bias")+"</li>"
     txt(1267) = "</ul></div></td>"
  else
     txt(1267) = "JJA</td>"
  end if

  txt(1270) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialstddev_jas.indmem.png")) then
     txt(1271) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_stddev_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_stddev_jas"+quote+">JAS</a>" 
     txt(1272) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_stddev_jas"+quote+">"
     txt(1273) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1274) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_jas.indmem.png","Indiv")+"</li>"
     txt(1275) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_jas.indmemdiff.png","Bias")+"</li>"
     txt(1277) = "</ul></div></td>"
  else
     txt(1277) = "JAS</td>"
  end if

  txt(1280) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialstddev_son.indmem.png")) then
     txt(1281) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_stddev_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_stddev_son"+quote+">SON</a>" 
     txt(1282) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_stddev_son"+quote+">"
     txt(1283) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1284) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_son.indmem.png","Indiv")+"</li>"
     txt(1285) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_son.indmemdiff.png","Bias")+"</li>"
     txt(1287) = "</ul></div></td>"
  else
     txt(1287) = "SON</td>"
  end if

  txt(1290) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialstddev_ndjfma.indmem.png")) then
     txt(1291) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_stddev_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_stddev_ndjfma"+quote+">NDJFMA</a>"
     txt(1292) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_stddev_ndjfma"+quote+">"
     txt(1293) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1294) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_ndjfma.indmem.png","Indiv")+"</li>"
     txt(1295) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(1297) = "</ul></div></td>"
  else
     txt(1297) = "NDJFMA</td>"
  end if

  txt(1300) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialstddev_mjjaso.indmem.png")) then
     txt(1301) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_stddev_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_stddev_mjjaso"+quote+">MJJASO</a>"
     txt(1302) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_stddev_mjjaso"+quote+">"
     txt(1303) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1304) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_mjjaso.indmem.png","Indiv")+"</li>"
     txt(1305) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(1307) = "</ul></div></td>"
  else
     txt(1307) = "MJJASO</td>"
  end if

  txt(1310) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_spatialstddev_ann.indmem.png")) then
     txt(1311) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_stddev_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_stddev_ann"+quote+">ANN</a>" 
     txt(1312) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_stddev_ann"+quote+">"
     txt(1313) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1314) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_ann.indmem.png","Indiv")+"</li>"
     txt(1315) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_spatialstddev_ann.indmemdiff.png","Bias")+"</li>"
     txt(1317) = "</ul></div></td>"
  else
     txt(1317) = "ANN</td>"
  end if
  txt(1318) = "</tr>"

  txt(1324) = "<tr class="+quote+"d-flex"+quote+">"
  txt(1325) = "<td class="+quote+"col"+quote+"><b>PSL</b></td>"

  txt(1330) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialstddev_djf.indmem.png")) then
     txt(1331) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_stddev_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_stddev_djf"+quote+">DJF</a>" 
     txt(1332) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_stddev_djf"+quote+">"
     txt(1333) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1334) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_djf.indmem.png","Indiv")+"</li>"
     txt(1335) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_djf.indmemdiff.png","Bias")+"</li>"
     txt(1337) = "</ul></div></td>"
  else
     txt(1337) = "DJF</td>"
  end if

  txt(1340) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialstddev_jfm.indmem.png")) then
     txt(1341) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_stddev_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_stddev_jfm"+quote+">JFM</a>" 
     txt(1342) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_stddev_jfm"+quote+">"
     txt(1343) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1344) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_jfm.indmem.png","Indiv")+"</li>"
     txt(1345) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_jfm.indmemdiff.png","Bias")+"</li>"
     txt(1347) = "</ul></div></td>"
  else
     txt(1347) = "JFM</td>"
  end if

  txt(1350) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialstddev_mam.indmem.png")) then
     txt(1351) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_stddev_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_stddev_mam"+quote+">MAM</a>" 
     txt(1352) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_stddev_mam"+quote+">"
     txt(1353) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1354) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_mam.indmem.png","Indiv")+"</li>"
     txt(1355) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_mam.indmemdiff.png","Bias")+"</li>"
     txt(1357) = "</ul></div></td>"
  else
     txt(1357) = "MAM</td>"
  end if

  txt(1360) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialstddev_jja.indmem.png")) then
     txt(1361) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_stddev_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_stddev_jja"+quote+">JJA</a>" 
     txt(1362) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_stddev_jja"+quote+">"
     txt(1363) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1364) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_jja.indmem.png","Indiv")+"</li>"
     txt(1365) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_jja.indmemdiff.png","Bias")+"</li>"
     txt(1367) = "</ul></div></td>"
  else
     txt(1367) = "JJA</td>"
  end if

  txt(1370) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialstddev_jas.indmem.png")) then
     txt(1371) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_stddev_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_stddev_jas"+quote+">JAS</a>" 
     txt(1372) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_stddev_jas"+quote+">"
     txt(1373) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1374) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_jas.indmem.png","Indiv")+"</li>"
     txt(1375) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_jas.indmemdiff.png","Bias")+"</li>"
     txt(1377) = "</ul></div></td>"
  else
     txt(1377) = "JAS</td>"
  end if

  txt(1380) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialstddev_son.indmem.png")) then
     txt(1381) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_stddev_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_stddev_son"+quote+">SON</a>" 
     txt(1382) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_stddev_son"+quote+">"
     txt(1383) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1384) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_son.indmem.png","Indiv")+"</li>"
     txt(1385) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_son.indmemdiff.png","Bias")+"</li>"
     txt(1387) = "</ul></div></td>"
  else
     txt(1387) = "SON</td>"
  end if

  txt(1390) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialstddev_ndjfma.indmem.png")) then
     txt(1391) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_stddev_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_stddev_ndjfma"+quote+">NDJFMA</a>"
     txt(1392) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_stddev_ndjfma"+quote+">"
     txt(1393) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1394) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_ndjfma.indmem.png","Indiv")+"</li>"
     txt(1395) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(1397) = "</ul></div></td>"
  else
     txt(1397) = "NDJFMA</td>"
  end if

  txt(1400) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialstddev_mjjaso.indmem.png")) then
     txt(1401) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_stddev_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_stddev_mjjaso"+quote+">MJJASO</a>"
     txt(1402) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_stddev_mjjaso"+quote+">"
     txt(1403) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1404) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_mjjaso.indmem.png","Indiv")+"</li>"
     txt(1405) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(1407) = "</ul></div></td>"
  else
     txt(1407) = "MJJASO</td>"
  end if

  txt(1410) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_spatialstddev_ann.indmem.png")) then
     txt(1411) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_stddev_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_stddev_ann"+quote+">ANN</a>" 
     txt(1412) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_stddev_ann"+quote+">"
     txt(1413) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1414) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_ann.indmem.png","Indiv")+"</li>"
     txt(1415) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_spatialstddev_ann.indmemdiff.png","Bias")+"</li>"
     txt(1417) = "</ul></div></td>"
  else
     txt(1417) = "ANN</td>"
  end if
  txt(1418) = "</tr>"

  txt(1444) = "<tr class="+quote+"d-flex"+quote+">"
  txt(1445) = "<td class="+quote+"col"+quote+"><b>PR</b></td>"

  txt(1450) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialstddev_djf.indmem.png")) then
     txt(1451) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_stddev_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_stddev_djf"+quote+">DJF</a>" 
     txt(1452) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_stddev_djf"+quote+">"
     txt(1453) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1454) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_djf.indmem.png","Indiv")+"</li>"
     txt(1455) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_djf.indmemdiff.png","Bias")+"</li>"
     txt(1457) = "</ul></div></td>"
  else
     txt(1457) = "DJF</td>"
  end if

  txt(1460) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialstddev_jfm.indmem.png")) then
     txt(1461) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_stddev_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_stddev_jfm"+quote+">JFM</a>" 
     txt(1462) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_stddev_jfm"+quote+">"
     txt(1463) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1464) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_jfm.indmem.png","Indiv")+"</li>"
     txt(1465) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_jfm.indmemdiff.png","Bias")+"</li>"
     txt(1467) = "</ul></div></td>"
  else
     txt(1467) = "JFM</td>"
  end if

  txt(1470) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialstddev_mam.indmem.png")) then
     txt(1471) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_stddev_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_stddev_mam"+quote+">MAM</a>" 
     txt(1472) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_stddev_mam"+quote+">"
     txt(1473) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1474) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_mam.indmem.png","Indiv")+"</li>"
     txt(1475) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_mam.indmemdiff.png","Bias")+"</li>"
     txt(1477) = "</ul></div></td>"
  else
     txt(1477) = "MAM</td>"
  end if

  txt(1480) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialstddev_jja.indmem.png")) then
     txt(1481) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_stddev_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_stddev_jja"+quote+">JJA</a>" 
     txt(1482) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_stddev_jja"+quote+">"
     txt(1483) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1484) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_jja.indmem.png","Indiv")+"</li>"
     txt(1485) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_jja.indmemdiff.png","Bias")+"</li>"
     txt(1487) = "</ul></div></td>"
  else
     txt(1487) = "JJA</td>"
  end if

  txt(1490) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialstddev_jas.indmem.png")) then
     txt(1491) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_stddev_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_stddev_jas"+quote+">JAS</a>" 
     txt(1492) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_stddev_jas"+quote+">"
     txt(1493) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1494) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_jas.indmem.png","Indiv")+"</li>"
     txt(1495) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_jas.indmemdiff.png","Bias")+"</li>"
     txt(1497) = "</ul></div></td>"
  else
     txt(1497) = "JAS</td>"
  end if

  txt(1500) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialstddev_son.indmem.png")) then
     txt(1501) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_stddev_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_stddev_son"+quote+">SON</a>" 
     txt(1502) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_stddev_son"+quote+">"
     txt(1503) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1504) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_son.indmem.png","Indiv")+"</li>"
     txt(1505) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_son.indmemdiff.png","Bias")+"</li>"
     txt(1507) = "</ul></div></td>"
  else
     txt(1507) = "SON</td>"
  end if

  txt(1510) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialstddev_ndjfma.indmem.png")) then
     txt(1511) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_stddev_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_stddev_ndjfma"+quote+">NDJFMA</a>"
     txt(1512) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_stddev_ndjfma"+quote+">"
     txt(1513) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1514) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_ndjfma.indmem.png","Indiv")+"</li>"
     txt(1515) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(1517) = "</ul></div></td>"
  else
     txt(1517) = "NDJFMA</td>"
  end if

  txt(1520) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialstddev_mjjaso.indmem.png")) then
     txt(1521) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_stddev_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_stddev_mjjaso"+quote+">MJJASO</a>"
     txt(1522) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_stddev_mjjaso"+quote+">"
     txt(1523) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1524) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_mjjaso.indmem.png","Indiv")+"</li>"
     txt(1525) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(1527) = "</ul></div></td>"
  else
     txt(1527) = "MJJASO</td>"
  end if

  txt(1530) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_spatialstddev_ann.indmem.png")) then
     txt(1531) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_stddev_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_stddev_ann"+quote+">ANN</a>" 
     txt(1532) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_stddev_ann"+quote+">"
     txt(1533) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1534) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_ann.indmem.png","Indiv")+"</li>"
     txt(1535) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_spatialstddev_ann.indmemdiff.png","Bias")+"</li>"
     txt(1537) = "</ul></div></td>"
  else
     txt(1537) = "ANN</td>"
  end if
  txt(1538) = "</tr>"

  txt(1568) = "<tr class="+quote+"d-flex"+quote+">"
  txt(1569) = "<td class="+quote+"col"+quote+"><b>SIC NH</b></td>"

  txt(1570) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialstddev_djf.indmem.png")) then
     txt(1571) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_stddev_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_stddev_djf"+quote+">DJF</a>" 
     txt(1572) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_stddev_djf"+quote+">"
     txt(1573) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1574) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_djf.indmem.png","Indiv")+"</li>"
     txt(1575) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_djf.indmemdiff.png","Bias")+"</li>"
     txt(1577) = "</ul></div></td>"
  else
     txt(1577) = "DJF</td>"
  end if

  txt(1580) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialstddev_jfm.indmem.png")) then
     txt(1581) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_stddev_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_stddev_jfm"+quote+">JFM</a>" 
     txt(1582) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_stddev_jfm"+quote+">"
     txt(1583) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1584) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_jfm.indmem.png","Indiv")+"</li>"
     txt(1585) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_jfm.indmemdiff.png","Bias")+"</li>"
     txt(1587) = "</ul></div></td>"
  else
     txt(1587) = "JFM</td>"
  end if

  txt(1590) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialstddev_mam.indmem.png")) then
     txt(1591) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_stddev_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_stddev_mam"+quote+">MAM</a>" 
     txt(1592) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_stddev_mam"+quote+">"
     txt(1593) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1594) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_mam.indmem.png","Indiv")+"</li>"
     txt(1595) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_mam.indmemdiff.png","Bias")+"</li>"
     txt(1597) = "</ul></div></td>"
  else
     txt(1597) = "MAM</td>"
  end if

  txt(1600) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialstddev_jja.indmem.png")) then
     txt(1601) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_stddev_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_stddev_jja"+quote+">JJA</a>" 
     txt(1602) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_stddev_jja"+quote+">"
     txt(1603) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1604) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_jja.indmem.png","Indiv")+"</li>"
     txt(1605) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_jja.indmemdiff.png","Bias")+"</li>"
     txt(1607) = "</ul></div></td>"
  else
     txt(1607) = "JJA</td>"
  end if

  txt(1610) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialstddev_jas.indmem.png")) then
     txt(1611) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_stddev_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_stddev_jas"+quote+">JAS</a>" 
     txt(1612) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_stddev_jas"+quote+">"
     txt(1613) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1614) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_jas.indmem.png","Indiv")+"</li>"
     txt(1615) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_jas.indmemdiff.png","Bias")+"</li>"
     txt(1617) = "</ul></div></td>"
  else
     txt(1617) = "JAS</td>"
  end if

  txt(1620) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialstddev_son.indmem.png")) then
     txt(1621) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_stddev_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_stddev_son"+quote+">SON</a>" 
     txt(1622) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_stddev_son"+quote+">"
     txt(1623) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1624) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_son.indmem.png","Indiv")+"</li>"
     txt(1625) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_son.indmemdiff.png","Bias")+"</li>"
     txt(1627) = "</ul></div></td>"
  else
     txt(1627) = "SON</td>"
  end if

  txt(1630) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialstddev_ndjfma.indmem.png")) then
     txt(1631) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_stddev_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_stddev_ndjfma"+quote+">NDJFMA</a>"
     txt(1632) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_stddev_ndjfma"+quote+">"
     txt(1633) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1634) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_ndjfma.indmem.png","Indiv")+"</li>"
     txt(1635) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(1637) = "</ul></div></td>"
  else
     txt(1637) = "NDJFMA</td>"
  end if

  txt(1640) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialstddev_mjjaso.indmem.png")) then
     txt(1641) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_stddev_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_stddev_mjjaso"+quote+">MJJASO</a>"
     txt(1642) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_stddev_mjjaso"+quote+">"
     txt(1643) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1644) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_mjjaso.indmem.png","Indiv")+"</li>"
     txt(1645) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(1647) = "</ul></div></td>"
  else
     txt(1647) = "MJJASO</td>"
  end if

  txt(1650) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_spatialstddev_ann.indmem.png")) then
     txt(1651) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_stddev_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_stddev_ann"+quote+">ANN</a>" 
     txt(1652) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_stddev_ann"+quote+">"
     txt(1653) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1654) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_ann.indmem.png","Indiv")+"</li>"
     txt(1655) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_spatialstddev_ann.indmemdiff.png","Bias")+"</li>"
     txt(1657) = "</ul></div></td>"
  else
     txt(1657) = "ANN</td>"
  end if
  txt(1658) = "</tr>"

  txt(1684) = "<tr class="+quote+"d-flex"+quote+">"
  txt(1685) = "<td class="+quote+"col"+quote+"><b>SIC SH</b></td>"

  txt(1690) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialstddev_djf.indmem.png")) then
     txt(1691) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_stddev_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_stddev_djf"+quote+">DJF</a>" 
     txt(1692) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_stddev_djf"+quote+">"
     txt(1693) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1694) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_djf.indmem.png","Indiv")+"</li>"
     txt(1695) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_djf.indmemdiff.png","Bias")+"</li>"
     txt(1697) = "</ul></div></td>"
  else
     txt(1697) = "DJF</td>"
  end if

  txt(1700) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialstddev_jfm.indmem.png")) then
     txt(1701) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_stddev_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_stddev_jfm"+quote+">JFM</a>" 
     txt(1702) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_stddev_jfm"+quote+">"
     txt(1703) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1704) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_jfm.indmem.png","Indiv")+"</li>"
     txt(1705) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_jfm.indmemdiff.png","Bias")+"</li>"
     txt(1707) = "</ul></div></td>"
  else
     txt(1707) = "JFM</td>"
  end if

  txt(1710) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialstddev_mam.indmem.png")) then
     txt(1711) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_stddev_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_stddev_mam"+quote+">MAM</a>" 
     txt(1712) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_stddev_mam"+quote+">"
     txt(1713) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1714) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_mam.indmem.png","Indiv")+"</li>"
     txt(1715) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_mam.indmemdiff.png","Bias")+"</li>"
     txt(1717) = "</ul></div></td>"
  else
     txt(1717) = "MAM</td>"
  end if

  txt(1720) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialstddev_jja.indmem.png")) then
     txt(1721) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_stddev_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_stddev_jja"+quote+">JJA</a>" 
     txt(1722) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_stddev_jja"+quote+">"
     txt(1723) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1724) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_jja.indmem.png","Indiv")+"</li>"
     txt(1725) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_jja.indmemdiff.png","Bias")+"</li>"
     txt(1727) = "</ul></div></td>"
  else
     txt(1727) = "JJA</td>"
  end if

  txt(1730) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialstddev_jas.indmem.png")) then
     txt(1731) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_stddev_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_stddev_jas"+quote+">JAS</a>" 
     txt(1732) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_stddev_jas"+quote+">"
     txt(1733) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1734) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_jas.indmem.png","Indiv")+"</li>"
     txt(1735) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_jas.indmemdiff.png","Bias")+"</li>"
     txt(1737) = "</ul></div></td>"
  else
     txt(1737) = "JAS</td>"
  end if

  txt(1740) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialstddev_son.indmem.png")) then
     txt(1741) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_stddev_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_stddev_son"+quote+">SON</a>" 
     txt(1742) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_stddev_son"+quote+">"
     txt(1743) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1744) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_son.indmem.png","Indiv")+"</li>"
     txt(1745) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_son.indmemdiff.png","Bias")+"</li>"
     txt(1747) = "</ul></div></td>"
  else
     txt(1747) = "SON</td>"
  end if

  txt(1750) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialstddev_ndjfma.indmem.png")) then
     txt(1751) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_stddev_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_stddev_ndjfma"+quote+">NDJFMA</a>"
     txt(1752) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_stddev_ndjfma"+quote+">"
     txt(1753) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1754) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_ndjfma.indmem.png","Indiv")+"</li>"
     txt(1755) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(1757) = "</ul></div></td>"
  else
     txt(1757) = "NDJFMA</td>"
  end if

  txt(1760) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialstddev_mjjaso.indmem.png")) then
     txt(1761) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_stddev_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_stddev_mjjaso"+quote+">MJJASO</a>"
     txt(1762) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_stddev_mjjaso"+quote+">"
     txt(1763) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1764) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_mjjaso.indmem.png","Indiv")+"</li>"
     txt(1765) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(1767) = "</ul></div></td>"
  else
     txt(1767) = "MJJASO</td>"
  end if

  txt(1770) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_spatialstddev_ann.indmem.png")) then
     txt(1771) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_stddev_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_stddev_ann"+quote+">ANN</a>" 
     txt(1772) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_stddev_ann"+quote+">"
     txt(1773) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(1774) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_ann.indmem.png","Indiv")+"</li>"
     txt(1775) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_spatialstddev_ann.indmemdiff.png","Bias")+"</li>"
     txt(1777) = "</ul></div></td>"
  else
     txt(1777) = "ANN</td>"
  end if
  txt(1778) = "</tr>"
  txt(1780) = "</table></div></div>"


  txt(2100) = "<div class="+quote+"row"+quote+">"
  txt(2101) = "<div class="+quote+"col"+quote+">"
  txt(2102) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(2103) = "<h3 class="+quote+"display-6"+quote+">Climate Trend Maps</h3>"
  txt(2104) = "<tr class="+quote+"d-flex"+quote+">"
  txt(2105) = "<td class="+quote+"col"+quote+"><b>SST</b></td>"

  txt(2110) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_trends_djf.indmem.png")) then
     txt(2111) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_trends_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_trends_djf"+quote+">DJF</a>" 
     txt(2112) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_trends_djf"+quote+">"
     txt(2113) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2114) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_djf.indmem.png","Indiv")+"</li>"
     txt(2115) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_djf.indmemdiff.png","Bias")+"</li>"
     txt(2117) = "</ul></div></td>"
  else
     txt(2117) = "DJF</td>"
  end if

  txt(2120) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_trends_jfm.indmem.png")) then
     txt(2121) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_trends_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_trends_jfm"+quote+">JFM</a>" 
     txt(2122) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_trends_jfm"+quote+">"
     txt(2123) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2124) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_jfm.indmem.png","Indiv")+"</li>"
     txt(2125) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_jfm.indmemdiff.png","Bias")+"</li>"
     txt(2127) = "</ul></div></td>"
  else
     txt(2127) = "JFM</td>"
  end if

  txt(2130) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_trends_mam.indmem.png")) then
     txt(2131) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_trends_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_trends_mam"+quote+">MAM</a>" 
     txt(2132) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_trends_mam"+quote+">"
     txt(2133) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2134) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_mam.indmem.png","Indiv")+"</li>"
     txt(2135) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_mam.indmemdiff.png","Bias")+"</li>"
     txt(2137) = "</ul></div></td>"
  else
     txt(2137) = "MAM</td>"
  end if

  txt(2140) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_trends_jja.indmem.png")) then
     txt(2141) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_trends_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_trends_jja"+quote+">JJA</a>" 
     txt(2142) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_trends_jja"+quote+">"
     txt(2143) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2144) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_jja.indmem.png","Indiv")+"</li>"
     txt(2145) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_jja.indmemdiff.png","Bias")+"</li>"
     txt(2147) = "</ul></div></td>"
  else
     txt(2147) = "JJA</td>"
  end if

  txt(2150) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_trends_jas.indmem.png")) then
     txt(2151) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_trends_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_trends_jas"+quote+">JAS</a>" 
     txt(2152) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_trends_jas"+quote+">"
     txt(2153) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2154) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_jas.indmem.png","Indiv")+"</li>"
     txt(2155) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_jas.indmemdiff.png","Bias")+"</li>"
     txt(2157) = "</ul></div></td>"
  else
     txt(2157) = "JAS</td>"
  end if

  txt(2160) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_trends_son.indmem.png")) then
     txt(2161) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_trends_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_trends_son"+quote+">SON</a>" 
     txt(2162) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_trends_son"+quote+">"
     txt(2163) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2164) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_son.indmem.png","Indiv")+"</li>"
     txt(2165) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_son.indmemdiff.png","Bias")+"</li>"
     txt(2167) = "</ul></div></td>"
  else
     txt(2167) = "SON</td>"
  end if

  txt(2170) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_trends_ndjfma.indmem.png")) then
     txt(2171) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_trends_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_trends_ndjfma"+quote+">NDJFMA</a>"
     txt(2172) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_trends_ndjfma"+quote+">"
     txt(2173) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2174) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_ndjfma.indmem.png","Indiv")+"</li>"
     txt(2175) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(2177) = "</ul></div></td>"
  else
     txt(2177) = "NDJFMA</td>"
  end if

  txt(2180) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_trends_mjjaso.indmem.png")) then
     txt(2181) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_trends_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_trends_mjjaso"+quote+">MJJASO</a>"
     txt(2182) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_trends_mjjaso"+quote+">"
     txt(2183) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2184) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_mjjaso.indmem.png","Indiv")+"</li>"
     txt(2185) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(2187) = "</ul></div></td>"
  else
     txt(2187) = "MJJASO</td>"
  end if

  txt(2190) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"sst_trends_ann.indmem.png")) then
     txt(2191) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sst_trends_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sst_trends_ann"+quote+">ANN</a>" 
     txt(2192) = "<div class="+quote+"collapse"+quote+" id="+quote+"sst_trends_ann"+quote+">"
     txt(2193) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2194) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_ann.indmem.png","Indiv")+"</li>"
     txt(2195) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sst_trends_ann.indmemdiff.png","Bias")+"</li>"
     txt(2197) = "</ul></div></td>"
  else
     txt(2197) = "ANN</td>"
  end if
  txt(2198) = "</tr>"

  txt(2234) = "<tr class="+quote+"d-flex"+quote+">"
  txt(2235) = "<td class="+quote+"col"+quote+"><b>TAS</b></td>"

  txt(2240) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_trends_djf.indmem.png")) then
     txt(2241) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_trends_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_trends_djf"+quote+">DJF</a>" 
     txt(2242) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_trends_djf"+quote+">"
     txt(2243) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2244) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_djf.indmem.png","Indiv")+"</li>"
     txt(2245) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_djf.indmemdiff.png","Bias")+"</li>"
     txt(2247) = "</ul></div></td>"
  else
     txt(2247) = "DJF</td>"
  end if

  txt(2250) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_trends_jfm.indmem.png")) then
     txt(2251) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_trends_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_trends_jfm"+quote+">JFM</a>" 
     txt(2252) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_trends_jfm"+quote+">"
     txt(2253) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2254) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_jfm.indmem.png","Indiv")+"</li>"
     txt(2255) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_jfm.indmemdiff.png","Bias")+"</li>"
     txt(2257) = "</ul></div></td>"
  else
     txt(2257) = "JFM</td>"
  end if

  txt(2260) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_trends_mam.indmem.png")) then
     txt(2261) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_trends_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_trends_mam"+quote+">MAM</a>" 
     txt(2262) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_trends_mam"+quote+">"
     txt(2263) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2264) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_mam.indmem.png","Indiv")+"</li>"
     txt(2265) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_mam.indmemdiff.png","Bias")+"</li>"
     txt(2267) = "</ul></div></td>"
  else
     txt(2267) = "MAM</td>"
  end if

  txt(2270) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_trends_jja.indmem.png")) then
     txt(2271) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_trends_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_trends_jja"+quote+">JJA</a>" 
     txt(2272) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_trends_jja"+quote+">"
     txt(2273) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2274) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_jja.indmem.png","Indiv")+"</li>"
     txt(2275) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_jja.indmemdiff.png","Bias")+"</li>"
     txt(2277) = "</ul></div></td>"
  else
     txt(2277) = "JJA</td>"
  end if

  txt(2280) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_trends_jas.indmem.png")) then
     txt(2281) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_trends_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_trends_jas"+quote+">JAS</a>" 
     txt(2282) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_trends_jas"+quote+">"
     txt(2283) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2284) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_jas.indmem.png","Indiv")+"</li>"
     txt(2285) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_jas.indmemdiff.png","Bias")+"</li>"
     txt(2287) = "</ul></div></td>"
  else
     txt(2287) = "JAS</td>"
  end if

  txt(2290) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_trends_son.indmem.png")) then
     txt(2291) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_trends_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_trends_son"+quote+">SON</a>" 
     txt(2292) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_trends_son"+quote+">"
     txt(2293) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2294) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_son.indmem.png","Indiv")+"</li>"
     txt(2295) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_son.indmemdiff.png","Bias")+"</li>"
     txt(2297) = "</ul></div></td>"
  else
     txt(2297) = "SON</td>"
  end if

  txt(2300) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_trends_ndjfma.indmem.png")) then
     txt(2301) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_trends_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_trends_ndjfma"+quote+">NDJFMA</a>"
     txt(2302) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_trends_ndjfma"+quote+">"
     txt(2303) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2304) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_ndjfma.indmem.png","Indiv")+"</li>"
     txt(2305) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(2307) = "</ul></div></td>"
  else
     txt(2307) = "NDJFMA</td>"
  end if

  txt(2310) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_trends_mjjaso.indmem.png")) then
     txt(2311) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_trends_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_trends_mjjaso"+quote+">MJJASO</a>"
     txt(2312) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_trends_mjjaso"+quote+">"
     txt(2313) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2314) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_mjjaso.indmem.png","Indiv")+"</li>"
     txt(2315) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(2317) = "</ul></div></td>"
  else
     txt(2317) = "MJJASO</td>"
  end if

  txt(2320) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"tas_trends_ann.indmem.png")) then
     txt(2321) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tas_trends_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tas_trends_ann"+quote+">ANN</a>" 
     txt(2322) = "<div class="+quote+"collapse"+quote+" id="+quote+"tas_trends_ann"+quote+">"
     txt(2323) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2324) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_ann.indmem.png","Indiv")+"</li>"
     txt(2325) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tas_trends_ann.indmemdiff.png","Bias")+"</li>"
     txt(2327) = "</ul></div></td>"
  else
     txt(2327) = "ANN</td>"
  end if
  txt(2328) = "</tr>"

  txt(2354) = "<tr class="+quote+"d-flex"+quote+">"
  txt(2355) = "<td class="+quote+"col"+quote+"><b>PSL</b></td>"

  txt(2360) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_trends_djf.indmem.png")) then
     txt(2361) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_trends_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_trends_djf"+quote+">DJF</a>" 
     txt(2362) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_trends_djf"+quote+">"
     txt(2363) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2364) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_djf.indmem.png","Indiv")+"</li>"
     txt(2365) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_djf.indmemdiff.png","Bias")+"</li>"
     txt(2367) = "</ul></div></td>"
  else
     txt(2367) = "DJF</td>"
  end if

  txt(2370) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_trends_jfm.indmem.png")) then
     txt(2371) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_trends_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_trends_jfm"+quote+">JFM</a>" 
     txt(2372) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_trends_jfm"+quote+">"
     txt(2373) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2374) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_jfm.indmem.png","Indiv")+"</li>"
     txt(2375) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_jfm.indmemdiff.png","Bias")+"</li>"
     txt(2377) = "</ul></div></td>"
  else
     txt(2377) = "JFM</td>"
  end if

  txt(2380) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_trends_mam.indmem.png")) then
     txt(2381) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_trends_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_trends_mam"+quote+">MAM</a>" 
     txt(2382) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_trends_mam"+quote+">"
     txt(2383) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2384) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_mam.indmem.png","Indiv")+"</li>"
     txt(2385) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_mam.indmemdiff.png","Bias")+"</li>"
     txt(2387) = "</ul></div></td>"
  else
     txt(2387) = "MAM</td>"
  end if

  txt(2390) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_trends_jja.indmem.png")) then
     txt(2391) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_trends_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_trends_jja"+quote+">JJA</a>" 
     txt(2392) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_trends_jja"+quote+">"
     txt(2393) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2394) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_jja.indmem.png","Indiv")+"</li>"
     txt(2395) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_jja.indmemdiff.png","Bias")+"</li>"
     txt(2397) = "</ul></div></td>"
  else
     txt(2397) = "JJA</td>"
  end if

  txt(2400) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_trends_jas.indmem.png")) then
     txt(2401) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_trends_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_trends_jas"+quote+">JAS</a>" 
     txt(2402) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_trends_jas"+quote+">"
     txt(2403) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2404) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_jas.indmem.png","Indiv")+"</li>"
     txt(2405) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_jas.indmemdiff.png","Bias")+"</li>"
     txt(2407) = "</ul></div></td>"
  else
     txt(2407) = "JAS</td>"
  end if

  txt(2410) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_trends_son.indmem.png")) then
     txt(2411) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_trends_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_trends_son"+quote+">SON</a>"
     txt(2412) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_trends_son"+quote+">"
     txt(2413) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2414) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_son.indmem.png","Indiv")+"</li>"
     txt(2415) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_son.indmemdiff.png","Bias")+"</li>"
     txt(2417) = "</ul></div></td>"
  else
     txt(2417) = "SON</td>"
  end if

  txt(2420) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_trends_ndjfma.indmem.png")) then
     txt(2421) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_trends_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_trends_ndjfma"+quote+">NDJFMA</a>" 
     txt(2422) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_trends_ndjfma"+quote+">"
     txt(2423) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2424) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_ndjfma.indmem.png","Indiv")+"</li>"
     txt(2425) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(2427) = "</ul></div></td>"
  else
     txt(2427) = "NDJFMA</td>"
  end if

  txt(2430) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_trends_mjjaso.indmem.png")) then
     txt(2431) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_trends_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_trends_mjjaso"+quote+">MJJASO</a>"
     txt(2432) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_trends_mjjaso"+quote+">"
     txt(2433) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2434) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_mjjaso.indmem.png","Indiv")+"</li>"
     txt(2435) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(2437) = "</ul></div></td>"
  else
     txt(2437) = "MJJASO</td>"
  end if

  txt(2440) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"psl_trends_ann.indmem.png")) then
     txt(2441) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psl_trends_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psl_trends_ann"+quote+">ANN</a>" 
     txt(2442) = "<div class="+quote+"collapse"+quote+" id="+quote+"psl_trends_ann"+quote+">"
     txt(2443) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2444) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_ann.indmem.png","Indiv")+"</li>"
     txt(2445) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psl_trends_ann.indmemdiff.png","Bias")+"</li>"
     txt(2447) = "</ul></div></td>"
  else
     txt(2447) = "ANN</td>"
  end if
  txt(2448) = "</tr>"

  txt(2464) = "<tr class="+quote+"d-flex"+quote+">"
  txt(2465) = "<td class="+quote+"col"+quote+"><b>PR</b></td>"

  txt(2470) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_trends_djf.indmem.png")) then
     txt(2471) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_trends_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_trends_djf"+quote+">DJF</a>" 
     txt(2472) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_trends_djf"+quote+">"
     txt(2473) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2474) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_djf.indmem.png","Indiv")+"</li>"
     txt(2475) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_djf.indmemdiff.png","Bias")+"</li>"
     txt(2477) = "</ul></div></td>"
  else
     txt(2477) = "DJF</td>"
  end if

  txt(2480) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_trends_jfm.indmem.png")) then
     txt(2481) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_trends_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_trends_jfm"+quote+">JFM</a>" 
     txt(2482) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_trends_jfm"+quote+">"
     txt(2483) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2484) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_jfm.indmem.png","Indiv")+"</li>"
     txt(2485) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_jfm.indmemdiff.png","Bias")+"</li>"
     txt(2487) = "</ul></div></td>"
  else
     txt(2487) = "JFM</td>"
  end if

  txt(2490) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_trends_mam.indmem.png")) then
     txt(2491) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_trends_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_trends_mam"+quote+">MAM</a>" 
     txt(2492) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_trends_mam"+quote+">"
     txt(2493) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2494) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_mam.indmem.png","Indiv")+"</li>"
     txt(2495) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_mam.indmemdiff.png","Bias")+"</li>"
     txt(2497) = "</ul></div></td>"
  else
     txt(2497) = "MAM</td>"
  end if

  txt(2500) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_trends_jja.indmem.png")) then
     txt(2501) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_trends_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_trends_jja"+quote+">JJA</a>" 
     txt(2502) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_trends_jja"+quote+">"
     txt(2503) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2504) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_jja.indmem.png","Indiv")+"</li>"
     txt(2505) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_jja.indmemdiff.png","Bias")+"</li>"
     txt(2507) = "</ul></div></td>"
  else
     txt(2507) = "JJA</td>"
  end if

  txt(2510) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_trends_jas.indmem.png")) then
     txt(2511) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_trends_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_trends_jas"+quote+">JAS</a>" 
     txt(2512) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_trends_jas"+quote+">"
     txt(2513) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2514) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_jas.indmem.png","Indiv")+"</li>"
     txt(2515) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_jas.indmemdiff.png","Bias")+"</li>"
     txt(2517) = "</ul></div></td>"
  else
     txt(2517) = "JAS</td>"
  end if

  txt(2520) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_trends_son.indmem.png")) then
     txt(2521) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_trends_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_trends_son"+quote+">SON</a>" 
     txt(2522) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_trends_son"+quote+">"
     txt(2523) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2524) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_son.indmem.png","Indiv")+"</li>"
     txt(2525) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_son.indmemdiff.png","Bias")+"</li>"
     txt(2527) = "</ul></div></td>"
  else
     txt(2527) = "SON</td>"
  end if

  txt(2530) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_trends_ndjfma.indmem.png")) then
     txt(2531) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_trends_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_trends_ndjfma"+quote+">NDJFMA</a>"
     txt(2532) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_trends_ndjfma"+quote+">"
     txt(2533) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2534) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_ndjfma.indmem.png","Indiv")+"</li>"
     txt(2535) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(2537) = "</ul></div></td>"
  else
     txt(2537) = "NDJFMA</td>"
  end if

  txt(2540) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_trends_mjjaso.indmem.png")) then
     txt(2541) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_trends_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_trends_mjjaso"+quote+">MJJASO</a>"
     txt(2542) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_trends_mjjaso"+quote+">"
     txt(2543) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2544) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_mjjaso.indmem.png","Indiv")+"</li>"
     txt(2545) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(2547) = "</ul></div></td>"
  else
     txt(2547) = "MJJASO</td>"
  end if

  txt(2550) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"pr_trends_ann.indmem.png")) then
     txt(2551) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pr_trends_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pr_trends_ann"+quote+">ANN</a>" 
     txt(2552) = "<div class="+quote+"collapse"+quote+" id="+quote+"pr_trends_ann"+quote+">"
     txt(2553) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2554) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_ann.indmem.png","Indiv")+"</li>"
     txt(2555) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pr_trends_ann.indmemdiff.png","Bias")+"</li>"
     txt(2557) = "</ul></div></td>"
  else
     txt(2557) = "ANN</td>"
  end if
  txt(2558) = "</tr>"


  txt(2607) = "<tr class="+quote+"d-flex"+quote+">"
  txt(2608) = "<td class="+quote+"col"+quote+"><b>SIC NH</b></td>"

  txt(2610) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_trends_djf.indmem.png")) then
     txt(2611) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_trends_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_trends_djf"+quote+">DJF</a>" 
     txt(2612) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_trends_djf"+quote+">"
     txt(2613) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2614) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_djf.indmem.png","Indiv")+"</li>"
     txt(2615) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_djf.indmemdiff.png","Bias")+"</li>"
     txt(2617) = "</ul></div></td>"
  else
     txt(2617) = "DJF</td>"
  end if

  txt(2620) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_trends_jfm.indmem.png")) then
     txt(2621) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_trends_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_trends_jfm"+quote+">JFM</a>" 
     txt(2622) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_trends_jfm"+quote+">"
     txt(2623) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2624) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_jfm.indmem.png","Indiv")+"</li>"
     txt(2625) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_jfm.indmemdiff.png","Bias")+"</li>"
     txt(2627) = "</ul></div></td>"
  else
     txt(2627) = "JFM</td>"
  end if

  txt(2630) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_trends_mam.indmem.png")) then
     txt(2631) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_trends_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_trends_mam"+quote+">MAM</a>" 
     txt(2632) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_trends_mam"+quote+">"
     txt(2633) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2634) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_mam.indmem.png","Indiv")+"</li>"
     txt(2635) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_mam.indmemdiff.png","Bias")+"</li>"
     txt(2637) = "</ul></div></td>"
  else
     txt(2637) = "MAM</td>"
  end if

  txt(2640) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_trends_jja.indmem.png")) then
     txt(2641) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_trends_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_trends_jja"+quote+">JJA</a>" 
     txt(2642) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_trends_jja"+quote+">"
     txt(2643) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2644) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_jja.indmem.png","Indiv")+"</li>"
     txt(2645) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_jja.indmemdiff.png","Bias")+"</li>"
     txt(2647) = "</ul></div></td>"
  else
     txt(2647) = "JJA</td>"
  end if

  txt(2650) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_trends_jas.indmem.png")) then
     txt(2651) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_trends_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_trends_jas"+quote+">JAS</a>" 
     txt(2652) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_trends_jas"+quote+">"
     txt(2653) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2654) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_jas.indmem.png","Indiv")+"</li>"
     txt(2655) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_jas.indmemdiff.png","Bias")+"</li>"
     txt(2657) = "</ul></div></td>"
  else
     txt(2657) = "JAS</td>"
  end if

  txt(2660) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_trends_son.indmem.png")) then
     txt(2661) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_trends_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_trends_son"+quote+">SON</a>" 
     txt(2662) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_trends_son"+quote+">"
     txt(2663) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2664) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_son.indmem.png","Indiv")+"</li>"
     txt(2665) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_son.indmemdiff.png","Bias")+"</li>"
     txt(2667) = "</ul></div></td>"
  else
     txt(2667) = "SON</td>"
  end if

  txt(2670) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_trends_ndjfma.indmem.png")) then
     txt(2671) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_trends_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_trends_ndjfma"+quote+">NDJFMA</a>"
     txt(2672) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_trends_ndjfma"+quote+">"
     txt(2673) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2674) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_ndjfma.indmem.png","Indiv")+"</li>"
     txt(2675) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(2677) = "</ul></div></td>"
  else
     txt(2677) = "NDJFMA</td>"
  end if

  txt(2680) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_trends_mjjaso.indmem.png")) then
     txt(2681) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_trends_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_trends_mjjaso"+quote+">MJJASO</a>"
     txt(2682) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_trends_mjjaso"+quote+">"
     txt(2683) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2684) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_mjjaso.indmem.png","Indiv")+"</li>"
     txt(2685) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(2687) = "</ul></div></td>"
  else
     txt(2687) = "MJJASO</td>"
  end if

  txt(2690) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_nh_trends_ann.indmem.png")) then
     txt(2691) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_nh_trends_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_nh_trends_ann"+quote+">ANN</a>" 
     txt(2692) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_nh_trends_ann"+quote+">"
     txt(2693) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2694) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_ann.indmem.png","Indiv")+"</li>"
     txt(2695) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_nh_trends_ann.indmemdiff.png","Bias")+"</li>"
     txt(2697) = "</ul></div></td>"
  else
     txt(2697) = "ANN</td>"
  end if
  txt(2698) = "</tr>"

  txt(2734) = "<tr class="+quote+"d-flex"+quote+">"
  txt(2735) = "<td class="+quote+"col"+quote+"><b>SIC SH</b></td>"

  txt(2740) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_trends_djf.indmem.png")) then
     txt(2741) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_trends_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_trends_djf"+quote+">DJF</a>" 
     txt(2742) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_trends_djf"+quote+">"
     txt(2743) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2744) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_djf.indmem.png","Indiv")+"</li>"
     txt(2745) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_djf.indmemdiff.png","Bias")+"</li>"
     txt(2747) = "</ul></div></td>"
  else
     txt(2747) = "DJF</td>"
  end if

  txt(2750) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_trends_jfm.indmem.png")) then
     txt(2751) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_trends_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_trends_jfm"+quote+">JFM</a>" 
     txt(2752) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_trends_jfm"+quote+">"
     txt(2753) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2754) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_jfm.indmem.png","Indiv")+"</li>"
     txt(2755) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_jfm.indmemdiff.png","Bias")+"</li>"
     txt(2757) = "</ul></div></td>"
  else
     txt(2757) = "JFM</td>"
  end if

  txt(2760) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_trends_mam.indmem.png")) then
     txt(2761) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_trends_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_trends_mam"+quote+">MAM</a>" 
     txt(2762) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_trends_mam"+quote+">"
     txt(2763) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2764) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_mam.indmem.png","Indiv")+"</li>"
     txt(2765) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_mam.indmemdiff.png","Bias")+"</li>"
     txt(2767) = "</ul></div></td>"
  else
     txt(2767) = "MAM</td>"
  end if

  txt(2770) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_trends_jja.indmem.png")) then
     txt(2771) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_trends_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_trends_jja"+quote+">JJA</a>" 
     txt(2772) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_trends_jja"+quote+">"
     txt(2773) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2774) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_jja.indmem.png","Indiv")+"</li>"
     txt(2775) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_jja.indmemdiff.png","Bias")+"</li>"
     txt(2777) = "</ul></div></td>"
  else
     txt(2777) = "JJA</td>"
  end if

  txt(2780) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_trends_jas.indmem.png")) then
     txt(2781) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_trends_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_trends_jas"+quote+">JAS</a>" 
     txt(2782) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_trends_jas"+quote+">"
     txt(2783) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2784) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_jas.indmem.png","Indiv")+"</li>"
     txt(2785) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_jas.indmemdiff.png","Bias")+"</li>"
     txt(2787) = "</ul></div></td>"
  else
     txt(2787) = "JAS</td>"
  end if

  txt(2790) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_trends_son.indmem.png")) then
     txt(2791) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_trends_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_trends_son"+quote+">SON</a>" 
     txt(2792) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_trends_son"+quote+">"
     txt(2793) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2794) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_son.indmem.png","Indiv")+"</li>"
     txt(2795) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_son.indmemdiff.png","Bias")+"</li>"
     txt(2797) = "</ul></div></td>"
  else
     txt(2797) = "SON</td>"
  end if

  txt(2800) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_trends_ndjfma.indmem.png")) then
     txt(2801) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_trends_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_trends_ndjfma"+quote+">NDJFMA</a>"
     txt(2802) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_trends_ndjfma"+quote+">"
     txt(2803) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2804) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_ndjfma.indmem.png","Indiv")+"</li>"
     txt(2805) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(2807) = "</ul></div></td>"
  else
     txt(2807) = "NDJFMA</td>"
  end if

  txt(2810) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_trends_mjjaso.indmem.png")) then
     txt(2811) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_trends_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_trends_mjjaso"+quote+">MJJASO</a>"
     txt(2812) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_trends_mjjaso"+quote+">"
     txt(2813) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2814) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_mjjaso.indmem.png","Indiv")+"</li>"
     txt(2815) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(2817) = "</ul></div></td>"
  else
     txt(2817) = "MJJASO</td>"
  end if

  txt(2820) = "<td class="+quote+"col"+quote+">"
  if (isfilepresent2(OUTDIR+"siconc_sh_trends_ann.indmem.png")) then
     txt(2821) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#siconc_sh_trends_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"siconc_sh_trends_ann"+quote+">ANN</a>" 
     txt(2822) = "<div class="+quote+"collapse"+quote+" id="+quote+"siconc_sh_trends_ann"+quote+">"
     txt(2823) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(2824) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_ann.indmem.png","Indiv")+"</li>"
     txt(2825) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"siconc_sh_trends_ann.indmemdiff.png","Bias")+"</li>"
     txt(2827) = "</ul></div></td>"
  else
     txt(2827) = "ANN</td>"
  end if
  txt(2828) = "</tr>"
  txt(2830) = "</table></div></div>"


  txt(4100) = "<div class="+quote+"row"+quote+">"
  txt(4101) = "<div class="+quote+"col"+quote+">"
  txt(4102) = "<table class="+quote+"table table-bordered"+quote+">"
  txt(4103) = "<h3 class="+quote+"display-6"+quote+">Coupled Modes of Variability</h3>"
  txt(4104) = "<tr>"
  txt(4105) = "<td rowspan=7><b>ENSO</b></td>"
  
  txt(4190) = "<td rowspan=4>Spatial Composites</td>"
  txt(4191) = "<td>El Ni&ntilde;o - La Ni&ntilde;a<br>SST/TAS/PSL<br>"
  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.indmem.jja0.png")) then
     txt(4201) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_jja0"+quote+">JJA<sup>0</sup></a> " 
     txt(4202) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_jja0"+quote+">"
     txt(4203) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4204) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.indmem.jja0.png","Indiv")+"</li>"
     txt(4205) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.indmemdiff.jja0.png","Bias")+"</li>"
     txt(4207) = "</ul></div>"
  else
     txt(4207) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.indmem.son0.png")) then
     txt(4211) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_son0"+quote+">SON<sup>0</sup></a> " 
     txt(4212) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_son0"+quote+">"
     txt(4213) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4214) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.indmem.son0.png","Indiv")+"</li>"
     txt(4215) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.indmemdiff.son0.png","Bias")+"</li>"
     txt(4217) = "</ul></div>"
  else
     txt(4217) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.indmem.djf1.png")) then
     txt(4221) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_djf1"+quote+">DJF<sup>1</sup></a> " 
     txt(4222) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_djf1"+quote+">"
     txt(4223) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4224) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.indmem.djf1.png","Indiv")+"</li>"
     txt(4225) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.indmemdiff.djf1.png","Bias")+"</li>"
     txt(4227) = "</ul></div>"
  else
     txt(4227) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.indmem.mam1.png")) then
     txt(4231) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nnino34_spatialcomp_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_mam1"+quote+">MAM<sup>1</sup></a> " 
     txt(4232) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_mam1"+quote+">"
     txt(4233) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4234) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.indmem.mam1.png","Indiv")+"</li>"
     txt(4235) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.indmemdiff.mam1.png","Bias")+"</li>"
     txt(4237) = "</ul></div></td>"
  else
     txt(4237) = " MAM<sup>1</sup></td>"
  end if

  txt(4250) = "<td>El Ni&ntilde;o - La Ni&ntilde;a<br>PR<br>"
  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.pr.indmem.jja0.png")) then
     txt(4251) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_pr_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_pr_jja0"+quote+">JJA<sup>0</sup></a> " 
     txt(4252) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_pr_jja0"+quote+">"
     txt(4253) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4254) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.pr.indmem.jja0.png","Indiv")+"</li>"
     txt(4255) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.pr.indmemdiff.jja0.png","Bias")+"</li>"
     txt(4257) = "</ul></div>"
  else
     txt(4257) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.pr.indmem.son0.png")) then
     txt(4261) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_pr_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_pr_son0"+quote+">SON<sup>0</sup></a> " 
     txt(4262) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_pr_son0"+quote+">"
     txt(4263) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4264) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.pr.indmem.son0.png","Indiv")+"</li>"
     txt(4265) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.pr.indmemdiff.son0.png","Bias")+"</li>"
     txt(4267) = "</ul></div>"
  else
     txt(4267) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.pr.indmem.djf1.png")) then
     txt(4271) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_pr_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_pr_djf1"+quote+">DJF<sup>1</sup></a> " 
     txt(4272) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_pr_djf1"+quote+">"
     txt(4273) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4274) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.pr.indmem.djf1.png","Indiv")+"</li>"
     txt(4275) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.pr.indmemdiff.djf1.png","Bias")+"</li>"
     txt(4277) = "</ul></div>"
  else
     txt(4277) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.pr.indmem.mam1.png")) then
     txt(4281) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_pr_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_pr_mam1"+quote+">MAM<sup>1</sup></a> " 
     txt(4282) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_pr_mam1"+quote+">"
     txt(4283) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4284) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.pr.indmem.mam1.png","Indiv")+"</li>"
     txt(4285) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.pr.indmemdiff.mam1.png","Bias")+"</li>"
     txt(4287) = "</ul></div></td></tr>"
  else
     txt(4287) = " MAM<sup>1</sup></td></tr>"
  end if

  txt(4291) = "<tr><td>El Ni&ntilde;o SST/TAS/PSL<br>"
  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.elnino.indmem.jja0.png")) then
     txt(4301) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_elnino_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_elnino_jja0"+quote+">JJA<sup>0</sup></a> " 
     txt(4302) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_elnino_jja0"+quote+">"
     txt(4303) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4304) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.indmem.jja0.png","Indiv")+"</li>"
     txt(4305) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.indmemdiff.jja0.png","Bias")+"</li>"
     txt(4307) = "</ul></div>"
  else
     txt(4307) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.elnino.indmem.son0.png")) then
     txt(4311) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_elnino_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_elnino_son0"+quote+">SON<sup>0</sup></a> " 
     txt(4312) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_elnino_son0"+quote+">"
     txt(4313) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4314) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.indmem.son0.png","Indiv")+"</li>"
     txt(4315) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.indmemdiff.son0.png","Bias")+"</li>"
     txt(4317) = "</ul></div>"
  else
     txt(4317) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.elnino.indmem.djf1.png")) then
     txt(4321) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_elnino_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_elnino_djf1"+quote+">DJF<sup>1</sup></a> " 
     txt(4322) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_elnino_djf1"+quote+">"
     txt(4323) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4324) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.indmem.djf1.png","Indiv")+"</li>"
     txt(4325) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.indmemdiff.djf1.png","Bias")+"</li>"
     txt(4327) = "</ul></div>"
  else
     txt(4327) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.elnino.indmem.mam1.png")) then
     txt(4331) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_elnino_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_elnino_mam1"+quote+">MAM<sup>1</sup></a> " 
     txt(4332) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_elnino_mam1"+quote+">"
     txt(4333) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4334) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.indmem.mam1.png","Indiv")+"</li>"
     txt(4335) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.indmemdiff.mam1.png","Bias")+"</li>"
     txt(4337) = "</ul></div></td>"
  else
     txt(4337) = " MAM<sup>1</sup></td>"
  end if

  txt(4350) = "<td>El Ni&ntilde;o PR<br>"
  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.elnino.pr.indmem.jja0.png")) then
     txt(4351) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_elnino_pr_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_elnino_pr_jja0"+quote+">JJA<sup>0</sup></a> " 
     txt(4352) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_elnino_pr_jja0"+quote+">"
     txt(4353) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4354) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.pr.indmem.jja0.png","Indiv")+"</li>"
     txt(4355) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.pr.indmemdiff.jja0.png","Bias")+"</li>"
     txt(4357) = "</ul></div>"
  else
     txt(4357) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.elnino.pr.indmem.son0.png")) then
     txt(4361) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_elnino_pr_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_elnino_pr_son0"+quote+">SON<sup>0</sup></a> " 
     txt(4362) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_elnino_pr_son0"+quote+">"
     txt(4363) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4364) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.pr.indmem.son0.png","Indiv")+"</li>"
     txt(4365) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.pr.indmemdiff.son0.png","Bias")+"</li>"
     txt(4367) = "</ul></div>"
  else
     txt(4367) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.elnino.pr.indmem.djf1.png")) then
     txt(4371) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_elnino_pr_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_elnino_pr_djf1"+quote+">DJF<sup>1</sup></a> " 
     txt(4372) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_elnino_pr_djf1"+quote+">"
     txt(4373) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4374) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.pr.indmem.djf1.png","Indiv")+"</li>"
     txt(4375) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.pr.indmemdiff.djf1.png","Bias")+"</li>"
     txt(4377) = "</ul></div>"
  else
     txt(4377) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.elnino.pr.indmem.mam1.png")) then
     txt(4381) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_elnino_pr_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_elnino_pr_mam1"+quote+">MAM<sup>1</sup></a> " 
     txt(4382) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_elnino_pr_mam1"+quote+">"
     txt(4383) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4384) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.pr.indmem.mam1.png","Indiv")+"</li>"
     txt(4385) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.elnino.pr.indmemdiff.mam1.png","Bias")+"</li>"
     txt(4387) = "</ul></div></td></tr>"
  else
     txt(4387) = " MAM<sup>1</sup></td></tr>"
  end if


  txt(4391) = "<tr><td>La Ni&ntilde;a SST/TAS/PSL<br>"
  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.lanina.indmem.jja0.png")) then
     txt(4401) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_lanina_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_lanina_jja0"+quote+">JJA<sup>0</sup></a> " 
     txt(4402) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_lanina_jja0"+quote+">"
     txt(4403) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4404) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.indmem.jja0.png","Indiv")+"</li>"
     txt(4405) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.indmemdiff.jja0.png","Bias")+"</li>"
     txt(4407) = "</ul></div>"
  else
     txt(4407) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.lanina.indmem.son0.png")) then
     txt(4411) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_lanina_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_lanina_son0"+quote+">SON<sup>0</sup></a> " 
     txt(4412) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_lanina_son0"+quote+">"
     txt(4413) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4414) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.indmem.son0.png","Indiv")+"</li>"
     txt(4415) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.indmemdiff.son0.png","Bias")+"</li>"
     txt(4417) = "</ul></div>"
  else
     txt(4417) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.lanina.indmem.djf1.png")) then
     txt(4421) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_lanina_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_lanina_djf1"+quote+">DJF<sup>1</sup></a> " 
     txt(4422) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_lanina_djf1"+quote+">"
     txt(4423) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4424) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.indmem.djf1.png","Indiv")+"</li>"
     txt(4425) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.indmemdiff.djf1.png","Bias")+"</li>"
     txt(4427) = "</ul></div>"
  else
     txt(4427) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.lanina.indmem.mam1.png")) then
     txt(4431) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_lanina_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_lanina_mam1"+quote+">MAM<sup>1</sup></a> " 
     txt(4432) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_lanina_mam1"+quote+">"
     txt(4433) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4434) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.indmem.mam1.png","Indiv")+"</li>"
     txt(4435) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.indmemdiff.mam1.png","Bias")+"</li>"
     txt(4437) = "</ul></div></td>"
  else
     txt(4437) = " MAM<sup>1</sup></td>"
  end if

  txt(4450) = "<td>La Ni&ntilde;a PR<br>"
  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.lanina.pr.indmem.jja0.png")) then
     txt(4451) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_lanina_pr_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_lanina_pr_jja0"+quote+">JJA<sup>0</sup></a> " 
     txt(4452) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_lanina_pr_jja0"+quote+">"
     txt(4453) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4454) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.pr.indmem.jja0.png","Indiv")+"</li>"
     txt(4455) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.pr.indmemdiff.jja0.png","Bias")+"</li>"
     txt(4457) = "</ul></div>"
  else
     txt(4457) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.lanina.pr.indmem.son0.png")) then
     txt(4461) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_lanina_pr_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_lanina_pr_son0"+quote+">SON<sup>0</sup></a> " 
     txt(4462) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_lanina_pr_son0"+quote+">"
     txt(4463) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4464) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.pr.indmem.son0.png","Indiv")+"</li>"
     txt(4465) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.pr.indmemdiff.son0.png","Bias")+"</li>"
     txt(4467) = "</ul></div>"
  else
     txt(4467) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.lanina.pr.indmem.djf1.png")) then
     txt(4471) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_lanina_pr_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_lanina_pr_djf1"+quote+">DJF<sup>1</sup></a> " 
     txt(4472) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_lanina_pr_djf1"+quote+">"
     txt(4473) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4474) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.pr.indmem.djf1.png","Indiv")+"</li>"
     txt(4475) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.pr.indmemdiff.djf1.png","Bias")+"</li>"
     txt(4477) = "</ul></div>"
  else
     txt(4477) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"nino34.spatialcomp.lanina.pr.indmem.mam1.png")) then
     txt(4481) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_spatialcomp_lanina_pr_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_spatialcomp_lanina_pr_mam1"+quote+">MAM<sup>1</sup></a> " 
     txt(4482) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_spatialcomp_lanina_pr_mam1"+quote+">"
     txt(4483) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4484) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.pr.indmem.mam1.png","Indiv")+"</li>"
     txt(4485) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.spatialcomp.lanina.pr.indmemdiff.mam1.png","Bias")+"</li>"
     txt(4487) = "</ul></div></td></tr>"
  else
     txt(4487) = " MAM<sup>1</sup></td></tr>"
  end if



  txt(4490) = "<tr>"
  txt(4500) = "<td>"
  if (isfilepresent2(OUTDIR+"nino34.hov.elnino.indmem.png")) then
     txt(4501) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_hov_elnino"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_hov_elnino"+quote+">El Ni&ntilde;o Hovm&ouml;ller</a> " 
     txt(4502) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_hov_elnino"+quote+">"
     txt(4503) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4504) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.hov.elnino.indmem.png","Indiv")+"</li>"
     txt(4505) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.hov.elnino.indmemdiff.png","Bias")+"</li>"
     txt(4507) = "</ul></div></td>"
  else
     txt(4507) = "El Ni&ntilde;o Hovm&ouml;ller</td>"
  end if
  txt(4510) = "<td>"
  if (isfilepresent2(OUTDIR+"nino34.hov.lanina.indmem.png")) then
     txt(4511) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_hov_lanina"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_hov_lanina"+quote+">La Ni&ntilde;a Hovm&ouml;ller</a> " 
     txt(4512) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_hov_lanina"+quote+">"
     txt(4513) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4514) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.hov.lanina.indmem.png","Indiv")+"</li>"
     txt(4515) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.hov.lanina.indmemdiff.png","Bias")+"</li>"
     txt(4517) = "</ul></div></td></tr>"
  else
     txt(4517) = "La Ni&ntilde;a Hovm&ouml;ller</td></tr>"
  end if

  txt(4519) = "<tr>"
  txt(4600) = "<td rowspan=3>Ni&ntilde;o3.4</td>"
  txt(4601) = "<td>"+table_link_setup(OUTDIR,"nino34.timeseries.indmem.png","Timeseries")+"</td>"
  txt(4610) = "<td>"+table_link_setup(OUTDIR,"nino34.monstddev.indmem.png","Monthly Std. Dev.")+"</td></tr>"
  txt(4611) = "<tr><td>"+table_link_setup(OUTDIR,"nino34.powspec.indmem.png","Power Spectra")+"</td>"
  txt(4612) = "<td>"
  if (isfilepresent2(OUTDIR+"nino34.wavelet.indmem.png")) then
     txt(4613) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nino34_wavelet"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nino34_wavelet"+quote+">Wavelet</a> " 
     txt(4614) = "<div class="+quote+"collapse"+quote+" id="+quote+"nino34_wavelet"+quote+">"
     txt(4615) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(4616) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.wavelet.indmem.png","Indiv")+"</li>"
     txt(4617) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nino34.wavelet.indmemdiff.png","Bias")+"</li>"
     txt(4618) = "</ul></div>"
  else
     txt(4613) = "Wavelet"
  end if
  txt(4619) = "</td></tr>" 
  txt(4620) = "<tr><td>"+table_link_setup(OUTDIR,"nino34.autocor.indmem.png","Autocorrelation")+"</td>"
  txt(4621) = "<td>"+table_link_setup(OUTDIR,"nino34_runstddev.timeseries.indmem.png","Running Standard Deviation")+"</td></tr>"

  txt(5196) = "<tr>"
  txt(5197) = "<td rowspan=2><b>AMV</b></td>"
  txt(5198) = "<td>Regr: "
  if (isfilepresent2(OUTDIR+"amv.indmem.png")) then
     txt(5199) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amo"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amo"+quote+">SST</a> " 
     txt(5200) = "<div class="+quote+"collapse"+quote+" id="+quote+"amo"+quote+">"
     txt(5201) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5202) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.indmem.png","Indiv")+"</li>"
     txt(5203) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.indmemdiff.png","Bias")+"</li>"
     txt(5205) = "</ul></div>"
  else
     txt(5205) = "SST "
  end if
  if (isfilepresent2(OUTDIR+"amv.tassstreg.indmem.png")) then
     txt(5210) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_tassstreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_tassstreg"+quote+">TAS</a> " 
     txt(5211) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_tassstreg"+quote+">"
     txt(5212) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5213) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.tassstreg.indmem.png","Indiv")+"</li>"
     txt(5214) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.tassstreg.indmemdiff.png","Bias")+"</li>"
     txt(5216) = "</ul></div>"
  else
     txt(5210) = "TAS "
  end if
  if (isfilepresent2(OUTDIR+"amv.prreg.indmem.png")) then
     txt(5220) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_prreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_prreg"+quote+">PR</a> " 
     txt(5221) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_prreg"+quote+">"
     txt(5222) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5223) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.prreg.indmem.png","Indiv")+"</li>"
     txt(5224) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.prreg.indmemdiff.png","Bias")+"</li>"
     txt(5226) = "</ul></div></td>"
  else
     txt(5220) = "PR</td>"
  end if

  txt(5250) = "<td>"+table_link_setup(OUTDIR,"amv_timeseries_mon.indmem.png","Timeseries")+"</td>"
  txt(5251) = "<td rowspan=2>"+table_link_setup(OUTDIR,"amv.powspec.indmem.png","Power Spectra")+"</td></tr>"

  txt(5268) = "<tr><td>Regr LP: "
  if (isfilepresent2(OUTDIR+"amv.lp.indmem.png")) then
     txt(5269) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_lp"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_lp"+quote+">SST</a> " 
     txt(5270) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_lp"+quote+">"
     txt(5271) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5272) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.indmem.png","Indiv")+"</li>"
     txt(5273) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.indmemdiff.png","Bias")+"</li>"
     txt(5275) = "</ul></div>"
  else
     txt(5275) = "SST "
  end if
  if (isfilepresent2(OUTDIR+"amv.lp.tassstreg.indmem.png")) then
     txt(5280) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_lp_tassstreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_lp_tassstreg"+quote+">TAS</a> " 
     txt(5281) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_lp_tassstreg"+quote+">"
     txt(5282) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5283) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.tassstreg.indmem.png","Indiv")+"</li>"
     txt(5284) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.tassstreg.indmemdiff.png","Bias")+"</li>"
     txt(5286) = "</ul></div>"
  else
     txt(5280) = "TAS "
  end if
  if (isfilepresent2(OUTDIR+"amv.lp.prreg.indmem.png")) then
     txt(5290) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_lp_prreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_lp_prreg"+quote+">PR</a> " 
     txt(5291) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_lp_prreg"+quote+">"
     txt(5292) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5293) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.prreg.indmem.png","Indiv")+"</li>"
     txt(5294) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.prreg.indmemdiff.png","Bias")+"</li>"
     txt(5296) = "</ul></div></td></tr>"
  else
     txt(5290) = "PR</td>"
  end if
  txt(5296) = "<td>"+table_link_setup(OUTDIR,"amv_timeseries_lowpass_mon.indmem.png","Timeseries")+"</td></tr>"

  txt(5297) = "<tr><td rowspan=2><b>AMV'</b></td>"
  txt(5298) = "<td>Regr: "
  if (isfilepresent2(OUTDIR+"amv.prime.indmem.png")) then
     txt(5299) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_prime"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_prime"+quote+">SST</a> " 
     txt(5300) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_prime"+quote+">"
     txt(5301) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5302) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.prime.indmem.png","Indiv")+"</li>"
     txt(5303) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.prime.indmemdiff.png","Bias")+"</li>"
     txt(5305) = "</ul></div>"
  else
     txt(5305) = "SST "
  end if
  if (isfilepresent2(OUTDIR+"amv.prime.tassstreg.indmem.png")) then
     txt(5310) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_prime_tassstreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_prime_tassstreg"+quote+">TAS</a> " 
     txt(5311) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_prime_tassstreg"+quote+">"
     txt(5312) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5313) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.prime.tassstreg.indmem.png","Indiv")+"</li>"
     txt(5314) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.prime.tassstreg.indmemdiff.png","Bias")+"</li>"
     txt(5316) = "</ul></div>"
  else
     txt(5310) = "TAS "
  end if
  if (isfilepresent2(OUTDIR+"amv.prime.prreg.indmem.png")) then
     txt(5320) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_prime_prreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_prime_prreg"+quote+">PR</a> " 
     txt(5321) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_prime_prreg"+quote+">"
     txt(5322) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5323) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.prime.prreg.indmem.png","Indiv")+"</li>"
     txt(5324) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.prime.prreg.indmemdiff.png","Bias")+"</li>"
     txt(5326) = "</ul></div></td>"
  else
     txt(5320) = "PR</td>"
  end if

  txt(5350) = "<td>"+table_link_setup(OUTDIR,"amv_prime_timeseries_mon.indmem.png","Timeseries")+"</td>"
  txt(5351) = "<td rowspan=2>"+table_link_setup(OUTDIR,"amv.prime.powspec.indmem.png","Power Spectra")+"</td></tr>"


  txt(5368) = "<tr><td>Regr LP: "
  if (isfilepresent2(OUTDIR+"amv.lp.prime.indmem.png")) then
     txt(5369) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_lp_prime"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_lp_prime"+quote+">SST</a> " 
     txt(5370) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_lp_prime"+quote+">"
     txt(5371) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5372) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.prime.indmem.png","Indiv")+"</li>"
     txt(5373) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.prime.indmemdiff.png","Bias")+"</li>"
     txt(5375) = "</ul></div>"
  else
     txt(5375) = "SST "
  end if
  if (isfilepresent2(OUTDIR+"amv.lp.prime.tassstreg.indmem.png")) then
     txt(5380) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_lp_prime_tassstreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_lp_prime_tassstreg"+quote+">TAS</a> " 
     txt(5381) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_lp_prime_tassstreg"+quote+">"
     txt(5382) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5383) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.prime.tassstreg.indmem.png","Indiv")+"</li>"
     txt(5384) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.prime.tassstreg.indmemdiff.png","Bias")+"</li>"
     txt(5386) = "</ul></div>"
  else
     txt(5380) = "TAS "
  end if
  if (isfilepresent2(OUTDIR+"amv.lp.prime.prreg.indmem.png")) then
     txt(5390) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amv_lp_prime_prreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amv_lp_prime_prreg"+quote+">PR</a> " 
     txt(5391) = "<div class="+quote+"collapse"+quote+" id="+quote+"amv_lp_prime_prreg"+quote+">"
     txt(5392) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5393) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.prime.prreg.indmem.png","Indiv")+"</li>"
     txt(5394) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amv.lp.prime.prreg.indmemdiff.png","Bias")+"</li>"
     txt(5396) = "</ul></div></td>"
  else
     txt(5390) = "PR</td>"
  end if
  txt(5397) = "<td>"+table_link_setup(OUTDIR,"amv_prime_timeseries_lowpass_mon.indmem.png","Timeseries")+"</td></tr>"


  txt(5496) = "<tr>"
  txt(5497) = "<td><b>PDV</b></td>"
  txt(5498) = "<td>Regr: "
  if (isfilepresent2(OUTDIR+"pdv.indmem.png")) then
     txt(5499) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pdo"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pdo"+quote+">SST</a> " 
     txt(5500) = "<div class="+quote+"collapse"+quote+" id="+quote+"pdo"+quote+">"
     txt(5501) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5502) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.indmem.png","Indiv")+"</li>"
     txt(5503) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.indmemdiff.png","Bias")+"</li>"
     txt(5505) = "</ul></div>"
  else
     txt(5505) = "SST "
  end if
  if (isfilepresent2(OUTDIR+"pdv.tassstreg.indmem.png")) then
     txt(5510) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pdv_tassstreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pdv_tassstreg"+quote+">TAS</a> " 
     txt(5511) = "<div class="+quote+"collapse"+quote+" id="+quote+"pdv_tassstreg"+quote+">"
     txt(5512) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5513) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.tassstreg.indmem.png","Indiv")+"</li>"
     txt(5514) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.tassstreg.indmemdiff.png","Bias")+"</li>"
     txt(5516) = "</ul></div>"
  else
     txt(5510) = "TAS "
  end if
  if (isfilepresent2(OUTDIR+"pdv.prreg.indmem.png")) then
     txt(5520) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pdv_prreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pdv_prreg"+quote+">PR</a> " 
     txt(5521) = "<div class="+quote+"collapse"+quote+" id="+quote+"pdv_prreg"+quote+">"
     txt(5522) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5523) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.prreg.indmem.png","Indiv")+"</li>"
     txt(5524) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.prreg.indmemdiff.png","Bias")+"</li>"
     txt(5526) = "</ul></div></td>"
  else
     txt(5520) = "PR</td>"
  end if

  txt(5550) = "<td>"+table_link_setup(OUTDIR,"pdv_timeseries_mon.indmem.png","Timeseries")+"</td>"
  txt(5551) = "<td>"+table_link_setup(OUTDIR,"pdv.powspec.indmem.png","Power Spectra")+"</td></tr>"

  txt(5596) = "<tr>"
  txt(5597) = "<td><b>PDV'</b></td>"
  txt(5598) = "<td>Regr: "
  if (isfilepresent2(OUTDIR+"pdv.prime.indmem.png")) then
     txt(5599) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pdv_prime"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pdv_prime"+quote+">SST</a> " 
     txt(5600) = "<div class="+quote+"collapse"+quote+" id="+quote+"pdv_prime"+quote+">"
     txt(5601) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5602) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.prime.indmem.png","Indiv")+"</li>"
     txt(5603) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.prime.indmemdiff.png","Bias")+"</li>"
     txt(5605) = "</ul></div>"
  else
     txt(5605) = "SST "
  end if
  if (isfilepresent2(OUTDIR+"pdv.prime.tassstreg.indmem.png")) then
     txt(5610) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pdv_prime_tassstreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pdv_prime_tassstreg"+quote+">TAS</a> " 
     txt(5611) = "<div class="+quote+"collapse"+quote+" id="+quote+"pdv_prime_tassstreg"+quote+">"
     txt(5612) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5613) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.prime.tassstreg.indmem.png","Indiv")+"</li>"
     txt(5614) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.prime.tassstreg.indmemdiff.png","Bias")+"</li>"
     txt(5616) = "</ul></div>"
  else
     txt(5610) = "TAS "
  end if
  if (isfilepresent2(OUTDIR+"pdv.prime.prreg.indmem.png")) then
     txt(5620) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pdv_prime_prreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pdv_prime_prreg"+quote+">PR</a> " 
     txt(5621) = "<div class="+quote+"collapse"+quote+" id="+quote+"pdv_prime_prreg"+quote+">"
     txt(5622) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5623) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.prime.prreg.indmem.png","Indiv")+"</li>"
     txt(5624) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pdv.prime.prreg.indmemdiff.png","Bias")+"</li>"
     txt(5626) = "</ul></div></td>"
  else
     txt(5620) = "PR</td>"
  end if
  txt(5650) = "<td>"+table_link_setup(OUTDIR,"pdv_prime_timeseries_mon.indmem.png","Timeseries")+"</td>"
  txt(5651) = "<td>"+table_link_setup(OUTDIR,"pdv.prime.powspec.indmem.png","Power Spectra")+"</td></tr>"

  txt(5696) = "<tr>"
  txt(5697) = "<td><b>TPDV</b></td>"
  txt(5698) = "<td>Regr: "
  if (isfilepresent2(OUTDIR+"tpdv.indmem.png")) then
     txt(5699) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tpdv"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tpdv"+quote+">SST</a> "
     txt(5700) = "<div class="+quote+"collapse"+quote+" id="+quote+"tpdv"+quote+">"
     txt(5701) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5702) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tpdv.indmem.png","Indiv")+"</li>"
     txt(5703) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tpdv.indmemdiff.png","Bias")+"</li>"
     txt(5705) = "</ul></div>"
  else
     txt(5705) = "SST "
  end if
  if (isfilepresent2(OUTDIR+"tpdv.tassstreg.indmem.png")) then
     txt(5710) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tpdv_tassstreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tpdv_tassstreg"+quote+">TAS</a> "
     txt(5711) = "<div class="+quote+"collapse"+quote+" id="+quote+"tpdv_tassstreg"+quote+">"
     txt(5712) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5713) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tpdv.tassstreg.indmem.png","Indiv")+"</li>"
     txt(5714) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tpdv.tassstreg.indmemdiff.png","Bias")+"</li>"
     txt(5716) = "</ul></div>"
  else
     txt(5710) = "TAS "
  end if
  if (isfilepresent2(OUTDIR+"tpdv.prreg.indmem.png")) then
     txt(5720) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#tpdv_prreg"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"tpdv_prreg"+quote+">PR</a> "
     txt(5721) = "<div class="+quote+"collapse"+quote+" id="+quote+"tpdv_prreg"+quote+">"
     txt(5722) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5723) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tpdv.prreg.indmem.png","Indiv")+"</li>"
     txt(5724) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"tpdv.prreg.indmemdiff.png","Bias")+"</li>"
     txt(5726) = "</ul></div></td>"
  else
     txt(5720) = "PR</td>"
  end if
  txt(5750) = "<td>"+table_link_setup(OUTDIR,"tpdv_timeseries_mon.indmem.png","Timeseries")+"</td>"
  txt(5751) = "<td>"+table_link_setup(OUTDIR,"tpdv.powspec.indmem.png","Power Spectra")+"</td></tr>"

  txt(5800) = "<tr><td rowspan=3><b>AMOC</b></td><td>"
  if (isfilepresent2(OUTDIR+"amoc.mean.ann.indmem.png")) then
     txt(5801) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amoc_mean_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amoc_mean_ann"+quote+">Means</a> " 
     txt(5802) = "<div class="+quote+"collapse"+quote+" id="+quote+"amoc_mean_ann"+quote+">"
     txt(5803) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5804) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amoc.mean.ann.indmem.png","Indiv")+"</li>"
     txt(5805) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amoc.mean.ann.indmemdiff.png","Bias")+"</li>"
     txt(5806) = "</ul></div></td>"
  else
     txt(5801) = "Means</td>"
  end if

  txt(5810) = "<td>"
  if (isfilepresent2(OUTDIR+"amoc.stddev.ann.indmem.png")) then
     txt(5811) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amoc_stddev_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amoc_stddev_ann"+quote+">Standard Deviations</a> " 
     txt(5812) = "<div class="+quote+"collapse"+quote+" id="+quote+"amoc_stddev_ann"+quote+">"
     txt(5813) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5814) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amoc.stddev.ann.indmem.png","Indiv")+"</li>"
     txt(5815) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amoc.stddev.ann.indmemdiff.png","Bias")+"</li>"
     txt(5816) = "</ul></div></td>"
  else
     txt(5811) = "Standard Deviations</td>"
  end if

  txt(5820) = "<td>"
  if (isfilepresent2(OUTDIR+"amoc.pattern.ann.indmem.png")) then
     txt(5821) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amoc_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amoc_pattern_ann"+quote+">Patterns</a> " 
     txt(5822) = "<div class="+quote+"collapse"+quote+" id="+quote+"amoc_pattern_ann"+quote+">"
     txt(5823) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5824) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amoc.pattern.ann.indmem.png","Indiv")+"</li>"
     txt(5825) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amoc.pattern.ann.indmemdiff.png","Bias")+"</li>"
     txt(5826) = "</ul></div></td>"
  else
     txt(5821) = "Patterns</td></tr>"
  end if

  txt(5830) = "<tr><td>"+table_link_setup(OUTDIR,"amoc.timeseries.ann.indmem.png","Timeseries")+"</td><td colspan=2>"
  if (isfilepresent2(OUTDIR+"amoc.tassstreg.ann.indmem.png")) then
     txt(5831) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#amoc_tassstreg_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"amoc_tassstreg_ann"+quote+">SST/TAS Regressions</a> " 
     txt(5832) = "<div class="+quote+"collapse"+quote+" id="+quote+"amoc_tassstreg_ann"+quote+">"
     txt(5833) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5834) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amoc.tassstreg.ann.indmem.png","Indiv")+"</li>"
     txt(5835) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"amoc.tassstreg.ann.indmemdiff.png","Bias")+"</li>"
     txt(5836) = "</ul></div></td>"
  else
     txt(5831) = "SST/TAS Regressions</td></tr>"
  end if
  txt(5840) = "<tr><td>"+table_link_setup(OUTDIR,"amoc.powspec.indmem.png","Spectra")+"</td>"
  txt(5841) = "<td colspan=2>"+table_link_setup(OUTDIR,"amoc_amv.leadlag.ann.indmem.png","AMV/AMOC Lag Correlations")+"</td></tr>"
  txt(5899) = "</table></div></div>"


  txt(5900) = "<div class="+quote+"row"+quote+">"
  txt(5901) = "<div class="+quote+"col"+quote+">"
  txt(5902) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(5903) = "<h3 class="+quote+"display-6"+quote+">Atmospheric Modes of Variability</h3>"

  txt(5909) = "<tr><td rowspan=2><b>SO</b></td>"
  txt(5910) = "<td>Patterns</td><td>"
  if (isfilepresent2(OUTDIR+"so_pattern_djf.indmem.png")) then
     txt(5911) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#so_pattern_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"so_pattern_djf"+quote+">DJF</a>" 
     txt(5912) = "<div class="+quote+"collapse"+quote+" id="+quote+"so_pattern_djf"+quote+">"
     txt(5913) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5914) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_djf.indmem.png","Indiv")+"</li>"
     txt(5915) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_djf.indmemdiff.png","Bias")+"</li>"
     txt(5917) = "</ul></div></td>"
  else
     txt(5917) = "DJF</td>"
  end if

  txt(5920) = "<td>"
  if (isfilepresent2(OUTDIR+"so_pattern_jfm.indmem.png")) then
     txt(5921) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#so_pattern_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"so_pattern_jfm"+quote+">JFM</a>" 
     txt(5922) = "<div class="+quote+"collapse"+quote+" id="+quote+"so_pattern_jfm"+quote+">"
     txt(5923) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5924) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_jfm.indmem.png","Indiv")+"</li>"
     txt(5925) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_jfm.indmemdiff.png","Bias")+"</li>"
     txt(5927) = "</ul></div></td>"
  else
     txt(5927) = "JFM</td>"
  end if

  txt(5930) = "<td>"
  if (isfilepresent2(OUTDIR+"so_pattern_mam.indmem.png")) then
     txt(5931) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#so_pattern_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"so_pattern_mam"+quote+">MAM</a>" 
     txt(5932) = "<div class="+quote+"collapse"+quote+" id="+quote+"so_pattern_mam"+quote+">"
     txt(5933) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5934) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_mam.indmem.png","Indiv")+"</li>"
     txt(5935) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_mam.indmemdiff.png","Bias")+"</li>"
     txt(5937) = "</ul></div></td>"
  else
     txt(5937) = "MAM</td>"
  end if

  txt(5940) = "<td>"
  if (isfilepresent2(OUTDIR+"so_pattern_jja.indmem.png")) then
     txt(5941) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#so_pattern_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"so_pattern_jja"+quote+">JJA</a>" 
     txt(5942) = "<div class="+quote+"collapse"+quote+" id="+quote+"so_pattern_jja"+quote+">"
     txt(5943) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5944) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_jja.indmem.png","Indiv")+"</li>"
     txt(5945) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_jja.indmemdiff.png","Bias")+"</li>"
     txt(5947) = "</ul></div></td>"
  else
     txt(5947) = "JJA</td>"
  end if

  txt(5950) = "<td>"
  if (isfilepresent2(OUTDIR+"so_pattern_jas.indmem.png")) then
     txt(5951) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#so_pattern_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"so_pattern_jas"+quote+">JAS</a>" 
     txt(5952) = "<div class="+quote+"collapse"+quote+" id="+quote+"so_pattern_jas"+quote+">"
     txt(5953) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5954) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_jas.indmem.png","Indiv")+"</li>"
     txt(5955) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_jas.indmemdiff.png","Bias")+"</li>"
     txt(5957) = "</ul></div></td>"
  else
     txt(5957) = "JAS</td>"
  end if

  txt(5960) = "<td>"
  if (isfilepresent2(OUTDIR+"so_pattern_son.indmem.png")) then
     txt(5961) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#so_pattern_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"so_pattern_son"+quote+">SON</a>" 
     txt(5962) = "<div class="+quote+"collapse"+quote+" id="+quote+"so_pattern_son"+quote+">"
     txt(5963) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5964) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_son.indmem.png","Indiv")+"</li>"
     txt(5965) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_son.indmemdiff.png","Bias")+"</li>"
     txt(5967) = "</ul></div></td>"
  else
     txt(5967) = "SON</td>"
  end if

  txt(5970) = "<td>"
  if (isfilepresent2(OUTDIR+"so_pattern_ndjfma.indmem.png")) then
     txt(5971) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#so_pattern_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"so_pattern_ndjfma"+quote+">NDJFMA</a>"
     txt(5972) = "<div class="+quote+"collapse"+quote+" id="+quote+"so_pattern_ndjfma"+quote+">"
     txt(5973) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5974) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_ndjfma.indmem.png","Indiv")+"</li>"
     txt(5975) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(5977) = "</ul></div></td>"
  else
     txt(5977) = "NDJFMA</td>"
  end if

  txt(5980) = "<td>"
  if (isfilepresent2(OUTDIR+"so_pattern_mjjaso.indmem.png")) then
     txt(5981) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#so_pattern_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"so_pattern_mjjaso"+quote+">MJJASO</a>"
     txt(5982) = "<div class="+quote+"collapse"+quote+" id="+quote+"so_pattern_mjjaso"+quote+">"
     txt(5983) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5984) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_mjjaso.indmem.png","Indiv")+"</li>"
     txt(5985) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(5987) = "</ul></div></td>"
  else
     txt(5987) = "MJJASO</td>"
  end if

  txt(5990) = "<td>"
  if (isfilepresent2(OUTDIR+"so_pattern_ann.indmem.png")) then
     txt(5991) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#so_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"so_pattern_ann"+quote+">ANN</a>" 
     txt(5992) = "<div class="+quote+"collapse"+quote+" id="+quote+"so_pattern_ann"+quote+">"
     txt(5993) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(5994) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_ann.indmem.png","Indiv")+"</li>"
     txt(5995) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"so_pattern_ann.indmemdiff.png","Bias")+"</li>"
     txt(5997) = "</ul></div></td></tr>"
  else
     txt(5997) = "ANN</td></tr>"
  end if
  txt(6001) = "<tr><td>Timeseries</td>"
  txt(6002) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_djf.indmem.png","DJF")+"</td>"
  txt(6003) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_jfm.indmem.png","JFM")+"</td>"
  txt(6004) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_mam.indmem.png","MAM")+"</td>"
  txt(6005) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_jja.indmem.png","JJA")+"</td>"
  txt(6006) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_jas.indmem.png","JAS")+"</td>"
  txt(6007) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_son.indmem.png","SON")+"</td>"
  txt(6008) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(6009) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(6010) = "<td>"+table_link_setup(OUTDIR,"so_timeseries_ann.indmem.png","ANN")+"</td></tr>"

  txt(6031) = "<tr><td rowspan=2><b>NAM</b></td>"
  txt(6032) = "<td>Patterns</td><td>"
  if (isfilepresent2(OUTDIR+"nam_pattern_djf.indmem.png")) then
     txt(6033) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nam_pattern_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nam_pattern_djf"+quote+">DJF</a>" 
     txt(6034) = "<div class="+quote+"collapse"+quote+" id="+quote+"nam_pattern_djf"+quote+">"
     txt(6035) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6036) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_djf.indmem.png","Indiv")+"</li>"
     txt(6037) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_djf.indmemdiff.png","Bias")+"</li>"
     txt(6038) = "</ul></div></td>"
  else
     txt(6039) = "DJF</td>"
  end if

  txt(6040) = "<td>"
  if (isfilepresent2(OUTDIR+"nam_pattern_jfm.indmem.png")) then
     txt(6041) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nam_pattern_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nam_pattern_jfm"+quote+">JFM</a>" 
     txt(6042) = "<div class="+quote+"collapse"+quote+" id="+quote+"nam_pattern_jfm"+quote+">"
     txt(6043) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6044) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_jfm.indmem.png","Indiv")+"</li>"
     txt(6045) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_jfm.indmemdiff.png","Bias")+"</li>"
     txt(6047) = "</ul></div></td>"
  else
     txt(6047) = "JFM</td>"
  end if

  txt(6050) = "<td>"
  if (isfilepresent2(OUTDIR+"nam_pattern_mam.indmem.png")) then
     txt(6051) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nam_pattern_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nam_pattern_mam"+quote+">MAM</a>" 
     txt(6052) = "<div class="+quote+"collapse"+quote+" id="+quote+"nam_pattern_mam"+quote+">"
     txt(6053) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6054) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_mam.indmem.png","Indiv")+"</li>"
     txt(6055) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_mam.indmemdiff.png","Bias")+"</li>"
     txt(6057) = "</ul></div></td>"
  else
     txt(6057) = "MAM</td>"
  end if

  txt(6060) = "<td>"
  if (isfilepresent2(OUTDIR+"nam_pattern_jja.indmem.png")) then
     txt(6061) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nam_pattern_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nam_pattern_jja"+quote+">JJA</a>" 
     txt(6062) = "<div class="+quote+"collapse"+quote+" id="+quote+"nam_pattern_jja"+quote+">"
     txt(6063) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6064) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_jja.indmem.png","Indiv")+"</li>"
     txt(6065) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_jja.indmemdiff.png","Bias")+"</li>"
     txt(6067) = "</ul></div></td>"
  else
     txt(6067) = "JJA</td>"
  end if

  txt(6070) = "<td>"
  if (isfilepresent2(OUTDIR+"nam_pattern_jas.indmem.png")) then
     txt(6071) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nam_pattern_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nam_pattern_jas"+quote+">JAS</a>" 
     txt(6072) = "<div class="+quote+"collapse"+quote+" id="+quote+"nam_pattern_jas"+quote+">"
     txt(6073) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6074) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_jas.indmem.png","Indiv")+"</li>"
     txt(6075) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_jas.indmemdiff.png","Bias")+"</li>"
     txt(6077) = "</ul></div></td>"
  else
     txt(6077) = "JAS</td>"
  end if

  txt(6080) = "<td>"
  if (isfilepresent2(OUTDIR+"nam_pattern_son.indmem.png")) then
     txt(6081) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nam_pattern_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nam_pattern_son"+quote+">SON</a>" 
     txt(6082) = "<div class="+quote+"collapse"+quote+" id="+quote+"nam_pattern_son"+quote+">"
     txt(6083) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6084) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_son.indmem.png","Indiv")+"</li>"
     txt(6085) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_son.indmemdiff.png","Bias")+"</li>"
     txt(6087) = "</ul></div></td>"
  else
     txt(6087) = "SON</td>"
  end if

  txt(6090) = "<td>"
  if (isfilepresent2(OUTDIR+"nam_pattern_ndjfma.indmem.png")) then
     txt(6091) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nam_pattern_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nam_pattern_ndjfma"+quote+">NDJFMA</a>"
     txt(6092) = "<div class="+quote+"collapse"+quote+" id="+quote+"nam_pattern_ndjfma"+quote+">"
     txt(6093) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6094) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_ndjfma.indmem.png","Indiv")+"</li>"
     txt(6095) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(6097) = "</ul></div></td>"
  else
     txt(6097) = "NDJFMA</td>"
  end if

  txt(6100) = "<td>"
  if (isfilepresent2(OUTDIR+"nam_pattern_mjjaso.indmem.png")) then
     txt(6101) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nam_pattern_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nam_pattern_mjjaso"+quote+">MJJASO</a>"
     txt(6102) = "<div class="+quote+"collapse"+quote+" id="+quote+"nam_pattern_mjjaso"+quote+">"
     txt(6103) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6104) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_mjjaso.indmem.png","Indiv")+"</li>"
     txt(6105) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(6107) = "</ul></div></td>"
  else
     txt(6107) = "MJJASO</td>"
  end if

  txt(6110) = "<td>"
  if (isfilepresent2(OUTDIR+"nam_pattern_ann.indmem.png")) then
     txt(6111) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nam_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nam_pattern_ann"+quote+">ANN</a>" 
     txt(6112) = "<div class="+quote+"collapse"+quote+" id="+quote+"nam_pattern_ann"+quote+">"
     txt(6113) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6114) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_ann.indmem.png","Indiv")+"</li>"
     txt(6115) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nam_pattern_ann.indmemdiff.png","Bias")+"</li>"
     txt(6117) = "</ul></div></td></tr>"
  else
     txt(6117) = "ANN</td></tr>"
  end if
  txt(6121) = "<tr><td>Timeseries</td>"
  txt(6122) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_djf.indmem.png","DJF")+"</td>"
  txt(6123) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_jfm.indmem.png","JFM")+"</td>"
  txt(6124) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_mam.indmem.png","MAM")+"</td>"
  txt(6125) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_jja.indmem.png","JJA")+"</td>"
  txt(6126) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_jas.indmem.png","JAS")+"</td>"
  txt(6127) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_son.indmem.png","SON")+"</td>"
  txt(6128) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(6129) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(6130) = "<td>"+table_link_setup(OUTDIR,"nam_timeseries_ann.indmem.png","ANN")+"</td></tr>"

  txt(6209) = "<tr><td rowspan=2><b>NAO</b></td>"
  txt(6210) = "<td>Patterns</td><td>"
  if (isfilepresent2(OUTDIR+"nao_pattern_djf.indmem.png")) then
     txt(6211) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nao_pattern_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nao_pattern_djf"+quote+">DJF</a>" 
     txt(6212) = "<div class="+quote+"collapse"+quote+" id="+quote+"nao_pattern_djf"+quote+">"
     txt(6213) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6214) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_djf.indmem.png","Indiv")+"</li>"
     txt(6215) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_djf.indmemdiff.png","Bias")+"</li>"
     txt(6217) = "</ul></div></td>"
  else
     txt(6217) = "DJF</td>"
  end if

  txt(6220) = "<td>"
  if (isfilepresent2(OUTDIR+"nao_pattern_jfm.indmem.png")) then
     txt(6221) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nao_pattern_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nao_pattern_jfm"+quote+">JFM</a>" 
     txt(6222) = "<div class="+quote+"collapse"+quote+" id="+quote+"nao_pattern_jfm"+quote+">"
     txt(6223) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6224) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_jfm.indmem.png","Indiv")+"</li>"
     txt(6225) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_jfm.indmemdiff.png","Bias")+"</li>"
     txt(6227) = "</ul></div></td>"
  else
     txt(6227) = "JFM</td>"
  end if

  txt(6230) = "<td>"
  if (isfilepresent2(OUTDIR+"nao_pattern_mam.indmem.png")) then
     txt(6231) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nao_pattern_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nao_pattern_mam"+quote+">MAM</a>" 
     txt(6232) = "<div class="+quote+"collapse"+quote+" id="+quote+"nao_pattern_mam"+quote+">"
     txt(6233) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6234) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_mam.indmem.png","Indiv")+"</li>"
     txt(6235) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_mam.indmemdiff.png","Bias")+"</li>"
     txt(6237) = "</ul></div></td>"
  else
     txt(6237) = "MAM</td>"
  end if

  txt(6240) = "<td>"
  if (isfilepresent2(OUTDIR+"nao_pattern_jja.indmem.png")) then
     txt(6241) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nao_pattern_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nao_pattern_jja"+quote+">JJA</a>" 
     txt(6242) = "<div class="+quote+"collapse"+quote+" id="+quote+"nao_pattern_jja"+quote+">"
     txt(6243) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6244) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_jja.indmem.png","Indiv")+"</li>"
     txt(6245) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_jja.indmemdiff.png","Bias")+"</li>"
     txt(6247) = "</ul></div></td>"
  else
     txt(6247) = "JJA</td>"
  end if

  txt(6250) = "<td>"
  if (isfilepresent2(OUTDIR+"nao_pattern_jas.indmem.png")) then
     txt(6251) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nao_pattern_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nao_pattern_jas"+quote+">JAS</a>" 
     txt(6252) = "<div class="+quote+"collapse"+quote+" id="+quote+"nao_pattern_jas"+quote+">"
     txt(6253) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6254) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_jas.indmem.png","Indiv")+"</li>"
     txt(6255) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_jas.indmemdiff.png","Bias")+"</li>"
     txt(6257) = "</ul></div></td>"
  else
     txt(6257) = "JAS</td>"
  end if

  txt(6260) = "<td>"
  if (isfilepresent2(OUTDIR+"nao_pattern_son.indmem.png")) then
     txt(6261) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nao_pattern_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nao_pattern_son"+quote+">SON</a>" 
     txt(6262) = "<div class="+quote+"collapse"+quote+" id="+quote+"nao_pattern_son"+quote+">"
     txt(6263) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6264) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_son.indmem.png","Indiv")+"</li>"
     txt(6265) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_son.indmemdiff.png","Bias")+"</li>"
     txt(6267) = "</ul></div></td>"
  else
     txt(6267) = "SON</td>"
  end if

  txt(6270) = "<td>"
  if (isfilepresent2(OUTDIR+"nao_pattern_ndjfma.indmem.png")) then
     txt(6271) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nao_pattern_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nao_pattern_ndjfma"+quote+">NDJFMA</a>"
     txt(6272) = "<div class="+quote+"collapse"+quote+" id="+quote+"nao_pattern_ndjfma"+quote+">"
     txt(6273) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6274) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_ndjfma.indmem.png","Indiv")+"</li>"
     txt(6275) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(6277) = "</ul></div></td>"
  else
     txt(6277) = "NDJFMA</td>"
  end if

  txt(6280) = "<td>"
  if (isfilepresent2(OUTDIR+"nao_pattern_mjjaso.indmem.png")) then
     txt(6281) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nao_pattern_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nao_pattern_mjjaso"+quote+">MJJASO</a>"
     txt(6282) = "<div class="+quote+"collapse"+quote+" id="+quote+"nao_pattern_mjjaso"+quote+">"
     txt(6283) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6284) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_mjjaso.indmem.png","Indiv")+"</li>"
     txt(6285) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(6287) = "</ul></div></td>"
  else
     txt(6287) = "MJJASO</td>"
  end if

  txt(6290) = "<td>"
  if (isfilepresent2(OUTDIR+"nao_pattern_ann.indmem.png")) then
     txt(6291) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nao_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"nao_pattern_ann"+quote+">ANN</a>" 
     txt(6292) = "<div class="+quote+"collapse"+quote+" id="+quote+"nao_pattern_ann"+quote+">"
     txt(6293) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6294) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_ann.indmem.png","Indiv")+"</li>"
     txt(6295) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"nao_pattern_ann.indmemdiff.png","Bias")+"</li>"
     txt(6297) = "</ul></div></td></tr>"
  else
     txt(6297) = "ANN</td></tr>"
  end if
  txt(6301) = "<tr><td>Timeseries</td>"
  txt(6302) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_djf.indmem.png","DJF")+"</td>"
  txt(6303) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_jfm.indmem.png","JFM")+"</td>"
  txt(6304) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_mam.indmem.png","MAM")+"</td>"
  txt(6305) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_jja.indmem.png","JJA")+"</td>"
  txt(6306) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_jas.indmem.png","JAS")+"</td>"
  txt(6307) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_son.indmem.png","SON")+"</td>"
  txt(6308) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(6309) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(6310) = "<td>"+table_link_setup(OUTDIR,"nao_timeseries_ann.indmem.png","ANN")+"</td></tr>"

  txt(6409) = "<tr><td rowspan=2><b>SAM</b></td>"
  txt(6410) = "<td>Patterns</td><td>"
  if (isfilepresent2(OUTDIR+"sam_pattern_djf.indmem.png")) then
     txt(6411) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sam_pattern_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sam_pattern_djf"+quote+">DJF</a>" 
     txt(6412) = "<div class="+quote+"collapse"+quote+" id="+quote+"sam_pattern_djf"+quote+">"
     txt(6413) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6414) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_djf.indmem.png","Indiv")+"</li>"
     txt(6415) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_djf.indmemdiff.png","Bias")+"</li>"
     txt(6417) = "</ul></div></td>"
  else
     txt(6417) = "DJF</td>"
  end if

  txt(6420) = "<td>"
  if (isfilepresent2(OUTDIR+"sam_pattern_jfm.indmem.png")) then
     txt(6421) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sam_pattern_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sam_pattern_jfm"+quote+">JFM</a>" 
     txt(6422) = "<div class="+quote+"collapse"+quote+" id="+quote+"sam_pattern_jfm"+quote+">"
     txt(6423) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6424) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_jfm.indmem.png","Indiv")+"</li>"
     txt(6425) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_jfm.indmemdiff.png","Bias")+"</li>"
     txt(6427) = "</ul></div></td>"
  else
     txt(6427) = "JFM</td>"
  end if

  txt(6430) = "<td>"
  if (isfilepresent2(OUTDIR+"sam_pattern_mam.indmem.png")) then
     txt(6431) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sam_pattern_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sam_pattern_mam"+quote+">MAM</a>" 
     txt(6432) = "<div class="+quote+"collapse"+quote+" id="+quote+"sam_pattern_mam"+quote+">"
     txt(6433) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6434) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_mam.indmem.png","Indiv")+"</li>"
     txt(6435) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_mam.indmemdiff.png","Bias")+"</li>"
     txt(6437) = "</ul></div></td>"
  else
     txt(6437) = "MAM</td>"
  end if

  txt(6440) = "<td>"
  if (isfilepresent2(OUTDIR+"sam_pattern_jja.indmem.png")) then
     txt(6441) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sam_pattern_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sam_pattern_jja"+quote+">JJA</a>" 
     txt(6442) = "<div class="+quote+"collapse"+quote+" id="+quote+"sam_pattern_jja"+quote+">"
     txt(6443) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6444) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_jja.indmem.png","Indiv")+"</li>"
     txt(6445) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_jja.indmemdiff.png","Bias")+"</li>"
     txt(6447) = "</ul></div></td>"
  else
     txt(6447) = "JJA</td>"
  end if

  txt(6450) = "<td>"
  if (isfilepresent2(OUTDIR+"sam_pattern_jas.indmem.png")) then
     txt(6451) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sam_pattern_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sam_pattern_jas"+quote+">JAS</a>" 
     txt(6452) = "<div class="+quote+"collapse"+quote+" id="+quote+"sam_pattern_jas"+quote+">"
     txt(6453) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6454) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_jas.indmem.png","Indiv")+"</li>"
     txt(6455) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_jas.indmemdiff.png","Bias")+"</li>"
     txt(6457) = "</ul></div></td>"
  else
     txt(6457) = "JAS</td>"
  end if

  txt(6460) = "<td>"
  if (isfilepresent2(OUTDIR+"sam_pattern_son.indmem.png")) then
     txt(6461) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sam_pattern_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sam_pattern_son"+quote+">SON</a>" 
     txt(6462) = "<div class="+quote+"collapse"+quote+" id="+quote+"sam_pattern_son"+quote+">"
     txt(6463) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6464) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_son.indmem.png","Indiv")+"</li>"
     txt(6465) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_son.indmemdiff.png","Bias")+"</li>"
     txt(6467) = "</ul></div></td>"
  else
     txt(6467) = "SON</td>"
  end if

  txt(6470) = "<td>"
  if (isfilepresent2(OUTDIR+"sam_pattern_ndjfma.indmem.png")) then
     txt(6471) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sam_pattern_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sam_pattern_ndjfma"+quote+">NDJFMA</a>"
     txt(6472) = "<div class="+quote+"collapse"+quote+" id="+quote+"sam_pattern_ndjfma"+quote+">"
     txt(6473) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6474) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_ndjfma.indmem.png","Indiv")+"</li>"
     txt(6475) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(6477) = "</ul></div></td>"
  else
     txt(6477) = "NDJFMA</td>"
  end if

  txt(6480) = "<td>"
  if (isfilepresent2(OUTDIR+"sam_pattern_mjjaso.indmem.png")) then
     txt(6481) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sam_pattern_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sam_pattern_mjjaso"+quote+">MJJASO</a>"
     txt(6482) = "<div class="+quote+"collapse"+quote+" id="+quote+"sam_pattern_mjjaso"+quote+">"
     txt(6483) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6484) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_mjjaso.indmem.png","Indiv")+"</li>"
     txt(6485) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(6487) = "</ul></div></td>"
  else
     txt(6487) = "MJJASO</td>"
  end if

  txt(6490) = "<td>"
  if (isfilepresent2(OUTDIR+"sam_pattern_ann.indmem.png")) then
     txt(6491) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#sam_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"sam_pattern_ann"+quote+">ANN</a>" 
     txt(6492) = "<div class="+quote+"collapse"+quote+" id="+quote+"sam_pattern_ann"+quote+">"
     txt(6493) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6494) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_ann.indmem.png","Indiv")+"</li>"
     txt(6495) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"sam_pattern_ann.indmemdiff.png","Bias")+"</li>"
     txt(6497) = "</ul></div></td></tr>"
  else
     txt(6497) = "ANN</td></tr>"
  end if
  txt(6501) = "<tr><td>Timeseries</td>"
  txt(6502) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_djf.indmem.png","DJF")+"</td>"
  txt(6503) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_jfm.indmem.png","JFM")+"</td>"
  txt(6504) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_mam.indmem.png","MAM")+"</td>"
  txt(6505) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_jja.indmem.png","JJA")+"</td>"
  txt(6506) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_jas.indmem.png","JAS")+"</td>"
  txt(6507) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_son.indmem.png","SON")+"</td>"
  txt(6508) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(6509) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(6510) = "<td>"+table_link_setup(OUTDIR,"sam_timeseries_ann.indmem.png","ANN")+"</td></tr>"

  txt(6609) = "<tr><td rowspan=2><b>PNA</b></td>"
  txt(6610) = "<td>Patterns</td><td>"
  if (isfilepresent2(OUTDIR+"pna_pattern_djf.indmem.png")) then
     txt(6611) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pna_pattern_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pna_pattern_djf"+quote+">DJF</a>" 
     txt(6612) = "<div class="+quote+"collapse"+quote+" id="+quote+"pna_pattern_djf"+quote+">"
     txt(6613) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6614) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_djf.indmem.png","Indiv")+"</li>"
     txt(6615) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_djf.indmemdiff.png","Bias")+"</li>"
     txt(6617) = "</ul></div></td>"
  else
     txt(6617) = "DJF</td>"
  end if

  txt(6620) = "<td>"
  if (isfilepresent2(OUTDIR+"pna_pattern_jfm.indmem.png")) then
     txt(6621) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pna_pattern_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pna_pattern_jfm"+quote+">JFM</a>" 
     txt(6622) = "<div class="+quote+"collapse"+quote+" id="+quote+"pna_pattern_jfm"+quote+">"
     txt(6623) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6624) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_jfm.indmem.png","Indiv")+"</li>"
     txt(6625) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_jfm.indmemdiff.png","Bias")+"</li>"
     txt(6627) = "</ul></div></td>"
  else
     txt(6627) = "JFM</td>"
  end if

  txt(6630) = "<td>"
  if (isfilepresent2(OUTDIR+"pna_pattern_mam.indmem.png")) then
     txt(6631) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pna_pattern_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pna_pattern_mam"+quote+">MAM</a>" 
     txt(6632) = "<div class="+quote+"collapse"+quote+" id="+quote+"pna_pattern_mam"+quote+">"
     txt(6633) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6634) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_mam.indmem.png","Indiv")+"</li>"
     txt(6635) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_mam.indmemdiff.png","Bias")+"</li>"
     txt(6637) = "</ul></div></td>"
  else
     txt(6637) = "MAM</td>"
  end if

  txt(6640) = "<td>"
  if (isfilepresent2(OUTDIR+"pna_pattern_jja.indmem.png")) then
     txt(6641) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pna_pattern_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pna_pattern_jja"+quote+">JJA</a>" 
     txt(6642) = "<div class="+quote+"collapse"+quote+" id="+quote+"pna_pattern_jja"+quote+">"
     txt(6643) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6644) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_jja.indmem.png","Indiv")+"</li>"
     txt(6645) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_jja.indmemdiff.png","Bias")+"</li>"
     txt(6647) = "</ul></div></td>"
  else
     txt(6647) = "JJA</td>"
  end if

  txt(6650) = "<td>"
  if (isfilepresent2(OUTDIR+"pna_pattern_jas.indmem.png")) then
     txt(6651) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pna_pattern_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pna_pattern_jas"+quote+">JAS</a>" 
     txt(6652) = "<div class="+quote+"collapse"+quote+" id="+quote+"pna_pattern_jas"+quote+">"
     txt(6653) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6654) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_jas.indmem.png","Indiv")+"</li>"
     txt(6655) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_jas.indmemdiff.png","Bias")+"</li>"
     txt(6657) = "</ul></div></td>"
  else
     txt(6657) = "JAS</td>"
  end if

  txt(6660) = "<td>"
  if (isfilepresent2(OUTDIR+"pna_pattern_son.indmem.png")) then
     txt(6661) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pna_pattern_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pna_pattern_son"+quote+">SON</a>" 
     txt(6662) = "<div class="+quote+"collapse"+quote+" id="+quote+"pna_pattern_son"+quote+">"
     txt(6663) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6664) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_son.indmem.png","Indiv")+"</li>"
     txt(6665) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_son.indmemdiff.png","Bias")+"</li>"
     txt(6667) = "</ul></div></td>"
  else
     txt(6667) = "SON</td>"
  end if

  txt(6670) = "<td>"
  if (isfilepresent2(OUTDIR+"pna_pattern_ndjfma.indmem.png")) then
     txt(6671) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pna_pattern_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pna_pattern_ndjfma"+quote+">NDJFMA</a>"
     txt(6672) = "<div class="+quote+"collapse"+quote+" id="+quote+"pna_pattern_ndjfma"+quote+">"
     txt(6673) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6674) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_ndjfma.indmem.png","Indiv")+"</li>"
     txt(6675) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(6677) = "</ul></div></td>"
  else
     txt(6677) = "NDJFMA</td>"
  end if

  txt(6680) = "<td>"
  if (isfilepresent2(OUTDIR+"pna_pattern_mjjaso.indmem.png")) then
     txt(6681) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pna_pattern_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pna_pattern_mjjaso"+quote+">MJJASO</a>"
     txt(6682) = "<div class="+quote+"collapse"+quote+" id="+quote+"pna_pattern_mjjaso"+quote+">"
     txt(6683) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6684) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_mjjaso.indmem.png","Indiv")+"</li>"
     txt(6685) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(6687) = "</ul></div></td>"
  else
     txt(6687) = "MJJASO</td>"
  end if

  txt(6690) = "<td>"
  if (isfilepresent2(OUTDIR+"pna_pattern_ann.indmem.png")) then
     txt(6691) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#pna_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"pna_pattern_ann"+quote+">ANN</a>" 
     txt(6692) = "<div class="+quote+"collapse"+quote+" id="+quote+"pna_pattern_ann"+quote+">"
     txt(6693) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6694) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_ann.indmem.png","Indiv")+"</li>"
     txt(6695) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"pna_pattern_ann.indmemdiff.png","Bias")+"</li>"
     txt(6697) = "</ul></div></td></tr>"
  else
     txt(6697) = "ANN</td></tr>"
  end if
  txt(6701) = "<tr><td>Timeseries</td>"
  txt(6702) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_djf.indmem.png","DJF")+"</td>"
  txt(6703) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_jfm.indmem.png","JFM")+"</td>"
  txt(6704) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_mam.indmem.png","MAM")+"</td>"
  txt(6705) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_jja.indmem.png","JJA")+"</td>"
  txt(6706) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_jas.indmem.png","JAS")+"</td>"
  txt(6707) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_son.indmem.png","SON")+"</td>"
  txt(6708) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(6709) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(6710) = "<td>"+table_link_setup(OUTDIR,"pna_timeseries_ann.indmem.png","ANN")+"</td></tr>"

  txt(6809) = "<tr><td rowspan=2><b>NPO</b></td>"
  txt(6810) = "<td>Patterns</td><td>"
  if (isfilepresent2(OUTDIR+"npo_pattern_djf.indmem.png")) then
     txt(6811) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#npo_pattern_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"npo_pattern_djf"+quote+">DJF</a>" 
     txt(6812) = "<div class="+quote+"collapse"+quote+" id="+quote+"npo_pattern_djf"+quote+">"
     txt(6813) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6814) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_djf.indmem.png","Indiv")+"</li>"
     txt(6815) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_djf.indmemdiff.png","Bias")+"</li>"
     txt(6817) = "</ul></div></td>"
  else
     txt(6817) = "DJF</td>"
  end if

  txt(6820) = "<td>"
  if (isfilepresent2(OUTDIR+"npo_pattern_jfm.indmem.png")) then
     txt(6821) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#npo_pattern_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"npo_pattern_jfm"+quote+">JFM</a>" 
     txt(6822) = "<div class="+quote+"collapse"+quote+" id="+quote+"npo_pattern_jfm"+quote+">"
     txt(6823) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6824) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_jfm.indmem.png","Indiv")+"</li>"
     txt(6825) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_jfm.indmemdiff.png","Bias")+"</li>"
     txt(6827) = "</ul></div></td>"
  else
     txt(6827) = "JFM</td>"
  end if

  txt(6830) = "<td>"
  if (isfilepresent2(OUTDIR+"npo_pattern_mam.indmem.png")) then
     txt(6831) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#npo_pattern_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"npo_pattern_mam"+quote+">MAM</a>" 
     txt(6832) = "<div class="+quote+"collapse"+quote+" id="+quote+"npo_pattern_mam"+quote+">"
     txt(6833) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6834) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_mam.indmem.png","Indiv")+"</li>"
     txt(6835) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_mam.indmemdiff.png","Bias")+"</li>"
     txt(6837) = "</ul></div></td>"
  else
     txt(6837) = "MAM</td>"
  end if

  txt(6840) = "<td>"
  if (isfilepresent2(OUTDIR+"npo_pattern_jja.indmem.png")) then
     txt(6841) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#npo_pattern_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"npo_pattern_jja"+quote+">JJA</a>" 
     txt(6842) = "<div class="+quote+"collapse"+quote+" id="+quote+"npo_pattern_jja"+quote+">"
     txt(6843) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6844) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_jja.indmem.png","Indiv")+"</li>"
     txt(6845) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_jja.indmemdiff.png","Bias")+"</li>"
     txt(6847) = "</ul></div></td>"
  else
     txt(6847) = "JJA</td>"
  end if

  txt(6850) = "<td>"
  if (isfilepresent2(OUTDIR+"npo_pattern_jas.indmem.png")) then
     txt(6851) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#npo_pattern_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"npo_pattern_jas"+quote+">JAS</a>" 
     txt(6852) = "<div class="+quote+"collapse"+quote+" id="+quote+"npo_pattern_jas"+quote+">"
     txt(6853) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6854) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_jas.indmem.png","Indiv")+"</li>"
     txt(6855) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_jas.indmemdiff.png","Bias")+"</li>"
     txt(6857) = "</ul></div></td>"
  else
     txt(6857) = "JAS</td>"
  end if

  txt(6860) = "<td>"
  if (isfilepresent2(OUTDIR+"npo_pattern_son.indmem.png")) then
     txt(6861) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#npo_pattern_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"npo_pattern_son"+quote+">SON</a>" 
     txt(6862) = "<div class="+quote+"collapse"+quote+" id="+quote+"npo_pattern_son"+quote+">"
     txt(6863) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6864) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_son.indmem.png","Indiv")+"</li>"
     txt(6865) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_son.indmemdiff.png","Bias")+"</li>"
     txt(6867) = "</ul></div></td>"
  else
     txt(6867) = "SON</td>"
  end if

  txt(6870) = "<td>"
  if (isfilepresent2(OUTDIR+"npo_pattern_ndjfma.indmem.png")) then
     txt(6871) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#npo_pattern_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"npo_pattern_ndjfma"+quote+">NDJFMA</a>"
     txt(6872) = "<div class="+quote+"collapse"+quote+" id="+quote+"npo_pattern_ndjfma"+quote+">"
     txt(6873) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6874) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_ndjfma.indmem.png","Indiv")+"</li>"
     txt(6875) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(6877) = "</ul></div></td>"
  else
     txt(6877) = "NDJFMA</td>"
  end if

  txt(6880) = "<td>"
  if (isfilepresent2(OUTDIR+"npo_pattern_mjjaso.indmem.png")) then
     txt(6881) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#npo_pattern_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"npo_pattern_mjjaso"+quote+">MJJASO</a>"
     txt(6882) = "<div class="+quote+"collapse"+quote+" id="+quote+"npo_pattern_mjjaso"+quote+">"
     txt(6883) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6884) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_mjjaso.indmem.png","Indiv")+"</li>"
     txt(6885) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(6887) = "</ul></div></td>"
  else
     txt(6887) = "MJJASO</td>"
  end if

  txt(6890) = "<td>"
  if (isfilepresent2(OUTDIR+"npo_pattern_ann.indmem.png")) then
     txt(6891) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#npo_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"npo_pattern_ann"+quote+">ANN</a>" 
     txt(6892) = "<div class="+quote+"collapse"+quote+" id="+quote+"npo_pattern_ann"+quote+">"
     txt(6893) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(6894) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_ann.indmem.png","Indiv")+"</li>"
     txt(6895) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"npo_pattern_ann.indmemdiff.png","Bias")+"</li>"
     txt(6897) = "</ul></div></td></tr>"
  else
     txt(6897) = "ANN</td></tr>"
  end if
  txt(6901) = "<tr><td>Timeseries</td>"
  txt(6902) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_djf.indmem.png","DJF")+"</td>"
  txt(6903) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_jfm.indmem.png","JFM")+"</td>"
  txt(6904) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_mam.indmem.png","MAM")+"</td>"
  txt(6905) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_jja.indmem.png","JJA")+"</td>"
  txt(6906) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_jas.indmem.png","JAS")+"</td>"
  txt(6907) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_son.indmem.png","SON")+"</td>"
  txt(6908) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(6909) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(6910) = "<td>"+table_link_setup(OUTDIR,"npo_timeseries_ann.indmem.png","ANN")+"</td></tr>"

  txt(7009) = "<tr><td rowspan=2><b>PSA1</b></td>"
  txt(7010) = "<td>Patterns</td><td>"
  if (isfilepresent2(OUTDIR+"psa1_pattern_djf.indmem.png")) then
     txt(7011) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa1_pattern_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa1_pattern_djf"+quote+">DJF</a>" 
     txt(7012) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa1_pattern_djf"+quote+">"
     txt(7013) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7014) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_djf.indmem.png","Indiv")+"</li>"
     txt(7015) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_djf.indmemdiff.png","Bias")+"</li>"
     txt(7017) = "</ul></div></td>"
  else
     txt(7017) = "DJF</td>"
  end if

  txt(7020) = "<td>"
  if (isfilepresent2(OUTDIR+"psa1_pattern_jfm.indmem.png")) then
     txt(7021) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa1_pattern_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa1_pattern_jfm"+quote+">JFM</a>" 
     txt(7022) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa1_pattern_jfm"+quote+">"
     txt(7023) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7024) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_jfm.indmem.png","Indiv")+"</li>"
     txt(7025) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_jfm.indmemdiff.png","Bias")+"</li>"
     txt(7027) = "</ul></div></td>"
  else
     txt(7027) = "JFM</td>"
  end if

  txt(7030) = "<td>"
  if (isfilepresent2(OUTDIR+"psa1_pattern_mam.indmem.png")) then
     txt(7031) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa1_pattern_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa1_pattern_mam"+quote+">MAM</a>" 
     txt(7032) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa1_pattern_mam"+quote+">"
     txt(7033) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7034) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_mam.indmem.png","Indiv")+"</li>"
     txt(7035) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_mam.indmemdiff.png","Bias")+"</li>"
     txt(7037) = "</ul></div></td>"
  else
     txt(7037) = "MAM</td>"
  end if

  txt(7040) = "<td>"
  if (isfilepresent2(OUTDIR+"psa1_pattern_jja.indmem.png")) then
     txt(7041) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa1_pattern_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa1_pattern_jja"+quote+">JJA</a>" 
     txt(7042) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa1_pattern_jja"+quote+">"
     txt(7043) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7044) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_jja.indmem.png","Indiv")+"</li>"
     txt(7045) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_jja.indmemdiff.png","Bias")+"</li>"
     txt(7047) = "</ul></div></td>"
  else
     txt(7047) = "JJA</td>"
  end if

  txt(7050) = "<td>"
  if (isfilepresent2(OUTDIR+"psa1_pattern_jas.indmem.png")) then
     txt(7051) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa1_pattern_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa1_pattern_jas"+quote+">JAS</a>" 
     txt(7052) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa1_pattern_jas"+quote+">"
     txt(7053) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7054) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_jas.indmem.png","Indiv")+"</li>"
     txt(7055) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_jas.indmemdiff.png","Bias")+"</li>"
     txt(7057) = "</ul></div></td>"
  else
     txt(7057) = "JAS</td>"
  end if

  txt(7060) = "<td>"
  if (isfilepresent2(OUTDIR+"psa1_pattern_son.indmem.png")) then
     txt(7061) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa1_pattern_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa1_pattern_son"+quote+">SON</a>" 
     txt(7062) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa1_pattern_son"+quote+">"
     txt(7063) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7064) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_son.indmem.png","Indiv")+"</li>"
     txt(7065) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_son.indmemdiff.png","Bias")+"</li>"
     txt(7067) = "</ul></div></td>"
  else
     txt(7067) = "SON</td>"
  end if

  txt(7070) = "<td>"
  if (isfilepresent2(OUTDIR+"psa1_pattern_ndjfma.indmem.png")) then
     txt(7071) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa1_pattern_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa1_pattern_ndjfma"+quote+">NDJFMA</a>"
     txt(7072) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa1_pattern_ndjfma"+quote+">"
     txt(7073) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7074) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_ndjfma.indmem.png","Indiv")+"</li>"
     txt(7075) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(7077) = "</ul></div></td>"
  else
     txt(7077) = "NDJFMA</td>"
  end if

  txt(7080) = "<td>"
  if (isfilepresent2(OUTDIR+"psa1_pattern_mjjaso.indmem.png")) then
     txt(7081) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa1_pattern_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa1_pattern_mjjaso"+quote+">MJJASO</a>"
     txt(7082) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa1_pattern_mjjaso"+quote+">"
     txt(7083) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7084) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_mjjaso.indmem.png","Indiv")+"</li>"
     txt(7085) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(7087) = "</ul></div></td>"
  else
     txt(7087) = "MJJASO</td>"
  end if

  txt(7090) = "<td>"
  if (isfilepresent2(OUTDIR+"psa1_pattern_ann.indmem.png")) then
     txt(7091) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa1_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa1_pattern_ann"+quote+">ANN</a>" 
     txt(7092) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa1_pattern_ann"+quote+">"
     txt(7093) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7094) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_ann.indmem.png","Indiv")+"</li>"
     txt(7095) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa1_pattern_ann.indmemdiff.png","Bias")+"</li>"
     txt(7097) = "</ul></div></td></tr>"
  else
     txt(7097) = "ANN</td></tr>"
  end if
  txt(7101) = "<tr><td>Timeseries</td>"
  txt(7102) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_djf.indmem.png","DJF")+"</td>"
  txt(7103) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_jfm.indmem.png","JFM")+"</td>"
  txt(7104) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_mam.indmem.png","MAM")+"</td>"
  txt(7105) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_jja.indmem.png","JJA")+"</td>"
  txt(7106) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_jas.indmem.png","JAS")+"</td>"
  txt(7107) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_son.indmem.png","SON")+"</td>"
  txt(7108) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(7109) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(7110) = "<td>"+table_link_setup(OUTDIR,"psa1_timeseries_ann.indmem.png","ANN")+"</td></tr>"

  txt(7209) = "<tr><td rowspan=2><b>PSA2</b></td>"
  txt(7210) = "<td>Patterns</td><td>"
  if (isfilepresent2(OUTDIR+"psa2_pattern_djf.indmem.png")) then
     txt(7211) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa2_pattern_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa2_pattern_djf"+quote+">DJF</a>" 
     txt(7212) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa2_pattern_djf"+quote+">"
     txt(7213) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7214) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_djf.indmem.png","Indiv")+"</li>"
     txt(7215) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_djf.indmemdiff.png","Bias")+"</li>"
     txt(7217) = "</ul></div></td>"
  else
     txt(7217) = "DJF</td>"
  end if

  txt(7220) = "<td>"
  if (isfilepresent2(OUTDIR+"psa2_pattern_jfm.indmem.png")) then
     txt(7221) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa2_pattern_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa2_pattern_jfm"+quote+">JFM</a>" 
     txt(7222) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa2_pattern_jfm"+quote+">"
     txt(7223) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7224) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_jfm.indmem.png","Indiv")+"</li>"
     txt(7225) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_jfm.indmemdiff.png","Bias")+"</li>"
     txt(7227) = "</ul></div></td>"
  else
     txt(7227) = "JFM</td>"
  end if

  txt(7230) = "<td>"
  if (isfilepresent2(OUTDIR+"psa2_pattern_mam.indmem.png")) then
     txt(7231) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa2_pattern_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa2_pattern_mam"+quote+">MAM</a>" 
     txt(7232) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa2_pattern_mam"+quote+">"
     txt(7233) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7234) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_mam.indmem.png","Indiv")+"</li>"
     txt(7235) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_mam.indmemdiff.png","Bias")+"</li>"
     txt(7237) = "</ul></div></td>"
  else
     txt(7237) = "MAM</td>"
  end if

  txt(7240) = "<td>"
  if (isfilepresent2(OUTDIR+"psa2_pattern_jja.indmem.png")) then
     txt(7241) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa2_pattern_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa2_pattern_jja"+quote+">JJA</a>" 
     txt(7242) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa2_pattern_jja"+quote+">"
     txt(7243) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7244) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_jja.indmem.png","Indiv")+"</li>"
     txt(7245) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_jja.indmemdiff.png","Bias")+"</li>"
     txt(7247) = "</ul></div></td>"
  else
     txt(7247) = "JJA</td>"
  end if

  txt(7250) = "<td>"
  if (isfilepresent2(OUTDIR+"psa2_pattern_jas.indmem.png")) then
     txt(7251) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa2_pattern_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa2_pattern_jas"+quote+">JAS</a>" 
     txt(7252) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa2_pattern_jas"+quote+">"
     txt(7253) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7254) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_jas.indmem.png","Indiv")+"</li>"
     txt(7255) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_jas.indmemdiff.png","Bias")+"</li>"
     txt(7257) = "</ul></div></td>"
  else
     txt(7257) = "JAS</td>"
  end if

  txt(7260) = "<td>"
  if (isfilepresent2(OUTDIR+"psa2_pattern_son.indmem.png")) then
     txt(7261) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa2_pattern_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa2_pattern_son"+quote+">SON</a>" 
     txt(7262) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa2_pattern_son"+quote+">"
     txt(7263) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7264) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_son.indmem.png","Indiv")+"</li>"
     txt(7265) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_son.indmemdiff.png","Bias")+"</li>"
     txt(7267) = "</ul></div></td>"
  else
     txt(7267) = "SON</td>"
  end if

  txt(7270) = "<td>"
  if (isfilepresent2(OUTDIR+"psa2_pattern_ndjfma.indmem.png")) then
     txt(7271) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa2_pattern_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa2_pattern_ndjfma"+quote+">NDJFMA</a>"
     txt(7272) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa2_pattern_ndjfma"+quote+">"
     txt(7273) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7274) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_ndjfma.indmem.png","Indiv")+"</li>"
     txt(7275) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(7277) = "</ul></div></td>"
  else
     txt(7277) = "NDJFMA</td>"
  end if

  txt(7280) = "<td>"
  if (isfilepresent2(OUTDIR+"psa2_pattern_mjjaso.indmem.png")) then
     txt(7281) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa2_pattern_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa2_pattern_mjjaso"+quote+">MJJASO</a>"
     txt(7282) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa2_pattern_mjjaso"+quote+">"
     txt(7283) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7284) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_mjjaso.indmem.png","Indiv")+"</li>"
     txt(7285) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(7287) = "</ul></div></td>"
  else
     txt(7287) = "MJJASO</td>"
  end if

  txt(7290) = "<td>"
  if (isfilepresent2(OUTDIR+"psa2_pattern_ann.indmem.png")) then
     txt(7291) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#psa2_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"psa2_pattern_ann"+quote+">ANN</a>" 
     txt(7292) = "<div class="+quote+"collapse"+quote+" id="+quote+"psa2_pattern_ann"+quote+">"
     txt(7293) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7294) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_ann.indmem.png","Indiv")+"</li>"
     txt(7295) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"psa2_pattern_ann.indmemdiff.png","Bias")+"</li>"
     txt(7297) = "</ul></div></td></tr>"
  else
     txt(7297) = "ANN</td></tr>"
  end if
  txt(7301) = "<tr><td>Timeseries</td>"
  txt(7302) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_djf.indmem.png","DJF")+"</td>"
  txt(7303) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_jfm.indmem.png","JFM")+"</td>"
  txt(7304) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_mam.indmem.png","MAM")+"</td>"
  txt(7305) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_jja.indmem.png","JJA")+"</td>"
  txt(7306) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_jas.indmem.png","JAS")+"</td>"
  txt(7307) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_son.indmem.png","SON")+"</td>"
  txt(7308) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(7309) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(7310) = "<td>"+table_link_setup(OUTDIR,"psa2_timeseries_ann.indmem.png","ANN")+"</td></tr>"

  txt(7409) = "<tr><td rowspan=2><b>SST(EOF1)</b></td>"
  txt(7410) = "<td>Patterns</td><td>"
  if (isfilepresent2(OUTDIR+"ssteof1_pattern_djf.indmem.png")) then
     txt(7411) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#ssteof1_pattern_djf"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"ssteof1_pattern_djf"+quote+">DJF</a>"
     txt(7412) = "<div class="+quote+"collapse"+quote+" id="+quote+"ssteof1_pattern_djf"+quote+">"
     txt(7413) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7414) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_djf.indmem.png","Indiv")+"</li>"
     txt(7415) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_djf.indmemdiff.png","Bias")+"</li>"
     txt(7417) = "</ul></div></td>"
  else
     txt(7417) = "DJF</td>"
  end if

  txt(7420) = "<td>"
  if (isfilepresent2(OUTDIR+"ssteof1_pattern_jfm.indmem.png")) then
     txt(7421) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#ssteof1_pattern_jfm"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"ssteof1_pattern_jfm"+quote+">JFM</a>"
     txt(7422) = "<div class="+quote+"collapse"+quote+" id="+quote+"ssteof1_pattern_jfm"+quote+">"
     txt(7423) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7424) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_jfm.indmem.png","Indiv")+"</li>"
     txt(7425) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_jfm.indmemdiff.png","Bias")+"</li>"
     txt(7427) = "</ul></div></td>"
  else
     txt(7427) = "JFM</td>"
  end if

  txt(7430) = "<td>"
  if (isfilepresent2(OUTDIR+"ssteof1_pattern_mam.indmem.png")) then
     txt(7431) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#ssteof1_pattern_mam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"ssteof1_pattern_mam"+quote+">MAM</a>"
     txt(7432) = "<div class="+quote+"collapse"+quote+" id="+quote+"ssteof1_pattern_mam"+quote+">"
     txt(7433) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7434) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_mam.indmem.png","Indiv")+"</li>"
     txt(7435) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_mam.indmemdiff.png","Bias")+"</li>"
     txt(7437) = "</ul></div></td>"
  else
     txt(7437) = "MAM</td>"
  end if

  txt(7440) = "<td>"
  if (isfilepresent2(OUTDIR+"ssteof1_pattern_jja.indmem.png")) then
     txt(7441) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#ssteof1_pattern_jja"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"ssteof1_pattern_jja"+quote+">JJA</a>"
     txt(7442) = "<div class="+quote+"collapse"+quote+" id="+quote+"ssteof1_pattern_jja"+quote+">"
     txt(7443) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7444) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_jja.indmem.png","Indiv")+"</li>"
     txt(7445) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_jja.indmemdiff.png","Bias")+"</li>"
     txt(7447) = "</ul></div></td>"
  else
     txt(7447) = "JJA</td>"
  end if
  txt(7450) = "<td>"
  if (isfilepresent2(OUTDIR+"ssteof1_pattern_jas.indmem.png")) then
     txt(7451) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#ssteof1_pattern_jas"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"ssteof1_pattern_jas"+quote+">JAS</a>"
     txt(7452) = "<div class="+quote+"collapse"+quote+" id="+quote+"ssteof1_pattern_jas"+quote+">"
     txt(7453) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7454) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_jas.indmem.png","Indiv")+"</li>"
     txt(7455) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_jas.indmemdiff.png","Bias")+"</li>"
     txt(7457) = "</ul></div></td>"
  else
     txt(7457) = "JAS</td>"
  end if

  txt(7460) = "<td>"
  if (isfilepresent2(OUTDIR+"ssteof1_pattern_son.indmem.png")) then
     txt(7461) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#ssteof1_pattern_son"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"ssteof1_pattern_son"+quote+">SON</a>"
     txt(7462) = "<div class="+quote+"collapse"+quote+" id="+quote+"ssteof1_pattern_son"+quote+">"
     txt(7463) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7464) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_son.indmem.png","Indiv")+"</li>"
     txt(7465) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_son.indmemdiff.png","Bias")+"</li>"
     txt(7467) = "</ul></div></td>"
  else
     txt(7467) = "SON</td>"
  end if

  txt(7470) = "<td>"
  if (isfilepresent2(OUTDIR+"ssteof1_pattern_ndjfma.indmem.png")) then
     txt(7471) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#ssteof1_pattern_ndjfma"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"ssteof1_pattern_ndjfma"+quote+">NDJFMA</a>"
     txt(7472) = "<div class="+quote+"collapse"+quote+" id="+quote+"ssteof1_pattern_ndjfma"+quote+">"
     txt(7473) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7474) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_ndjfma.indmem.png","Indiv")+"</li>"
     txt(7475) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_ndjfma.indmemdiff.png","Bias")+"</li>"
     txt(7477) = "</ul></div></td>"
  else
     txt(7477) = "NDJFMA</td>"
  end if

  txt(7480) = "<td>"
  if (isfilepresent2(OUTDIR+"ssteof1_pattern_mjjaso.indmem.png")) then
     txt(7481) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#ssteof1_pattern_mjjaso"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"ssteof1_pattern_mjjaso"+quote+">MJJASO</a>"
     txt(7482) = "<div class="+quote+"collapse"+quote+" id="+quote+"ssteof1_pattern_mjjaso"+quote+">"
     txt(7483) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7484) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_mjjaso.indmem.png","Indiv")+"</li>"
     txt(7485) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_mjjaso.indmemdiff.png","Bias")+"</li>"
     txt(7487) = "</ul></div></td>"
  else
     txt(7487) = "MJJASO</td>"
  end if

  txt(7490) = "<td>"
  if (isfilepresent2(OUTDIR+"ssteof1_pattern_ann.indmem.png")) then
     txt(7491) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#ssteof1_pattern_ann"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"ssteof1_pattern_ann"+quote+">ANN</a>"
     txt(7492) = "<div class="+quote+"collapse"+quote+" id="+quote+"ssteof1_pattern_ann"+quote+">"
     txt(7493) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(7494) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_ann.indmem.png","Indiv")+"</li>"
     txt(7495) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"ssteof1_pattern_ann.indmemdiff.png","Bias")+"</li>"
     txt(7497) = "</ul></div></td></tr>"
  else
     txt(7497) = "ANN</td></tr>"
  end if

  txt(7501) = "<tr><td>Timeseries</td>"
  txt(7502) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_djf.indmem.png","DJF")+"</td>"
  txt(7503) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_jfm.indmem.png","JFM")+"</td>"
  txt(7504) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_mam.indmem.png","MAM")+"</td>"
  txt(7505) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_jja.indmem.png","JJA")+"</td>"
  txt(7506) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_jas.indmem.png","JAS")+"</td>"
  txt(7507) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_son.indmem.png","SON")+"</td>"
  txt(7508) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(7509) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(7510) = "<td>"+table_link_setup(OUTDIR,"ssteof1_timeseries_ann.indmem.png","ANN")+"</td></tr>"
  txt(7600) = "</table></div></div>"

  txt(16000) = "<div class="+quote+"row"+quote+">"
  txt(16001) = "<div class="+quote+"col"+quote+">"
  txt(16002) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(16003) = "<h3 class="+quote+"display-6"+quote+">Southern Polar Timeseries</h3>"

  txt(16010) = "<tr class="+quote+"d-flex"+quote+">"
  txt(16011) = "<td class="+quote+"col"+quote+"><b>SST</b></td>"
  txt(16012) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_djf.indmem.png","DJF")+"</td>"
  txt(16013) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_jfm.indmem.png","JFM")+"</td>"
  txt(16014) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_mam.indmem.png","MAM")+"</td>"
  txt(16015) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_jja.indmem.png","JJA")+"</td>"
  txt(16016) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_jas.indmem.png","JAS")+"</td>"
  txt(16017) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_son.indmem.png","SON")+"</td>"
  txt(16018) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(16019) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(16020) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sst_polar_avg_ann.indmem.png","ANN")+"</td>"
  txt(16021) = "</tr>"

  txt(16022) = "<tr class="+quote+"d-flex"+quote+">"
  txt(16023) = "<td class="+quote+"col"+quote+"><b>TAS</b></td>"
  txt(16024) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_djf.indmem.png","DJF")+"</td>"
  txt(16025) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_jfm.indmem.png","JFM")+"</td>"
  txt(16026) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_mam.indmem.png","MAM")+"</td>"
  txt(16027) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_jja.indmem.png","JJA")+"</td>"
  txt(16028) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_jas.indmem.png","JAS")+"</td>"
  txt(16029) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_son.indmem.png","SON")+"</td>"
  txt(16030) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(16031) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(16032) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tas_polar_avg_ann.indmem.png","ANN")+"</td>"
  txt(16033) = "</tr>"

  txt(16040) = "<tr class="+quote+"d-flex"+quote+">"
  txt(16041) = "<td class="+quote+"col"+quote+"><b>PR</b></td>"
  txt(16042) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_djf.indmem.png","DJF")+"</td>"
  txt(16043) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_jfm.indmem.png","JFM")+"</td>"
  txt(16044) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_mam.indmem.png","MAM")+"</td>"
  txt(16045) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_jja.indmem.png","JJA")+"</td>"
  txt(16046) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_jas.indmem.png","JAS")+"</td>"
  txt(16047) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_son.indmem.png","SON")+"</td>"
  txt(16048) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(16049) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(16050) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_ann.indmem.png","ANN")+"</td>"
  txt(16051) = "</tr>"
  txt(16052) = "<tr class="+quote+"d-flex"+quote+">"
  txt(16053) = "<td class="+quote+"col"+quote+"><b>PR<br>(land-only)</b></td>"
  txt(16054) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_djf.indmem.png","DJF")+"</td>"
  txt(16055) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_jfm.indmem.png","JFM")+"</td>"
  txt(16056) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_mam.indmem.png","MAM")+"</td>"
  txt(16057) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_jja.indmem.png","JJA")+"</td>"
  txt(16058) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_jas.indmem.png","JAS")+"</td>"
  txt(16059) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_son.indmem.png","SON")+"</td>"
  txt(16060) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(16061) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(16062) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"pr_polar_avg_land_ann.indmem.png","ANN")+"</td>"
  txt(16063) = "</tr>"
  txt(16077) = "</tr></table></div></div>"

  txt(18600) = "<div class="+quote+"row"+quote+">"
  txt(18601) = "<div class="+quote+"col"+quote+">"
  txt(18602) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(18603) = "<h3 class="+quote+"display-6"+quote+">Cimate Index Timeseries</h3>"
  txt(18604) = "<tr class="+quote+"d-flex"+quote+">"
  txt(18605) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"atlantic_meridional_mode.timeseries.indmem.png","Atlantic SST Meridional Mode")+"</td>"
  txt(18606) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"atlantic_nino.timeseries.indmem.png","Atlantic Ni&ntilde;o SST")+"</td>"
  txt(18607) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"north_atlantic.timeseries.indmem.png","North Atlantic SST")+"</td>"
  txt(18608) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"north_tropical_atlantic.timeseries.indmem.png","Tropical North Atlantic SST")+"</td>"
  txt(18609) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"south_tropical_atlantic.timeseries.indmem.png","Tropical South Atlantic SST")+"</td></tr>"
  txt(18610) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino12.timeseries.indmem.png","ni&ntilde;o1+2 SST")+"</td>"
  txt(18617) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino3.timeseries.indmem.png","ni&ntilde;o3 SST")+"</td>"
  txt(18618) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino34.timeseries.indmem.png","ni&ntilde;o3.4 SST")+"</td>"
  txt(18619) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino4.timeseries.indmem.png","ni&ntilde;o4 SST")+"</td></tr>"
  txt(18620) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"north_pacific_index_ndjfm.indmem.png","North Pacific PSL Index (NPI)")+"</td>"
  txt(18621) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"north_pacific_meridional_mode.timeseries.indmem.png","North Pacific SST Meridional Mode")+"</td>"
  txt(18622) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"south_pacific_meridional_mode.timeseries.indmem.png","South Pacific SST Meridional Mode")+"</td></tr>"
  txt(18623) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"indian_ocean_dipole.timeseries.indmem.png","Indian Ocean SST Dipole")+"</td>"
  txt(18624) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"tropical_indian_ocean.timeseries.indmem.png","Tropical Indian Ocean SST")+"</td>"
  txt(18625) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"southern_ocean.timeseries.indmem.png","Southern Ocean SST")+"</td></tr>"
  txt(18626) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"scnino34.timeseries.indmem.png","Cumulative ni&ntilde;o3.4 SST")+"</td>"
  txt(18627) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino_el_nmon.timeseries.indmem.png","El ni&ntilde;o events")+"</td>"
  txt(18628) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino_la_nmon.timeseries.indmem.png","La ni&ntilde;a events")+"</td>"
  txt(18629) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"nino_elmla_nmon.timeseries.indmem.png","El ni&ntilde;o - La ni&ntilde;a events")+"</td></tr>"
  txt(18630) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sam_ns_nmon.timeseries.indmem.png","SAM(+) events")+"</td>"
  txt(18631) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sam_ns_nmon.timeseries.indmem.png","SAM(-) events")+"</td>"
  txt(18632) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"sam_psmns_nmon.timeseries.indmem.png","SAM(+) - SAM(-) events")+"</td></tr>"
  txt(18633) = "<tr class="+quote+"d-flex"+quote+"><td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"asl_ps_nmon.timeseries.indmem.png","ASL(+) events")+"</td>"
  txt(18634) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"asl_ns_nmon.timeseries.indmem.png","ASL(-) events")+"</td>"
  txt(18635) = "<td class="+quote+"col"+quote+">"+table_link_setup(OUTDIR,"asl_psmns_nmon.timeseries.indmem.png","ASL(+) - ASL(-) events")+"</td></tr>"
  txt(18636) = "</table></div></div>"

  txt(18700) = "<div class="+quote+"row"+quote+">"
  txt(18701) = "<div class="+quote+"col"+quote+">"
  txt(18702) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(18703) = "<h3 class="+quote+"display-6"+quote+">Sea Ice Extent Timeseries</h3>"
  txt(18705) = "<tr><td rowspan=2><b>NH</b></td>"
  txt(18706) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_djf.indmem.png","DJF")+"</td>"
  txt(18707) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_jfm.indmem.png","JFM")+"</td>"
  txt(18708) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_mam.indmem.png","MAM")+"</td>"
  txt(18709) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_jja.indmem.png","JJA")+"</td>"
  txt(18710) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_jas.indmem.png","JAS")+"</td>"
  txt(18711) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_son.indmem.png","SON")+"</td>"
  txt(18712) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(18713) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(18714) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_ann.indmem.png","ANN")+"</td></tr>"
  txt(18718) = "<tr><td>"+table_link_setup(OUTDIR,"siconc_nh_extent_feb.indmem.png","Feb")+"</td>"
  txt(18719) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_mar.indmem.png","Mar")+"</td>"
  txt(18720) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_sep.indmem.png","Sep")+"</td>"
  txt(18721) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_oct.indmem.png","Oct")+"</td>"
  txt(18722) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_mon.indmem.png","Monthly")+"</td>"
  txt(18723) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent_anom_mon.indmem.png","Monthly Anomalies")+"</td>"
  txt(18724) = "<td>"+table_link_setup(OUTDIR,"siconc_nh_extent.climo.indmem.png","Climatology")+"</td></tr>"
  txt(18727) = "<tr><td rowspan=2><b>SH</b></td>"
  txt(18728) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_djf.indmem.png","DJF")+"</td>"
  txt(18729) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_jfm.indmem.png","JFM")+"</td>"
  txt(18730) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_mam.indmem.png","MAM")+"</td>"
  txt(18731) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_jja.indmem.png","JJA")+"</td>"
  txt(18732) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_jas.indmem.png","JAS")+"</td>"
  txt(18733) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_son.indmem.png","SON")+"</td>"
  txt(18734) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_ndjfma.indmem.png","NDJFMA")+"</td>"
  txt(18735) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_mjjaso.indmem.png","MJJASO")+"</td>"
  txt(18736) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_ann.indmem.png","ANN")+"</td></tr>"
  txt(18740) = "<tr><td>"+table_link_setup(OUTDIR,"siconc_sh_extent_feb.indmem.png","Feb")+"</td>"
  txt(18741) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_mar.indmem.png","Mar")+"</td>"
  txt(18742) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_sep.indmem.png","Sep")+"</td>"
  txt(18743) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_oct.indmem.png","Oct")+"</td>"
  txt(18744) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_mon.indmem.png","Monthly")+"</td>"
  txt(18745) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent_anom_mon.indmem.png","Monthly Anomalies")+"</td>"
  txt(18746) = "<td>"+table_link_setup(OUTDIR,"siconc_sh_extent.climo.indmem.png","Climatology")+"</td></tr>"
  txt(18747) = "</table></div></div>"

  txt(19000) = "<div class="+quote+"row"+quote+">"
  txt(19001) = "<div class="+quote+"col"+quote+">"
  txt(19002) = "<table class="+quote+"table table-bordered"+quote+">"
  txt(19003) = "<h3 class="+quote+"display-6"+quote+">Regional Modes of Variability</h3>"
  txt(19004) = "<tr>"

  txt(19005) = "<td rowspan=7><b>SAM(Mashall)</b></td>"
  txt(19090) = "<td rowspan=4>Spatial Composites</td>"
  txt(19091) = "<td>SAM(+) - SAM(-)<br>SST/TAS/PSL<br>"
  if (isfilepresent2(OUTDIR+"samind.spatialcomp.indmem.jja0.png")) then
     txt(19101) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind_spatialcomp_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind_spatialcomp_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19102) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind_spatialcomp_jja0"+quote+">"
     txt(19103) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19104) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.indmem.jja0.png","Indiv")+"</li>"
     txt(19105) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19107) = "</ul></div>"
  else
     txt(19107) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.indmem.son0.png")) then
     txt(19111) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind_spatialcomp_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind_spatialcomp_son0"+quote+">SON<sup>0</sup></a> "
     txt(19112) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind_spatialcomp_son0"+quote+">"
     txt(19113) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19114) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.indmem.son0.png","Indiv")+"</li>"
     txt(19115) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.indmemdiff.son0.png","Bias")+"</li>"
     txt(19117) = "</ul></div>"
  else
     txt(19117) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.indmem.djf1.png")) then
     txt(19121) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind_spatialcomp_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind_spatialcomp_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19122) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind_spatialcomp_djf1"+quote+">"
     txt(19123) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19124) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.indmem.djf1.png","Indiv")+"</li>"
     txt(19125) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19127) = "</ul></div>"
  else
     txt(19127) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.indmem.mam1.png")) then
     txt(19131) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#nsamind_spatialcomp_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind_spatialcomp_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19132) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind_spatialcomp_mam1"+quote+">"
     txt(19133) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19134) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.indmem.mam1.png","Indiv")+"</li>"
     txt(19135) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19137) = "</ul></div></td>"
  else
     txt(19137) = " MAM<sup>1</sup></td>"
  end if

  txt(19150) = "<td>SAM(+) - SAM(-)<br>PR<br>"
  if (isfilepresent2(OUTDIR+"samind.spatialcomp.pr.indmem.jja0.png")) then
     txt(19151) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind_spatialcomp_pr_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind_spatialcomp_pr_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19152) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind_spatialcomp_pr_jja0"+quote+">"
     txt(19153) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19154) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.pr.indmem.jja0.png","Indiv")+"</li>"
     txt(19155) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.pr.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19157) = "</ul></div>"
  else
     txt(19157) = "JJA<sup>0</sup>"
  end if


  if (isfilepresent2(OUTDIR+"samind.spatialcomp.pr.indmem.son0.png")) then
     txt(19161) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind_spatialcomp_pr_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind_spatialcomp_pr_son0"+quote+">SON<sup>0</sup></a> "
     txt(19162) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind_spatialcomp_pr_son0"+quote+">"
     txt(19163) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19164) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.pr.indmem.son0.png","Indiv")+"</li>"
     txt(19165) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.pr.indmemdiff.son0.png","Bias")+"</li>"
     txt(19167) = "</ul></div>"
  else
     txt(19167) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.pr.indmem.djf1.png")) then
     txt(19171) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind_spatialcomp_pr_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind_spatialcomp_pr_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19172) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind_spatialcomp_pr_djf1"+quote+">"
     txt(19173) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19174) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.pr.indmem.djf1.png","Indiv")+"</li>"
     txt(19175) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.pr.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19177) = "</ul></div>"
  else
     txt(19177) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.pr.indmem.mam1.png")) then
     txt(19181) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind_spatialcomp_pr_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind_spatialcomp_pr_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19182) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind_spatialcomp_pr_mam1"+quote+">"
     txt(19183) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19184) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.pr.indmem.mam1.png","Indiv")+"</li>"
     txt(19185) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.pr.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19187) = "</ul></div></td></tr>"
  else
     txt(19187) = " MAM<sup>1</sup></td></tr>"
  end if

  txt(19191) = "<tr><td>SAM(+) SST/TAS/PSL<br>"
  if (isfilepresent2(OUTDIR+"samind.spatialcomp.psam.indmem.jja0.png")) then
     txt(19201) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.psam_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.psam_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19202) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.psam_jja0"+quote+">"
     txt(19203) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19204) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.indmem.jja0.png","Indiv")+"</li>"
     txt(19205) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19207) = "</ul></div>"
  else
     txt(19207) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.psam.indmem.son0.png")) then
     txt(19211) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.psam_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.psam_son0"+quote+">SON<sup>0</sup></a> "
     txt(19212) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.psam_son0"+quote+">"
     txt(19213) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19214) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.indmem.son0.png","Indiv")+"</li>"
     txt(19215) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.indmemdiff.son0.png","Bias")+"</li>"
     txt(19217) = "</ul></div>"
  else
     txt(19217) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.psam.indmem.djf1.png")) then
     txt(19221) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.psam_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.psam_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19222) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.psam_djf1"+quote+">"
     txt(19223) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19224) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.indmem.djf1.png","Indiv")+"</li>"
     txt(19225) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19227) = "</ul></div>"
  else
     txt(19227) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.psam.indmem.mam1.png")) then
     txt(19231) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.psam_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.psam_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19232) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.psam_mam1"+quote+">"
     txt(19233) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19234) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.indmem.mam1.png","Indiv")+"</li>"
     txt(19235) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19237) = "</ul></div></td>"
  else
     txt(19237) = " MAM<sup>1</sup></td>"
  end if

  txt(19250) = "<td>SAM(+) PR<br>"
  if (isfilepresent2(OUTDIR+"samind.spatialcomp.psam.pr.indmem.jja0.png")) then
     txt(19251) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.psam_pr_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.psam_pr_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19252) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.psam_pr_jja0"+quote+">"
     txt(19253) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19254) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.pr.indmem.jja0.png","Indiv")+"</li>"
     txt(19255) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.pr.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19257) = "</ul></div>"
  else
     txt(19257) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.psam.pr.indmem.son0.png")) then
     txt(19261) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.psam_pr_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.psam_pr_son0"+quote+">SON<sup>0</sup></a> "
     txt(19262) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.psam_pr_son0"+quote+">"
     txt(19263) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19264) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.pr.indmem.son0.png","Indiv")+"</li>"
     txt(19265) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.pr.indmemdiff.son0.png","Bias")+"</li>"
     txt(19267) = "</ul></div>"
  else
     txt(19267) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.psam.pr.indmem.djf1.png")) then
     txt(19271) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.psam_pr_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.psam_pr_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19272) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.psam_pr_djf1"+quote+">"
     txt(19273) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19274) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.pr.indmem.djf1.png","Indiv")+"</li>"
     txt(19275) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.pr.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19277) = "</ul></div>"
  else
     txt(19277) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.psam.pr.indmem.mam1.png")) then
     txt(19281) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.psam_pr_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.psam_pr_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19282) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.psam_pr_mam1"+quote+">"
     txt(19283) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19284) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.pr.indmem.mam1.png","Indiv")+"</li>"
     txt(19285) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.psam.pr.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19287) = "</ul></div></td></tr>"
  else
     txt(19287) = " MAM<sup>1</sup></td></tr>"
  end if

  txt(19291) = "<tr><td>SAM(-) SST/TAS/PSL<br>"
  if (isfilepresent2(OUTDIR+"samind.spatialcomp.nsam.indmem.jja0.png")) then
     txt(19301) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.nsam_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.nsam_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19302) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.nsam_jja0"+quote+">"
     txt(19303) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19304) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.indmem.jja0.png","Indiv")+"</li>"
     txt(19305) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19307) = "</ul></div>"
  else
     txt(19307) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.nsam.indmem.son0.png")) then
     txt(19311) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.nsam_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.nsam_son0"+quote+">SON<sup>0</sup></a> "
     txt(19312) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.nsam_son0"+quote+">"
     txt(19313) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19314) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.indmem.son0.png","Indiv")+"</li>"
     txt(19315) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.indmemdiff.son0.png","Bias")+"</li>"
     txt(19317) = "</ul></div>"
  else
     txt(19317) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.nsam.indmem.djf1.png")) then
     txt(19321) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.nsam_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.nsam_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19322) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.nsam_djf1"+quote+">"
     txt(19323) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19324) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.indmem.djf1.png","Indiv")+"</li>"
     txt(19325) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19327) = "</ul></div>"
  else
     txt(19327) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.nsam.indmem.mam1.png")) then
     txt(19331) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.nsam_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.nsam_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19332) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.nsam_mam1"+quote+">"
     txt(19333) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19334) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.indmem.mam1.png","Indiv")+"</li>"
     txt(19335) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19337) = "</ul></div></td>"
  else
     txt(19337) = " MAM<sup>1</sup></td>"
  end if

  txt(19350) = "<td>SAM(-) PR<br>"
  if (isfilepresent2(OUTDIR+"samind.spatialcomp.nsam.pr.indmem.jja0.png")) then
     txt(19351) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.nsam_pr_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.nsam_pr_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19352) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.nsam_pr_jja0"+quote+">"
     txt(19353) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19354) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.pr.indmem.jja0.png","Indiv")+"</li>"
     txt(19355) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.pr.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19357) = "</ul></div>"
  else
     txt(19357) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.nsam.pr.indmem.son0.png")) then
     txt(19361) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.nsam_pr_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.nsam_pr_son0"+quote+">SON<sup>0</sup></a> "
     txt(19362) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.nsam_pr_son0"+quote+">"
     txt(19363) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19364) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.pr.indmem.son0.png","Indiv")+"</li>"
     txt(19365) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.pr.indmemdiff.son0.png","Bias")+"</li>"
     txt(19367) = "</ul></div>"
  else
     txt(19367) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.nsam.pr.indmem.djf1.png")) then
     txt(19371) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.nsam_pr_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.nsam_pr_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19372) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.nsam_pr_djf1"+quote+">"
     txt(19373) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19374) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.pr.indmem.djf1.png","Indiv")+"</li>"
     txt(19375) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.pr.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19377) = "</ul></div>"
  else
     txt(19377) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"samind.spatialcomp.nsam.pr.indmem.mam1.png")) then
     txt(19381) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.spatialcomp.nsam_pr_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.spatialcomp.nsam_pr_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19382) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.spatialcomp.nsam_pr_mam1"+quote+">"
     txt(19383) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19384) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.pr.indmem.mam1.png","Indiv")+"</li>"
     txt(19385) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.spatialcomp.nsam.pr.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19387) = "</ul></div></td></tr>"
  end if

  txt(19390) = "<tr>"
  txt(19400) = "<td>"
  if (isfilepresent2(OUTDIR+"samind.hov.psam.indmem.png")) then
     txt(19401) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.hov.psam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.hov.psam"+quote+">SAM(+) Hovm&ouml;ller</a> "
     txt(19402) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.hov.psam"+quote+">"
     txt(19403) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19404) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.hov.psam.indmem.png","Indiv")+"</li>"
     txt(19405) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.hov.psam.indmemdiff.png","Bias")+"</li>"
     txt(19407) = "</ul></div></td>"
  else
     txt(19407) = "SAM(+) Hovm&ouml;ller</td>"
  end if
  txt(19410) = "<td>"
  if (isfilepresent2(OUTDIR+"samind.hov.nsam.indmem.png")) then
     txt(19411) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind.hov.nsam"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind.hov.nsam"+quote+">SAM(-) Hovm&ouml;ller</a> "
     txt(19412) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind.hov.nsam"+quote+">"
     txt(19413) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19414) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.hov.nsam.indmem.png","Indiv")+"</li>"
     txt(19415) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.hov.nsam.indmemdiff.png","Bias")+"</li>"
     txt(19417) = "</ul></div></td></tr>"
  else
     txt(19417) = "SAM(-) Hovm&ouml;ller</td></tr>"
  end if

  txt(19419) = "<tr>"
  txt(19500) = "<td rowspan=3>SAM index</td>"
  txt(19501) = "<td>"+table_link_setup(OUTDIR,"samind.timeseries.indmem.png","Timeseries")+"</td>"
  txt(19510) = "<td>"+table_link_setup(OUTDIR,"samind.monstddev.indmem.png","Monthly Std. Dev.")+"</td></tr>"
  txt(19511) = "<tr><td>"+table_link_setup(OUTDIR,"samind.powspec.indmem.png","Power Spectra")+"</td>"
  txt(19512) = "<td>"
  if (isfilepresent2(OUTDIR+"samind.wavelet.indmem.png")) then
     txt(19513) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#samind_wavelet"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"samind_wavelet"+quote+">Wavelet</a> "
     txt(19514) = "<div class="+quote+"collapse"+quote+" id="+quote+"samind_wavelet"+quote+">"
     txt(19515) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19516) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.wavelet.indmem.png","Indiv")+"</li>"
     txt(19517) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"samind.wavelet.indmemdiff.png","Bias")+"</li>"
     txt(19518) = "</ul></div>"
  else
     txt(19513) = "Wavelet"
  end if
  txt(19519) = "</td></tr>"
  txt(19520) = "<tr><td>"+table_link_setup(OUTDIR,"samind.autocor.indmem.png","Autocorrelation")+"</td>"
  txt(19521) = "<td>"+table_link_setup(OUTDIR,"scsamind.timeseries.indmem.png","Cumulative SAM index")+"</td></tr>"

  txt(19605) = "<td rowspan=7><b>ASL(Hosking)</b></td>"
  txt(19690) = "<td rowspan=4>Spatial Composites</td>"
  txt(19691) = "<td>ASL(+) - ASL(-)<br>SST/TAS/PSL<br>"
  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.indmem.jja0.png")) then
     txt(19701) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19702) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp_jja0"+quote+">"
     txt(19703) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19704) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.indmem.jja0.png","Indiv")+"</li>"
     txt(19705) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19707) = "</ul></div>"
  else
     txt(19707) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.indmem.son0.png")) then
     txt(19711) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp_son0"+quote+">SON<sup>0</sup></a> "
     txt(19712) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp_son0"+quote+">"
     txt(19713) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19714) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.indmem.son0.png","Indiv")+"</li>"
     txt(19715) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.indmemdiff.son0.png","Bias")+"</li>"
     txt(19717) = "</ul></div>"
  else
     txt(19717) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.indmem.djf1.png")) then
     txt(19721) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19722) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp_djf1"+quote+">"
     txt(19723) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19724) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.indmem.djf1.png","Indiv")+"</li>"
     txt(19725) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19727) = "</ul></div>"
  else
     txt(19727) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.indmem.mam1.png")) then
     txt(19731) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#naslind_spatialcomp_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19732) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp_mam1"+quote+">"
     txt(19733) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19734) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.indmem.mam1.png","Indiv")+"</li>"
     txt(19735) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19737) = "</ul></div></td>"
  else
     txt(19737) = " MAM<sup>1</sup></td>"
  end if

  txt(19750) = "<td>ASL(+) - ASL(-)<br>PR<br>"
  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pr.indmem.jja0.png")) then
     txt(19751) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp_pr_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp_pr_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19752) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp_pr_jja0"+quote+">"
     txt(19753) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19754) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pr.indmem.jja0.png","Indiv")+"</li>"
     txt(19755) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pr.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19757) = "</ul></div>"
  else
     txt(19757) = "JJA<sup>0</sup>"
  end if


  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pr.indmem.son0.png")) then
     txt(19761) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp_pr_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp_pr_son0"+quote+">SON<sup>0</sup></a> "
     txt(19762) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp_pr_son0"+quote+">"
     txt(19763) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19764) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pr.indmem.son0.png","Indiv")+"</li>"
     txt(19765) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pr.indmemdiff.son0.png","Bias")+"</li>"
     txt(19767) = "</ul></div>"
  else
     txt(19767) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pr.indmem.djf1.png")) then
     txt(19771) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp_pr_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp_pr_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19772) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp_pr_djf1"+quote+">"
     txt(19773) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19774) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pr.indmem.djf1.png","Indiv")+"</li>"
     txt(19775) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pr.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19777) = "</ul></div>"
  else
     txt(19777) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pr.indmem.mam1.png")) then
     txt(19781) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp_pr_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp_pr_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19782) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp_pr_mam1"+quote+">"
     txt(19783) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19784) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pr.indmem.mam1.png","Indiv")+"</li>"
     txt(19785) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pr.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19787) = "</ul></div></td></tr>"
  else
     txt(19787) = " MAM<sup>1</sup></td></tr>"
  end if

  txt(19791) = "<tr><td>ASL(+) SST/TAS/PSL<br>"
  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pasl.indmem.jja0.png")) then
     txt(19801) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.pasl_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.pasl_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19802) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.pasl_jja0"+quote+">"
     txt(19803) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19804) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.indmem.jja0.png","Indiv")+"</li>"
     txt(19805) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19807) = "</ul></div>"
  else
     txt(19807) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pasl.indmem.son0.png")) then
     txt(19811) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.pasl_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.pasl_son0"+quote+">SON<sup>0</sup></a> "
     txt(19812) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.pasl_son0"+quote+">"
     txt(19813) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19814) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.indmem.son0.png","Indiv")+"</li>"
     txt(19815) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.indmemdiff.son0.png","Bias")+"</li>"
     txt(19817) = "</ul></div>"
  else
     txt(19817) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pasl.indmem.djf1.png")) then
     txt(19821) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.pasl_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.pasl_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19822) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.pasl_djf1"+quote+">"
     txt(19823) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19824) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.indmem.djf1.png","Indiv")+"</li>"
     txt(19825) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19827) = "</ul></div>"
  else
     txt(19827) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pasl.indmem.mam1.png")) then
     txt(19831) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.pasl_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.pasl_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19832) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.pasl_mam1"+quote+">"
     txt(19833) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19834) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.indmem.mam1.png","Indiv")+"</li>"
     txt(19835) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19837) = "</ul></div></td>"
  else
     txt(19837) = " MAM<sup>1</sup></td>"
  end if

  txt(19850) = "<td>ASL(+) PR<br>"
  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pasl.pr.indmem.jja0.png")) then
     txt(19851) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.pasl_pr_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.pasl_pr_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19852) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.pasl_pr_jja0"+quote+">"
     txt(19853) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19854) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.pr.indmem.jja0.png","Indiv")+"</li>"
     txt(19855) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.pr.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19857) = "</ul></div>"
  else
     txt(19857) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pasl.pr.indmem.son0.png")) then
     txt(19861) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.pasl_pr_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.pasl_pr_son0"+quote+">SON<sup>0</sup></a> "
     txt(19862) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.pasl_pr_son0"+quote+">"
     txt(19863) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19864) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.pr.indmem.son0.png","Indiv")+"</li>"
     txt(19865) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.pr.indmemdiff.son0.png","Bias")+"</li>"
     txt(19867) = "</ul></div>"
  else
     txt(19867) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pasl.pr.indmem.djf1.png")) then
     txt(19871) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.pasl_pr_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.pasl_pr_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19872) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.pasl_pr_djf1"+quote+">"
     txt(19873) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19874) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.pr.indmem.djf1.png","Indiv")+"</li>"
     txt(19875) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.pr.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19877) = "</ul></div>"
  else
     txt(19877) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.pasl.pr.indmem.mam1.png")) then
     txt(19881) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.pasl_pr_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.pasl_pr_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19882) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.pasl_pr_mam1"+quote+">"
     txt(19883) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19884) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.pr.indmem.mam1.png","Indiv")+"</li>"
     txt(19885) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.pasl.pr.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19887) = "</ul></div></td></tr>"
  else
     txt(19887) = " MAM<sup>1</sup></td></tr>"
  end if


  txt(19891) = "<tr><td>ASL(-) SST/TAS/PSL<br>"
  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.nasl.indmem.jja0.png")) then
     txt(19901) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.nasl_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.nasl_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19902) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.nasl_jja0"+quote+">"
     txt(19903) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19904) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.indmem.jja0.png","Indiv")+"</li>"
     txt(19905) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19907) = "</ul></div>"
  else
     txt(19907) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.nasl.indmem.son0.png")) then
     txt(19911) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.nasl_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.nasl_son0"+quote+">SON<sup>0</sup></a> "
     txt(19912) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.nasl_son0"+quote+">"
     txt(19913) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19914) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.indmem.son0.png","Indiv")+"</li>"
     txt(19915) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.indmemdiff.son0.png","Bias")+"</li>"
     txt(19917) = "</ul></div>"
  else
     txt(19917) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.nasl.indmem.djf1.png")) then
     txt(19921) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.nasl_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.nasl_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19922) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.nasl_djf1"+quote+">"
     txt(19923) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19924) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.indmem.djf1.png","Indiv")+"</li>"
     txt(19925) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19927) = "</ul></div>"
  else
     txt(19927) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.nasl.indmem.mam1.png")) then
     txt(19931) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.nasl_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.nasl_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19932) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.nasl_mam1"+quote+">"
     txt(19933) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19934) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.indmem.mam1.png","Indiv")+"</li>"
     txt(19935) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19937) = "</ul></div></td>"
  else
     txt(19937) = " MAM<sup>1</sup></td>"
  end if

  txt(19950) = "<td>ASL(-) PR<br>"
  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.nasl.pr.indmem.jja0.png")) then
     txt(19951) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.nasl_pr_jja0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.nasl_pr_jja0"+quote+">JJA<sup>0</sup></a> "
     txt(19952) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.nasl_pr_jja0"+quote+">"
     txt(19953) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19954) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.pr.indmem.jja0.png","Indiv")+"</li>"
     txt(19955) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.pr.indmemdiff.jja0.png","Bias")+"</li>"
     txt(19957) = "</ul></div>"
  else
     txt(19957) = "JJA<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.nasl.pr.indmem.son0.png")) then
     txt(19961) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.nasl_pr_son0"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.nasl_pr_son0"+quote+">SON<sup>0</sup></a> "
     txt(19962) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.nasl_pr_son0"+quote+">"
     txt(19963) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19964) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.pr.indmem.son0.png","Indiv")+"</li>"
     txt(19965) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.pr.indmemdiff.son0.png","Bias")+"</li>"
     txt(19967) = "</ul></div>"
  else
     txt(19967) = " SON<sup>0</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.nasl.pr.indmem.djf1.png")) then
     txt(19971) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.nasl_pr_djf1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.nasl_pr_djf1"+quote+">DJF<sup>1</sup></a> "
     txt(19972) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.nasl_pr_djf1"+quote+">"
     txt(19973) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19974) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.pr.indmem.djf1.png","Indiv")+"</li>"
     txt(19975) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.pr.indmemdiff.djf1.png","Bias")+"</li>"
     txt(19977) = "</ul></div>"
  else
     txt(19977) = " DJF<sup>1</sup>"
  end if

  if (isfilepresent2(OUTDIR+"aslind.spatialcomp.nasl.pr.indmem.mam1.png")) then
     txt(19981) = " <a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_spatialcomp.nasl_pr_mam1"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_spatialcomp.nasl_pr_mam1"+quote+">MAM<sup>1</sup></a> "
     txt(19982) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_spatialcomp.nasl_pr_mam1"+quote+">"
     txt(19983) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(19984) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.pr.indmem.mam1.png","Indiv")+"</li>"
     txt(19985) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.spatialcomp.nasl.pr.indmemdiff.mam1.png","Bias")+"</li>"
     txt(19987) = "</ul></div></td></tr>"
  end if

  txt(19990) = "<tr>"
  txt(20000) = "<td>"
  if (isfilepresent2(OUTDIR+"aslind.hov.pasl.indmem.png")) then
     txt(20001) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_hov_pasl"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_hov_pasl"+quote+">ASL(+) Hovm&ouml;ller</a> "
     txt(20002) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_hov_pasl"+quote+">"
     txt(20003) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(20004) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.hov.pasl.indmem.png","Indiv")+"</li>"
     txt(20005) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.hov.pasl.indmemdiff.png","Bias")+"</li>"
     txt(20007) = "</ul></div></td>"
  else
     txt(20007) = "ASL(+) Hovm&ouml;ller</td>"
  end if
  txt(20010) = "<td>"
  if (isfilepresent2(OUTDIR+"aslind.hov.nasl.indmem.png")) then
     txt(20011) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_hov_nasl"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_hov_nasl"+quote+">ASL(-) Hovm&ouml;ller</a> "
     txt(20012) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_hov_nasl"+quote+">"
     txt(20013) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(20014) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.hov.nasl.indmem.png","Indiv")+"</li>"
     txt(20015) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.hov.nasl.indmemdiff.png","Bias")+"</li>"
     txt(20017) = "</ul></div></td></tr>"
  else
     txt(20017) = "ASL(-) Hovm&ouml;ller</td></tr>"
  end if

  txt(20019) = "<tr>"
  txt(20100) = "<td rowspan=3>ASL index</td>"
  txt(20101) = "<td>"+table_link_setup(OUTDIR,"aslind.timeseries.indmem.png","Timeseries")+"</td>"
  txt(20110) = "<td>"+table_link_setup(OUTDIR,"aslind.monstddev.indmem.png","Monthly Std. Dev.")+"</td></tr>"
  txt(20111) = "<tr><td>"+table_link_setup(OUTDIR,"aslind.powspec.indmem.png","Power Spectra")+"</td>"
  txt(20112) = "<td>"
  if (isfilepresent2(OUTDIR+"aslind.wavelet.indmem.png")) then
     txt(20113) = "<a class="+quote+"collapse-link"+quote+" data-toggle="+quote+"collapse"+quote+" href="+quote+"#aslind_wavelet"+quote+" role="+quote+"button"+quote+" aria-expanded="+quote+"false"+quote+" aria-controls="+quote+"aslind_wavelet"+quote+">Wavelet</a> "
     txt(20114) = "<div class="+quote+"collapse"+quote+" id="+quote+"aslind_wavelet"+quote+">"
     txt(20115) = "<ul class="+quote+"list-inline my-0"+quote+">"
     txt(20116) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.wavelet.indmem.png","Indiv")+"</li>"
     txt(20117) = "<li class="+quote+"list-inline-item"+quote+">"+table_link_setup_le(OUTDIR,"aslind.wavelet.indmemdiff.png","Bias")+"</li>"
     txt(20118) = "</ul></div>"
  else
     txt(20113) = "Wavelet"
  end if
  txt(20119) = "</td></tr>"
  txt(20120) = "<tr><td>"+table_link_setup(OUTDIR,"aslind.autocor.indmem.png","Autocorrelation")+"</td>"
  txt(20121) = "<td>"+table_link_setup(OUTDIR,"scaslind.timeseries.indmem.png","Cumulative ASL index")+"</td></tr>"

  txt(21000) = "</div></body></html>"

  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  tt2 := ind(.not.ismissing(txt2))
  txt3 := txt2(tt2)
  asciiwrite(OUTDIR+"index2.html",txt3)
  delete([/txt,tt,tt2,txt2,txt3/])
;----------------------------------------------------------------------------
; Namelist pages
  txt := new(500,"string")  
  
  txt(0) = "<HTML><HEAD><TITLE>Climate Variability Diagnostics Package</TITLE><STYLE>"
  txt(1) = "body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
  txt(2) = "img.title {width:990; height:105; align:left}"
  txt(3) = "p.subtitle1 {font-size:20pt; color:darkgray}"
  txt(4) = "p.subtitle {font-size:20pt; color:black; text-align:center; font-weight:bold}"
  txt(5) = "p.btext {font-size:12pt; text-align:left}"
  txt(6) = "p.btext2 {font-size:9pt; text-align:left}"
  txt(7) = "p.c {font-size:9pt; text-align:left, white-space:pre}"
  txt(9) = "td.s1 {text-align:left; font-size:11pt}"
  
  txt(20) = "td {text-align:center; font-size:12pt}"
  txt(21) = "td.s1 {text-align:left; font-size:11pt}"
  txt(22) = "td.tablehdr {text-align:center; font-size:17pt}"
  txt(23) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}"
  txt(24) = "</STYLE></HEAD><BODY>"
  txt(25) = "<img class="+quote+"img-fluid"+quote+" src="+quote+"cas_cvdp-le.png"+quote+" alt="+quote+"CVDP-LE logo"+quote+">"
  txt(26)= "<TABLE width='990' border=0 cellpadding=6>"
  txt(27) = "<tr><td width='30'><p class=btext>Go to:</p></td><td class=s1 width='380'><a href="+quote+"http://dx.doi.org/10.5065/h7c7-f961"+quote+">User's Guide</a><br><a href="+quote+"index.html"+quote+">Diagnostics Plots</a><br><hr>"

  txt(28) = "Input Namelists: <b>Observations</b> | <a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
;  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><p class=subtitle>"+webtitle+"</p></td></tr></table><hr width=990 align=left>"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Input Namelist: Observations</p>" 
  z := asciiread(OUTDIR+"namelist_obs",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_obs.html",txt2)

  txt(28) = "Input Namelists: <a href="+quote+"namelist_obs.html"+quote+">Observations</a> | <b>Simulations</b><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Input Namelist: Simulations</p>" 
  z := asciiread(OUTDIR+"namelist",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_simulations.html",txt2)

  txt(28) = "Input Namelists: <a href="+quote+"namelist_obs.html"+quote+">Observations</a> | <a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <b>MSFTMZ</b> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: MSFTMZ</p>" 
  z := asciiread(OUTDIR+"namelist_moc",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_msftmz.html",txt2)

  txt(28) = "Input Namelists: <a href="+quote+"namelist_obs.html"+quote+">Observations</a> | <a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <b>PR</b> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: PR</p>" 
  z := asciiread(OUTDIR+"namelist_prect",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_pr.html",txt2)

  txt(28) = "Input Namelists: <a href="+quote+"namelist_obs.html"+quote+">Observations</a> | <a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <b>PSL</b> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: PSL</p>" 
  z := asciiread(OUTDIR+"namelist_psl",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_psl.html",txt2)

  txt(28) = "Input Namelists: <a href="+quote+"namelist_obs.html"+quote+">Observations</a> | <a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><b>SICONC NH</b> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: SICONC NH</p>" 
  z := asciiread(OUTDIR+"namelist_aice_nh",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_siconc_nh.html",txt2)

  txt(28) = "Input Namelists: <a href="+quote+"namelist_obs.html"+quote+">Observations</a> | <a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <b>SICONC SH</b> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: SICONC SH</p>" 
  z := asciiread(OUTDIR+"namelist_aice_sh",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_siconc_sh.html",txt2)

  txt(28) = "Input Namelists: <a href="+quote+"namelist_obs.html"+quote+">Observations</a> | <a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <b>TAS</b> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: TAS</p>" 
  z := asciiread(OUTDIR+"namelist_trefht",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_tas.html",txt2)

  txt(28) = "Input Namelists: <a href="+quote+"namelist_obs.html"+quote+">Observations</a> | <a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+webtitle+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: TS</p>" 
  z := asciiread(OUTDIR+"namelist_ts",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>CVDP-LE Version "+VERSION+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_ts.html",txt2)

  print("Finished: webpage.ncl")  
end

