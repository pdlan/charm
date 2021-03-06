      !!! Fortran module variables, implicit and explicit save variables,
      !!! and common blocks are all unsafe if mutable, and must be privatized.
      !!! This is done by declaring all mutable global/static variables with
      !!! OpenMP's threadprivate attribute and compiling with ampif90's -tlsglobals
      !!! option. Since parameter variables are immutable, they need not be privatized.

      module test_mod_tlsglobals

        implicit none

        integer, parameter :: parameter_variable = 0
        integer, target :: module_variable
        !$omp threadprivate(module_variable)

      end module test_mod_tlsglobals


      subroutine mpi_main

        implicit none
        include 'mpif.h'

        integer :: ierr

        call mpi_init(ierr)

        call privatization_test_framework()

        call mpi_finalize(ierr)

      end subroutine mpi_main


      subroutine subroutine_save(failed, rank, my_wth, operation)

        implicit none
        save

        integer :: failed, rank, my_wth, operation
        integer, target :: save_variable3
        !$omp threadprivate(save_variable3)

        call test_privatization(failed, rank, my_wth, operation, save_variable3)

      end subroutine subroutine_save


      subroutine perform_test_batch(failed, rank, my_wth, operation)

        use test_mod_tlsglobals
        implicit none

        integer :: failed, rank, my_wth, operation
        integer, target :: save_variable1 = 0
        integer, save, target :: save_variable2
        integer, target :: common_variable
        common /commons/ common_variable
        !$omp threadprivate(save_variable1)
        !$omp threadprivate(save_variable2)
        !$omp threadprivate(/commons/)

        call test_privatization(failed, rank, my_wth, operation, module_variable)
        call test_privatization(failed, rank, my_wth, operation, save_variable1)
        call test_privatization(failed, rank, my_wth, operation, save_variable2)
        call subroutine_save(failed, rank, my_wth, operation)
        call test_privatization(failed, rank, my_wth, operation, common_variable)

      end subroutine perform_test_batch
