##########################################################################################################
# NAME
#   Main
# PURPOSE
#   thermal optimal test
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#   20151222 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
     
module  model_hydraulic
          
    contains
    !20151222
    SUBROUTINE K99LIQMAX (FREE,TKELV,SMC,SH2O,SMCMAX,BEXP,PSIS)

    ! ----------------------------------------------------------------------
    ! SUBROUTINE FRH2O
    ! ----------------------------------------------------------------------
    ! CALCULATE AMOUNT OF SUPERCOOLED LIQUID SOIL WATER CONTENT IF
    ! TEMPERATURE IS BELOW 273.15K (T0).  REQUIRES NEWTON-TYPE ITERATION TO
    ! SOLVE THE NONLINEAR IMPLICIT EQUATION GIVEN IN EQN 17 OF KOREN ET AL
    ! (1999, JGR, VOL 104(D16), 19569-19585).
    ! ----------------------------------------------------------------------
    ! NEW VERSION (JUNE 2001): MUCH FASTER AND MORE ACCURATE NEWTON
    ! ITERATION ACHIEVED BY FIRST TAKING LOG OF EQN CITED ABOVE -- LESS THAN
    ! 4 (TYPICALLY 1 OR 2) ITERATIONS ACHIEVES CONVERGENCE.  ALSO, EXPLICIT
    ! 1-STEP SOLUTION OPTION FOR SPECIAL CASE OF PARAMETER CK=0, WHICH
    ! REDUCES THE ORIGINAL IMPLICIT EQUATION TO A SIMPLER EXPLICIT FORM,
    ! KNOWN AS THE "FLERCHINGER EQN". IMPROVED HANDLING OF SOLUTION IN THE
    ! LIMIT OF FREEZING POINT TEMPERATURE T0.
    ! ----------------------------------------------------------------------
    ! INPUT:

    !   TKELV.........TEMPERATURE (Kelvin)
    !   SMC...........TOTAL SOIL MOISTURE CONTENT (VOLUMETRIC)
    !   SH2O..........LIQUID SOIL MOISTURE CONTENT (VOLUMETRIC)
    !   SMCMAX........SATURATION SOIL MOISTURE CONTENT (FROM REDPRM)
    !   B.............SOIL TYPE "B" PARAMETER (FROM REDPRM)
    !   PSIS..........SATURATED SOIL MATRIC POTENTIAL (FROM REDPRM)

    ! OUTPUT:
    !   FRH2O.........SUPERCOOLED LIQUID WATER CONTENT
    !   FREE..........SUPERCOOLED LIQUID WATER CONTENT
    ! ----------------------------------------------------------------------
    IMPLICIT NONE
    REAL, INTENT(IN)     :: BEXP,PSIS,SH2O,SMC,SMCMAX,TKELV
    REAL, INTENT(OUT)    :: FREE
    REAL                 :: BX,DENOM,DF,DSWL,FK,SWL,SWLK
    INTEGER              :: NLOG,KCOUNT
    !      PARAMETER(CK = 0.0)
    REAL, PARAMETER      :: CK = 8.0, BLIM = 5.5, ERROR = 0.005,       &
        HLICE = 3.335E5, GS = 9.81,DICE = 920.0,   &
        DH2O = 1000.0, T0 = 273.15

    ! ----------------------------------------------------------------------
    ! LIMITS ON PARAMETER B: B < 5.5  (use parameter BLIM)
    ! SIMULATIONS SHOWED IF B > 5.5 UNFROZEN WATER CONTENT IS
    ! NON-REALISTICALLY HIGH AT VERY LOW TEMPERATURES.
    ! ----------------------------------------------------------------------
    BX = BEXP

    ! ----------------------------------------------------------------------
    ! INITIALIZING ITERATIONS COUNTER AND ITERATIVE SOLUTION FLAG.
    ! ----------------------------------------------------------------------
    IF (BEXP >  BLIM) BX = BLIM
    NLOG = 0

    ! ----------------------------------------------------------------------
    !  IF TEMPERATURE NOT SIGNIFICANTLY BELOW FREEZING (T0), SH2O = SMC
    ! ----------------------------------------------------------------------
    KCOUNT = 0
    !      FRH2O = SMC
    IF (TKELV > (T0- 1.E-3)) THEN
        FREE = SMC
    ELSE

        ! ----------------------------------------------------------------------
        ! OPTION 1: ITERATED SOLUTION FOR NONZERO CK
        ! IN KOREN ET AL, JGR, 1999, EQN 17
        ! ----------------------------------------------------------------------
        ! INITIAL GUESS FOR SWL (frozen content)
        ! ----------------------------------------------------------------------
        IF (CK /= 0.0) THEN
            SWL = SMC - SH2O
            ! ----------------------------------------------------------------------
            ! KEEP WITHIN BOUNDS.
            ! ----------------------------------------------------------------------
            IF (SWL > (SMC -0.02)) SWL = SMC -0.02

            ! ----------------------------------------------------------------------
            !  START OF ITERATIONS
            ! ----------------------------------------------------------------------
            IF (SWL < 0.) SWL = 0.
1001        Continue
            IF (.NOT.( (NLOG < 10) .AND. (KCOUNT == 0)))   goto 1002
            NLOG = NLOG +1
            DF = ALOG ( ( PSIS * GS / HLICE ) * ( ( 1. + CK * SWL )**2.) * &
                ( SMCMAX / (SMC - SWL) )** BX) - ALOG ( - (               &
                TKELV - T0)/ TKELV)
            DENOM = 2. * CK / ( 1. + CK * SWL ) + BX / ( SMC - SWL )
            SWLK = SWL - DF / DENOM
            ! ----------------------------------------------------------------------
            ! BOUNDS USEFUL FOR MATHEMATICAL SOLUTION.
            ! ----------------------------------------------------------------------
            IF (SWLK > (SMC -0.02)) SWLK = SMC - 0.02
            IF (SWLK < 0.) SWLK = 0.

            ! ----------------------------------------------------------------------
            ! MATHEMATICAL SOLUTION BOUNDS APPLIED.
            ! ----------------------------------------------------------------------
            DSWL = ABS (SWLK - SWL)

            ! ----------------------------------------------------------------------
            ! IF MORE THAN 10 ITERATIONS, USE EXPLICIT METHOD (CK=0 APPROX.)
            ! WHEN DSWL LESS OR EQ. ERROR, NO MORE ITERATIONS REQUIRED.
            ! ----------------------------------------------------------------------
            SWL = SWLK
            IF ( DSWL <= ERROR ) THEN
                KCOUNT = KCOUNT +1
            END IF
            ! ----------------------------------------------------------------------
            !  END OF ITERATIONS
            ! ----------------------------------------------------------------------
            ! BOUNDS APPLIED WITHIN DO-BLOCK ARE VALID FOR PHYSICAL SOLUTION.
            ! ----------------------------------------------------------------------
            !          FRH2O = SMC - SWL
            goto 1001
1002        continue
            FREE = SMC - SWL
        END IF
        ! ----------------------------------------------------------------------
        ! END OPTION 1
        ! ----------------------------------------------------------------------
        ! ----------------------------------------------------------------------
        ! OPTION 2: EXPLICIT SOLUTION FOR FLERCHINGER EQ. i.e. CK=0
        ! IN KOREN ET AL., JGR, 1999, EQN 17
        ! APPLY PHYSICAL BOUNDS TO FLERCHINGER SOLUTION
        ! ----------------------------------------------------------------------
        IF (KCOUNT == 0) THEN
            PRINT *,'Flerchinger USEd in NEW version. Iterations=',NLOG
            FK = ( ( (HLICE / (GS * ( - PSIS)))*                    &
                ( (TKELV - T0)/ TKELV))** ( -1/ BX))* SMCMAX
            !            FRH2O = MIN (FK, SMC)
            IF (FK < 0.02) FK = 0.02
            FREE = MIN (FK, SMC)
            ! ----------------------------------------------------------------------
            ! END OPTION 2
            ! ----------------------------------------------------------------------
        END IF
    END IF
    ! ----------------------------------------------------------------------
    END SUBROUTINE K99LIQMAX

    !20151222
    SUBROUTINE  N06LIQMAX(FREE,TKELV,SMCMAX,BEXP,PSIS)
    
    ! ----------------------------------------------------------------------
    ! SUBROUTINE SUPERCOOL
    ! ----------------------------------------------------------------------
    ! CALCULATE AMOUNT OF SUPERCOOLED LIQUID SOIL WATER CONTENT IF
    ! TEMPERATURE IS BELOW 273.15K (T0).  REQUIRES NEWTON-TYPE ITERATION TO
    ! SOLVE THE NONLINEAR IMPLICIT EQUATION GIVEN IN EQN 3 OF NIU ET AL
    ! (NIU, JGR, VOL 104(D16), 19569-19585).
    ! ----------------------------------------------------------------------
    IMPLICIT NONE
    REAL, PARAMETER :: HFUS   = 0.3336E06  !latent heat of fusion (j/kg)
    REAL, PARAMETER :: TFRZ   = 273.16     !freezing/melting point (k)
    REAL, PARAMETER :: GRAV   = 9.80616    !acceleration due to gravity (m/s2)

    REAL, INTENT(IN)     :: BEXP,PSIS,SMCMAX,TKELV
    REAL, INTENT(OUT)    :: FREE
    REAL                 :: SMP,FK

    SMP = (HFUS*(TFRZ-TKELV))/(GRAV*TKELV*PSIS)  !(m)
    FK  = SMCMAX*(SMP**(-1./BEXP))
    FREE = MAX (FK, 0.)
    
    END SUBROUTINE N06LIQMAX

    !20151227
    SUBROUTINE  N06WCND(FCR,FICE)
    REAL,INTENT(OUT) :: FCR
    REAL,INTENT(IN)  :: FICE
    REAL, PARAMETER :: A = 4.0
    FCR     = MAX(0.0,EXP(-A*(1.-FICE))- EXP(-A)) /  &
               (1.0 - EXP(-A))
    FCR     = 1 - FCR
    END SUBROUTINE N06WCND
    
    !20151227
    SUBROUTINE  EI10WCND(FCR,FICE)
    
    REAL,INTENT(OUT) :: FCR
    REAL,INTENT(IN)  :: FICE
    REAL :: EI,SICE
    REAL, PARAMETER :: DKSAT  = 7.72E-3
    REAL, PARAMETER :: MAXSMC = 0.262
    SICE =  MAXSMC * FICE  
    EI  = 1.25 * (DKSAT - 3)**2 + 6
    FCR = 10**(-EI*SICE)
    
    END SUBROUTINE EI10WCND
    
    
    
end module model_hydraulic