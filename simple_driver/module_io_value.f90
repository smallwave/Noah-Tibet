module module_io_value
    ! this program is for output intresting value
    ! 
    implicit none
    
    contains 
    
  ! method for producing a ASCII output file
  !2015.11.20
  subroutine writeRealAscii(dataNum)
    ! .....................................................
    real, intent(in) :: dataNum
    integer :: outFileID ! local variables
    character(len=20) :: filename  = trim("output.dat")
    logical alive 
    inquire(file=filename, exist=alive) 
    if(alive) then 
        open(newunit=outFileID, file=filename,STATUS='OLD',position="append",action='READWRITE' )
    else  
        open(newunit=outFileID, file=filename,STATUS='NEW',action='READWRITE' )
    end if
    write(outFileID, '(f10.8)') dataNum
    ! simulation results
    close(outFileID)
  end subroutine writeRealAscii 
  
  !
  subroutine writeIntAscii(dataNum)
    ! .....................................................
    integer, intent(in) :: dataNum
    integer :: outFileID ! local variables
    character(len=20) :: filename  = trim("output.dat")
    logical alive 
    inquire(file=filename, exist=alive) 
    if(alive) then 
        open(newunit=outFileID, file=filename,STATUS='OLD',position="append",action='READWRITE' )
    else  
        open(newunit=outFileID, file=filename,STATUS='NEW',action='READWRITE' )
    end if
    write(outFileID, '(3I5)') dataNum
    ! simulation results
    close(outFileID)
  end subroutine writeIntAscii  
  
end module module_io_value
    