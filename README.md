# Grid-Engine-historically-SGE-Cluster-Report-
This shell script generates a cluster report of usage based on Grid Engine calls.

Note:
This script was created on a machine running RedHat 6.6 with a tcsh shell.

The shell variable "SGEDIR" must be changed to point to your SGE installation directory.

Dependancies:
GNU Plot must be installed to produce the parallel environmnet (PE) graphs.
--The file "peplot.gp" must also be in the execution directory but can be altered to ajust the graphs as wanted.   

For Report with HTML Tags Usage:
./report-html > reportname.html

For report in the shell
./report
  ** ALT to send report information to a file:
    ./report > report_name.txt

