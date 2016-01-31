##########################################################################################################
# NAME
#   Main
# PURPOSE
#   thermal optimal test
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#   20151202 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
     
module  model_thermal
    
    contains
    !2015.12.02
    SUBROUTINE KE_Y05_UN (KE,SR)
        REAL, INTENT(IN)     :: SR
        REAL, INTENT(OUT)    :: KE
        REAL, PARAMETER      :: KT = 0.10
        KE = EXP(KT * ( 1- 1 / SR))
          
    END SUBROUTINE KE_Y05_UN

    !2015.12.02
    SUBROUTINE KE_J75_UN (KE,SR)
        REAL, INTENT(IN)     :: SR
        REAL, INTENT(OUT)    :: KE
        IF ( SR >  0.1 ) THEN
            KE = LOG10 (SR) + 1.0
        ELSE
            KE = 0.0
        END IF
    END SUBROUTINE KE_J75_UN
     
    
    SUBROUTINE KE_J75_UN_GRAVEL (KE,SR)
        REAL, INTENT(IN)     :: SR
        REAL, INTENT(OUT)    :: KE
        IF ( SR >  0.05 ) THEN
            KE = 0.7 * LOG10 (SR) + 1.0
        ELSE
            KE = 0.0
        END IF
    END SUBROUTINE KE_J75_UN_GRAVEL
    
    !2015.12.02
    SUBROUTINE KE_C05_UN (KE,SR)
        REAL, INTENT(IN)     :: SR
        REAL, INTENT(OUT)    :: KE
        REAL, PARAMETER      :: KT = 1.9
        KE =   (KT * SR) / (1 + (KT - 1) * SR )
    END SUBROUTINE KE_C05_UN
    
    SUBROUTINE KE_C05_UN_GRAVEL (KE,SR)
        REAL, INTENT(IN)     :: SR
        REAL, INTENT(OUT)    :: KE
        REAL, PARAMETER      :: KT = 4.6
        KE =   (KT * SR) / (1 + (KT - 1) * SR )
    END SUBROUTINE KE_C05_UN_GRAVEL 
    
    
    !2015.12.02
    SUBROUTINE KE_C05_FRE (KE,SR)
        REAL, INTENT(IN)     :: SR
        REAL, INTENT(OUT)    :: KE
        REAL, PARAMETER      :: KT = 0.85
        KE =   (KT * SR) / (1 + (KT - 1) * SR )
    END SUBROUTINE KE_C05_FRE
    
    !2015.12.02
    SUBROUTINE  KDRY_J75(KDRY,SMCMAX)
       REAL, INTENT(IN)     :: SMCMAX
       REAL, INTENT(OUT)    :: KDRY
       REAL                 :: GAMMD
       ! DRY DENSITY IN KG/M3
       GAMMD = (1. - SMCMAX)*2700.
       ! DRY THERMAL CONDUCTIVITY IN W.M-1.K-1
       KDRY = (0.135* GAMMD+ 64.7)/ (2700. - 0.947* GAMMD)
    END SUBROUTINE KDRY_J75
    
    SUBROUTINE  KDRY_J75_GRAVE (KDRY,SMCMAX)
       REAL, INTENT(IN)     :: SMCMAX
       REAL, INTENT(OUT)    :: KDRY
       ! DRY THERMAL CONDUCTIVITY IN W.M-1.K-1
       KDRY = 0.039 *  SMCMAX ** (-2.2)
    END SUBROUTINE KDRY_J75_GRAVE
    !2015.12.02
    SUBROUTINE  KDRY_C05(KDRY,SMCMAX,NSOILTYPE)
       REAL, INTENT(IN)     :: SMCMAX
       INTEGER, INTENT(IN)  :: NSOILTYPE
       REAL, INTENT(OUT)    :: KDRY
       REAL :: X = 1.70
       REAL :: Y = 1.80
       SELECT CASE (NSOILTYPE)
         CASE (1,15,16)
            X = 1.70
            Y = 1.80
         CASE (2,3,4,5,6,7,8,9,10,11,12,13)
            X = 0.75
            Y = 1.20
         CASE DEFAULT
            X = 1.70
            Y = 1.80
       END SELECT
       KDRY =  X * 10 ** (-Y * SMCMAX)
    END SUBROUTINE KDRY_C05
    
end module model_thermal