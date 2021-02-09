#!/bin/tcsh 

setenv POST            "/global/cfs/cdirs/e3sm/zhan391"
setenv WKROOT          "${POST}/diagnostic_package"
setenv MODEL_DATA_ROOT "/global/cfs/cdirs/e3sm/zhan391/data/E3SM"
setenv OBS_DATA_ROOT   "/global/cfs/cdirs/e3sm/zhan391/data/obs_for_e3sm_diags/climatology"

setenv COMPARE          "Model_vs_Model" #"Model_vs_OBS"
setenv STATISTICA_TEST  "TTEST"           

setenv CTRL   "20201124.alpha5_59_fallback.piControl.ne30pg2_r05_EC30to60E2r2-1900_ICG.compy"
setenv TEST   "20201211.beta1_01.piControl.compy"
setenv CPATH  "${MODEL_DATA_ROOT}/$CTRL/climo"
setenv TPATH  "${MODEL_DATA_ROOT}/$TEST/climo"
 
setenv CTRL_NAME "alpha5_59"  #"alpha5_59_fallback"
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
sed "s/XXXYYY/$TEST/" aerosol.html >a1.html
sed "s/XXXZZZ/$CTRL/" a1.html >aerosol.html
rm -f a1.html
cd $WKROOT

cd code
foreach f (lat_lon_lreg.ncl lat_lon_sreg.ncl) #(eof_hgt.ncl eof_sfc.ncl lat_hgt.ncl) #(*.ncl)
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

foreach f (set*)
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

  cd ..
end

exit 0
