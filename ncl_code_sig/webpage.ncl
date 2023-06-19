; Create the index.html, methodology.html, and metrics.html web pages.
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$CVDP_SCRIPTS/functions.ncl"

begin
  print("Starting: webpage.ncl")

  OUTDIR      = getenv("OUTDIR") 
  VERSION     = getenv("VERSION")
  OT          = getenv("OUTPUT_DATA")
  OPT_CLIMO   = getenv("OPT_CLIMO")
  CLIMO_SYEAR = getenv("CLIMO_SYEAR")
  CLIMO_EYEAR = getenv("CLIMO_EYEAR")
  OBS         = getenv("OBS")
 
  NCAR_CVDP_VER = "5.2.0"
  quote = str_get_dq()
  strs  = str_split(webtitle,";")
  title_str = new(2,string)
  if(dimsizes(strs).eq.2) then 
    title_str(:) = strs 
  else 
    title_str(0) = strs(0)
    title_str(1) = "" 
  end if 
  delete(strs)

  if (OPT_CLIMO.eq."Full") then
     subtxt = "Climatological Period Used: Full"
  end if
  if (OPT_CLIMO.eq."Custom") then
     if (toint(CLIMO_SYEAR).lt.0) then
        subtxt = "Climo. Period (relative to record end): "+CLIMO_SYEAR+"-"+CLIMO_EYEAR
     else
        subtxt = "Climatological Period Used: "+CLIMO_SYEAR+"-"+CLIMO_EYEAR
     end if
  end if

  nsim_noobs = numAsciiRow("namelist")
  na = asciiread("namelist",(/nsim_noobs/),"string")
  names = new(nsim_noobs,"string")
  delim = "|"
  do gg = 0,nsim_noobs-1
     names(gg) = str_strip(str_get_field(na(gg),1,delim))
  end do
;  print(names)
  
  txt = new(2000,"string")
  quote = str_get_dq()
  
  txt(0) = "<html><head><title>Climate Variability Diagnostics Package</title>"
  txt(1) = "<link rel="+quote+"stylesheet"+quote+" href="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"+quote+" integrity="+quote+"sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"+quote+" crossorigin="+quote+"anonymous"+quote+">"
  txt(2) = "<script src="+quote+"https://code.jquery.com/jquery-3.3.1.slim.min.js"+quote+" integrity="+quote+"sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
  txt(3) = "<script src="+quote+"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"+quote+" integrity="+quote+"sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
  txt(4) = "<script src="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"+quote+" integrity="+quote+"sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
  txt(5) = "<style>body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
  txt(6) = "img.title {width:990; height:105; align:left}"
  txt(7) = "p.subtitle {font-size:20pt; color:black; text-align:center; font-weight:bold}"
  txt(8) = "p.btext {font-size:11pt; text-align:left}"
  txt(9) = "font.s1 {font-size:13.5pt; text-align:left}"
  txt(10) = "td {text-align:center; font-size:12pt}"
  txt(11) = "td.s1 {text-align:left; font-size:11pt}"
  txt(12) = "td.s2 {border-bottom: 4px double darkgray}"
  txt(13) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}"
  txt(14) = "</style></head>"

  txt(15) = "<body><div class="+quote+"container"+quote+">"
	 txt(16) = "<div class="+quote+"row"+quote+">"
		txt(17) = "<img class="+quote+"img-fluid"+quote+" src="+quote+"e3sm-cvdp.png"+quote+" alt="+quote+"CVDP logo"+quote+">"
  txt(18) = "</div>"

  txt(19) = "<div class="+quote+"row"+quote+"><div class="+quote+"col"+quote+"><table class="+quote+"table my-0"+quote+">"
		txt(20) = "<tr><td class="+quote+"text-left"+quote+"><ul class="+quote+"list-inline my-0"+quote+"><li class="+quote+"list-inline-item"+quote+"><font class=s1><a href="+quote+"methodology.html"+quote+">Methodology and Definitions</a></font></li><br>"
  if (isfilepresent2(OUTDIR+"metrics.txt")) then
     if (isfilepresent2(OUTDIR+"metrics.table_1.gif")) then
        txt(21) = "<li class="+quote+"list-inline-item"+quote+">Summary Metrics: <a href="+quote+"metrics.table_0.html"+quote+">Pattern Correlations</a> | <a href="+quote+"metrics.table_14.html"+quote+">RMS</a></li><br>"
     else
        txt(21) = "<li class="+quote+"list-inline-item"+quote+"><a href="+quote+"metrics.html"+quote+">Metrics Table</a></li><br>"
     end if
  end if

  if (OBS.eq."True") then
     txt(22) = "<li class="+quote+"list-inline-item"+quote+">Namelists: <a href="+quote+"namelist_obs.html"+quote+">Input</a> | <a href="+quote+"namelist_msftmz.html"+quote+">Derived</a></li><br>"
  else
     txt(22) = "<li class="+quote+"list-inline-item"+quote+">Namelists: <a href="+quote+"namelist_models.html"+quote+">Input</a> | <a href="+quote+"namelist_msftmz.html"+quote+">Derived</a></li><br>"
  end if

  txt(23) = "<li class="+quote+"list-inline-item"+quote+">"+subtxt+"</li><br><li class="+quote+"list-inline-item"+quote+">Created: "+systemfunc("date")+"</li><br><li class="+quote+"list-inline-item"+quote+">Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</li></ul></td>"

  txt(24) = "<td><p class=subtitle>"+title_str(0)+"</p><p class=subtitle>"+title_str(1)+"</p></td></tr></table></div></div>"
  delete([/subtxt/])

  txt(37)   = "<a name="+quote+"stddev"+quote+">"
  txt(38) = "<div class="+quote+"row"+quote+">"
  txt(39) = "<div class="+quote+"col"+quote+">"
  txt(40) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(41) = "<h3 class="+quote+"display-6"+quote+">Standard Deviations (link to <a href="+quote+"#mean"+quote+">Mean Climatology)</a></h3>"
  txt(42) = "<tr><td><b>SST</b></td><td>"+table_link_setup(OUTDIR,"sst.stddev.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"sst.stddev.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"sst.stddev.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"sst.stddev.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"sst.stddev.ann.png","Annual")+"</td></tr>"    
  txt(43) = "<tr><td><b>TAS</b></td><td>"+table_link_setup(OUTDIR,"tas.stddev.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"tas.stddev.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"tas.stddev.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"tas.stddev.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"tas.stddev.ann.png","Annual")+"</td></tr>"    
  txt(44) = "<tr><td><b>PSL</b></td><td>"+table_link_setup(OUTDIR,"psl.stddev.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psl.stddev.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"psl.stddev.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psl.stddev.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"psl.stddev.ann.png","Annual")+"</td></tr>"    
  txt(45) = "<tr><td><b>PR</b></td><td>"+table_link_setup(OUTDIR,"pr.stddev.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pr.stddev.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"pr.stddev.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pr.stddev.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"pr.stddev.ann.png","Annual")+"</td></tr>"    
  txt(46) = "<tr><td><b>SND</b></td><td>"+table_link_setup(OUTDIR,"snd.stddev.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"snd.stddev.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"snd.stddev.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"snd.stddev.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"snd.stddev.ann.png","Annual")+"</td></tr>"    
  txt(47) = "<tr><td><b>SIC NH</b></td><td>"+table_link_setup(OUTDIR,"aice.stddev.nh.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"aice.stddev.nh.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"aice.stddev.nh.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"aice.stddev.nh.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"aice.stddev.nh.ann.png","Annual")+"</td></tr>"      
  txt(48) = "<tr><td><b>SIC SH</b></td><td>"+table_link_setup(OUTDIR,"aice.stddev.sh.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"aice.stddev.sh.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"aice.stddev.sh.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"aice.stddev.sh.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"aice.stddev.sh.ann.png","Annual")+"</td></tr>"      
  txt(49) = "</table></div></div>"  
  
  txt(68) = "<div class="+quote+"row"+quote+">"
  txt(69) = "<div class="+quote+"col"+quote+">"  
  txt(70) = "<table class="+quote+"table table-bordered"+quote+">"
  txt(71) = "<h3 class="+quote+"display-6"+quote+">Coupled Modes of Variability</h3>"  
  txt(72) = "<tr><td rowspan=12><b>ENSO</b></td>"
  txt(73) = "<td rowspan=2>Spatial Composites (DJF ENSO)</td><td colspan=3>SST/TAS/PSL<br>"+table_link_setup(OUTDIR,"nino34.spatialcomp.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"nino34.spatialcomp.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"nino34.spatialcomp.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"nino34.spatialcomp.mam1.png","MAM<sup>+1</sup>")+"</td>"
  txt(74) = "<td colspan=3>PR<br>"+table_link_setup(OUTDIR,"nino34.spatialcomp.pr.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"nino34.spatialcomp.pr.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"nino34.spatialcomp.pr.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"nino34.spatialcomp.pr.mam1.png","MAM<sup>+1</sup>")+"</td></tr>"
  txt(75) = "<tr><td colspan=3>"+table_link_setup(OUTDIR,"nino34.hov.elnino.png","El Ni&ntilde;o Hovm&ouml;ller")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"nino34.hov.lanina.png","La Ni&ntilde;a Hovm&ouml;ller")+"</td></tr>"
  txt(76) = "<tr class=s1><td rowspan=3>Ni&ntilde;o3.4</td><td colspan=3>"+table_link_setup(OUTDIR,"nino34.timeseries.png","Timeseries")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"nino34.powspec.png","Power Spectra")+"</td></tr>"
  txt(77) = "<tr><td colspan=3>"+table_link_setup(OUTDIR,"nino34.monstddev.png","Monthly  Std. Dev.")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"nino34.runstddev.png","Running Std. Dev.")+"</td></tr>"
  txt(78) = "<tr><td colspan=3>"+table_link_setup(OUTDIR,"nino34.autocor.png","Autocorrelation")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"nino34.wavelet.png","Wavelet Analysis")+"</td></tr>"
  txt(79) = "<tr><td>Ni&ntilde;o3.4 SST Regressions</td><td>"+table_link_setup(OUTDIR,"nino34.tsreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nino34.tsreg.mam.png","MAM")+"</td>"
  txt(80) = "<td>"+table_link_setup(OUTDIR,"nino34.tsreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nino34.tsreg.son.png","SON")+"</td>"
  txt(81) = "<td>"+table_link_setup(OUTDIR,"nino34.tsreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nino34.tsreg.mon.png","Monthly")+"</td></tr>"
  txt(82) = "<tr><td>Ni&ntilde;o3.4 TAS Regressions</td><td>"+table_link_setup(OUTDIR,"nino34.trefhtreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nino34.trefhtreg.mam.png","MAM")+"</td>"
  txt(83) = "<td>"+table_link_setup(OUTDIR,"nino34.trefhtreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nino34.trefhtreg.son.png","SON")+"</td>"
  txt(84) = "<td>"+table_link_setup(OUTDIR,"nino34.trefhtreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nino34.trefhtreg.mon.png","Monthly")+"</td></tr>"
  txt(85) = "<tr><td>Ni&ntilde;o3.4 PSL Regressions</td><td>"+table_link_setup(OUTDIR,"nino34.pslreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nino34.pslreg.mam.png","MAM")+"</td>"
  txt(86) = "<td>"+table_link_setup(OUTDIR,"nino34.pslreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nino34.pslreg.son.png","SON")+"</td>"
  txt(87) = "<td>"+table_link_setup(OUTDIR,"nino34.pslreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nino34.pslreg.mon.png","Monthly")+"</td></tr>"
  txt(88) = "<tr><td>Ni&ntilde;o3.4 PR Regressions</td><td>"+table_link_setup(OUTDIR,"nino34.prectreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nino34.prectreg.mam.png","MAM")+"</td>"
  txt(89) = "<td>"+table_link_setup(OUTDIR,"nino34.prectreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nino34.prectreg.son.png","SON")+"</td>"
  txt(90) = "<td>"+table_link_setup(OUTDIR,"nino34.prectreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nino34.prectreg.mon.png","Monthly")+"</td></tr>"
  txt(91) = "<tr><td>Ni&ntilde;o3.4 OLR Regressions</td><td>"+table_link_setup(OUTDIR,"nino34.olrreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nino34.olrreg.mam.png","MAM")+"</td>"
  txt(92) = "<td>"+table_link_setup(OUTDIR,"nino34.olrreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nino34.olrreg.son.png","SON")+"</td>"
  txt(93) = "<td>"+table_link_setup(OUTDIR,"nino34.olrreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nino34.olrreg.mon.png","Monthly")+"</td></tr>"
  txt(94) = "<tr><td>Metrics Table (Pattern CORR)</td><td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patcor_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patcor_mam.png","MAM")+"</td>"
  txt(95) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patcor_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patcor_son.png","SON")+"</td>"
  txt(96) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patcor_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patcor_mon.png","Monthly")+"</td></tr>"
  txt(97) = "<tr><td>Metrics Table (Pattern RMSD)</td><td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patrms_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patrms_mam.png","MAM")+"</td>"
  txt(98) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patrms_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patrms_son.png","SON")+"</td>"
  txt(99) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patrms_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nino34_patrms_mon.png","Monthly")+"</td></tr>"

  txt(109) = "<tr><td><b>PDO</b></td>"  
  txt(110) = "<td>Regr: &nbsp;"+table_link_setup(OUTDIR,"pdo.png","SST")+"&nbsp;"+table_link_setup(OUTDIR,"pdo.tasreg.png","TAS")+"&nbsp;"+table_link_setup(OUTDIR,"pdo.prreg.png","PR")+"</td>"
  txt(111) = "<td colspan=3>"+table_link_setup(OUTDIR,"pdo.timeseries.png","Timeseries")+"</td>"
  txt(112) = "<td colspan=3>"+table_link_setup(OUTDIR,"pdo.powspec.png","Power Spectra")+"</td></tr>" 
  txt(113) = "<tr><td><b>IPO</b></td>"  
  txt(114) = "<td>Regr: &nbsp;"+table_link_setup(OUTDIR,"ipo.png","SST")+"&nbsp"+table_link_setup(OUTDIR,"ipo.tasreg.png","TAS")+"&nbsp;"+table_link_setup(OUTDIR,"ipo.prreg.png","PR")+"</td>"
  txt(115) = "<td colspan=3>"+table_link_setup(OUTDIR,"ipo.timeseries.png","Timeseries")+"</td>"
  txt(116) = "<td colspan=3>"+table_link_setup(OUTDIR,"ipo.powspec.png","Power Spectra")+"</td></tr>" 

  txt(117) = "<tr><td rowspan=2><b>AMO</b></td>"  
  txt(118) = "<td>Regr: &nbsp;"+table_link_setup(OUTDIR,"amo.png","SST")+"&nbsp;"+table_link_setup(OUTDIR,"amo.tasreg.png","TAS")+"&nbsp;"+table_link_setup(OUTDIR,"amo.prreg.png","PR")+"</td>"
  txt(119) = "<td rowspan=2 colspan=3>"+table_link_setup(OUTDIR,"amo.timeseries.png","Timeseries")+"</td>"
  txt(120) = "<td rowspan=2 colspan=3>"+table_link_setup(OUTDIR,"amo.powspec.png","Power Spectra")+"</td></tr>" 
  txt(121) = "<tr><td>Regr LP: &nbsp;"+table_link_setup(OUTDIR,"amo.lp.png","SST")+"&nbsp;"+table_link_setup(OUTDIR,"amo.lp.tasreg.png","TAS")+"&nbsp;"+table_link_setup(OUTDIR,"amo.lp.prreg.png","PR")+"</td></tr>"
  txt(122) = "<tr><td rowspan=3><b>AMOC</b></td>"  
  txt(123) = "<td>"+table_link_setup(OUTDIR,"amoc.mean.ann.png","Means")+"</td>"
  txt(124) = "<td colspan=3>"+table_link_setup(OUTDIR,"amoc.stddev.ann.png","Standard Deviations")+"</td>"
  txt(125) = "<td colspan=3>"+table_link_setup(OUTDIR,"amoc.ann.png","Patterns")+"</td></tr>"
  txt(126) = "<tr><td>"+table_link_setup(OUTDIR,"amoc.timeseries.ann.png","Timeseries")+"</td>"
  txt(127) = "<td colspan=3>"+table_link_setup(OUTDIR,"amoc.sstreg.ann.png","SST Regressions")+"</td>"
  txt(128) = "<td colspan=3>"+table_link_setup(OUTDIR,"amoc.tasreg.ann.png","TAS Regressions")+"</td></tr>"
  txt(129) = "<tr><td>"+table_link_setup(OUTDIR,"amoc.powspec.ann.png","Spectra")+"</td>"
  txt(130) = "<td colspan=6>"+table_link_setup(OUTDIR,"amoc_amo.leadlag.ann.png","AMO/AMOC Lag Correlations")+"</td></tr></table></div></div>" 


  txt(137) = "<div class="+quote+"row"+quote+">"
  txt(138) = "<div class="+quote+"col"+quote+">"
  txt(139) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(140) = "<h3 class="+quote+"display-6"+quote+">Atmospheric Modes of Variability</h3>"  
  txt(141) = "<tr><td rowspan=8><b>NAM</b></td>"
  txt(142) = "<td>Patterns (EOF)</td><td>"+table_link_setup(OUTDIR,"nam.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nam.mam.png","MAM")+"</td>"
  txt(143) = "<td>"+table_link_setup(OUTDIR,"nam.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nam.son.png","SON")+"</td>"
  txt(144) = "<td>"+table_link_setup(OUTDIR,"nam.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nam.mon.png","Monthly")+"</td></tr>"
  txt(145) = "<tr><td>Timeseries (EOF)</td><td>"+table_link_setup(OUTDIR,"nam.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nam.timeseries.mam.png","MAM")+"</td>"
  txt(146) = "<td>"+table_link_setup(OUTDIR,"nam.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nam.timeseries.son.png","SON")+"</td>"
  txt(147) = "<td>"+table_link_setup(OUTDIR,"nam.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nam.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(148) = "<tr><td>SST Regressions</td><td>"+table_link_setup(OUTDIR,"nam.tsreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nam.tsreg.mam.png","MAM")+"</td>"
  txt(149) = "<td>"+table_link_setup(OUTDIR,"nam.tsreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nam.tsreg.son.png","SON")+"</td>"
  txt(150) = "<td>"+table_link_setup(OUTDIR,"nam.tsreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nam.tsreg.mon.png","Monthly")+"</td></tr>"
  txt(151) = "<tr><td>TAS Regressions</td><td>"+table_link_setup(OUTDIR,"nam.trefhtreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nam.trefhtreg.mam.png","MAM")+"</td>"
  txt(152) = "<td>"+table_link_setup(OUTDIR,"nam.trefhtreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nam.trefhtreg.son.png","SON")+"</td>"
  txt(153) = "<td>"+table_link_setup(OUTDIR,"nam.trefhtreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nam.trefhtreg.mon.png","Monthly")+"</td></tr>"
  txt(154) = "<tr><td>PR Regressions</td><td>"+table_link_setup(OUTDIR,"nam.prectreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nam.prectreg.mam.png","MAM")+"</td>"
  txt(155) = "<td>"+table_link_setup(OUTDIR,"nam.prectreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nam.prectreg.son.png","SON")+"</td>"
  txt(156) = "<td>"+table_link_setup(OUTDIR,"nam.prectreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nam.prectreg.mon.png","Monthly")+"</td></tr>"
  txt(157) = "<tr><td>OLR Regressions</td><td>"+table_link_setup(OUTDIR,"nam.olrreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nam.olrreg.mam.png","MAM")+"</td>"
  txt(158) = "<td>"+table_link_setup(OUTDIR,"nam.olrreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nam.olrreg.son.png","SON")+"</td>"
  txt(159) = "<td>"+table_link_setup(OUTDIR,"nam.olrreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nam.olrreg.mon.png","Monthly")+"</td></tr>"
  txt(160) = "<tr><td>Metrics Table (Pattern CORR)</td><td>"+table_link_setup(OUTDIR,"metrics.table_nam_patcor_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nam_patcor_mam.png","MAM")+"</td>"
  txt(161) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nam_patcor_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nam_patcor_son.png","SON")+"</td>"
  txt(162) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nam_patcor_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nam_patcor_mon.png","Monthly")+"</td></tr>"
  txt(163) = "<tr><td>Metrics Table (Pattern RMSD)</td><td>"+table_link_setup(OUTDIR,"metrics.table_nam_patrms_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nam_patrms_mam.png","MAM")+"</td>"
  txt(164) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nam_patrms_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nam_patrms_son.png","SON")+"</td>"
  txt(165) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nam_patrms_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nam_patrms_mon.png","Monthly")+"</td></tr>"

  txt(172) = ""
  txt(173) = "<tr><td rowspan=13><b>SAM</b></td>"
  txt(174) = "<td>Patterns (EOF)</td><td>"+table_link_setup(OUTDIR,"sam.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"sam.mam.png","MAM")+"</td>"
  txt(175) = "<td>"+table_link_setup(OUTDIR,"sam.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"sam.son.png","SON")+"</td>"
  txt(176) = "<td>"+table_link_setup(OUTDIR,"sam.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"sam.mon.png","Monthly")+"</td></tr>"
  txt(177) = "<tr><td>Timeseries (EOF)</td><td>"+table_link_setup(OUTDIR,"sam.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"sam.timeseries.mam.png","MAM")+"</td>"
  txt(178) = "<td>"+table_link_setup(OUTDIR,"sam.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"sam.timeseries.son.png","SON")+"</td>"
  txt(179) = "<td>"+table_link_setup(OUTDIR,"sam.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"sam.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(180) = "<tr><td>SST Regressions</td><td>"+table_link_setup(OUTDIR,"sam.tsreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"sam.tsreg.mam.png","MAM")+"</td>"
  txt(181) = "<td>"+table_link_setup(OUTDIR,"sam.tsreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"sam.tsreg.son.png","SON")+"</td>"
  txt(182) = "<td>"+table_link_setup(OUTDIR,"sam.tsreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"sam.tsreg.mon.png","Monthly")+"</td></tr>"
  txt(183) = "<tr><td>TAS Regressions</td><td>"+table_link_setup(OUTDIR,"sam.trefhtreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"sam.trefhtreg.mam.png","MAM")+"</td>"
  txt(184) = "<td>"+table_link_setup(OUTDIR,"sam.trefhtreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"sam.trefhtreg.son.png","SON")+"</td>"
  txt(185) = "<td>"+table_link_setup(OUTDIR,"sam.trefhtreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"sam.trefhtreg.mon.png","Monthly")+"</td></tr>"
  txt(186) = "<tr><td>PR Regressions</td><td>"+table_link_setup(OUTDIR,"sam.prectreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"sam.prectreg.mam.png","MAM")+"</td>"
  txt(187) = "<td>"+table_link_setup(OUTDIR,"sam.prectreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"sam.prectreg.son.png","SON")+"</td>"
  txt(188) = "<td>"+table_link_setup(OUTDIR,"sam.prectreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"sam.prectreg.mon.png","Monthly")+"</td></tr>"
  txt(189) = "<tr><td>OLR Regressions</td><td>"+table_link_setup(OUTDIR,"sam.olrreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"sam.olrreg.mam.png","MAM")+"</td>"
  txt(190) = "<td>"+table_link_setup(OUTDIR,"sam.olrreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"sam.olrreg.son.png","SON")+"</td>"
  txt(191) = "<td>"+table_link_setup(OUTDIR,"sam.olrreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"sam.olrreg.mon.png","Monthly")+"</td></tr>"
  txt(192) = "<tr><td>Metrics Table (Pattern CORR)</td><td>"+table_link_setup(OUTDIR,"metrics.table_sam_patcor_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_sam_patcor_mam.png","MAM")+"</td>"
  txt(193) = "<td>"+table_link_setup(OUTDIR,"metrics.table_sam_patcor_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_sam_patcor_son.png","SON")+"</td>"
  txt(194) = "<td>"+table_link_setup(OUTDIR,"metrics.table_sam_patcor_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_sam_patcor_mon.png","Monthly")+"</td></tr>"
  txt(195) = "<tr><td>Metrics Table (Pattern RMSD)</td><td>"+table_link_setup(OUTDIR,"metrics.table_sam_patrms_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_sam_patrms_mam.png","MAM")+"</td>"
  txt(196) = "<td>"+table_link_setup(OUTDIR,"metrics.table_sam_patrms_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_sam_patrms_son.png","SON")+"</td>"
  txt(197) = "<td>"+table_link_setup(OUTDIR,"metrics.table_sam_patrms_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_sam_patrms_mon.png","Monthly")+"</td></tr>"
  txt(198) = "<tr class=s1><td rowspan=4>SAM(Marshall)</td><td colspan=3>"+table_link_setup(OUTDIR,"samind.timeseries.png","Timeseries")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"samind.powspec.png","Power Spectra")+"</td></tr>"
  txt(199) = "<td colspan=3>"+table_link_setup(OUTDIR,"samind.monstddev.png","Monthly  Std. Dev.")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"samind.runstddev.png","Running Std. Dev.")+"</td></tr>"
  txt(200) = "<td colspan=3>"+table_link_setup(OUTDIR,"samind.autocor.png","Autocorrelation")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"samind.wavelet.png","Wavelet Analysis")+"</td></tr>"
  txt(201) = "<td colspan=2>"+table_link_setup(OUTDIR,"samlat.hov.png","Lat. Pos. Hovm&ouml;ller")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"samlat_mave.timeseries.png","Lat. Pos. Meridional Mean Evolution")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"samlat_tave.timeseries.png","Lat. Pos. Meridional Time Ave.")+"</td></tr>"
  txt(202) = "<tr><td>Spatial Composites (JJA SAM)</td><td colspan=3>SST/TAS/PSL<br>"+table_link_setup(OUTDIR,"samind.spatialcomp.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"samind.spatialcomp.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"samind.spatialcomp.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"samind.spatialcomp.mam1.png","MAM<sup>+1</sup>")+"</td>"
  txt(203) = "<td colspan=3>PR<br>"+table_link_setup(OUTDIR,"samind.spatialcomp.pr.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"samind.spatialcomp.pr.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"samind.spatialcomp.pr.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"samind.spatialcomp.pr.mam1.png","MAM<sup>+1</sup>")+"</td></tr>"

  txt(210) = ""
  txt(211) = "<tr><td rowspan=8><b>NAO</b></td>"
  txt(212) = "<td>Patterns (EOF)</td><td>"+table_link_setup(OUTDIR,"nao.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nao.mam.png","MAM")+"</td>"
  txt(213) = "<td>"+table_link_setup(OUTDIR,"nao.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nao.son.png","SON")+"</td>"
  txt(214) = "<td>"+table_link_setup(OUTDIR,"nao.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nao.mon.png","Monthly")+"</td></tr>"
  txt(215) = "<tr><td>Timeseries (EOF)</td><td>"+table_link_setup(OUTDIR,"nao.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nao.timeseries.mam.png","MAM")+"</td>"
  txt(216) = "<td>"+table_link_setup(OUTDIR,"nao.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nao.timeseries.son.png","SON")+"</td>"
  txt(217) = "<td>"+table_link_setup(OUTDIR,"nao.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nao.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(218) = "<tr><td>SST Regressions</td><td>"+table_link_setup(OUTDIR,"nao.tsreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nao.tsreg.mam.png","MAM")+"</td>"
  txt(219) = "<td>"+table_link_setup(OUTDIR,"nao.tsreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nao.tsreg.son.png","SON")+"</td>"
  txt(220) = "<td>"+table_link_setup(OUTDIR,"nao.tsreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nao.tsreg.mon.png","Monthly")+"</td></tr>"
  txt(221) = "<tr><td>TAS Regressions</td><td>"+table_link_setup(OUTDIR,"nao.trefhtreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nao.trefhtreg.mam.png","MAM")+"</td>"
  txt(222) = "<td>"+table_link_setup(OUTDIR,"nao.trefhtreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nao.trefhtreg.son.png","SON")+"</td>"
  txt(223) = "<td>"+table_link_setup(OUTDIR,"nao.trefhtreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nao.trefhtreg.mon.png","Monthly")+"</td></tr>"
  txt(224) = "<tr><td>PR Regressions</td><td>"+table_link_setup(OUTDIR,"nao.prectreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nao.prectreg.mam.png","MAM")+"</td>"
  txt(225) = "<td>"+table_link_setup(OUTDIR,"nao.prectreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nao.prectreg.son.png","SON")+"</td>"
  txt(226) = "<td>"+table_link_setup(OUTDIR,"nao.prectreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nao.prectreg.mon.png","Monthly")+"</td></tr>"
  txt(227) = "<tr><td>OLR Regressions</td><td>"+table_link_setup(OUTDIR,"nao.olrreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"nao.olrreg.mam.png","MAM")+"</td>"
  txt(228) = "<td>"+table_link_setup(OUTDIR,"nao.olrreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"nao.olrreg.son.png","SON")+"</td>"
  txt(229) = "<td>"+table_link_setup(OUTDIR,"nao.olrreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"nao.olrreg.mon.png","Monthly")+"</td></tr>"
  txt(230) = "<tr><td>Metrics Table (Pattern CORR)</td><td>"+table_link_setup(OUTDIR,"metrics.table_nao_patcor_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nao_patcor_mam.png","MAM")+"</td>"
  txt(231) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nao_patcor_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nao_patcor_son.png","SON")+"</td>"
  txt(232) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nao_patcor_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nao_patcor_mon.png","Monthly")+"</td></tr>"
  txt(233) = "<tr><td>Metrics Table (Pattern RMSD)</td><td>"+table_link_setup(OUTDIR,"metrics.table_nao_patrms_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nao_patrms_mam.png","MAM")+"</td>"
  txt(234) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nao_patrms_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nao_patrms_son.png","SON")+"</td>"
  txt(235) = "<td>"+table_link_setup(OUTDIR,"metrics.table_nao_patrms_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_nao_patrms_mon.png","Monthly")+"</td></tr>"

  txt(242) = ""
  txt(243) = "<tr><td rowspan=8><b>PNA</b></td>"
  txt(244) = "<td>Patterns (EOF)</td><td>"+table_link_setup(OUTDIR,"pna.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pna.mam.png","MAM")+"</td>"
  txt(245) = "<td>"+table_link_setup(OUTDIR,"pna.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pna.son.png","SON")+"</td>"
  txt(246) = "<td>"+table_link_setup(OUTDIR,"pna.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"pna.mon.png","Monthly")+"</td></tr>"
  txt(247) = "<tr><td>Timeseries (EOF)</td><td>"+table_link_setup(OUTDIR,"pna.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pna.timeseries.mam.png","MAM")+"</td>"
  txt(248) = "<td>"+table_link_setup(OUTDIR,"pna.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pna.timeseries.son.png","SON")+"</td>"
  txt(249) = "<td>"+table_link_setup(OUTDIR,"pna.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"pna.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(250) = "<tr><td>SST Regressions</td><td>"+table_link_setup(OUTDIR,"pna.tsreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pna.tsreg.mam.png","MAM")+"</td>"
  txt(251) = "<td>"+table_link_setup(OUTDIR,"pna.tsreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pna.tsreg.son.png","SON")+"</td>"
  txt(252) = "<td>"+table_link_setup(OUTDIR,"pna.tsreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"pna.tsreg.mon.png","Monthly")+"</td></tr>"
  txt(253) = "<tr><td>TAS Regressions</td><td>"+table_link_setup(OUTDIR,"pna.trefhtreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pna.trefhtreg.mam.png","MAM")+"</td>"
  txt(254) = "<td>"+table_link_setup(OUTDIR,"pna.trefhtreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pna.trefhtreg.son.png","SON")+"</td>"
  txt(255) = "<td>"+table_link_setup(OUTDIR,"pna.trefhtreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"pna.trefhtreg.mon.png","Monthly")+"</td></tr>"
  txt(256) = "<tr><td>PR Regressions</td><td>"+table_link_setup(OUTDIR,"pna.prectreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pna.prectreg.mam.png","MAM")+"</td>"
  txt(257) = "<td>"+table_link_setup(OUTDIR,"pna.prectreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pna.prectreg.son.png","SON")+"</td>"
  txt(258) = "<td>"+table_link_setup(OUTDIR,"pna.prectreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"pna.prectreg.mon.png","Monthly")+"</td></tr>"
  txt(259) = "<tr><td>OLR Regressions</td><td>"+table_link_setup(OUTDIR,"pna.olrreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pna.olrreg.mam.png","MAM")+"</td>"
  txt(260) = "<td>"+table_link_setup(OUTDIR,"pna.olrreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pna.olrreg.son.png","SON")+"</td>"
  txt(261) = "<td>"+table_link_setup(OUTDIR,"pna.olrreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"pna.olrreg.mon.png","Monthly")+"</td></tr>"
  txt(262) = "<tr><td>Metrics Table (Pattern CORR)</td><td>"+table_link_setup(OUTDIR,"metrics.table_pna_patcor_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_pna_patcor_mam.png","MAM")+"</td>"
  txt(263) = "<td>"+table_link_setup(OUTDIR,"metrics.table_pna_patcor_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_pna_patcor_son.png","SON")+"</td>"
  txt(264) = "<td>"+table_link_setup(OUTDIR,"metrics.table_pna_patcor_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_pna_patcor_mon.png","Monthly")+"</td></tr>"
  txt(265) = "<tr><td>Metrics Table (Pattern RMSD)</td><td>"+table_link_setup(OUTDIR,"metrics.table_pna_patrms_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_pna_patrms_mam.png","MAM")+"</td>"
  txt(266) = "<td>"+table_link_setup(OUTDIR,"metrics.table_pna_patrms_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_pna_patrms_son.png","SON")+"</td>"
  txt(267) = "<td>"+table_link_setup(OUTDIR,"metrics.table_pna_patrms_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_pna_patrms_mon.png","Monthly")+"</td></tr>"

  txt(274) = ""
  txt(275) = "<tr><td rowspan=8><b>NPO</b></td>"
  txt(276) = "<td>Patterns (EOF)</td><td>"+table_link_setup(OUTDIR,"npo.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"npo.mam.png","MAM")+"</td>"
  txt(277) = "<td>"+table_link_setup(OUTDIR,"npo.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"npo.son.png","SON")+"</td>"
  txt(278) = "<td>"+table_link_setup(OUTDIR,"npo.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"npo.mon.png","Monthly")+"</td></tr>"
  txt(279) = "<tr><td>Timeseries (EOF)</td><td>"+table_link_setup(OUTDIR,"npo.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"npo.timeseries.mam.png","MAM")+"</td>"
  txt(280) = "<td>"+table_link_setup(OUTDIR,"npo.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"npo.timeseries.son.png","SON")+"</td>"
  txt(281) = "<td>"+table_link_setup(OUTDIR,"npo.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"npo.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(282) = "<tr><td>SST Regressions</td><td>"+table_link_setup(OUTDIR,"npo.tsreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"npo.tsreg.mam.png","MAM")+"</td>"
  txt(283) = "<td>"+table_link_setup(OUTDIR,"npo.tsreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"npo.tsreg.son.png","SON")+"</td>"
  txt(284) = "<td>"+table_link_setup(OUTDIR,"npo.tsreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"npo.tsreg.mon.png","Monthly")+"</td></tr>"
  txt(285) = "<tr><td>TAS Regressions</td><td>"+table_link_setup(OUTDIR,"npo.trefhtreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"npo.trefhtreg.mam.png","MAM")+"</td>"
  txt(286) = "<td>"+table_link_setup(OUTDIR,"npo.trefhtreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"npo.trefhtreg.son.png","SON")+"</td>"
  txt(287) = "<td>"+table_link_setup(OUTDIR,"npo.trefhtreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"npo.trefhtreg.mon.png","Monthly")+"</td></tr>"
  txt(288) = "<tr><td>PR Regressions</td><td>"+table_link_setup(OUTDIR,"npo.prectreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"npo.prectreg.mam.png","MAM")+"</td>"
  txt(289) = "<td>"+table_link_setup(OUTDIR,"npo.prectreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"npo.prectreg.son.png","SON")+"</td>"
  txt(290) = "<td>"+table_link_setup(OUTDIR,"npo.prectreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"npo.prectreg.mon.png","Monthly")+"</td></tr>"
  txt(291) = "<tr><td>OLR Regressions</td><td>"+table_link_setup(OUTDIR,"npo.olrreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"npo.olrreg.mam.png","MAM")+"</td>"
  txt(292) = "<td>"+table_link_setup(OUTDIR,"npo.olrreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"npo.olrreg.son.png","SON")+"</td>"
  txt(293) = "<td>"+table_link_setup(OUTDIR,"npo.olrreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"npo.olrreg.mon.png","Monthly")+"</td></tr>"
  txt(294) = "<tr><td>Metrics Table (Pattern CORR)</td><td>"+table_link_setup(OUTDIR,"metrics.table_npo_patcor_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_npo_patcor_mam.png","MAM")+"</td>"
  txt(295) = "<td>"+table_link_setup(OUTDIR,"metrics.table_npo_patcor_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_npo_patcor_son.png","SON")+"</td>"
  txt(296) = "<td>"+table_link_setup(OUTDIR,"metrics.table_npo_patcor_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_npo_patcor_mon.png","Monthly")+"</td></tr>"
  txt(297) = "<tr><td>Metrics Table (Pattern RMSD)</td><td>"+table_link_setup(OUTDIR,"metrics.table_npo_patrms_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_npo_patrms_mam.png","MAM")+"</td>"
  txt(298) = "<td>"+table_link_setup(OUTDIR,"metrics.table_npo_patrms_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_npo_patrms_son.png","SON")+"</td>"
  txt(299) = "<td>"+table_link_setup(OUTDIR,"metrics.table_npo_patrms_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_npo_patrms_mon.png","Monthly")+"</td></tr>"

  txt(306) = ""
  txt(307) = "<tr><td rowspan=8><b>PSA1</b></td>"
  txt(308) = "<td>Patterns (EOF)</td><td>"+table_link_setup(OUTDIR,"psa1.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa1.mam.png","MAM")+"</td>"
  txt(309) = "<td>"+table_link_setup(OUTDIR,"psa1.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa1.son.png","SON")+"</td>"
  txt(310) = "<td>"+table_link_setup(OUTDIR,"psa1.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa1.mon.png","Monthly")+"</td></tr>"
  txt(311) = "<tr><td>Timeseries (EOF)</td><td>"+table_link_setup(OUTDIR,"psa1.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa1.timeseries.mam.png","MAM")+"</td>"
  txt(312) = "<td>"+table_link_setup(OUTDIR,"psa1.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa1.timeseries.son.png","SON")+"</td>"
  txt(313) = "<td>"+table_link_setup(OUTDIR,"psa1.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa1.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(314) = "<tr><td>SST Regressions</td><td>"+table_link_setup(OUTDIR,"psa1.tsreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa1.tsreg.mam.png","MAM")+"</td>"
  txt(315) = "<td>"+table_link_setup(OUTDIR,"psa1.tsreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa1.tsreg.son.png","SON")+"</td>"
  txt(316) = "<td>"+table_link_setup(OUTDIR,"psa1.tsreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa1.tsreg.mon.png","Monthly")+"</td></tr>"
  txt(317) = "<tr><td>TAS Regressions</td><td>"+table_link_setup(OUTDIR,"psa1.trefhtreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa1.trefhtreg.mam.png","MAM")+"</td>"
  txt(318) = "<td>"+table_link_setup(OUTDIR,"psa1.trefhtreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa1.trefhtreg.son.png","SON")+"</td>"
  txt(319) = "<td>"+table_link_setup(OUTDIR,"psa1.trefhtreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa1.trefhtreg.mon.png","Monthly")+"</td></tr>"
  txt(320) = "<tr><td>PR Regressions</td><td>"+table_link_setup(OUTDIR,"psa1.prectreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa1.prectreg.mam.png","MAM")+"</td>"
  txt(321) = "<td>"+table_link_setup(OUTDIR,"psa1.prectreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa1.prectreg.son.png","SON")+"</td>"
  txt(322) = "<td>"+table_link_setup(OUTDIR,"psa1.prectreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa1.prectreg.mon.png","Monthly")+"</td></tr>"
  txt(323) = "<tr><td>OLR Regressions</td><td>"+table_link_setup(OUTDIR,"psa1.olrreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa1.olrreg.mam.png","MAM")+"</td>"
  txt(324) = "<td>"+table_link_setup(OUTDIR,"psa1.olrreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa1.olrreg.son.png","SON")+"</td>"
  txt(325) = "<td>"+table_link_setup(OUTDIR,"psa1.olrreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa1.olrreg.mon.png","Monthly")+"</td></tr>"
  txt(326) = "<tr><td>Metrics Table (Pattern CORR)</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patcor_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patcor_mam.png","MAM")+"</td>"
  txt(327) = "<td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patcor_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patcor_son.png","SON")+"</td>"
  txt(328) = "<td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patcor_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patcor_mon.png","Monthly")+"</td></tr>"
  txt(329) = "<tr><td>Metrics Table (Pattern RMSD)</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patrms_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patrms_mam.png","MAM")+"</td>"
  txt(330) = "<td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patrms_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patrms_son.png","SON")+"</td>"
  txt(331) = "<td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patrms_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa1_patrms_mon.png","Monthly")+"</td></tr>"

  txt(338) = ""
  txt(339) = "<tr><td rowspan=8><b>PSA2</b></td>"
  txt(340) = "<td>Patterns (EOF)</td><td>"+table_link_setup(OUTDIR,"psa2.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa2.mam.png","MAM")+"</td>"
  txt(341) = "<td>"+table_link_setup(OUTDIR,"psa2.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa2.son.png","SON")+"</td>"
  txt(342) = "<td>"+table_link_setup(OUTDIR,"psa2.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa2.mon.png","Monthly")+"</td></tr>"
  txt(343) = "<tr><td>Timeseries (EOF)</td><td>"+table_link_setup(OUTDIR,"psa2.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa2.timeseries.mam.png","MAM")+"</td>"
  txt(344) = "<td>"+table_link_setup(OUTDIR,"psa2.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa2.timeseries.son.png","SON")+"</td>"
  txt(345) = "<td>"+table_link_setup(OUTDIR,"psa2.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa2.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(346) = "<tr><td>SST Regressions</td><td>"+table_link_setup(OUTDIR,"psa2.tsreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa2.tsreg.mam.png","MAM")+"</td>"
  txt(347) = "<td>"+table_link_setup(OUTDIR,"psa2.tsreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa2.tsreg.son.png","SON")+"</td>"
  txt(348) = "<td>"+table_link_setup(OUTDIR,"psa2.tsreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa2.tsreg.mon.png","Monthly")+"</td></tr>"
  txt(349) = "<tr><td>TAS Regressions</td><td>"+table_link_setup(OUTDIR,"psa2.trefhtreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa2.trefhtreg.mam.png","MAM")+"</td>"
  txt(350) = "<td>"+table_link_setup(OUTDIR,"psa2.trefhtreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa2.trefhtreg.son.png","SON")+"</td>"
  txt(351) = "<td>"+table_link_setup(OUTDIR,"psa2.trefhtreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa2.trefhtreg.mon.png","Monthly")+"</td></tr>"
  txt(352) = "<tr><td>PR Regressions</td><td>"+table_link_setup(OUTDIR,"psa2.prectreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa2.prectreg.mam.png","MAM")+"</td>"
  txt(353) = "<td>"+table_link_setup(OUTDIR,"psa2.prectreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa2.prectreg.son.png","SON")+"</td>"
  txt(354) = "<td>"+table_link_setup(OUTDIR,"psa2.prectreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa2.prectreg.mon.png","Monthly")+"</td></tr>"
  txt(355) = "<tr><td>OLR Regressions</td><td>"+table_link_setup(OUTDIR,"psa2.olrreg.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psa2.olrreg.mam.png","MAM")+"</td>"
  txt(356) = "<td>"+table_link_setup(OUTDIR,"psa2.olrreg.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psa2.olrreg.son.png","SON")+"</td>"
  txt(357) = "<td>"+table_link_setup(OUTDIR,"psa2.olrreg.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psa2.olrreg.mon.png","Monthly")+"</td></tr>"
  txt(358) = "<tr><td>Metrics Table (Pattern CORR)</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_mam.png","MAM")+"</td>"
  txt(359) = "<td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_son.png","SON")+"</td>"
  txt(360) = "<td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_mon.png","Monthly")+"</td></tr>"
  txt(361) = "<tr><td>Metrics Table (Pattern RMSD)</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_mam.png","MAM")+"</td>"
  txt(362) = "<td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_son.png","SON")+"</td>"
  txt(363) = "<td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"metrics.table_psa2_patcor_mon.png","Monthly")+"</td></tr>"

  txt(370) = ""
  txt(371) = "<tr><td rowspan=13><b>Hadley Cell (HC)</b></td>"
  txt(372) = "<td>Patterns</td><td>"+table_link_setup(OUTDIR,"zmsf.mean.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.mean.mam.png","MAM")+"</td>"
  txt(373) = "<td>"+table_link_setup(OUTDIR,"zmsf.mean.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.mean.son.png","SON")+"</td>"
  txt(374) = "<td>"+table_link_setup(OUTDIR,"zmsf.mean.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.mean.mon.png","N/A")+"</td></tr>"
  txt(375) = "<tr><td>Stddev Patterns</td><td>"+table_link_setup(OUTDIR,"zmsf.stddev.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.stddev.mam.png","MAM")+"</td>"
  txt(376) = "<td>"+table_link_setup(OUTDIR,"zmsf.stddev.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.stddev.son.png","SON")+"</td>"
  txt(377) = "<td>"+table_link_setup(OUTDIR,"zmsf.stddev.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.stddev.mon.png","N/A")+"</td></tr>"
  txt(378) = "<tr><td>Lat-time Hovm&ouml;ller</td><td>"+table_link_setup(OUTDIR,"zmsf.hovmoller.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.hovmoller.mam.png","MAM")+"</td>"
  txt(379) = "<td>"+table_link_setup(OUTDIR,"zmsf.hovmoller.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.hovmoller.son.png","SON")+"</td>"
  txt(380) = "<td>"+table_link_setup(OUTDIR,"zmsf.hovmoller.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.hovmoller.mon.png","N/A")+"</td></tr>"
  txt(381) = "<tr><td>Trend Patterns</td><td>"+table_link_setup(OUTDIR,"zmsf.trends.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.trends.mam.png","MAM")+"</td>"
  txt(382) = "<td>"+table_link_setup(OUTDIR,"zmsf.trends.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.trends.son.png","SON")+"</td>"
  txt(383) = "<td>"+table_link_setup(OUTDIR,"zmsf.trends.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"zmsf.trends.mon.png","Monthly")+"</td></tr>"
  txt(384) = "<tr><td>Width</td><td>"+table_link_setup(OUTDIR,"hcwd_djf.timeseries.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"hcwd_mam.timeseries.png","MAM")+"</td>"
  txt(385) = "<td>"+table_link_setup(OUTDIR,"hcwd_jja.timeseries.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"hcwd_son.timeseries.png","SON")+"</td>"
  txt(386) = "<td>"+table_link_setup(OUTDIR,"hcwd_ann.timeseries.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"hcwd_mon.timeseries.png","Monthly")+"</td></tr>"
  txt(387) = "<tr><td>Intersection</td><td>"+table_link_setup(OUTDIR,"hcei_djf.timeseries.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"hcei_mam.timeseries.png","MAM")+"</td>"
  txt(388) = "<td>"+table_link_setup(OUTDIR,"hcei_jja.timeseries.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"hcei_son.timeseries.png","SON")+"</td>"
  txt(389) = "<td>"+table_link_setup(OUTDIR,"hcei_ann.timeseries.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"hcei_mon.timeseries.png","Monthly")+"</td></tr>"
  txt(390) = "<tr><td>NH edge</td><td>"+table_link_setup(OUTDIR,"hcen_djf.timeseries.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"hcen_mam.timeseries.png","MAM")+"</td>"
  txt(391) = "<td>"+table_link_setup(OUTDIR,"hcen_jja.timeseries.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"hcen_son.timeseries.png","SON")+"</td>"
  txt(392) = "<td>"+table_link_setup(OUTDIR,"hcen_ann.timeseries.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"hcen_mon.timeseries.png","Monthly")+"</td></tr>"
  txt(393) = "<tr><td>SH edge</td><td>"+table_link_setup(OUTDIR,"hces_djf.timeseries.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"hces_mam.timeseries.png","MAM")+"</td>"
  txt(394) = "<td>"+table_link_setup(OUTDIR,"hces_jja.timeseries.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"hces_son.timeseries.png","SON")+"</td>"
  txt(395) = "<td>"+table_link_setup(OUTDIR,"hces_ann.timeseries.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"hces_mon.timeseries.png","Monthly")+"</td></tr>"
  txt(396) = "<tr><td>NH Intensity</td><td>"+table_link_setup(OUTDIR,"hcin_djf.timeseries.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"hcin_mam.timeseries.png","MAM")+"</td>"
  txt(397) = "<td>"+table_link_setup(OUTDIR,"hcin_jja.timeseries.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"hcin_son.timeseries.png","SON")+"</td>"
  txt(398) = "<td>"+table_link_setup(OUTDIR,"hcin_ann.timeseries.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"hcin_mon.timeseries.png","Monthly")+"</td></tr>"
  txt(399) = "<tr><td>SH intensity</td><td>"+table_link_setup(OUTDIR,"hcis_djf.timeseries.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"hcis_mam.timeseries.png","MAM")+"</td>"
  txt(400) = "<td>"+table_link_setup(OUTDIR,"hcis_jja.timeseries.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"hcis_son.timeseries.png","SON")+"</td>"
  txt(401) = "<td>"+table_link_setup(OUTDIR,"hcis_ann.timeseries.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"hcis_mon.timeseries.png","Monthly")+"</td></tr>"
  txt(402) = "<tr class=s1><td rowspan=2>Width Variation</td><td colspan=3>"+table_link_setup(OUTDIR,"hc.monstddev.png","Monthly  Std. Dev.")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"hc.powspec.png","Power Spectra")+"</td></tr>"
  txt(403) = "<td colspan=3>"+table_link_setup(OUTDIR,"hc.autocor.png","Autocorrelation")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"hc.wavelet.png","Wavelet Analysis")+"</td></tr>"
  txt(404) = "<tr><td>Spatial Composites (DJF Width)</td><td colspan=3>SST/TAS/PSL<br>"+table_link_setup(OUTDIR,"hc.spatialcomp.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"hc.spatialcomp.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"hc.spatialcomp.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"hc.spatialcomp.mam1.png","MAM<sup>+1</sup>")+"</td>"
  txt(405) = "<td colspan=3>PR<br>"+table_link_setup(OUTDIR,"hc.spatialcomp.pr.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"hc.spatialcomp.pr.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"hc.spatialcomp.pr.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"hc.spatialcomp.pr.mam1.png","MAM<sup>+1</sup>")+"</td></tr>"

  txt(415) = ""
  txt(416) = "<tr><td rowspan=6><b>Subtropical jet (NH)</b></td>"
  txt(417) = "<td>Intensity</td><td>"+table_link_setup(OUTDIR,"stjnhins.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"stjnhins.timeseries.mam.png","MAM")+"</td>"
  txt(418) = "<td>"+table_link_setup(OUTDIR,"stjnhins.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"stjnhins.timeseries.son.png","SON")+"</td>"
  txt(419) = "<td>"+table_link_setup(OUTDIR,"stjnhins.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"stjnhins.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(420) = "<td>Position</td><td>"+table_link_setup(OUTDIR,"stjnhloc.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"stjnhloc.timeseries.mam.png","MAM")+"</td>"
  txt(421) = "<td>"+table_link_setup(OUTDIR,"stjnhloc.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"stjnhloc.timeseries.son.png","SON")+"</td>"
  txt(422) = "<td>"+table_link_setup(OUTDIR,"stjnhloc.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"stjnhloc.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(423) = "<tr class=s1><td rowspan=3>Position Variation</td><td colspan=3>"+table_link_setup(OUTDIR,"stjnh.monstddev.png","Monthly  Std. Dev.")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"stjnh.powspec.png","Power Spectra")+"</td></tr>"
  txt(424) = "<td colspan=3>"+table_link_setup(OUTDIR,"stjnh.autocor.png","Autocorrelation")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"stjnh.wavelet.png","Wavelet Analysis")+"</td></tr>"
  txt(425) = "<td colspan=2>"+table_link_setup(OUTDIR,"stjnhlat.hov.png","Lat. Pos. Hovm&ouml;ller")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"stjnhlat_mave.timeseries.png","Lat. Pos. Meridional Mean Evolution")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"stjnhlat_tave.timeseries.png","Lat. Pos. Meridional Time Ave.")+"</td></tr>"
  txt(426) = "<tr><td>Spatial Composites (JJA Position)</td><td colspan=3>SST/TAS/PSL<br>"+table_link_setup(OUTDIR,"stjnh.spatialcomp.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"stjnh.spatialcomp.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"stjnh.spatialcomp.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"stjnh.spatialcomp.mam1.png","MAM<sup>+1</sup>")+"</td>"
  txt(427) = "<td colspan=3>PR<br>"+table_link_setup(OUTDIR,"stjnh.spatialcomp.pr.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"stjnh.spatialcomp.pr.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"stjnh.spatialcomp.pr.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"stjnh.spatialcomp.pr.mam1.png","MAM<sup>+1</sup>")+"</td></tr>"

  txt(438) = ""
  txt(439) = "<tr><td rowspan=6><b>Subtropical jet (SH)</b></td>"
  txt(440) = "<td>Intensity</td><td>"+table_link_setup(OUTDIR,"stjshins.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"stjshins.timeseries.mam.png","MAM")+"</td>"
  txt(441) = "<td>"+table_link_setup(OUTDIR,"stjshins.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"stjshins.timeseries.son.png","SON")+"</td>"
  txt(442) = "<td>"+table_link_setup(OUTDIR,"stjshins.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"stjshins.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(443) = "<td>Position</td><td>"+table_link_setup(OUTDIR,"stjshloc.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"stjshloc.timeseries.mam.png","MAM")+"</td>"
  txt(444) = "<td>"+table_link_setup(OUTDIR,"stjshloc.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"stjshloc.timeseries.son.png","SON")+"</td>"
  txt(445) = "<td>"+table_link_setup(OUTDIR,"stjshloc.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"stjshloc.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(446) = "<tr class=s1><td rowspan=3>Position Variation</td><td colspan=3>"+table_link_setup(OUTDIR,"stjsh.monstddev.png","Monthly  Std. Dev.")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"stjsh.powspec.png","Power Spectra")+"</td></tr>"
  txt(447) = "<td colspan=3>"+table_link_setup(OUTDIR,"stjsh.autocor.png","Autocorrelation")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"stjsh.wavelet.png","Wavelet Analysis")+"</td></tr>"
  txt(448) = "<td colspan=2>"+table_link_setup(OUTDIR,"stjshlat.hov.png","Lat. Pos. Hovm&ouml;ller")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"stjshlat_mave.timeseries.png","Lat. Pos. Meridional Mean Evolution")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"stjshlat_tave.timeseries.png","Lat. Pos. Meridional Time Ave.")+"</td></tr>"
  txt(449) = "<tr><td>Spatial Composites (JJA Position)</td><td colspan=3>SST/TAS/PSL<br>"+table_link_setup(OUTDIR,"stjsh.spatialcomp.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"stjsh.spatialcomp.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"stjsh.spatialcomp.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"stjsh.spatialcomp.mam1.png","MAM<sup>+1</sup>")+"</td>"
  txt(450) = "<td colspan=3>PR<br>"+table_link_setup(OUTDIR,"stjsh.spatialcomp.pr.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"stjsh.spatialcomp.pr.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"stjsh.spatialcomp.pr.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"stjsh.spatialcomp.pr.mam1.png","MAM<sup>+1</sup>")+"</td></tr>"

  txt(460) = ""
  txt(461) = "<tr><td rowspan=6><b>Polar jet (NH)</b></td>"
  txt(462) = "<td>Intensity</td><td>"+table_link_setup(OUTDIR,"pnjetins.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pnjetins.timeseries.mam.png","MAM")+"</td>"
  txt(463) = "<td>"+table_link_setup(OUTDIR,"pnjetins.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pnjetins.timeseries.son.png","SON")+"</td>"
  txt(464) = "<td>"+table_link_setup(OUTDIR,"pnjetins.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"pnjetins.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(465) = "<td>Position</td><td>"+table_link_setup(OUTDIR,"pnjetloc.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pnjetloc.timeseries.mam.png","MAM")+"</td>"
  txt(466) = "<td>"+table_link_setup(OUTDIR,"pnjetloc.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pnjetloc.timeseries.son.png","SON")+"</td>"
  txt(467) = "<td>"+table_link_setup(OUTDIR,"pnjetloc.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"pnjetloc.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(468) = "<tr class=s1><td rowspan=3>Position Variation</td><td colspan=3>"+table_link_setup(OUTDIR,"pnjet.monstddev.png","Monthly  Std. Dev.")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"pnjet.powspec.png","Power Spectra")+"</td></tr>"
  txt(469) = "<td colspan=3>"+table_link_setup(OUTDIR,"pnjet.autocor.png","Autocorrelation")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"pnjet.wavelet.png","Wavelet Analysis")+"</td></tr>"
  txt(470) = "<td colspan=2>"+table_link_setup(OUTDIR,"pnjetlat.hov.png","Lat. Pos. Hovm&ouml;ller")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"pnjetlat_mave.timeseries.png","Lat. Pos. Meridional Mean Evolution")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"pnjetlat_tave.timeseries.png","Lat. Pos. Meridional Time Ave.")+"</td></tr>"
  txt(471) = "<tr><td>Spatial Composites (JJA Position)</td><td colspan=3>SST/TAS/PSL<br>"+table_link_setup(OUTDIR,"pnjet.spatialcomp.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"pnjet.spatialcomp.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"pnjet.spatialcomp.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"pnjet.spatialcomp.mam1.png","MAM<sup>+1</sup>")+"</td>"
  txt(472) = "<td colspan=3>PR<br>"+table_link_setup(OUTDIR,"pnjet.spatialcomp.pr.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"pnjet.spatialcomp.pr.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"pnjet.spatialcomp.pr.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"pnjet.spatialcomp.pr.mam1.png","MAM<sup>+1</sup>")+"</td></tr>"

  txt(483) = ""
  txt(484) = "<tr><td rowspan=8><b>Polar jet (SH)</b></td>"
  txt(485) = "<td>Intensity</td><td>"+table_link_setup(OUTDIR,"psjetins.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psjetins.timeseries.mam.png","MAM")+"</td>"
  txt(486) = "<td>"+table_link_setup(OUTDIR,"psjetins.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psjetins.timeseries.son.png","SON")+"</td>"
  txt(487) = "<td>"+table_link_setup(OUTDIR,"psjetins.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psjetins.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(488) = "<td>Position</td><td>"+table_link_setup(OUTDIR,"psjetloc.timeseries.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psjetloc.timeseries.mam.png","MAM")+"</td>"
  txt(489) = "<td>"+table_link_setup(OUTDIR,"psjetloc.timeseries.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psjetloc.timeseries.son.png","SON")+"</td>"
  txt(490) = "<td>"+table_link_setup(OUTDIR,"psjetloc.timeseries.ann.png","Annual")+"</td><td>"+table_link_setup(OUTDIR,"psjetloc.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(491) = "<tr class=s1><td rowspan=3>Position Variation</td><td colspan=3>"+table_link_setup(OUTDIR,"psjet.monstddev.png","Monthly  Std. Dev.")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"psjet.powspec.png","Power Spectra")+"</td></tr>"
  txt(492) = "<td colspan=3>"+table_link_setup(OUTDIR,"psjet.autocor.png","Autocorrelation")+"</td><td colspan=3>"+table_link_setup(OUTDIR,"psjet.wavelet.png","Wavelet Analysis")+"</td></tr>"
  txt(493) = "<td colspan=2>"+table_link_setup(OUTDIR,"psjetlat.hov.png","Lat. Pos. Hovm&ouml;ller")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"psjetlat_mave.timeseries.png","Lat. Pos. Meridional Mean Evolution")+"</td><td colspan=2>"+table_link_setup(OUTDIR,"psjetlat_tave.timeseries.png","Lat. Pos. Meridional Time Ave.")+"</td></tr>"
  txt(494) = "<tr><td>Spatial Composites (JJA Position)</td><td colspan=3>SST/TAS/PSL<br>"+table_link_setup(OUTDIR,"psjet.spatialcomp.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"psjet.spatialcomp.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"psjet.spatialcomp.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"psjet.spatialcomp.mam1.png","MAM<sup>+1</sup>")+"</td>"
  txt(495) = "<td colspan=3>PR<br>"+table_link_setup(OUTDIR,"psjet.spatialcomp.pr.jja0.png","JJA<sup>0</sup>")+" "+table_link_setup(OUTDIR,"psjet.spatialcomp.pr.son0.png","SON<sup>0</sup>")+"<br>"+table_link_setup(OUTDIR,"psjet.spatialcomp.pr.djf1.png","DJF<sup>+1</sup>")+" "+table_link_setup(OUTDIR,"psjet.spatialcomp.pr.mam1.png","MAM<sup>+1</sup>")+"</td></tr>"
  txt(496) = "</tr></table></div></div>"

  tt0 = 510
  txt(tt0+1) = "<div class="+quote+"row"+quote+">"
  txt(tt0+2) = "<div class="+quote+"col"+quote+">"
  txt(tt0+3) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(tt0+4) = "<h3 class="+quote+"display-6"+quote+">Ice Extent Timeseries</h3>"
  txt(tt0+5) = "<tr><td rowspan=2><b>SIC NH</b></td><td>"+table_link_setup(OUTDIR,"aice.extent.nh.djf.png","DJF")+"</td>"
  txt(tt0+6) = "<td>"+table_link_setup(OUTDIR,"aice.extent.nh.mam.png","MAM")+"</td>"
  txt(tt0+7) = "<td>"+table_link_setup(OUTDIR,"aice.extent.nh.jja.png","JJA")+"</td>"
  txt(tt0+8) = "<td>"+table_link_setup(OUTDIR,"aice.extent.nh.son.png","SON")+"</td>"
  txt(tt0+9) = "<td>"+table_link_setup(OUTDIR,"aice.extent.nh.ann.png","Annual")+"</td>"
  txt(tt0+10) = "<td>"+table_link_setup(OUTDIR,"aice.extent.nh.mon.png","Monthly")+"</td></tr>"
  txt(tt0+11) = "<tr><td colspan=2>"+table_link_setup(OUTDIR,"aice.extent.nh.feb.png","Feb")+"&nbsp;&nbsp;"+table_link_setup(OUTDIR,"aice.extent.nh.mar.png","Mar")+"&nbsp;&nbsp;"+table_link_setup(OUTDIR,"aice.extent.nh.sep.png","Sep")+"</td>"
  txt(tt0+13) = "<td colspan=2>"+table_link_setup(OUTDIR,"aice.extent.anom.nh.mon.png","Monthly Anomalies")+"</td>"
  txt(tt0+14) = "<td colspan=2>"+table_link_setup(OUTDIR,"aice.extent.nh.climo.png","Climatology")+"</td></tr>"
  txt(tt0+15) = "<tr><td rowspan=2><b>SIC SH</b></td><td>"+table_link_setup(OUTDIR,"aice.extent.sh.djf.png","DJF")+"</td>"
  txt(tt0+16) = "<td>"+table_link_setup(OUTDIR,"aice.extent.sh.mam.png","MAM")+"</td>"
  txt(tt0+17) = "<td>"+table_link_setup(OUTDIR,"aice.extent.sh.jja.png","JJA")+"</td>"
  txt(tt0+18) = "<td>"+table_link_setup(OUTDIR,"aice.extent.sh.son.png","SON")+"</td>"
  txt(tt0+19) = "<td>"+table_link_setup(OUTDIR,"aice.extent.sh.ann.png","Annual")+"</td>"
  txt(tt0+20) = "<td>"+table_link_setup(OUTDIR,"aice.extent.sh.mon.png","Monthly")+"</td></tr>"
  txt(tt0+21) = "<tr><td colspan=2>"+table_link_setup(OUTDIR,"aice.extent.sh.feb.png","Feb")+"&nbsp;&nbsp;"+table_link_setup(OUTDIR,"aice.extent.sh.mar.png","Mar")+"&nbsp;&nbsp;"+table_link_setup(OUTDIR,"aice.extent.sh.sep.png","Sep")+"</td>"
  txt(tt0+22) = "<td colspan=2>"+table_link_setup(OUTDIR,"aice.extent.anom.sh.mon.png","Monthly Anomalies")+"</td>"
  txt(tt0+23) = "<td colspan=2>"+table_link_setup(OUTDIR,"aice.extent.sh.climo.png","Climatology")+"</td></tr></table></div></div>"

  tt1 = tt0+54
  txt(tt1+1) = "<div class="+quote+"row"+quote+">"
  txt(tt1+2) = "<div class="+quote+"col"+quote+">"
  txt(tt1+3) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(tt1+4) = "<h3 class="+quote+"display-6"+quote+">Global Trend Maps</h3>"
  txt(tt1+5) = "<tr><td><b>SST</b></td><td>"+table_link_setup(OUTDIR,"sst.trends.djf.png","DJF")+"</td>"
  txt(tt1+6) = "<td>"+table_link_setup(OUTDIR,"sst.trends.mam.png","MAM")+"</td>"
  txt(tt1+7) = "<td>"+table_link_setup(OUTDIR,"sst.trends.jja.png","JJA")+"</td>"
  txt(tt1+8) = "<td>"+table_link_setup(OUTDIR,"sst.trends.son.png","SON")+"</td>"
  txt(tt1+9) = "<td>"+table_link_setup(OUTDIR,"sst.trends.ann.png","Annual")+"</td>"
  txt(tt1+10) = "<td>"+table_link_setup(OUTDIR,"sst.trends.mon.png","Monthly")+"</td></tr>"
  txt(tt1+11) = "<tr><td><b>TAS</b></td><td>"+table_link_setup(OUTDIR,"tas.trends.djf.png","DJF")+"</td>"
  txt(tt1+12) = "<td>"+table_link_setup(OUTDIR,"tas.trends.mam.png","MAM")+"</td>"
  txt(tt1+13) = "<td>"+table_link_setup(OUTDIR,"tas.trends.jja.png","JJA")+"</td>"
  txt(tt1+14) = "<td>"+table_link_setup(OUTDIR,"tas.trends.son.png","SON")+"</td>"
  txt(tt1+15) = "<td>"+table_link_setup(OUTDIR,"tas.trends.ann.png","Annual")+"</td>"
  txt(tt1+16) = "<td>"+table_link_setup(OUTDIR,"tas.trends.mon.png","Monthly")+"</td></tr>"
  txt(tt1+17) = "<tr><td><b>PSL</b></td><td>"+table_link_setup(OUTDIR,"psl.trends.djf.png","DJF")+"</td>"
  txt(tt1+18) = "<td>"+table_link_setup(OUTDIR,"psl.trends.mam.png","MAM")+"</td>"
  txt(tt1+19) = "<td>"+table_link_setup(OUTDIR,"psl.trends.jja.png","JJA")+"</td>"
  txt(tt1+20) = "<td>"+table_link_setup(OUTDIR,"psl.trends.son.png","SON")+"</td>"
  txt(tt1+21) = "<td>"+table_link_setup(OUTDIR,"psl.trends.ann.png","Annual")+"</td>"
  txt(tt1+22) = "<td>"+table_link_setup(OUTDIR,"psl.trends.mon.png","Monthly")+"</td></tr>"
  txt(tt1+23) = "<tr><td><b>PR</b></td><td>"+table_link_setup(OUTDIR,"pr.trends.djf.png","DJF")+"</td>"
  txt(tt1+24) = "<td>"+table_link_setup(OUTDIR,"pr.trends.mam.png","MAM")+"</td>"
  txt(tt1+25) = "<td>"+table_link_setup(OUTDIR,"pr.trends.jja.png","JJA")+"</td>"
  txt(tt1+26) = "<td>"+table_link_setup(OUTDIR,"pr.trends.son.png","SON")+"</td>"
  txt(tt1+27) = "<td>"+table_link_setup(OUTDIR,"pr.trends.ann.png","Annual")+"</td>"
  txt(tt1+28) = "<td>"+table_link_setup(OUTDIR,"pr.trends.mon.png","Monthly")+"</td></tr>" 
  txt(tt1+29) = "<tr><td><b>SND</b></td><td>"+table_link_setup(OUTDIR,"snd.trends.djf.png","DJF")+"</td>"
  txt(tt1+30) = "<td>"+table_link_setup(OUTDIR,"snd.trends.mam.png","MAM")+"</td>"
  txt(tt1+31) = "<td>"+table_link_setup(OUTDIR,"snd.trends.jja.png","JJA")+"</td>"
  txt(tt1+32) = "<td>"+table_link_setup(OUTDIR,"snd.trends.son.png","SON")+"</td>"
  txt(tt1+33) = "<td>"+table_link_setup(OUTDIR,"snd.trends.ann.png","Annual")+"</td>"
  txt(tt1+34) = "<td>"+table_link_setup(OUTDIR,"snd.trends.mon.png","Monthly")+"</td></tr>"
  txt(tt1+35) = "<tr><td><b>SIC NH</b></td><td>"+table_link_setup(OUTDIR,"aice.trends.nh.djf.png","DJF")+"</td>"
  txt(tt1+36) = "<td>"+table_link_setup(OUTDIR,"aice.trends.nh.mam.png","MAM")+"</td>"
  txt(tt1+37) = "<td>"+table_link_setup(OUTDIR,"aice.trends.nh.jja.png","JJA")+"</td>"
  txt(tt1+38) = "<td>"+table_link_setup(OUTDIR,"aice.trends.nh.son.png","SON")+"</td>"
  txt(tt1+39) = "<td>"+table_link_setup(OUTDIR,"aice.trends.nh.ann.png","Annual")+"</td>"
  txt(tt1+40) = "<td>"+table_link_setup(OUTDIR,"aice.trends.nh.mon.png","Monthly")+"</td></tr>" 
  txt(tt1+41) = "<tr><td><b>SIC SH</b></td><td>"+table_link_setup(OUTDIR,"aice.trends.sh.djf.png","DJF")+"</td>"
  txt(tt1+42) = "<td>"+table_link_setup(OUTDIR,"aice.trends.sh.mam.png","MAM")+"</td>"
  txt(tt1+43) = "<td>"+table_link_setup(OUTDIR,"aice.trends.sh.jja.png","JJA")+"</td>"
  txt(tt1+44) = "<td>"+table_link_setup(OUTDIR,"aice.trends.sh.son.png","SON")+"</td>"
  txt(tt1+45) = "<td>"+table_link_setup(OUTDIR,"aice.trends.sh.ann.png","Annual")+"</td>"
  txt(tt1+46) = "<td>"+table_link_setup(OUTDIR,"aice.trends.sh.mon.png","Monthly")+"</td></tr></table></div></div>"

  tt2=tt1+48
  txt(tt2) = "<div class="+quote+"row"+quote+">"
  txt(tt2+1) = "<div class="+quote+"col"+quote+">"
  txt(tt2+2) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(tt2+3) = "<h3 class="+quote+"display-6"+quote+">Globally-Averaged Timeseries</h3>"
  txt(tt2+4) = "<tr><td><b>SST</b></td><td>"+table_link_setup(OUTDIR,"sst.timeseries.djf.png","DJF")+"</td>"
  txt(tt2+5) = "<td>"+table_link_setup(OUTDIR,"sst.timeseries.mam.png","MAM")+"</td>"
  txt(tt2+6) = "<td>"+table_link_setup(OUTDIR,"sst.timeseries.jja.png","JJA")+"</td>"
  txt(tt2+7) = "<td>"+table_link_setup(OUTDIR,"sst.timeseries.son.png","SON")+"</td>"
  txt(tt2+8) = "<td>"+table_link_setup(OUTDIR,"sst.timeseries.ann.png","Annual")+"</td>"
  txt(tt2+9) = "<td>"+table_link_setup(OUTDIR,"sst.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(tt2+10) = "<tr><td><b>TAS</b></td><td>"+table_link_setup(OUTDIR,"tas.timeseries.djf.png","DJF")+"</td>"
  txt(tt2+11) = "<td>"+table_link_setup(OUTDIR,"tas.timeseries.mam.png","MAM")+"</td>"
  txt(tt2+12) = "<td>"+table_link_setup(OUTDIR,"tas.timeseries.jja.png","JJA")+"</td>"
  txt(tt2+13) = "<td>"+table_link_setup(OUTDIR,"tas.timeseries.son.png","SON")+"</td>"
  txt(tt2+14) = "<td>"+table_link_setup(OUTDIR,"tas.timeseries.ann.png","Annual")+"</td>"
  txt(tt2+15) = "<td>"+table_link_setup(OUTDIR,"tas.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(tt2+16) = "<tr><td><b>PR</b></td><td>"+table_link_setup(OUTDIR,"pr.timeseries.djf.png","DJF")+"</td>"
  txt(tt2+17) = "<td>"+table_link_setup(OUTDIR,"pr.timeseries.mam.png","MAM")+"</td>"
  txt(tt2+18) = "<td>"+table_link_setup(OUTDIR,"pr.timeseries.jja.png","JJA")+"</td>"
  txt(tt2+19) = "<td>"+table_link_setup(OUTDIR,"pr.timeseries.son.png","SON")+"</td>"
  txt(tt2+20) = "<td>"+table_link_setup(OUTDIR,"pr.timeseries.ann.png","Annual")+"</td>"
  txt(tt2+21) = "<td>"+table_link_setup(OUTDIR,"pr.timeseries.mon.png","Monthly")+"</td></tr>"
  txt(tt2+22) = "</table></div></div>"

  tt3 = tt2+145
  txt(tt3) = "<div class="+quote+"row"+quote+">"
  txt(tt3+1) = "<div class="+quote+"col"+quote+">"
  txt(tt3+2) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(tt3+3) = "<h3 class="+quote+"display-6"+quote+">Running Trends of Globally-Averaged Monthly Timeseries</h3>"
  txt(tt3+4) = "<tr><td><b>SST</b></td><td>"+table_link_setup(OUTDIR,"sst.8yr_runtrend.mon.png","8yr")+"</td>"
  txt(tt3+5) = "<td>"+table_link_setup(OUTDIR,"sst.10yr_runtrend.mon.png","10yr")+"</td>"
  txt(tt3+6) = "<td>"+table_link_setup(OUTDIR,"sst.12yr_runtrend.mon.png","12yr")+"</td>"
  txt(tt3+7) = "<td>"+table_link_setup(OUTDIR,"sst.14yr_runtrend.mon.png","14yr")+"</td>"
  txt(tt3+8) = "<td>"+table_link_setup(OUTDIR,"sst.16yr_runtrend.mon.png","16yr")+"</td></tr>"
  txt(tt3+9) = "<tr><td><b>TAS</b></td><td>"+table_link_setup(OUTDIR,"tas.8yr_runtrend.mon.png","8yr")+"</td>"
  txt(tt3+10) = "<td>"+table_link_setup(OUTDIR,"tas.10yr_runtrend.mon.png","10yr")+"</td>"
  txt(tt3+11) = "<td>"+table_link_setup(OUTDIR,"tas.12yr_runtrend.mon.png","12yr")+"</td>"
  txt(tt3+12) = "<td>"+table_link_setup(OUTDIR,"tas.14yr_runtrend.mon.png","14yr")+"</td>"
  txt(tt3+13) = "<td>"+table_link_setup(OUTDIR,"tas.16yr_runtrend.mon.png","16yr")+"</td></tr>"
  txt(tt3+14) = "</table></div></div>"
  
  tt4 = tt3+35
  txt(tt4) = "<div class="+quote+"row"+quote+">"
  txt(tt4+1) = "<div class="+quote+"col"+quote+">"
  txt(tt4+2) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(tt4+3) = "<h3 class="+quote+"display-6"+quote+">Additional Indices</h3>"
  txt(tt4+4) = "<tr><td>"+table_link_setup(OUTDIR,"amm.timeseries.png","Atlantic Meridional Mode")+"</td>"
  txt(tt4+5) = "<td>"+table_link_setup(OUTDIR,"atl3.timeseries.png","Atlantic Ni&ntilde;o (ATL3)")+"</td>"
  txt(tt4+6) = "<td>"+table_link_setup(OUTDIR,"tna.timeseries.png","Tropical North Atlantic SST")+"</td>"
  txt(tt4+7) = "<td>"+table_link_setup(OUTDIR,"tsa.timeseries.png","Tropical South Atlantic SST")+"</td></tr>"
  txt(tt4+8) = "<tr><td>"+table_link_setup(OUTDIR,"nino12.timeseries.png","ni&ntilde;o1+2")+"</td>"
  txt(tt4+9) = "<td>"+table_link_setup(OUTDIR,"nino3.timeseries.png","ni&ntilde;o3")+"</td>"
  txt(tt4+10) = "<td>"+table_link_setup(OUTDIR,"nino4.timeseries.png","ni&ntilde;o4")+"</td>"
  txt(tt4+11) = "<td>"+table_link_setup(OUTDIR,"npi.timeseries.ndjfm.png","North Pacific PSL")+"</td></tr>"
  txt(tt4+12) = "<tr><td>"+table_link_setup(OUTDIR,"iod.timeseries.png","Indian Ocean SST Dipole")+"</td>"
  txt(tt4+13) = "<td>"+table_link_setup(OUTDIR,"tio.timeseries.png","Tropical Indian Ocean SST")+"</td>"
  txt(tt4+14) = "<td>"+table_link_setup(OUTDIR,"socn.timeseries.png","Southern Ocean SST")+"</td>"
  txt(tt4+15) = "<td>"+table_link_setup(OUTDIR,"oni.timeseries.png","Oceanic Ni&ntilde;o3.4")+"</td></tr>"
  txt(tt4+16) = "<tr><td>"+table_link_setup(OUTDIR,"samind_norm.timeseries.png","SAM (Marshall) indices (norm.)")+"</td>"
  txt(tt4+17) = "<td>"+table_link_setup(OUTDIR,"sam_p40S.timeseries.png","SAM (Marshall) Zonal Mean Pressure at 40S")+"</td>"
  txt(tt4+18) = "<td>"+table_link_setup(OUTDIR,"sam_p65S.timeseries.png","SAM (Marshall) Zonal Mean Pressure at 65S")+"</td>"
  txt(tt4+19) = "<td>"+table_link_setup(OUTDIR,"aslind.timeseries.png","Amundsen Sea Low (ASL) indices (norm.)")+"</td></tr>"
  txt(tt4+20) = "<tr><td>"+table_link_setup(OUTDIR,"asl_clat.timeseries.png","ASL Central Latitude")+"</td>"
  txt(tt4+21) = "<td>"+table_link_setup(OUTDIR,"asl_clon.timeseries.png","ASL Central Longitude")+"</td>"
  txt(tt4+22) = "<td>"+table_link_setup(OUTDIR,"asl_cpsl.timeseries.png","ASL Central Pressure")+"</td>"
  txt(tt4+23) = "<td>"+table_link_setup(OUTDIR,"asl_rmpsl.timeseries.png","ASL Sector Mean Pressure")+"</td></tr>"
  txt(tt4+24) = "<tr><td>"+table_link_setup(OUTDIR,"asl_rcpsl.timeseries.png","ASL Relative Central Pressure")+"</td>"
  txt(tt4+25) = "<td>"+table_link_setup(OUTDIR,"hcwd_norm.timeseries.png","Hadley Cell Width (norm.)")+"</td>"
  txt(tt4+26) = "<td>"+table_link_setup(OUTDIR,"pnjet_norm.timeseries.png","Polar Jet (NH) Position (norm.)")+"</td>"
  txt(tt4+27) = "<td>"+table_link_setup(OUTDIR,"psjet_norm.timeseries.png","Polar Jet (SH) Position (norm.)")+"</td>"
  txt(tt4+28) = "</table></div></div>"
  
  tt5 = tt4+35
  txt(tt5)   = "<a name="+quote+"mean"+quote+">"
  txt(tt5+1) = "<div class="+quote+"row"+quote+"><div class="+quote+"col"+quote+">"
  txt(tt5+2) = "<table class="+quote+"table table-striped table-bordered"+quote+">"
  txt(tt5+3) = "<h3 class="+quote+"display-6"+quote+">Mean Climatology  (back to <a href="+quote+"#stddev"+quote+">Standard Deviation)</a></h3>"
  txt(tt5+4) = "<tr><td><b>SST</b></td><td>"+table_link_setup(OUTDIR,"sst.mean.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"sst.mean.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"sst.mean.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"sst.mean.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"sst.mean.ann.png","Annual")+"</td></tr>"
  txt(tt5+5) = "<tr><td><b>TAS</b></td><td>"+table_link_setup(OUTDIR,"tas.mean.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"tas.mean.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"tas.mean.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"tas.mean.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"tas.mean.ann.png","Annual")+"</td></tr>"
  txt(tt5+6) = "<tr><td><b>PSL</b></td><td>"+table_link_setup(OUTDIR,"psl.mean.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"psl.mean.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"psl.mean.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"psl.mean.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"psl.mean.ann.png","Annual")+"</td></tr>"
  txt(tt5+7) = "<tr><td><b>PR</b></td><td>"+table_link_setup(OUTDIR,"pr.mean.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pr.mean.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"pr.mean.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pr.mean.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"pr.mean.ann.png","Annual")+"</td></tr>"
  txt(tt5+8) = "<tr><td><b>[PR]</b></td><td>"+table_link_setup(OUTDIR,"pr.za.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"pr.za.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"pr.za.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"pr.za.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"pr.za.ann.png","Annual")+"</td></tr>"
  txt(tt5+9) = "<tr><td><b>SND</b></td><td>"+table_link_setup(OUTDIR,"snd.mean.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"snd.mean.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"snd.mean.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"snd.mean.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"snd.mean.ann.png","Annual")+"</td></tr>"
  txt(tt5+10) = "<tr><td><b>SIC NH</b></td><td>"+table_link_setup(OUTDIR,"aice.mean.nh.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"aice.mean.nh.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"aice.mean.nh.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"aice.mean.nh.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"aice.mean.nh.ann.png","Annual")+"</td></tr>" 
  txt(tt5+11) = "<tr><td><b>SIC SH</b></td><td>"+table_link_setup(OUTDIR,"aice.mean.sh.djf.png","DJF")+"</td><td>"+table_link_setup(OUTDIR,"aice.mean.sh.mam.png","MAM")+"</td><td>"+table_link_setup(OUTDIR,"aice.mean.sh.jja.png","JJA")+"</td><td>"+table_link_setup(OUTDIR,"aice.mean.sh.son.png","SON")+"</td><td>"+table_link_setup(OUTDIR,"aice.mean.sh.ann.png","Annual")+"</td></tr>" 
  txt(tt5+12) = "</table></div></div>"

  tt6 = tt5+37
;  if (OT.eq."True") then
;     txt(265) = "<p class=btext>Output timeseries written to "+OUTDIR+"</p>"
;  else
     txt(tt6+1) = "<br>"
;  end if  
  txt(tt6+2) = "</body></html>"
  
  tft   = ind(.not.ismissing(txt))
  txt2 = txt(:tft(dimsizes(tft)-1)+1)
  tft2 = ind(.not.ismissing(txt2))
  txt3 = txt2(tft2)
  asciiwrite(OUTDIR+"index.html",txt3)
  delete([/txt,tft,tft2,txt2,txt3,tt0,tt1,tt2,tt3,tt4,tt5,quote,names,na,nsim_noobs,OT/])
;----------------------------------------------------------------------------
;--   Create calculation description webpage
;----------------------------------------------------------------------------
  txt = new(5000,"string")
  quote = str_get_dq()
  
  txt(0) = "<html><head><title>Climate Variability Diagnostics Package</title>"
  txt(1) = "<link rel="+quote+"stylesheet"+quote+" href="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"+quote+" integrity="+quote+"sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"+quote+" crossorigin="+quote+"anonymous"+quote+">"
  txt(2) = "<script src="+quote+"https://code.jquery.com/jquery-3.3.1.slim.min.js"+quote+" integrity="+quote+"sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
  txt(3) = "<script src="+quote+"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"+quote+" integrity="+quote+"sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
  txt(4) = "<script src="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"+quote+" integrity="+quote+"sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"

  txt(5) = "<style>body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
  txt(6) = "img.title {width:990; height:95; align:left}"
  txt(7) = "p.title {font-size:20pt; color:black; font-weight:bold; text-align:center}"
  txt(8) = "p.subtitle1 {font-size:12pt; color:gray}"
  txt(9) = "p.subtitle {font-size:16pt; color:black; font-weight:bold; text-align:left}"
  txt(10) = "p.btext {font-size:9pt}"
  txt(11) = "td {text-align:left; font-size:12pt}"
  txt(12) = "td.s1 {text-align:left; font-size:11pt}"
  txt(13) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}"
  txt(14) = "</style></head><BODY>"
  txt(15) = "<img class=title src="+quote+"e3sm-cvdp.png"+quote+" alt="+quote+"CVDP logo"+quote+">"  
  txt(16) = "<TABLE width='990' border=0 cellpadding=6><tr><td class=s1 width='300'><a href="+quote+"index.html"+quote+">Back to Diagnostics Plots</a></td>"
  txt(17) = "<td><p class=title>Methodology and Definitions</p></td></tr></table><hr width=990 align=left>" 

  txt(20) = "<p class=subtitle>General Notes</p>"
  txt(21) = "<TABLE width='800' border=1 frame=void rules=all cellpadding=6 bordercolor=darkgray>"
  txt(22) = "<tr><td><ul><li>TS is surface ("+quote+"skin"+quote+") temperature and is used in lieu of sea surface temperatures (SSTs), TAS is 2m air temperature (E3SM or CESM equivalent = TREFHT)."
  txt(23) = "<li>PR is total precipitation (E3SM or CESM equivalent = PRECC+PRECL), PSL is sea level pressure, SND is snow depth (SNOWDP), OLR is outgoing longwave radiation (E3SM equivalent = FSNTOA - FSNT + FLNT), CLDTOT is total cloud fraction (%), U10 and V10 are surface zonal and meridional winds (using U V at 1000-hPa as an estimation if not model output), TAUX  and TAUY are surface zonal and meridional wind stress (E3SM equivalent = TAUX and TAUY), SWCRE is shortwave cloud radiative effects (E3SM equivalent = FSNT - FSNTC), U850 and V850 are zonal and meridional winds at 850-hPa, TH850 is potential temperature at 850hPa, Z500 is geopotential height at 500-hPa (E3SM equivalent = Z3 with interpolation to 500-hPa),and SIC is ice concentration (aice)."
  txt(24) = "<li>The annual cycle is removed prior to every calculation by subtracting the long-term monthly means. Exception: The annual cycle is not removed for mean spatial maps."
  txt(25) = "<li>Area-averages are always based on cosine of latitude weighting."
  txt(26) = "<li>The following calculations use linearly detrended data: standard deviations, Hadley cell width, SAM index, nino3.4 spectra, Hadley cell width, SAM index,nino3.4 autocorrelations, Hadley cell, SAM, ENSO spatial composites, and Hadley cell, SAM,ENSO Hovm&ouml;llers."
  txt(27) = "<li>For visual clarity, the Y-axis <i>may</i> differ amongst individual panels on a particular plot."
  txt(28) = "<li>Climatological Zonal Averages: Climatological means are zonally averaged over the globe." 
  txt(29) = "<li>Power Spectra: The best-fit first-order Markov red noise spectrum (red curve) and its 95% (blue curve) and 99% (green curve) confidence bounds are shown on each panel. Top X-axis shows the period (in years), and the bottom X-axis shows the frequency (cycles/mo). If calculated, the observational spectrum is overlaid in gray on each model spectrum. The spectra are displayed in variance-conserving form." 
  txt(30) = "<li>Wavelet Analysis: A wavelet transform is computed using a Morlet wavelet with a wavenumber of 6. Areas significant at the 95% based on a chi-square test are stippled and the “cone of influence” is hatched. See Torrence, C. and G. P. Compo, 1998: A Practical Guide to Wavelet Analysis. Bull. Amer. Meteor. Soc., 79, 61-78. doi: http://dx.doi.org/10.1175/1520-0477(1998)079<0061:APGTWA>2.0.CO;2."
  txt(31) = "<li>Running Trends: N-year running trends are computed by calculating the linear trend over the N-year interval beginning at each successive timestep.  For instance, for a global timeseries that runs from 1970-2012, the 8yr running trend value for January 1970 is the linear trend during January 1970 - December 1977, and the value for January 2005 is the linear trend during January 2005 - December 2012."
  txt(32) = "<li>Running Standard Deviations: 15-year running standard deviations are computed by calculating the standard deviation centered over the 15 year interval at each successive timestep, with a minimum of 20 years of data required. For example, for a timeseries that runs from 1920-2010, the 15yr running standard deviation value for January 1935 is calculated over the period January 1920-December 1934. The right subtitle shows the minimum / mean / maximum of the computed timeseries." 
  txt(33) = "<li>Metrics Tables: Area-weighted pattern correlations and rms differences are calculated between observations and each model simulation (regridded to match the observational grid) for selected climate metrics. The Total Score column shows the average of the pattern correlations (Z-transformed) and rms differences over all selected climate metrics included in the table. There are multiple metrics tables: 1. overall-performance score table: calculated with 11 selected climate metrics. The following domains are used to compute the pattern correlations and rms differences: Means, standard deviations, ENSO, AMO, and PDO: Global; global for means, standard deviations, ENSO, AMO, and PDO; entire longitude/temporal range shown for El Nino and La Nina Hovm&ouml;llers; entire domain shown for NAM (20:90&deg;N) and SAM (20:90&deg;S); 2. Regression of 20 selected physical quantities on normalized ni&ntilde;o3.4, NAM, SAM, NAO, PNA, NPO, PSA1, PSA2 indices, the domains for EOF analysis of atmospheric modes are used to calculate the pattern correlations and rms differences, except that global domain is used for ni&ntilde;o3.4."
  txt(34) = "<li>EOF significance: If an eigenvalue is significantly seperated from neighboring values a star is appended to the percent variance explained on the plot. Significance is calculated following North et al. (MWR, 1982)."
  txt(35) = "<li>Ice Extent: Any grid cell defined as having a value at or above 15% is assumed to be 100% ice covered. The area of these grid cells is summed to create ice extent. For data sets with a northern hemisphere pole hole the CVDP looks for an attribute named pole_hole_area that is attached to the AREA variable in the netCDF file. The format of pole_hole_area should be start month (YYYYMM), end month (YYYYMM), area value, (repeat as necessary). If pole_hole_area is detected the CVDP will add the area value to the calculated northern hemisphere ice extent timeseries from the specified start month to the specified end month, and a * is placed after the dataset name in the ice extent plots."    
  txt(36) = "<li>For more information on observational datasets and climate indices, see the <a href="+quote+"https://psl.noaa.gov/data/climateindices/list/"+quote+" target="+quote+"_blank"+quote+">NOAA PSL</a> and  <a href="+quote+"http://climatedataguide.ucar.edu/"+quote+" target="+quote+"_blank"+quote+">Climate Data Guide</a>.</ul>"
  txt(37) = "</td></tr></table>"

  txt(40) = "<p class=subtitle>Modes of Variability</p>"
  txt(41) = "<TABLE width='800' border=1 frame=void rules=all cellpadding=6 bordercolor=darkgray>"
  txt(42) = "<tr><td><b>ENSO Spatial Composites</b></td>"
  txt(43) = "<td>The normalized December nino3.4 timeseries is used to composite all years greater than 1 standard deviation (El Ni&ntilde;o) and all years less that -1 standard deviation (La Ni&ntilde;a). The number of El Ni&ntilde;o/La Ni&ntilde;a events composited is shown in the right subtitle. The December nino3.4 timeseries is based on the December values of the monthly nino3.4 time series smoothed with a 3-point binomial filter. TS/TAS/PSL composites: Temperatures are color shaded and in units of Celsius. Sea level pressure is contoured from -16 to 16hPa by 2hPa; negative contours are dashed. PR composites: Precipitation is color shaded and is in units of mm/day. See Deser, C., A. S. Phillips, R. A. Tomas, Y. Okumura, M. A. Alexander, A. Capotondi, J. D. Scott, Y. -O. Kwon, and M. Ohba, 2012: ENSO and Pacific Decadal Variability in Community Climate System Model Version 4. <i>J. Climate</i>, 25, 2622-2651, doi: 10.1175/JCLI-D-11-00301.1.</td></tr>"   
  txt(44) = "<tr><td><b>ENSO Hovm&ouml;llers</b></td>"
  txt(45) = "<td>A 1-2-1 running average is applied to the monthly nino3.4 timeseries, and then December values are selected and normalized. Meridional averages are calculated by averaging from 3&deg;S:3&deg;N, and spatial patterns are formed by compositing from Jan year 0 to May year 2 where the nino3.4 (1-2-1 weighted) December (year 0) index is greater than 1 (El Niño) and those years where the index is less than -1 (La Niña). See Deser, C., A. S. Phillips, R. A. Tomas, Y. Okumura, M. A. Alexander, A. Capotondi, J. D. Scott, Y. -O. Kwon, and M. Ohba, 2012: ENSO and Pacific Decadal Variability in Community Climate System Model Version 4. J. Climate, 25, 2622-2651, doi: 10.1175/JCLI-D-11-00301.1.</td></tr>"  
  txt(46) = "<tr><td><b>ENSO Teleconnections</b></td>"
  txt(47) = "<td>The ENSO teleconnections are reflected by regressing the slected quanties onto normalized nino3.4 (1-2-1 weighted) index. The monthly, seasonal and annual mean are calculated over the globe. The regressed patterns for PSL, SST, TAS, PR, PLR are shown in the package. The metrics tables for pattern correlation and root-mean-squre differences calculated for 20 selected quantities are also provied for evaluation</td></tr>" 
  txt(48) = "<tr><td><b>PDO</b> (Pacific Decadal Oscillation)</td>"  
  txt(49) = "<td>Monthly index timeseries defined as the leading principal component (PC) of North Pacific (20:70&deg;N, 110&deg;E:100&deg;W) area-weighted SST* anomalies, where SST* denotes that the global mean SST anomaly has been removed at each timestep. Pattern created by regressing SST anomalies (in Celsius) at each grid box onto the normalized PC timeseries. Low pass-filtered timeseries (black curve) is based on a a 61-month running mean. See Deser, C., M. A. Alexander, S. -P. Xie, and A. S. Phillips, 2010: Sea surface temperature variability: patterns and mechanisms. <i>Ann. Rev. Mar. Sci.</i>, 2010.2, 115-143, doi:10.1146/annurev-marine-120408-151453. Also see Mantua, N. J., S. R. Hare, Y. Zhang, J. M. Wallace, and R. Francis, 1997: A Pacific interdecadal climate oscillation with impacts on salmon production. <i>Bull. Amer. Met. Soc.</i>, 1069-1079. For more information on the PDO see the <a href="+quote+"https://climatedataguide.ucar.edu/climate-data/pacific-decadal-oscillation-pdo-definition-and-indices?qt-climatedatasetmaintabs=1"+quote+" target="+quote+"_blank"+quote+">Climate Data Guide</a>.</td></tr>"
  txt(50) = "<tr><td><b>IPO</b> (Interdecadal Pacific Oscillation)</td>"  
  txt(51) = "<td>Monthly index timeseries defined as the leading principal component (PC) of 13yr low pass filtered Pacific (40&deg;S:60&deg;N, 110&deg;E:70&deg;W) area-weighted SST* anomalies, where SST* denotes that the global mean SST anomaly has been removed at each timestep.  Pattern created by regressing SST anomalies (in Celsius) at each grid box onto the normalized PC timeseries. At least 40 years of data are required for the IPO to be calculated. See Meehl, G.A. and A. Hu, 2007: Megadroughts in the Indian Monsoon Region and Southwest North America and a Mechanism for Associated Multidecadal Pacific Sea Surface Temperature Anomalies, <i>J. Clim</i>, 19, 1605-1623, doi: 10.1175/JCLI3675.1.</td></tr>"

  txt(52) = "<tr><td><b>AMO</b> (Atlantic Multidecadal Oscillation)</td>"  
  txt(53) = "<td>Monthly index timeseries defined as area-weighted SST* anomalies averaged over the North Atlantic (0:60&deg;N, 80&deg;W:0&deg;E), where SST* denotes that the global (60&deg;S:60&deg;N) mean SST anomaly has been removed at each timestep. Pattern created by regressing SST* anomalies onto the index timeseries and smoothing with a 9-point spatial filter. Low pass-filtered timeseries (black curve superimposed on the monthly timeseries) is based on a a 61-month running mean. Based on Trenberth, K. E., and D. J. Shea, 2006: Atlantic hurricanes and natural variability in 2005, <i>Geophys. Res. Lett.</i>, 33, L12704, doi:10.1029/2006GL026894. Low-pass filtered regression maps ("+quote+"Regr LP"+quote+") use a 10-year running mean on both the index timeseries and the field being regressed. For more information on the AMO see the <a href="+quote+"https://climatedataguide.ucar.edu/climate-data/atlantic-multi-decadal-oscillation-amo?qt-climatedatasetmaintabs=1"+quote+" target="+quote+"_blank"+quote+">Climate Data Guide</a>.</td></tr>"
  txt(54) = "<tr><td><b>AMOC</b></td>"
  txt(55) = "<td>The Atlantic Meridional Overturning Circulation (AMOC) is defined as the oceanic meridional mass transport (Sv) in the Atlantic sector. To compute AMOC, we follow the methods of Danabasoglu et al. (2012). Here we use annual averages of the AMOC, weighted by the cosine of the latitude and vertical extent of each model layer. Areas in which AMOC variance is low (standard deviation < 1e-6 Sv) are set to missing values for clarity. The leading EOF and associated principal component (PC) timeseries are computed over the Atlantic basin from 33&deg;S to 90&deg;N. The AMOC patterns are created by regressing the AMOC anomalies (in Sv) onto the normalized PC timeseries. The SST/TAS patterns associated with AMOC variations are created by regressing TAS/SST anomalies (in Celsius) at each grid box over the globe onto the normalized AMOC PC timeseries. A 15-point low-pass Lanczos filter is applied to the AMOC PC (and AMO) timeseries prior to computing lead/lag correlations, with a minimum of 90 years of data required. The data are not detrended (unlike Danabasoglu et al., 2012). See Danabasoglu, G., S. G. Yeager, Y. -O. Kwon, J. J. Tribbia, A. S. Phillips, and J. W. Hurrell, 2012. Variability of the Atlantic Meridional Overturning Circulation in CCSM4. J. Climate, 25, 5153-5172, doi: 10.1175/JCLI-D-11-00463.1.<br><br>For CCSM4 and CESM1, the MOC variable is read in, the Eulerian Mean, Eddy-Induced and Submeso components are summed, and the Atlantic Ocean + Mediterranean Sea + Labrador Sea + GIN Sea + Arctic Ocean + Hudson Bay transport region is selected. For CCSM2 and CCSM3 the same transport region is selected but only the Eulerian Mean component is used as that is all that is available. For CMIP5 (CMIP6) data the msftmyz (msftmz) variable is read in and the atlantic_arctic_ocean basin is used. For CMIP3 data, the stfmmc variable is read in and the atlantic_ocean geo_region is used.</td></tr>" 

  txt(57) = "<tr><td><b>NAM</b> (Northern Annular Mode)</td>"  
  txt(58) = "<td>Seasonal/annual PSL averages are formed, square root of the cosine of the latitude weighting is applied, and then the leading EOF and associated principal component (PC) timeseries are computed over 20:90&deg;N, 0:360&deg;E. Pattern created by regressing global PSL anomalies (in hPa) onto normalized PC timeseries. Based on Hurrell, J. W., and C. Deser, 2009: North Atlantic climate variability: The role of the North Atlantic Oscillation. <i>J. Mar. Syst.</i>, 78, 28-41, doi:10.1016/j.jmarsys.2008.11.026. Also see Thompson, D. W. J., and J. M. Wallace, 2000: Annular modes in the extratropical circulation. Part I: Month-to-month variability. <i>J. Climate</i>, 13, 1000-1016.</td></tr>"  
  txt(59) = "<tr><td><b>NAO</b> (North Atlantic Oscillation)</td>"  
  txt(60) = "<td>Seasonal/annual PSL averages are formed, square root of the cosine of latitude weighting is applied, and then the leading EOF and associated principal component (PC) timeseries are computed over 20:80&deg;N, 90&deg;W:40&deg;E. Pattern created by regressing global PSL anomalies (in hPa) onto normalized PC timeseries. Based on Hurrell, J. W. and C. Deser, 2009: North Atlantic climate variability: The role of the North Atlantic Oscillation. <i>J. Mar. Syst.</i>, 78, 28-41, doi:10.1016/j.jmarsys.2008.11.026. For more information on the NAO see the <a href="+quote+"https://climatedataguide.ucar.edu/climate-data/hurrell-north-atlantic-oscillation-nao-index-pc-based?qt-climatedatasetmaintabs=1"+quote+" target="+quote+"_blank"+quote+">Climate Data Guide</a>.</td></tr>"  
  txt(61) = "<tr><td><b>SAM/PSA1/PSA2</b> (Southern Annular Mode, Pacific South American Patterns 1/2)</td>"  
  txt(62) = "<td>Seasonal/annual PSL averages are formed, square root of the cosine of latitude weighting is applied, and then the 1st (SAM), 2nd (PSA1) and 3rd (PSA2) EOFs and associated principal component (PC) timeseries are computed over 20:90&deg;S, 0:360&deg;E. Patterns created by regressing global PSL anomalies (in hPa) onto normalized PC timeseries. SAM calculation based on Thompson, D. W. J. and J.M. Wallace, 2000: Annular modes in the extratropical circulation. Part I: Month-to-month variability. <i>J. Climate</i>, 13, 1000-1016.</td></tr>"  
  txt(63) = "<tr><td><b>PNA/NPO</b> (Pacific North American Pattern, North Pacific Oscillation)</td>" 
  txt(64) = "<td>Seasonal/annual PSL averages are formed, the square root of the cosine of the latitude weighting is applied, and then the 1st (PNA) and 2nd (NPO) EOFs and associated principal component (PC) timeseries are computed over 20:85&deg;N, 120&deg;E:120&deg;W. Patterns created by regressing global PSL anomalies (in hPa) onto normalized PC timeseries.</td></tr>" 
  txt(65) = "<tr><td><b>Subtropical Jet(STJSH,STJNH)</b> (Subtropical Jet at Northern and Southern Hemisphere)</td>"
  txt(66) = "<td>Monthly U200 and U850 averages are used.  The approach used here follows that of (Adam et al. 2018; Waugh et al. 2018, and references therein), who define position of the STJ as the latitude of the maximum of the upper-level minus lower-level zonal wind. Strictly, the latitude of the maximum of the zonal wind averaged between the 100 and 400 hPa levels minus the zonal wind at the 850 hPa level should be used. In this diagnostic package, we use zonal wind at 200hPa as an estimation of the zonal wind averaged between the 100 and 400 hPa levels to identify STJ ( the results are proved to be similar to those following strict definition (see e.g. Liu et. al.(2021,10.1029/2021JD034876)). Specifically, we first interpolate the data into a 0.02deg grid, and find the latitude of maximum wind speed at an interval of 0.02deg. The search region is 10-50N in northern hemisphere and 10S-50S in southern hemisphere.Patterns created by regressing global U850 anomalies (in m/s) onto normalized Jet position (latitude) timeseries.</td></tr>"  
  txt(67) = "<tr><td><b>Polar Jet(PNJET,PSJET)</b> (Polar Jet at Northern and Southern Hemisphere)</td>"
  txt(68) = "<td>Monthly U850 averages are used.  The approach used here follows that of (Bracegirdle et al. 2018), who calculate jet diagnostics from latitudinally-interpolated zonal mean westerly wind on the 850 hPa level (U850) between the latitudes of 70N (S) and 20N(S). The main reason for choosing 850 hPa is that it captures the lower-tropospheric  jet whilst also avoiding uncertainties associated with reanalysis estimates of wind in the atmospheric boundary layer (Kent et al. 2012), therefore allowing for more direct model-observation comparisons.  Patterns created by regressing global U850 anomalies (in m/s) onto normalized Jet position (latitude) timeseries.</td></tr>"
  txt(69) = "<tr><td><b>Hadley Cell (HC)</b> (Hadley circulation at Northern and Southern Hemisphere)</td>"
  txt(70) = "<td>Monthly zonal-mean meridional streamfunction are used.  Diagnostics for the Hadley cell (HC) following Nguyen et al. (2013): Nguyen, H., Evans, A., Lucas, C., Smith, I., & Timbal, B. (2013). The Hadley Circulation in Reanalyses: Climatology, Variability, and Change, Journal of Climate, 26(10), 3357-3376. Retrieved Feb 16, 2023, from https://journals.ametsoc.org/view/journals/clim/26/10/jcli-d-12-00224.1.xml; Here, The zonal-mean meridional streamfunction derived from the meridional wind fields is chosen to diagnose the HC. Specifically, The monthly zonal-mean meridional streamfunction is computed from monthly-mean data, the diagnostics includes: 1. intensity: defined as the vertically averaged maximum value of between 900 and 200 hPa, marking the lower and upper limits of the cell 2. extent (or edge) of the HCs:  the zero isoline for stream function on the poleward side of these cells, averaged between 400 and 600 hPa; 3. the width of the Hadley circulation as the distance between the first latitudes poleward of the cell centers in which the 700-400-hPa average value of c equals zero, which is the width of both cells together. Here, the width of each cell is defined by the difference between these extents and the intersection between the two cells; 4. The intersection represents the latitude of zero value of c, averaged between 400 and 600 hPa, near the equator (i.e., when c changes sign as it passes from positive value in the NH cell to negative value in the SH cell), that separates the NH and SH cells; 5. the intensity is defined as the vertically averaged maximum value of c between 900 and 200 hPa, marking the lower and upper limits of the cell.</td></tr>"
  txt(71) = "<tr><td><b>SST Regressions</b></td>"
  txt(72) = "<td>SST anomalies (in Celsius) at each grid box are regressed upon the normalized atmospheric mode timeseries (dotted patterns indicate the region passes a 95% confidence level).</td></tr>" 
  txt(73) = "<tr><td><b>TAS Regressions</b></td>"
  txt(74) = "<td>TAS anomalies (in Celsius) at each grid box are regressed upon the normalized atmospheric mode timeseries (dotted patterns indicate the region passes a 95% confidence level).</td></tr>" 
  txt(75) = "<tr><td><b>PSL Regressions</b></td>"
  txt(76) = "<td>PSL anomalies (in hPa) at each grid box are regressed upon the normalized atmospheric mode timeseries (dotted patterns indicate the region passes a 95% confidence level).</td></tr>"
  txt(77) = "<tr><td><b>PR Regressions</b></td>"
  txt(78) = "<td>PR anomalies (in mm/day) at each grid box are regressed upon the normalized atmospheric mode timeseries (dotted patterns indicate the region passes a 95% confidence level).</td></tr>" 
  txt(79) = "<tr><td><b>OLR (Outgoing Longwave Radiation) Regressions</b></td>"
  txt(80) = "<td>OLR anomalies (in W/m2) at each grid box are regressed upon the normalized atmospheric mode timeseries (dotted patterns indicate the region passes a 95% confidence level).</td></tr>"
  txt(81) = "<tr><td><b>SIC (Sea Ice Concentration) Regressions</b></td>"
  txt(82) = "<td>To be added in near future.</td></tr>"
  txt(83) = "</td></tr></table>"

  txt(100) = "<p class=subtitle>Climate Indices</p>"
  txt(101) = "<TABLE width='800' border=1 frame=void rules=all cellpadding=6 bordercolor=darkgray>"
  txt(102) = "<tr><td><b>Atlantic Meridional Mode</b></td>"
  txt(103) = "<td>Defined as the difference between area-averaged SST anomalies (in Celsius) computed over 5:15&deg;N, 20:50&deg;W and area-averaged SST anomalies computed over 5:15&deg;S, 20&degW:10&deg;E. Red/blue shading denotes positive/negative departures from the best-fit linear trend line. See Doi, T., T. Tozuka and T. Yamagata (2009), Interannual variability of the Guinea Dome and its possible link with the Atlantic Meridional Mode. Climate Dynamics, 33, 985-998, doi:10.1007/s00382-009-0574-z.</td></tr>"
  txt(104) = "<tr><td><b>Atlantic Ni&ntilde;o (ATL3)</b></td>"
  txt(105) = "<td>Area-averaged SST anomalies (in Celsius) computed over 3&deg;S:3&deg;N, 20&deg;W:0&deg;E. Red/blue shading denotes positive/negative departures from the best-fit linear trend line. See Zebiak, S. E., (1993): Air–sea interaction in the equatorial Atlantic region. Journal of Climate, 6, 1567–1586.</td></tr>"
  txt(106) = "<tr><td><b>Tropical North Atlantic SST</b></td>"
  txt(107) = "<td>Area-averaged SST anomalies (in Celsius) computed over 5.5:23.5&deg;N, 15:57.5&deg;W. Red/blue shading denotes positive/negative departures from the best-fit linear trend line. See Enfield, D.B., A.M. Mestas, D.A. Mayer, and L. Cid-Serrano (1999), How ubiquitous is the dipole relationship in tropical Atlantic sea surface temperatures?, JGR-O, 104, 7841-7848.</td></tr>"
  txt(108) = "<tr><td><b>Tropical South Atlantic SST</b></td>"
  txt(109) = "<td>Area-averaged SST anomalies (in Celsius) computed over 0:20&deg;S, 30&deg;W:10&deg;E. Red/blue shading denotes positive/negative departures from the best-fit linear trend line. See Enfield, D.B., A.M. Mestas, D.A. Mayer, and L. Cid-Serrano (1999), How ubiquitous is the dipole relationship in tropical Atlantic sea surface temperatures?, JGR-O, 104, 7841-7848.</td></tr>"
  txt(110) = "<tr><td><b>ni&ntilde;o1+2</b></td>"
  txt(111) = "<td>Area-averaged SST anomalies (in Celsius) computed over 0:10&deg;S, 80:90&deg;W. Red/blue shading denotes positive/negative departures from the best-fit linear trend line.</td></tr>"
  txt(112) = "<tr><td><b>ni&ntilde;o3</b></td>"
  txt(113) = "<td>Area-averaged SST anomalies (in Celsius) computed over 5&deg;S:5&deg;N, 90:150&deg;W. Red/blue shading denotes positive/negative departures from the best-fit linear trend line. See Trenberth, K. E. (1997) The Definition of El Niño. Bulletin of the American Meteorological Society, 78, 2771-2777.</td></tr>"
  txt(114) = "<tr><td><b>ni&ntilde;o3.4</b></td>"
  txt(115) = "<td>Area-averaged SST anomalies (in Celsius) computed over 5&deg;S:5&deg;N, 120:170&deg;W. Red/blue shading denotes positive/negative departures from the best-fit linear trend line. See Trenberth, K. E. (1997) The Definition of El Niño. Bulletin of the American Meteorological Society, 78, 2771-2777.</td></tr>"
  txt(116) = "<tr><td><b>ni&ntilde;o4</b></td>"
  txt(117) = "<td>Area-averaged SST anomalies (in Celsius) computed over 5&deg;S:5&deg;N, 160&deg;E:150&deg;W. Red/blue shading denotes positive/negative departures from the best-fit linear trend line.</td></tr>"
  txt(118) = "<tr><td><b>ONI</b> (Oceanic Ni&ntilde;o3.4)</td>"
  txt(119) = "<td>The ONI uses the same region as the Niño 3.4 index.  The ONI uses a 3-month running mean, and to be classified as a full-fledged El Niño or La Niña, the anomalies must exceed +0.5C or -0.5C for at least five consecutive months.  This is the operational definition used by NOAA.</td></tr>"
  txt(120) = "<tr><td><b>NPI</b> (North Pacific PSL Index)</td>"
  txt(121) = "<td>Winter (December-March) average PSL anomalies (in hPa) area-averaged over 30&deg;:65&deg;N, 160&deg;E:140&deg;W. Based on Trenberth, K. E. and J. W. Hurrell, 1994: Decadal atmosphere-ocean variations in the Pacific, <i>Climate Dynamics</i>, 9, 303-319.</td></tr>"    

  txt(122) = "<tr><td><b>Indian Ocean SST Dipole</b></td>"
  txt(123) = "<td>Defined as the difference between area-averaged SST anomalies (in Celsius) computed over 10&deg;S:10&deg;N, 50:70&deg;E and area-averaged SST anomalies computed over 0:10&deg;S, 90:110&deg;E. Red/blue shading denotes positive/negative departures from the best-fit linear trend line. See: Saji N.H., Goswami B.N., Vinayachandran P.N., Yamagata T., 1999: A dipole mode in the tropical Indian Ocean, Nature, 401, 360-363.</td></tr>"
  txt(124) = "<tr><td><b>Tropical Indian Ocean SST</b></td>"
  txt(125) = "<td>Area-averaged SST anomalies (in Celsius) computed over 15&deg;S:15&deg;N, 40:110&deg;E. Red/blue shading denotes positive/negative departures from the best-fit linear trend line.</td></tr>"
  txt(126)= "<tr><td><b>Southern Ocean SST</b></td>"
  txt(127)= "<td>Area-averaged SST anomalies (in Celsius) computed over 50&deg;:70&deg;S, 0:360&deg;E. Red/blue shading denotes positive/negative departures from the best-fit linear trend line.</td></tr>"

  txt(128) = "<tr><td><b>SAMI</b> (Southern Annular Mode PSL index)</td>"
  txt(129) = "<td>The SAMI is based on the numerical definition of the SAM by Gong and Wang (1999), which uses the normalized monthly zonal sea level pressure (SLP) at 40S and 65S to compute SAM. The methodology is discussed in detail in Marshall (2003) and at the dataset website: https://legacy.bas.ac.uk/met/gjma/sam.html. In the package, we use SAM (Marshall) to distiguish this SAM index from those with EOF analysis. Along with the SAMI, the time series of PSL at 40S and 65S are also plotted to evaluate model representativeness of pressure at these two latitude-band locations. </td></tr>"
  txt(130) = "<tr><td><b>ASL</b> (Amundsen Sea Low indices)</td>"
  txt(131) = "<td>The Amundsen Sea Low (ASL) is a climatological low pressure center located over the extreme southern Pacific Ocean, off the coast of West Antarctica. Atmospheric variability in this region is larger than anywhere else in the Southern Hemisphere, and exhibits significant correlations with both the Southern Annular Mode (SAM) and ENSO.  A consistent set of indices of the ASL, including its absolute and relative central pressure, and the latitude and longitude of these central pressures are derieved following Hosking, J. S., Orr, A., Bracegirdle, T. J., Turner, J. (2016). Future circulation changes off West Antarctica: Sensitivity of the Amundsen Sea Low to projected anthropogenic forcing.. Geophysical Research Letters, 43, doi:10.1002/2015GL067143. The ASL indices include (a) the ASL latitude and longitude, which are identified using a minima finding algorithm within the ASL sector (170-298E, 80-60S); (b) the ASL Actual Central Pressure Index is simply defined as the pressure at the ASL location. Note that the ASL actual central pressure is strongly modulated by the Southern-Hemisphere Annual Mode (SAM) across all seasons, with time series correlations significant at p<0.01 (Hosking et al., 2013); (c) The ASL Relative Central Pressure is essentially a regional pressure anomaly. It is calculated by subtracting the ASL actual central pressure from the area-averaged pressure over the ASL domain (domain specified above). </td></tr>"
  txt(132) = "</table>"
  txt(133) = ""
  
  txt(135) = "<br>Created "+systemfunc("date")
  txt(136) = "<p class=btext>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p>"
  txt(137) = "</body></html>"
  
  tt = ind(.not.ismissing(txt))
  txt2 = txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"methodology.html",txt2)
  delete([/tt,txt,txt2/])
;----------------------------------------------------------------------------
;--   Create metrics webpage
;----------------------------------------------------------------------------
  if (isfilepresent2(OUTDIR+"metrics.txt")) then
     txt = new(5000,"string")  
     quote = str_get_dq()
  
     txt(0) = "<html><head><title>Climate Variability Diagnostics Package</title>"
     txt(1) = "<link rel="+quote+"stylesheet"+quote+" href="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"+quote+" integrity="+quote+"sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"+quote+" crossorigin="+quote+"anonymous"+quote+">"
     txt(2) = "<script src="+quote+"https://code.jquery.com/jquery-3.3.1.slim.min.js"+quote+" integrity="+quote+"sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
     txt(3) = "<script src="+quote+"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"+quote+" integrity="+quote+"sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
     txt(4) = "<script src="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"+quote+" integrity="+quote+"sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"

     txt(5) = "<style>body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
     txt(6) = "img.title {width:990; height:105; align:left}"
     txt(7) = "p.subtitle1 {font-size:15pt; color:gray}"
     txt(8) = "p.subtitle {font-size:20pt; color:black; text-align:center; font-weight:bold}"
     txt(9) = "p.btext {font-size:12pt; text-align:left}"
     txt(10) = "p.btext2 {font-size:9pt; text-align:left}"
     txt(11) = "td {text-align:center; font-size:12pt}"
     txt(12) = "td.s1 {text-align:left; font-size:11pt}"
     txt(13) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}"
     txt(14) = "</style></head><BODY>"
     txt(15) = "<img class=title src="+quote+"e3sm-cvdp.png"+quote+" alt="+quote+"CVDP logo"+quote+">"
     txt(16)= "<TABLE width='990' border=0 cellpadding=6>"
     txt(17) = "<tr><td width='300'><p class=btext><a href="+quote+"index.html"+quote+">Back to Diagnostics Plots</a></p></td>"
     txt(18) = "<td><p class=subtitle>"+title_str(0)+"</p><p class=subtitle>"+title_str(1)+"</p></td></tr></table><hr width=990 align=left><p class=subtitle1>Metrics Table</p>" 
     
     z = asciiread(OUTDIR+"metrics.txt",(/-1/),"string")
     nlines = dimsizes(z)
     txt(24) = "<PRE>"
     do gg = 0,nlines-1
        txt(25+gg) = z(gg)
     end do
     txt(25+nlines) = "</PRE>"
     txt(25+nlines+1) = "<p class=btext><a href="+quote+"namelist_obs"+quote+">Observations Used</a></p>"
     txt(25+nlines+2) = "Created "+systemfunc("date")
     txt(25+nlines+3) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  
     tt = ind(.not.ismissing(txt))
     txt2 = txt(:tt(dimsizes(tt)-1)+1)
     txt2 = where(ismissing(txt2),"",txt2)
     asciiwrite(OUTDIR+"metrics.html",txt2)
     delete([/txt,txt2,tt/])
  end if 
  if (isfilepresent2(OUTDIR+"metrics.table_1.gif")) then  ; create sorted metrics table pages
     txt = new(5000,"string")  
     quote = str_get_dq()
  
     txt(0) = "<html><head><title>Climate Variability Diagnostics Package</title>"
     txt(1) = "<link rel="+quote+"stylesheet"+quote+" href="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css"+quote+" integrity="+quote+"sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO"+quote+" crossorigin="+quote+"anonymous"+quote+">"
     txt(2) = "<script src="+quote+"https://code.jquery.com/jquery-3.3.1.slim.min.js"+quote+" integrity="+quote+"sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
     txt(3) = "<script src="+quote+"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"+quote+" integrity="+quote+"sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"
     txt(4) = "<script src="+quote+"https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"+quote+" integrity="+quote+"sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"+quote+" crossorigin="+quote+"anonymous"+quote+"></script>"

     txt(5) = "<style>body {background-color: WhiteSmoke; font-family: Verdana, Geneva, sans-serif}"
     txt(6) = "img.title {width:990; height:105; align:left}"
     txt(7) = "p.subtitle1 {font-size:20pt; color:darkgray}"
     txt(8) = "p.subtitle {font-size:20pt; color:black; text-align:center; font-weight:bold}"
     txt(9) = "p.btext {font-size:12pt; text-align:left}"
     txt(10) = "p.btext2 {font-size:9pt; text-align:left}"
     txt(11) = "td {text-align:center; font-size:12pt}"
     txt(12) = "td.s1 {text-align:left; font-size:11pt}"
     txt(13) = "td.tablehdr {text-align:center; font-size:17pt}"
     txt(14) = "CAPTION {text-align:left; font-size:14pt; font-weight:bold}</style></head><BODY>"
     txt(15) = "<img class=title src="+quote+"e3sm-cvdp.png"+quote+" alt="+quote+"CVDP logo"+quote+">"
     txt(16)= "<TABLE width='990' border=0 cellpadding=6>"


     sort_txt = (/"<a href="+quote+"metrics.table_0.html"+quote+">Namelist (default)</a> | ","<a href="+quote+"metrics.table_1.html"+quote+">Namelist (Alphabetically)</a> | ","<a href="+quote+"metrics.table_2.html"+quote+">ENSO TAS</a> | ","<a href="+quote+"metrics.table_3.html"+quote+">ENSO PSL</a> | ", \
                  "<a href="+quote+"metrics.table_4.html"+quote+">El Ni&ntilde;o Hovm&ouml;ller</a><br>","<a href="+quote+"metrics.table_5.html"+quote+">La Ni&ntilde;a Hovm&ouml;ller</a> | ","<a href="+quote+"metrics.table_6.html"+quote+">AMO</a> | ","<a href="+quote+"metrics.table_7.html"+quote+">PDO</a> | ", \
                  "<a href="+quote+"metrics.table_8.html"+quote+">NAM</a> | ","<a href="+quote+"metrics.table_9.html"+quote+">SAM</a> | ","<a href="+quote+"metrics.table_10.html"+quote+">SST std dev</a> | ","<a href="+quote+"metrics.table_11.html"+quote+">PSL std dev</a> | ", \
                  "<a href="+quote+"metrics.table_12.html"+quote+">PR std dev</a> | ","<a href="+quote+"metrics.table_13.html"+quote+">Mean Score</a>"/)
     sort_txt2 = (/"Namelist (default)","Namelist (Alphabetically)","ENSO TAS","ENSO PSL","El Ni&ntilde;o Hovm&ouml;ller","La Ni&ntilde;a Hovm&ouml;ller","AMO","PDO","NAM","SAM","SST std dev","PSL std dev","PR std dev","Mean Score"/)

     sort_txtA = (/"<a href="+quote+"metrics.table_14.html"+quote+">Namelist (default)</a> | ","<a href="+quote+"metrics.table_15.html"+quote+">Namelist (Alphabetically)</a> | ","<a href="+quote+"metrics.table_16.html"+quote+">ENSO TAS</a> | ","<a href="+quote+"metrics.table_17.html"+quote+">ENSO PSL</a> | ", \
                  "<a href="+quote+"metrics.table_18.html"+quote+">El Ni&ntilde;o Hovm&ouml;ller</a><br>","<a href="+quote+"metrics.table_19.html"+quote+">La Ni&ntilde;a Hovm&ouml;ller</a> | ","<a href="+quote+"metrics.table_20.html"+quote+">AMO</a> | ","<a href="+quote+"metrics.table_21.html"+quote+">PDO</a> | ", \
                  "<a href="+quote+"metrics.table_22.html"+quote+">NAM</a> | ","<a href="+quote+"metrics.table_23.html"+quote+">SAM</a> | ","<a href="+quote+"metrics.table_24.html"+quote+">SST std dev</a> | ","<a href="+quote+"metrics.table_25.html"+quote+">PSL std dev</a> | ", \
                  "<a href="+quote+"metrics.table_26.html"+quote+">PR std dev</a> | ","<a href="+quote+"metrics.table_27.html"+quote+">Mean Score</a>"/)

     strarr = new(14,string)
     strarr = " | "
     strarr(13) = " "
     do gg = 0,13
           txt(17) = "<tr><td width='50'><p class=btext>Go to:</p></td><td class=s1 width='300'><a href="+quote+"methodology.html"+quote+">Methodology and Definitions</a><br><a href="+quote+"index.html"+quote+">Diagnostics Plots</a><br><a href="+quote+"metrics.table_"+(gg+14)+".html"+quote+">RMS Metric Tables</a></td>"
           txt(18) = "<td><p class=subtitle>"+title_str(0)+"</p><p class=subtitle>"+title_str(1)+"</p></td></tr></table><hr width=990 align=left>"
           sort_txtT = sort_txt
           sort_txtT(gg) = "<b>"+sort_txt2(gg)+"</b>"+strarr(gg)
           txt(24) = "<p class=subtitle1><b>Pattern Correlation Metrics Tables</b></p>"
           txt(25) = "<TABLE width='900' border=0 cellpadding=16><tr><td width=50><b>Sort By:</b></td><td>"+str_concat(sort_txtT)+"</td></tr></table>" 
           txt(26) = "<img width=980 src="+quote+"metrics.table_"+gg+".gif"+quote+" />"
           txt(27) = "<p class=btext><a href="+quote+"namelist_obs"+quote+">Observations Used</a></p>"
           txt(28) = "Created "+systemfunc("date")
           txt(29) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
           tt = ind(.not.ismissing(txt))
           txt2 = txt(:tt(dimsizes(tt)-1)+1)
           txt2 = where(ismissing(txt2),"",txt2)
           asciiwrite(OUTDIR+"metrics.table_"+gg+".html",txt2)
           delete([/txt2,tt,sort_txtT/])
     end do

     
     do gg = 0,13
           txt(17) = "<tr><td width='50'><p class=btext>Go to:</p></td><td class=s1 width='300'><a href="+quote+"methodology.html"+quote+">Methodology and Definitions</a><br><a href="+quote+"index.html"+quote+">Diagnostics Plots</a><br><a href="+quote+"metrics.table_"+gg+".html"+quote+">Pattern Correlation Metric Tables</a></td>"
           txt(18) = "<td><p class=subtitle>"+title_str(0)+"</p><p class=subtitle>"+title_str(1)+"</p></td></tr></table><hr width=990 align=left>"
           sort_txtT = sort_txtA
           sort_txtT(gg) = "<b>"+sort_txt2(gg)+"</b>"+strarr(gg)
           txt(24) = "<p class=subtitle1><b>RMS Metrics Tables</b></p>"
           txt(25) = "<TABLE width='900' border=0 cellpadding=16><tr><td width=50><b>Sort By:</b></td><td>"+str_concat(sort_txtT)+"</td></tr></table>"
           txt(26) = "<img width=980 src="+quote+"metrics.table_"+(gg+14)+".gif"+quote+" />"
           txt(27) = "<p class=btext><a href="+quote+"namelist_obs"+quote+">Observations Used</a></p>"
           txt(28) = "Created "+systemfunc("date")
           txt(29) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
           tt = ind(.not.ismissing(txt))
           txt2 = txt(:tt(dimsizes(tt)-1)+1)
           txt2 = where(ismissing(txt2),"",txt2)
           asciiwrite(OUTDIR+"metrics.table_"+(gg+14)+".html",txt2)
           delete([/txt2,tt/])
     end do
     delete([/txt,strarr/])
  end if
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
  txt(25) = "<img class="+quote+"img-fluid"+quote+" src="+quote+"e3sm-cvdp.png"+quote+" alt="+quote+"CVDP logo"+quote+">"
  txt(26)= "<TABLE width='990' border=0 cellpadding=6>"
  txt(27) = "<tr><td width='30'><p class=btext>Go to:</p></td><td class=s1 width='380'><a href="+quote+"index.html"+quote+">Diagnostics Plots</a><br><hr>"

  namelist_obs_qtxt = "Input Namelists: "
  if (OBS.eq."True") then
     txt(28) = "Input Namelists: <b>Observations</b> | <a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
     txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
     txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_snd.html"+quote+">SND</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
     txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"
     txt(32) = "<p class=subtitle1>Input Namelist: Observations</p>" 
     z := asciiread(OUTDIR+"namelist_obs",(/-1/),"string")
     nlines = dimsizes(z)
     txt(33) = "<p class=c>"
     do gg = 0,nlines-1
        txt(33+gg) = z(gg)+"<br>"
     end do
     txt(34+nlines) = "</p>"
     txt(34+nlines+1) = "Created "+systemfunc("date")
     txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
     tt := ind(.not.ismissing(txt))
     txt2 := txt(:tt(dimsizes(tt)-1)+1)
     txt2 = where(ismissing(txt2),"",txt2)
     asciiwrite(OUTDIR+"namelist_obs.html",txt2)

     namelist_obs_qtxt = "Input Namelists: <a href="+quote+"namelist_obs.html"+quote+">Observations</a> | "
  end if
  txt(28:) = txt@_FillValue

  txt(28) = namelist_obs_qtxt+"<b>Simulations</b><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_snd.html"+quote+">SND</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Input Namelist: Simulations</p>" 

  z := asciiread(OUTDIR+"namelist",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_simulations.html",txt2)
  txt(28:) = txt@_FillValue

  txt(28) = namelist_obs_qtxt+"<a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <b>MSFTMZ</b> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_snd.html"+quote+">SND</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"

  txt(32) = "<p class=subtitle1>Derived Namelist: MSFTMZ</p>" 
  z := asciiread(OUTDIR+"namelist_moc",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_msftmz.html",txt2)

  txt(28) = namelist_obs_qtxt+"<a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <b>PR</b> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_snd.html"+quote+">SND</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: PR</p>" 
  z := asciiread(OUTDIR+"namelist_prect",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(34+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_pr.html",txt2)

  txt(28) = namelist_obs_qtxt+"<a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <b>PSL</b> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_snd.html"+quote+">SND</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: PSL</p>" 
  z := asciiread(OUTDIR+"namelist_psl",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_psl.html",txt2)

  txt(28) = namelist_obs_qtxt+"<a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br></b>SICONC NH</b> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_snd.html"+quote+">SND</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: SICONC NH</p>" 
  z := asciiread(OUTDIR+"namelist_aice_nh",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_siconc_nh.html",txt2)

  txt(28) = namelist_obs_qtxt+"<a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <b>SICONC SH</b> | <a href="+quote+"namelist_snd.html"+quote+">SND</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: SICONC SH</p>" 
  z := asciiread(OUTDIR+"namelist_aice_sh",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_siconc_sh.html",txt2)

  txt(28) = namelist_obs_qtxt+"<a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <b>SND</b> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: SND</p>" 
  z := asciiread(OUTDIR+"namelist_snowdp",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_snd.html",txt2)

  txt(28) = namelist_obs_qtxt+"<a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_snd.html"+quote+">SND</a> | <b>TAS</b> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: TAS</p>" 
  z := asciiread(OUTDIR+"namelist_trefht",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_tas.html",txt2)

  txt(28) = namelist_obs_qtxt+"<a href="+quote+"namelist_simulations.html"+quote+">Simulations</a><br>"
  txt(29) = "Derived Namelists: <a href="+quote+"namelist_msftmz.html"+quote+">MSFTMZ</a> | <a href="+quote+"namelist_pr.html"+quote+">PR</a> | <a href="+quote+"namelist_psl.html"+quote+">PSL</a> | "
  txt(30) = "<br><a href="+quote+"namelist_siconc_nh.html"+quote+">SICONC NH</a> | <a href="+quote+"namelist_siconc_sh.html"+quote+">SICONC SH</a> | <a href="+quote+"namelist_snd.html"+quote+">SND</a> | <a href="+quote+"namelist_tas.html"+quote+">TAS</a> |"
  txt(31) = "<a href="+quote+"namelist_ts.html"+quote+">TS</a></td><td><h2 class="+quote+"text-center"+quote+">"+title_str(0)+"</h2><h2 class="+quote+"text-center"+quote+">"+title_str(1)+"</h2></td></tr></table><hr width=990 align=left>"
  txt(32) = "<p class=subtitle1>Derived Namelist: TS</p>" 
  z := asciiread(OUTDIR+"namelist_ts",(/-1/),"string")
  nlines = dimsizes(z)
  txt(33) = "<p class=c>"
  do gg = 0,nlines-1
     txt(33+gg) = z(gg)+"<br>"
  end do
  txt(34+nlines) = "</p>"
  txt(34+nlines+1) = "Created "+systemfunc("date")
  txt(34+nlines+2) = "<p class=btext2>Enhanced on NCAR CVDP V"+NCAR_CVDP_VER+"</p></body></html>"
  tt := ind(.not.ismissing(txt))
  txt2 := txt(:tt(dimsizes(tt)-1)+1)
  txt2 = where(ismissing(txt2),"",txt2)
  asciiwrite(OUTDIR+"namelist_ts.html",txt2)

  print("Finished: webpage.ncl")  
end


