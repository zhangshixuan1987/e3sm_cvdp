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
  monNames   = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

  do is = 0,nsce-1,1

    scenario = scenarios(is)
    infil0   = outdir + "/out/CMIP6_delta_forcing_"+scenario+".nc"
    infil1   = outdir + "/out/CMIP6_delta_forcing_"+scenario+"_adjust.nc"

    fin0     = addfile(infil0,"r")
    fin1     = addfile(infil1,"r")

    v01      = e3sm_vnam(0) 
    v11      = e3sm_vnam(1) 

    rawsst     = fin0->$v01$
    rawsice    = fin0->$v11$
    adjsst     = fin1->$v01$
    adjsice    = fin1->$v11$

   
   do im = 0,nmons-1,1
 
    mstr   = monNames(im)
    fignm1 = v01+"_" + scenario+"_" +mstr
    fignm1 = v11+"_" + scenario+"_" +mstr

    odir   = "./figure"
    system("if ! test -d " + odir +" ; then mkdir " + odir + " ; fi")

    fignm0 = odir+"/"+v01+"_" + scenario+"_" +mstr
    fignm1 = odir+"/"+v11+"_" + scenario+"_" +mstr
    twks0                 = "png"                  ;-- plot output type
    twks0@wkWidth         =  1024                  ;-- wk width
    twks0@wkHeight        =  1024                  ;-- wk height
    twks1                 = twks0
    wks0 = gsn_open_wks(twks0,fignm0)   
    wks1 = gsn_open_wks(twks1,fignm1)    ; open workstation (plot destination)

    gsn_define_colormap(wks0,"BlueDarkRed18") ;"MPL_sstanom") ; choose colormap
    gray = NhlNewColor(wks0,0.8,0.8,0.8)   ; add gray to colormap
    gsn_define_colormap(wks1,"precip4_diff_19lev") ; choose colormap
    gray = NhlNewColor(wks1,0.8,0.8,0.8)   ; add gray to colormap

    res                      = True
    res@gsnDraw              = False                   ; don't draw yet
    res@gsnFrame             = False                   ; don't advance frame yet
    res@gsnMaximize          = True        ; maximize plot

    res@cnFillOn             = True        ; turn on color
    res@gsnSpreadColors      = True        ; use full range of colormap
    res@gsnSpreadColorStart  = 2           ; start at color 2
    res@gsnSpreadColorEnd    = -3          ; don't use added gray
    res@cnLinesOn            = False       ; no contour lines
    res@cnLineLabelsOn       = False       ; no contour lines
    res@cnInfoLabelOn        = False       ; turn off cn info label
   ;res@cnFillDrawOrder      = "PreDraw"   ; draw contours before continents
    res@cnFillMode           = "CellFill"

    res@mpDataSetName         = "Earth..4"             ;-- new database
    res@mpDataBaseVersion     = "MediumRes"            ;-- Medium resolution database
    res@mpOutlineOn           =  True                  ;-- turn on map outlines
    res@mpFillOn              =  True                  ;-- turn on map fill
    res@mpOutlineBoundarySets = "National"             ;-- draw only national bounds
    res@mpLandFillColor       = "Background"           ;-- set map land fill to white
    res@mpFillOn              = False
    res@mpFillDrawOrder       =  "PostDraw"

    res@gsnMajorLatSpacing    = 30              ; change maj lat tm spacing
    res@gsnMajorLonSpacing    = 60              ; change maj lon tm spacing
    res@mpCenterLonF          = 180.

    FontHeightF = 0.018
    res@tmXBLabelFontHeightF  =  FontHeightF                 ;-- change XB label font size
    res@tmYLLabelFontHeightF  =  FontHeightF                ;-- change YL label font size
    res@tmXBMajorLengthF      =  0.008                 ;-- change XB the tickmark length
    res@tmYLMajorLengthF      =  0.008                 ;-- change YL the tickmark length

    res@tiMainString          = ""
    res@tiMainFont            = "helvetica"            ;-- title string font
    res@tiMainFontHeightF     =  0.025                 ;-- set title string font size


    ;-- add custom label bar to the plot
    res@lbLabelBarOn          =  False 
    res@lbPerimOn             =  False                 ;-- no label bar box outline
    res@lbOrientation         = "Horizontal"           ;-- labelbar orientation

    ;;;;generate SST plot
    res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    res@cnLevels             = (/-2.5,-2.,-1.5,-1.,-.5,-.2,.2,.5,1.,1.5,2.,2.5/)   ; set levels
    plotx                    = new(2,graphic)
    res0                     = res
    res0@gsnCenterString     = "~F33~D~N~~F~SST (2041-2060 - 1991-2010) "+mstr + " (original)"
    plotx(0)                 = gsn_csm_contour_map_ce(wks0,rawsst(im,:,:), res0)
    res1                     = res
    res1@gsnCenterString     = "~F33~D~N~~F~SST (2041-2060 - 1991-2010) "+mstr + " (adjusted)"
    plotx(1)                 = gsn_csm_contour_map_ce(wks0,adjsst(im,:,:), res1)

    ;;;;generate seaice plot
    RES = res
    RES@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    RES@cnLevels            := (/-0.4,-0.3,-0.2,-0.1,-0.05,-0.01,0.01,0.05,0.1,0.2,0.3,0.4/)   ; set levels
    ploty                    = new(2,graphic)
    RES0                     = RES
    RES0@gsnCenterString     = "~F33~D~N~~F~SEAICE (2041-2060 - 1991-2010) "+mstr + " (original)"
    ploty(0)                 = gsn_csm_contour_map_ce(wks1,rawsice(im,:,:), RES0)
    RES1                     = RES
    RES1@gsnCenterString     = "~F33~D~N~~F~SEAICE (2041-2060 - 1991-2010) "+mstr + " (adjusted)"
    ploty(1)                 = gsn_csm_contour_map_ce(wks1,adjsice(im,:,:), RES1)

    panres                     = True
    panres@gsnMaximize         = True             ; maximize the plots
    panres@gsnPanelLabelBar    = True             ; turn on the panel label bar
    panres@gsnPaperOrientation = "portrait"       ; make sure the paper orientation is set to portrait
    panres@lbLabelStride       = 1                ; set the label bar label stride to 2
    panres@pmLabelBarWidthF    = 0.95    ; label bar width
    panres@pmLabelBarHeightF   = 0.04
    panres@lbLabelFontHeightF  = FontHeightF * 0.6
    panres@gsnPanelXWhiteSpacePercent = 2
    panres@gsnPanelYWhiteSpacePercent = 2
 
    gsn_panel(wks0,plotx,(/1,2/),panres) 
    gsn_panel(wks1,ploty,(/1,2/),panres)

   end do 

  end do 
end
