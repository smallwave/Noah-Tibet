module module_optimal

    contains

    !2015.11.15
    SUBROUTINE FRH2O (FREE,TKELV,SMC,SH2O,SMCMAX,BEXP,PSIS)

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
    END SUBROUTINE FRH2O

    !2015.11.15 wuxb update
    SUBROUTINE FRH2O_NY06 (FREE,TKELV,SMCMAX,BEXP,PSIS,SMC)
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

    REAL, INTENT(IN)     :: BEXP,PSIS,SMCMAX,TKELV,SMC
    REAL, INTENT(OUT)    :: FREE

    REAL                 :: SMP,FK

    SMP = (HFUS*(TFRZ-TKELV))/(GRAV*TKELV*PSIS)  !(m)
    FK  = SMCMAX*(SMP**(-1./BEXP))
    FREE = MAX ( MIN ( FK, SMC ) ,0. )

    END SUBROUTINE FRH2O_NY06

    !2015.11.15
    SUBROUTINE WDFCND (WDF,WCND,SMC,SMCMAX,BEXP,DKSAT,DWSAT, &
        &                      SICEMAX)

    ! ----------------------------------------------------------------------
    ! SUBROUTINE WDFCND
    ! ----------------------------------------------------------------------
    ! CALCULATE SOIL WATER DIFFUSIVITY AND SOIL HYDRAULIC CONDUCTIVITY.
    ! ----------------------------------------------------------------------
    IMPLICIT NONE
    REAL , INTENT(IN)   ::BEXP,DKSAT,DWSAT,SICEMAX,SMC,SMCMAX   
    REAL     VKwgt,EXPON,FACTR1,FACTR2
    REAL , INTENT(OUT)   :: WCND,WDF

    ! ----------------------------------------------------------------------
    !     CALC THE RATIO OF THE ACTUAL TO THE MAX PSBL SOIL H2O CONTENT
    ! ----------------------------------------------------------------------   
    FACTR1 = 0.05 / SMCMAX

    ! ----------------------------------------------------------------------
    ! PREP AN EXPNTL COEF AND CALC THE SOIL WATER DIFFUSIVITY
    ! ----------------------------------------------------------------------
    FACTR2 = SMC / SMCMAX
    FACTR1 = MIN(FACTR1,FACTR2)
    EXPON = BEXP + 2.0

    ! ----------------------------------------------------------------------
    ! FROZEN SOIL HYDRAULIC DIFFUSIVITY.  VERY SENSITIVE TO THE VERTICAL
    ! GRADIENT OF UNFROZEN WATER. THE LATTER GRADIENT CAN BECOME VERY
    ! EXTREME IN FREEZING/THAWING SITUATIONS, AND GIVEN THE RELATIVELY
    ! FEW AND THICK SOIL LAYERS, THIS GRADIENT SUFFERES SERIOUS
    ! TRUNCTION ERRORS YIELDING ERRONEOUSLY HIGH VERTICAL TRANSPORTS OF
    ! UNFROZEN WATER IN BOTH DIRECTIONS FROM HUGE HYDRAULIC DIFFUSIVITY.
    ! THEREFORE, WE FOUND WE HAD TO ARBITRARILY CONSTRAIN WDF
    ! --
    ! VERSION D_10CM: ........  FACTR1 = 0.2/SMCMAX
    ! WEIGHTED APPROACH...................... PABLO GRUNMANN, 28_SEP_1999.     page 69
    !
    ! ----------------------------------------------------------------------
    WDF = DWSAT * FACTR2 ** EXPON
    IF (SICEMAX .gt. 0.0) THEN
        VKWGT = 1./ (1. + (500.* SICEMAX)**3.)
        WDF = VKWGT * WDF + (1. - VKWGT)* DWSAT * FACTR1** EXPON
        ! ----------------------------------------------------------------------
        ! RESET THE EXPNTL COEF AND CALC THE HYDRAULIC CONDUCTIVITY
        ! ----------------------------------------------------------------------
    END IF
    EXPON = (2.0 * BEXP) + 3.0
    WCND = DKSAT * FACTR2 ** EXPON

    ! ----------------------------------------------------------------------
    END SUBROUTINE WDFCND

    !2015.11.15  wuxb update
    SUBROUTINE WDFCND_NY06 (WDF,WCND,MAXSMC,SMCMAX,BEXP,DKSAT,DWSAT,SICE)
    !SUBROUTINE WDFCND_NY06 (WDF,WCND,MAXSMC,SMCMAX,BEXP,DKSAT,DWSAT,SICE,FRZX,DICE)
    ! ----------------------------------------------------------------------
    ! calculate soil water diffusivity and soil hydraulic conductivity.
    ! ----------------------------------------------------------------------
    IMPLICIT NONE
    ! ----------------------------------------------------------------------
    ! input
    REAL,INTENT(IN)  :: MAXSMC,SMCMAX,BEXP,DWSAT,DKSAT,SICE
    ! output
    REAL,INTENT(OUT) :: WCND
    REAL,INTENT(OUT) :: WDF
    
    ! local
    REAL :: EXPON,FACTR,EI
    REAL :: FICE   !ice fraction in frozen soil
    REAL :: FCR    !impermeable fraction due to frozen soil
    REAL, PARAMETER :: A = 4.0
    ! ----------------------------------------------------------------------
    ! soil water diffusivity
    
    FICE    = MIN(1.0,SICE/SMCMAX)
    FCR     = MAX(0.0,EXP(-A*(1.-FICE))- EXP(-A)) /  &
               (1.0 - EXP(-A))
    
    EI  = 1.25 * (DWSAT - 3)**2 + 6
    FACTR = MAX(0.01, MAXSMC/SMCMAX)
    EXPON = BEXP + 2.0
    WDF   =  DWSAT * FACTR ** EXPON    
    !WDF   = WDF * (1.0 - FCR)
    WDF   = 10**(-EI*SICE) * WDF
    
    EI  = 1.25 * (DKSAT - 3)**2 + 6
    ! hydraulic conductivity
    EXPON  =  2.0*BEXP + 3.0
    WCND   = DKSAT * FACTR ** EXPON
    !WCND   = WCND * (1.0 - FCR)
    WCND   = 10**(-EI*SICE) * WCND

    
    END SUBROUTINE WDFCND_NY06


    !wuxb 2015.11.28
    SUBROUTINE TDFCND ( DF, SMC, QZ, SMCMAX, SH2O, NSOILTYPE)
    ! ----------------------------------------------------------------------
    ! SUBROUTINE TDFCND
    ! ----------------------------------------------------------------------
    ! CALCULATE THERMAL DIFFUSIVITY AND CONDUCTIVITY OF THE SOIL FOR A GIVEN
    ! POINT AND TIME.
    ! ----------------------------------------------------------------------
    ! PETERS-LIDARD APPROACH (PETERS-LIDARD et al., 1998)
    ! June 2001 CHANGES: FROZEN SOIL CONDITION.
    ! ----------------------------------------------------------------------
    IMPLICIT NONE
    REAL, INTENT(IN)          :: QZ,  SMC, SMCMAX, SH2O
    integer, INTENT(IN)       :: NSOILTYPE
    REAL, INTENT(OUT)         :: DF
    REAL                      :: AKE, GAMMD, THKDRY, THKICE, THKO,    &
        THKQTZ,THKSAT,THKS,THKW,SATRATIO,XU, &
        XUNFROZ
    LOGICAL                   :: GRAVEL
    ! ----------------------------------------------------------------------
    ! WE NOW GET QUARTZ AS AN INPUT ARGUMENT (SET IN ROUTINE REDPRM):
    !      DATA QUARTZ /0.82, 0.10, 0.25, 0.60, 0.52,
    !     &             0.35, 0.60, 0.40, 0.82/
    ! ----------------------------------------------------------------------
    ! IF THE SOIL HAS ANY MOISTURE CONTENT COMPUTE A PARTIAL SUM/PRODUCT
    ! OTHERWISE USE A CONSTANT VALUE WHICH WORKS WELL WITH MOST SOILS
    ! ----------------------------------------------------------------------
    !  THKW ......WATER THERMAL CONDUCTIVITY
    !  THKQTZ ....THERMAL CONDUCTIVITY FOR QUARTZ
    !  THKO ......THERMAL CONDUCTIVITY FOR OTHER SOIL COMPONENTS
    !  THKS ......THERMAL CONDUCTIVITY FOR THE SOLIDS COMBINED(QUARTZ+OTHER)
    !  THKICE ....ICE THERMAL CONDUCTIVITY
    !  SMCMAX ....POROSITY (= SMCMAX)
    !  QZ .........QUARTZ CONTENT (SOIL TYPE DEPENDENT)
    ! ----------------------------------------------------------------------
    ! USE AS IN PETERS-LIDARD, 1998 (MODIF. FROM JOHANSEN, 1975).

    !                                  PABLO GRUNMANN, 08/17/98
    ! REFS.:
    !      FAROUKI, O.T.,1986: THERMAL PROPERTIES OF SOILS. SERIES ON ROCK
    !              AND SOIL MECHANICS, VOL. 11, TRANS TECH, 136 PP.
    !      JOHANSEN, O., 1975: THERMAL CONDUCTIVITY OF SOILS. PH.D. THESIS,
    !              UNIVERSITY OF TRONDHEIM,
    !      PETERS-LIDARD, C. D., ET AL., 1998: THE EFFECT OF SOIL THERMAL
    !              CONDUCTIVITY PARAMETERIZATION ON SURFACE ENERGY FLUXES
    !              AND TEMPERATURES. JOURNAL OF THE ATMOSPHERIC SCIENCES,
    !              VOL. 55, PP. 1209-1224.
    ! ----------------------------------------------------------------------
    ! NEEDS PARAMETERS
    ! POROSITY(SOIL TYPE):
    !      POROS = SMCMAX
    ! SATURATION RATIO:
    ! PARAMETERS  W/(M.K)
    SATRATIO = SMC / SMCMAX
    ! ICE CONDUCTIVITY:
    THKICE = 2.2
    ! WATER CONDUCTIVITY:
    THKW = 0.57
    ! THERMAL CONDUCTIVITY OF "OTHER" SOIL COMPONENTS
    !      IF (QZ .LE. 0.2) THKO = 3.0
    THKO = 2.0
    ! QUARTZ' CONDUCTIVITY
    THKQTZ = 7.7
    ! SOLIDS' CONDUCTIVITY
    THKS = (THKQTZ ** QZ)* (THKO ** (1. - QZ))

    ! UNFROZEN FRACTION (FROM 1., i.e., 100%LIQUID, TO 0. (100% FROZEN))
    XUNFROZ = SH2O / SMC
    ! UNFROZEN VOLUME FOR SATURATION (POROSITY*XUNFROZ)
    XU = XUNFROZ * SMCMAX

    ! SATURATED THERMAL CONDUCTIVITY
    THKSAT = THKS ** (1. - SMCMAX)* THKICE ** (SMCMAX - XU)* THKW **   &
        (XU)

    CALL ISSOILGRAVEL(GRAVEL,NSOILTYPE)
    IF (GRAVEL) THEN
        THKDRY = 0.039 *  SMCMAX ** (-2.2)
    ELSE
        ! DRY DENSITY IN KG/M3
        GAMMD = (1. - SMCMAX)*2700.
        ! DRY THERMAL CONDUCTIVITY IN W.M-1.K-1
        THKDRY = (0.135* GAMMD+ 64.7)/ (2700. - 0.947* GAMMD)
    ENDIF

    ! FROZEN
    IF ( (SH2O + 0.0005) <  SMC ) THEN
        AKE = SATRATIO
        ! UNFROZEN
        ! RANGE OF VALIDITY FOR THE KERSTEN NUMBER (AKE)
    ELSE
    
        ! KERSTEN NUMBER (USING "FINE" FORMULA, VALID FOR SOILS CONTAINING AT
        ! LEAST 5% OF PARTICLES WITH DIAMETER LESS THAN 2.E-6 METERS.)
        ! (FOR "COARSE" FORMULA, SEE PETERS-LIDARD ET AL., 1998).
        IF ( SATRATIO >  0.1) THEN
            AKE = LOG10 (SATRATIO) + 1.0
            ! USE K = KDRY
        ELSE IF ( SATRATIO > 0.05 .AND. GRAVEL )  THEN
            AKE = 0.7 * LOG10 (SATRATIO) + 1.0
        ELSE 
            AKE = 0.0
        END IF
        !  THERMAL CONDUCTIVITY
    END IF
    
    DF = AKE * (THKSAT - THKDRY) + THKDRY
    
    ! ----------------------------------------------------------------------
    END SUBROUTINE TDFCND

    !wuxb 2015.11.28
    SUBROUTINE TDFCND_ORI ( DF, SMC, QZ, SMCMAX, SH2O)
   ! ----------------------------------------------------------------------
! SUBROUTINE TDFCND
! ----------------------------------------------------------------------
! CALCULATE THERMAL DIFFUSIVITY AND CONDUCTIVITY OF THE SOIL FOR A GIVEN
! POINT AND TIME.
! ----------------------------------------------------------------------
! PETERS-LIDARD APPROACH (PETERS-LIDARD et al., 1998)
! June 2001 CHANGES: FROZEN SOIL CONDITION.
! ----------------------------------------------------------------------
      IMPLICIT NONE
      REAL, INTENT(IN)          :: QZ,  SMC, SMCMAX, SH2O
      REAL, INTENT(OUT)         :: DF
      REAL                      :: AKE, GAMMD, THKDRY, THKICE, THKO,    &
                                   THKQTZ,THKSAT,THKS,THKW,SATRATIO,XU, &
                                   XUNFROZ

! ----------------------------------------------------------------------
! WE NOW GET QUARTZ AS AN INPUT ARGUMENT (SET IN ROUTINE REDPRM):
!      DATA QUARTZ /0.82, 0.10, 0.25, 0.60, 0.52,
!     &             0.35, 0.60, 0.40, 0.82/
! ----------------------------------------------------------------------
! IF THE SOIL HAS ANY MOISTURE CONTENT COMPUTE A PARTIAL SUM/PRODUCT
! OTHERWISE USE A CONSTANT VALUE WHICH WORKS WELL WITH MOST SOILS
! ----------------------------------------------------------------------
!  THKW ......WATER THERMAL CONDUCTIVITY
!  THKQTZ ....THERMAL CONDUCTIVITY FOR QUARTZ
!  THKO ......THERMAL CONDUCTIVITY FOR OTHER SOIL COMPONENTS
!  THKS ......THERMAL CONDUCTIVITY FOR THE SOLIDS COMBINED(QUARTZ+OTHER)
!  THKICE ....ICE THERMAL CONDUCTIVITY
!  SMCMAX ....POROSITY (= SMCMAX)
!  QZ .........QUARTZ CONTENT (SOIL TYPE DEPENDENT)
! ----------------------------------------------------------------------
! USE AS IN PETERS-LIDARD, 1998 (MODIF. FROM JOHANSEN, 1975).

!                                  PABLO GRUNMANN, 08/17/98
! REFS.:
!      FAROUKI, O.T.,1986: THERMAL PROPERTIES OF SOILS. SERIES ON ROCK
!              AND SOIL MECHANICS, VOL. 11, TRANS TECH, 136 PP.
!      JOHANSEN, O., 1975: THERMAL CONDUCTIVITY OF SOILS. PH.D. THESIS,
!              UNIVERSITY OF TRONDHEIM,
!      PETERS-LIDARD, C. D., ET AL., 1998: THE EFFECT OF SOIL THERMAL
!              CONDUCTIVITY PARAMETERIZATION ON SURFACE ENERGY FLUXES
!              AND TEMPERATURES. JOURNAL OF THE ATMOSPHERIC SCIENCES,
!              VOL. 55, PP. 1209-1224.
! ----------------------------------------------------------------------
! NEEDS PARAMETERS
! POROSITY(SOIL TYPE):
!      POROS = SMCMAX
! SATURATION RATIO:
! PARAMETERS  W/(M.K)
      SATRATIO = SMC / SMCMAX
! ICE CONDUCTIVITY:
      THKICE = 2.2
! WATER CONDUCTIVITY:
      THKW = 0.57
! THERMAL CONDUCTIVITY OF "OTHER" SOIL COMPONENTS
!      IF (QZ .LE. 0.2) THKO = 3.0
      THKO = 2.0
! QUARTZ' CONDUCTIVITY
      THKQTZ = 7.7
! SOLIDS' CONDUCTIVITY
      THKS = (THKQTZ ** QZ)* (THKO ** (1. - QZ))

! UNFROZEN FRACTION (FROM 1., i.e., 100%LIQUID, TO 0. (100% FROZEN))
      XUNFROZ = SH2O / SMC
! UNFROZEN VOLUME FOR SATURATION (POROSITY*XUNFROZ)
      XU = XUNFROZ * SMCMAX

! SATURATED THERMAL CONDUCTIVITY
      THKSAT = THKS ** (1. - SMCMAX)* THKICE ** (SMCMAX - XU)* THKW **   &
         (XU)

! DRY DENSITY IN KG/M3
      GAMMD = (1. - SMCMAX)*2700.

! DRY THERMAL CONDUCTIVITY IN W.M-1.K-1
      THKDRY = (0.135* GAMMD+ 64.7)/ (2700. - 0.947* GAMMD)
! FROZEN
      IF ( (SH2O + 0.0005) <  SMC ) THEN
         AKE = SATRATIO
! UNFROZEN
! RANGE OF VALIDITY FOR THE KERSTEN NUMBER (AKE)
      ELSE

! KERSTEN NUMBER (USING "FINE" FORMULA, VALID FOR SOILS CONTAINING AT
! LEAST 5% OF PARTICLES WITH DIAMETER LESS THAN 2.E-6 METERS.)
! (FOR "COARSE" FORMULA, SEE PETERS-LIDARD ET AL., 1998).

         IF ( SATRATIO >  0.1 ) THEN

            AKE = LOG10 (SATRATIO) + 1.0

! USE K = KDRY
         ELSE

            AKE = 0.0
         END IF
!  THERMAL CONDUCTIVITY

      END IF

      DF = AKE * (THKSAT - THKDRY) + THKDRY
    ! ----------------------------------------------------------------------
    END SUBROUTINE TDFCND_ORI
          
    !wuxb 2015.12.2
    SUBROUTINE TDFCND_C05 ( DF, SMC, QZ, SMCMAX, SH2O, NSOILTYPE)
    ! ----------------------------------------------------------------------
    ! SUBROUTINE TDFCND
    ! ----------------------------------------------------------------------
    ! CALCULATE THERMAL DIFFUSIVITY AND CONDUCTIVITY OF THE SOIL FOR A GIVEN
    ! POINT AND TIME.
    ! ----------------------------------------------------------------------
    ! PETERS-LIDARD APPROACH (PETERS-LIDARD et al., 1998)
    ! June 2001 CHANGES: FROZEN SOIL CONDITION.
    ! ----------------------------------------------------------------------
    IMPLICIT NONE
    REAL, INTENT(IN)          :: QZ,  SMC, SMCMAX, SH2O
    INTEGER, INTENT(IN)       :: NSOILTYPE
    REAL, INTENT(OUT)         :: DF
    REAL                      :: AKE, GAMMD, THKDRY, THKICE, THKO,    &
        THKQTZ,THKSAT,THKS,THKW,SATRATIO,XU, &
        XUNFROZ,X,Y,K
    LOGICAL                   :: GRAVEL
    INTEGER                   :: STCLASSS
    ! ----------------------------------------------------------------------
    ! WE NOW GET QUARTZ AS AN INPUT ARGUMENT (SET IN ROUTINE REDPRM):
    !      DATA QUARTZ /0.82, 0.10, 0.25, 0.60, 0.52,
    !     &             0.35, 0.60, 0.40, 0.82/
    ! ----------------------------------------------------------------------
    ! IF THE SOIL HAS ANY MOISTURE CONTENT COMPUTE A PARTIAL SUM/PRODUCT
    ! OTHERWISE USE A CONSTANT VALUE WHICH WORKS WELL WITH MOST SOILS
    ! ----------------------------------------------------------------------
    !  THKW ......WATER THERMAL CONDUCTIVITY
    !  THKQTZ ....THERMAL CONDUCTIVITY FOR QUARTZ
    !  THKO ......THERMAL CONDUCTIVITY FOR OTHER SOIL COMPONENTS
    !  THKS ......THERMAL CONDUCTIVITY FOR THE SOLIDS COMBINED(QUARTZ+OTHER)
    !  THKICE ....ICE THERMAL CONDUCTIVITY
    !  SMCMAX ....POROSITY (= SMCMAX)
    !  QZ .........QUARTZ CONTENT (SOIL TYPE DEPENDENT)
    ! ----------------------------------------------------------------------
    ! USE AS IN PETERS-LIDARD, 1998 (MODIF. FROM JOHANSEN, 1975).

    !                                  PABLO GRUNMANN, 08/17/98
    ! REFS.:
    !      FAROUKI, O.T.,1986: THERMAL PROPERTIES OF SOILS. SERIES ON ROCK
    !              AND SOIL MECHANICS, VOL. 11, TRANS TECH, 136 PP.
    !      JOHANSEN, O., 1975: THERMAL CONDUCTIVITY OF SOILS. PH.D. THESIS,
    !              UNIVERSITY OF TRONDHEIM,
    !      PETERS-LIDARD, C. D., ET AL., 1998: THE EFFECT OF SOIL THERMAL
    !              CONDUCTIVITY PARAMETERIZATION ON SURFACE ENERGY FLUXES
    !              AND TEMPERATURES. JOURNAL OF THE ATMOSPHERIC SCIENCES,
    !              VOL. 55, PP. 1209-1224.
    ! ----------------------------------------------------------------------
    ! NEEDS PARAMETERS
    ! POROSITY(SOIL TYPE):
    !      POROS = SMCMAX
    ! SATURATION RATIO:
    ! PARAMETERS  W/(M.K)
    SATRATIO = SMC / SMCMAX
    ! ICE CONDUCTIVITY:
    THKICE = 2.2
    ! WATER CONDUCTIVITY:
    THKW = 0.57
    ! THERMAL CONDUCTIVITY OF "OTHER" SOIL COMPONENTS
    !      IF (QZ .LE. 0.2) THKO = 3.0
    THKO = 2.0
    ! QUARTZ' CONDUCTIVITY
    THKQTZ = 7.7
    ! SOLIDS' CONDUCTIVITY
    THKS = (THKQTZ ** QZ)* (THKO ** (1. - QZ))

    ! UNFROZEN FRACTION (FROM 1., i.e., 100%LIQUID, TO 0. (100% FROZEN))
    XUNFROZ = SH2O / SMC
    ! UNFROZEN VOLUME FOR SATURATION (POROSITY*XUNFROZ)
    XU = XUNFROZ * SMCMAX

    ! SATURATED THERMAL CONDUCTIVITY
    THKSAT = THKS ** (1. - SMCMAX)* THKICE ** (SMCMAX - XU)* THKW **   &
        (XU)

    
    !C05 OPTIMAL
    !CALL ISSOILGRAVEL(GRAVEL,NSOILTYPE)
    !IF (GRAVEL) THEN
    !    X = 1.70
    !    Y = 1.80
    !ELSE
    !    X = 0.75
    !    Y = 1.20
    !END IF
    !THKDRY =  X * 10 ** (-Y * SMCMAX)
    
    CALL ISSOILGRAVEL(GRAVEL,NSOILTYPE)
    IF (GRAVEL) THEN
        THKDRY = 0.039 *  SMCMAX ** (-2.2)
    ELSE
        ! DRY DENSITY IN KG/M3
        GAMMD = (1. - SMCMAX)*2700.
        ! DRY THERMAL CONDUCTIVITY IN W.M-1.K-1
        THKDRY = (0.135* GAMMD+ 64.7)/ (2700. - 0.947* GAMMD)
    ENDIF

    CALL ISSOILGRAVELSAND(STCLASSS,NSOILTYPE) 
    ! FROZEN
    IF ( (SH2O + 0.0005) <  SMC ) THEN
        
       !SELECT CASE (STCLASSS)
       !   CASE (1)
       !     K = 1.70
       !   CASE (2)
       !     K = 0.95
       !   CASE (3)
       !     K = 0.85
       !   CASE DEFAULT
       !     K = 1.70
       !END SELECT
       !AKE =   (K * SATRATIO) / (1 + (K - 1) * SATRATIO )
       AKE = SATRATIO
       
    ELSE
        ! UNFROZEN
        ! RANGE OF VALIDITY FOR THE KERSTEN NUMBER (AKE)
        ! KERSTEN NUMBER (USING "FINE" FORMULA, VALID FOR SOILS CONTAINING AT
        ! LEAST 5% OF PARTICLES WITH DIAMETER LESS THAN 2.E-6 METERS.)
        ! (FOR "COARSE" FORMULA, SEE PETERS-LIDARD ET AL., 1998).
        
        !SELECT CASE (STCLASSS)
        !  CASE (1)
        !    K = 4.60
        !  CASE (2)
        !    K = 3.55
        !  CASE (3)
        !    K = 1.90
        !  CASE DEFAULT
        !    K = 4.60
        !END SELECT
        
        ! KERSTEN NUMBER (USING "FINE" FORMULA, VALID FOR SOILS CONTAINING AT
        ! LEAST 5% OF PARTICLES WITH DIAMETER LESS THAN 2.E-6 METERS.)
        ! (FOR "COARSE" FORMULA, SEE PETERS-LIDARD ET AL., 1998).

        !IF ( SATRATIO >  0.1) THEN
        !    AKE = LOG10 (SATRATIO) + 1.0
        !ELSE IF ( SATRATIO > 0.05 .AND. GRAVEL )  THEN
        !    AKE = 0.7 * LOG10 (SATRATIO) + 1.0
        !ELSE 
        !    AKE = 0.0
        !END IF

    END IF

    !  THERMAL CONDUCTIVITY
    DF = AKE * (THKSAT - THKDRY) + THKDRY
    ! ----------------------------------------------------------------------
    
    END SUBROUTINE TDFCND_C05

    ! wuxb  2015.12.02
    SUBROUTINE ISSOILGRAVEL(GRAVEL,NSOILTYPE)
          INTEGER, INTENT(IN)  :: NSOILTYPE
          logical, INTENT(OUT) :: GRAVEL
          SELECT CASE (NSOILTYPE)
            CASE (1,15,16)
                GRAVEL = .TRUE.
            CASE (2,3,4,5,6,7,8,9,10,11,12,13)
                GRAVEL = .FALSE.
            CASE DEFAULT
                GRAVEL = .TRUE.
           END SELECT
    END SUBROUTINE ISSOILGRAVEL 
    
    SUBROUTINE ISSOILGRAVELSAND(STCLASSS,NSOILTYPE)
          INTEGER, INTENT(IN)  :: NSOILTYPE
          INTEGER, INTENT(OUT) :: STCLASSS
          SELECT CASE (NSOILTYPE)
             CASE (1,2,15,16)
                STCLASSS = 1
             CASE (3,4)
                STCLASSS = 2
             CASE (5,6,7,8,9,10,11,12,13)
                STCLASSS = 3
             CASE DEFAULT
                STCLASSS = 1
           END SELECT
    END SUBROUTINE ISSOILGRAVELSAND 
    
end module module_optimal