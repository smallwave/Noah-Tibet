##########################################################################################################
# NAME
#   Main
# PURPOSE
#   Test  relationship 
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151202 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################

Program Main

   USE model_thermal
   USE model_hydraulic
   implicit none  
   
   INTEGER :: i
   !REAL :: rN(100)  = (/(i, i=1,100, 1)/) *0.01
   REAL :: rN(80)    = 273.16 - (/(i, i=1,80,1)/)*0.1  
   
   REAL :: KDRY
   REAL :: FCR
   REAL :: FREE,SH2O

   character(len=20) :: filename  = trim("output.dat")
   integer :: outFileID ! local variables
   logical alive 
   inquire(file=filename, exist=alive) 
   if(alive) then 
        open(newunit=outFileID, file=filename,STATUS='OLD',action='WRITE' )
   else  
        open(newunit=outFileID, file=filename,STATUS='NEW',action='WRITE' )
   end if
   
   do i=1,80
     !CALL KDRY_J75_GRAVE(KDRY,rN(i))
     !CALL KE_J75_UN_GRAVEL(KDRY,rN(i))
       
     !CALL N06WCND(FCR,rN(i))
       
     !K99LIQMAX (FREE,TKELV,SMC,SH2O,SMCMAX,BEXP,PSIS)  
     !CALL K99LIQMAX(FREE,rN(i),0.262,SH2O,0.262,1.58,0.660)
     !SH2O =  FREE
     CALL N06LIQMAX(FREE,rN(i),0.262,1.58,0.660)
     !N06LIQMAX(FREE,TKELV,SMCMAX,BEXP,PSIS)
     write(outFileID, '(10f13.4)') FREE 
   end do
   ! simulation results
   close(outFileID)
   
   
   pause

End program Main