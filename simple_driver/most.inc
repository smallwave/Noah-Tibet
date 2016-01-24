!
!#######################################################################
!
!     Constants used in Hogstrom's equations 
!
!#######################################################################

      REAL, PARAMETER :: kv = 0.4  ! Von Karman constant

      REAL, PARAMETER :: prantl01 = 1.0  ! Turbulent Prandtl number for stable case
      REAL, PARAMETER :: prantl02 = 0.95 ! Turbulent Prandtl number for unstable case

      REAL, PARAMETER :: gammam=19.0
      REAL, PARAMETER :: gammah=11.6
      REAL, PARAMETER :: betam=5.3
      REAL, PARAMETER :: betah=8.0

      REAL, PARAMETER :: blimit=0.50
      REAL, PARAMETER :: rd     = 287.0        ! Gas constant for dry air  (m**2/(s**2*K))
      REAL, PARAMETER :: cp     = 1004.0 ! Specific heat of dry air at constant pressure
                                         ! (m**2/(s**2*K)).

      REAL, PARAMETER :: rddcp  = rd/cp 

      REAL, PARAMETER :: g      = 9.8   ! Acceleration due to gravity at the earth surface.
                                 ! (m/(s**2))   

      REAL, PARAMETER :: p0     = 1.0e5  ! Surface reference pressure, is 100000 Pascal.
