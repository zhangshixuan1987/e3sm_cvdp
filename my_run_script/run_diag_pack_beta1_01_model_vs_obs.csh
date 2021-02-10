#!/bin/tcsh 

setenv POST            "/global/cfs/cdirs/e3sm/zhan391"
setenv WKROOT          "${POST}/polar_diag"
setenv MODEL_DATA_ROOT "/global/cfs/cdirs/e3sm/zhan391/data/E3SM"
setenv OBS_DATA_ROOT   "/global/cfs/cdirs/e3sm/zhan391/data/ERA5/1979-2020/regrid"

setenv DIAG_DATA_ROOT  "$WKROOT/data" 
setenv COMPARE          "Model_vs_OBS"

############################
#flag to control if significance test should be performed 
#for the bias plot 
############################
setenv DIFFERENCE_TEST  "TRUE" 

###########################################################
#flag to control if significance test should be performed 
#for the bias plot 
###########################################################
setenv REGRESSION_TEST  "TRUE"

###########################################################
#flag to control if the time series from eof anaysis etc. 
#should be saved for the regression plot 
###########################################################
setenv L_SAVE_EOF_PC     "TRUE"
setenv L_SAVE_JET_INDEX  "TRUE"

###########################################################
#Weighting file used for the regridding required by the 
#scripts for jet location and strength 
###########################################################
setenv JET_RGDWGT_FILE "$DIAG_DATA_ROOT/1deg_to_0.1deg.nc"

###########################################################
#flag to control if the time series from eof anaysis should 
#be saved for the regression plot 
###########################################################

setenv CTRL   "OBS"
setenv TEST   "20201211.beta1_01.piControl.compy"
setenv CPATH  "${OBS_DATA_ROOT}"
setenv TPATH  "${MODEL_DATA_ROOT}/$TEST/climo"
 
setenv CTRL_NAME "ERA5"  
setenv TEST_NAME "beta1_01"

############################
# END OF USER MODIFICATION #
############################

setenv CASEDIR "${WKROOT}/work/$TEST-$CTRL"

mkdir -p $CASEDIR

cp ${WKROOT}/figs.tar $CASEDIR/.
cd $CASEDIR
tar -xvf ./figs.tar 
rm -f figs.tar
#sed "s/XXXYYY/$TEST/" aerosol.html >a1.html
#sed "s/XXXZZZ/$CTRL/" a1.html >aerosol.html
#rm -f a1.html
cd $WKROOT

cd code
foreach f (jet_index_zonal_wind.ncl) #strength_position_taux.ncl) #eof_regression_sfc_monthly.ncl) #(eof_regression_sfc_seasonal.ncl) #(enso_regression_sfc_monthly.ncl)#strength_position_taux.ncl) #lat_hgt.ncl) #lat_lon_lreg.ncl lat_lon_sreg.ncl)#eof_regression_sfc.ncl) #eof_sfc.ncl, eof_hgt.ncl lat_lon_lreg.ncl lat_lon_sreg.ncl) #(eof_hgt.ncl eof_sfc.ncl lat_hgt.ncl) #(*.ncl)
echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
ncl<$f 
echo ""
echo ""
end

exit

cd $CASEDIR
echo "---------------------------------------------"
echo "Converting Figures"
echo "---------------------------------------------"

rm -rvf index.html

foreach f (*)
  cd $f

  set line = `ls -trl | grep .eps | wc -l`

  if  ( $line != 0 ) then
      foreach ff (*.eps)
        convert -density 300 -trim -scale 100% $ff $ff.png
      end

      foreach ff (*.png)
        set base = `basename $ff .eps.png`
        mv $ff $base.png
      end
      rm -f ./*.eps
  endif

  echo ""
  echo ""
  echo "generate the www link!"
  setenv WWWDIR  "$TEST-$CTRL/$f"
  ls *.png >> list 
  cp -r $WKROOT/code/create_html.ncl .
  ncl create_html.ncl
  rm -rvf create_html.ncl
  rm -rvf list
  echo ""
  echo ""
 
  cd .. 

end

exit 0
