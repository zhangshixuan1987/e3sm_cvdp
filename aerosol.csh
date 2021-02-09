#!/bin/tcsh 

setenv WKROOT "${POST}/aerodiag/"

setenv CTRL  "EXP01"
setenv TEST  "EXP02"

setenv CPATH "${POST}/climo/$CTRL"
setenv TPATH "${POST}/climo/$TEST"

setenv TMAM4 "false"
setenv CMAM4 "false"


############################
# END OF USER MODIFICATION #
############################

setenv CASEDIR "${WKROOT}/work/$TEST-$CTRL"

mkdir -p $CASEDIR

cp ./figs.tar $CASEDIR/.
cd $CASEDIR
tar -xvf ./figs.tar 
rm -f figs.tar
sed "s/XXXYYY/$TEST/" aerosol.html >a1.html
sed "s/XXXZZZ/$CTRL/" a1.html >aerosol.html
rm -f a1.html
cd $WKROOT

cd code
foreach f (*.ncl)
echo "---------------------------------------------"
echo $f "is running!"
echo "---------------------------------------------"
ncl<$f 
echo ""
echo ""
end

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
