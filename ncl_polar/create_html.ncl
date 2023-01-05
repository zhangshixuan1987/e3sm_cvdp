;;..........................................................
;; script to generate index.html for compy share www space   
;;..........................................................

   mydir      = getenv("WWWDIR")

   group_name = " "
   group_name1 = " "
   group_name2 = " "

   mlist1 = asciiread("list",-1,"string") 
   mlist2 = asciiread("list",-1,"string") 
   mlist3 = asciiread("list",-1,"string") 

   ml1 = dimsizes(mlist1) 
   ml2 = dimsizes(mlist2) 
   ml3 = dimsizes(mlist3) 

;;..........................................................
;; define " in NCL
;;..........................................................

   dblquote = integertochar(34) 

;;..........................................................
;; your www home 
;;..........................................................

   cml = "https://portal.nersc.gov/cfs/e3sm/zhan391/polar_diag/"+mydir+"/"  

;;..........................................................
;; define variable
;;..........................................................

   myhtml = new((/1000/),"string") 
   myhtml = " "

   ic = 0 

;;..........................................................
;; add empty lines
;;..........................................................

   nbr = 3 

   myhtml(ic:ic+nbr-1) = "<br>"

   ic = ic + nbr 

;;..........................................................
;; change font size
;;..........................................................

   myhtml(ic) = "<font size=" + dblquote + "4" + dblquote + ">"

   ic = ic + 1 

   myhtml(ic) = "<p>&ensp; &ensp; <b>" + group_name + "</b></p>"

   ic = ic + 1

   myhtml(ic) = "<br>"

   ic = ic + 1

;;..........................................................
;; E3SM
;;..........................................................

   myhtml(ic) = "<p>&ensp; &ensp; <b>" + group_name1 + "</b></p>"

   ic = ic + 1

   sta = "&ensp; &ensp;  <a href=" + dblquote 
   stb = dblquote + ">" 
   stc = "</a> <br> " 

   do il = 0,ml1-1
      mylink = sta + cml + mlist1(il) + stb + mlist1(il) + stc 
      myhtml(ic+il) = mylink 
   end do 

   ic = ic + ml1

   myhtml(ic) = "<br>" 

   ic = ic + 1

;;;;..........................................................
;;;; EAGLES
;;;;..........................................................
;;
;;   myhtml(ic) = "<p>&ensp; &ensp; <b>" + group_name2 + "</b></p>"
;;
;;   ic = ic + 1
;;
;;   do il = 0,ml2-1
;;      mylink = sta + cml + mlist2(il) + stb + mlist2(il) + stc
;;      myhtml(ic+il) = mylink
;;   end do
;;
;;   ic = ic + ml2 
;;
;;   myhtml(ic) = "<br>"
;;
;;   ic = ic + 1 

;;;;;;..........................................................
;;;;;; Others
;;;;;;..........................................................
;;;;
;;;;   myhtml(ic)   = "<p>&ensp; &ensp; <b>Others</b></p>"
;;;;
;;;;   ic = ic + 1 
;;;;
;;;;   do il = 0,ml3-1
;;;;      mylink = sta + cml + mlist3(il) + stb + mlist3(il) + stc
;;;;      myhtml(ic+il) = mylink
;;;;   end do
;;;;
;;;;   ic = ic + ml3
;;;;
;;;;   myhtml(ic) = "<br>"
;;;;
;;;;   ic = ic + 1 

;;..........................................................
;; Output
;;..........................................................

   asciiwrite("index.html",myhtml)


