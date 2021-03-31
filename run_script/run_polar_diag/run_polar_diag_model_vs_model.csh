#!/bin/tcsh 

setenv POST            "/global/cfs/cdirs/e3sm/zhan391"
setenv WKROOT          "${POST}/polar_diag"
setenv MODEL_DATA_ROOT "/global/cfs/cdirs/e3sm/zhan391/data/E3SM"
setenv COMPARE          "Model_vs_Model"

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

############################################################
#Set up the case name and the model output directories after
#the post-processing. The CTRL and TEST are the model run 
#case name, while the CTRL_NAME and TEST_NAME are the 
#short name for the figure string defined by users
###########################################################
setenv CTRL   "20201211.beta1_01.piControl.compy"
setenv TEST   "20210120.A_WCYCL1850S_CMIP6.ne30pg2_SOwISC12to60E2r4.beta1.maptest.anvil"
setenv CPATH  "${MODEL_DATA_ROOT}/$CTRL/climo"
setenv TPATH  "${MODEL_DATA_ROOT}/$TEST/climo"
setenv CTRL_NAME "Beta1"
setenv TEST_NAME "Beta1_SI_SORRMr4"

###########################################################
#Weighting file used for the regridding required by the 
#scripts for jet location and strength, you may not need to 
#change the information below this line 
###########################################################
setenv DIAG_DATA_ROOT  "$WKROOT/data/${DOUT_NAME}"
if ( ! -d $DIAG_DATA_ROOT ) then 
 mkdir -p $DIAG_DATA_ROOT
endif 
setenv REF_PRE_LEV     "$WKROOT/data/pres_lev.txt"
setenv JET_RGDWGT_FILE "$WKROOT/data/1deg_to_0.1deg.nc"
setenv DOUT_NAME "${TEST_NAME}_vs_${CTRL_NAME}"

############################
# END OF USER MODIFICATION #
############################

setenv CASEDIR "${WKROOT}/work/${DOUT_NAME}"

mkdir -p $CASEDIR

cp ${WKROOT}/figs.tar $CASEDIR/.
cd $CASEDIR
tar -xvf ./figs.tar 
rm -f figs.tar
cd $WKROOT

cd code
foreach f (lat_lon_glb.ncl lat_lon_vec_glb.ncl \
           lat_lon_sh_polar_lreg.ncl lat_lon_sh_polar_sreg.ncl \
           lat_lon_vec_sh_polar_lreg.ncl lat_lon_vec_sh_polar_sreg.ncl \
           lat_hgt_sh.ncl lat_hgt_nh.ncl lat_hgt_glb.ncl)
echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
ncl<$f &
echo ""
echo ""
end

foreach f (eof_hgt_monthly.ncl  eof_hgt_seasonal.ncl \
           eof_sfc_monthly.ncl  eof_sfc_seasonal.ncl \
           jet_index_stress.ncl jet_index_zonal_wind.ncl)
echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
ncl<$f &
echo ""
echo ""
end

wait

foreach f (eof_psl_regression_sfc_monthly.ncl \
           eof_psl_regression_sfc_seasonal.ncl \
           eof_hgt500_regression_sfc_monthly.ncl \
           eof_hgt500_regression_sfc_seasonal.ncl \
           enso_regression_sfc_monthly.ncl \
           jet_pos_regression_sfc_monthly.ncl \
           jet_ins_regression_sfc_monthly.ncl \
           polar_vortex_monthly.ncl\
           polar_vortex_seasonal.ncl )

echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
ncl<$f &
echo ""
echo ""
echo ""
end

cd $CASEDIR
echo "---------------------------------------------"
echo "Converting Figures"
echo "---------------------------------------------"

rm -rvf index.html

foreach f (*)
  cd $f

  #foreach ff (*.png.png)
  #  if( -f $ff ) then
  #    set base = `basename $ff .png.png`
  #    mv $ff $base.png
  #  endif 
  #end
  #rm -f ./*.png.png

  set line = `ls -trl | grep .eps | wc -l`

  if  ( $line != 0 ) then
      foreach ff (*.eps)
        convert -density 300 -trim -scale 100% $ff $ff.png
      end

      foreach ff (*.eps.png)
        set base = `basename $ff .eps.png`
        mv $ff $base.png
      end
      rm -f ./*.eps
  endif

  echo ""
  echo ""
  echo "generate the www link!"
  setenv WWWDIR  "${DOUT_NAME}/$f"
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
