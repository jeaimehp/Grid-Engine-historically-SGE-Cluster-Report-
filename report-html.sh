#!/bin/bash

##Load SGE module
module load /cm/shared/modulefiles/sge/2011.11p1

##Specify Color Variables
RCol='\e[0m'
Gre='\e[0;32m'
UGre='\e[4;32m'
IYel='\e[0;93m'
BRed='\e[1;31m'
URed='\e[4;31m'

##Directory to Grid Engine (SGE) binaries 
SGEDIR=/cm/shared/apps/sge/2011.11p1/bin/linux-x64

echo "<html> <head>"
echo -e "<title>[Turing Cluster Profile Report]\n</title>"
echo -e "<h1>[Turing Cluster Profile Report]\n</h1>"

##Prints the date of the report
echo "<body>"
echo "<em>"
/bin/date
echo "</em>"
echo "<p> </p> <pre>"
echo -e "<h2>CURRENT STATUS\n</h2>"
##Summary of all queue information
echo ""
$SGEDIR/qstat -g c | awk 'NR == 1 {print $2,$4,$6,$7,$9}' | column -t
$SGEDIR/qstat -g c | awk 'NR> 2 {print $1,$3,$5,$6,$8}' | column -t
echo ""
echo "<p> </p> <pre>"
echo -n "<h2>TOTAL SLOTS (CORES) = "
##Total Number of Slots Summed
$SGEDIR/qstat -g c | awk 'NR >2 {print $6}' | awk '{total = total + $1}END{print total}'
echo "</h2>"
echo "<h2>QUEUE LOADS</h2>"
##(Queue Slots Used / Queue Slots Total) * 100 for Queue Load Percentage 
$SGEDIR/qstat -g c | awk 'NR >3 {print $1"\t",($3/$6)*100,"%"}'
echo -e ""

##Prints node that are overloaded as compared to the number of slots submitted with a threshold of 1 cpu load
echo "<h2>OVERLOADED NODES</h2><em>(Note: Threshold = 1 CPU/SLOT)</em>"
echo ""
qstat -t | grep main@ | grep SLAVE | cut -c 72-77 | sort | uniq -c | awk '{printf $1"\t";system("qhost|grep "$2"")}' | awk '{$1 = $1 + 1; if ($1 < $5) print $2,"\t OVERLOADED", $1,"<",$5 }'
echo " "
echo ""


echo -n "<h2>TOTAL NODES ="
$SGEDIR/qhost | awk 'NR > 3 {print $1}'|wc -l
echo "</h2>"
echo -e "<h2>NODES DOWN\n</h2>"
echo "<p style="color:red">"
$SGEDIR/qhost|awk '$4 ~/-/ {print $1}'
echo -e "</p>"

echo -e "<h2>\nNODES DISABLED IN SGE</h2>"
echo "<p style="color:red">"
$SGEDIR/qstat -f|awk '$6 == "d" {print $1,$6}'
echo "</p>"



##rjobs is the number of currently running jobs
rjobs=$($SGEDIR/qstat | /bin/awk 'NR > 2 {print}' | /usr/bin/wc -l)

echo -e "<h2>\n\nTOP 5 LONGEST RUNNING JOBS\n</h2>"
#$SGEDIR/qstat | head -n 1
#$SGEDIR/qstat | sort -M | head -n 6
$SGEDIR/qstat | awk 'NR == 1 {print $1,$3,$4,$6,$9}' | column -t
$SGEDIR/qstat | sort -M | head -n 6 | awk 'NR != 1 {print $1,$3,4,$6,$9}'|column -t

echo ""






echo ""
echo -e "<hr>"
##Prints the number of currently running jobs
echo -e "<h1>[7-DAY JOB SUMMARY]</h1>"
echo ""
echo "Number of running jobs = "$rjobs
echo ""
##wcjobs is the number of completed jobs in a week (7 days)
wcjobs=$($SGEDIR/qacct -d 7 -j|awk 'BEGIN {RS = "=============================================================="};{FS="\n"}; {print $9}'|wc -l)
echo "Number of completed jobs = "$wcjobs
echo "--------------------"
##wtjobs is the total number of jobs
wtjobs=$(expr "$rjobs" + "$wcjobs")
echo "<h3>Total jobs in 7 days = "$wtjobs 
echo "</h3>"

echo -e "<h3>AVERAGES</h3>"
wtslots=$(qacct -d 7 -j | awk 'BEGIN {RS = "=============================================================="};{FS="\n"}; {print $17}' | awk '{print $2}'| awk '{total = total + $1}END{print total}')
echo -e ""
echo "Slots/Job = "$((wtslots / wcjobs))
echo -n "Wallclock/Job = "
qacct -d 7 | awk -v wjobs=$wcjobs 'NR > 3 {print $1/wjobs}'
echo -n "CPU/Job = "
qacct -d 7 | awk -v wjobs=$wcjobs 'NR > 3 {print $4/wjobs}'
echo -n "Memory/Job = "
qacct -d 7 | awk -v wjobs=$wcjobs 'NR > 3 {print $5/wjobs}'
echo -n "IO/Job = "
qacct -d 7 | awk -v wjobs=$wcjobs 'NR > 3 {print $6/wjobs}'
echo -e ""

echo -e "<h3>\n\nTOP 5 USERS BY CPU TIME (Completed jobs only)\n</h3>"
echo -e "User \t\t CPU\n---------------------------------------------"
$SGEDIR/qacct -d 7 -o | sort -k5 -n -r | head -n 5| awk '{print $1,"= "$5}'
echo ""

echo -e "<h3>\n\nTOP 5 USERS BY I/O (Completed jobs only)\n</h3>"
echo -e "User \t\t IO\n---------------------------------------------"
$SGEDIR/qacct -d 7 -o | sort -k7 -n -r | head -n 5 | awk '{print $1,"= "$7}'
echo ""





echo ""
##Prints the parallel enviroments (PE's) used with job data
echo "<h2>Grid Engine (SGE) Parallel Environment Stats</h2>"
$SGEDIR/qacct -d 7 -pe | awk 'NR != 2 {print $0}' | column -t | gnuplot peplot.gp
mv peplot.png 7day-peplot.png
echo "<img src="7day-peplot.png"/>"


$SGEDIR/qacct -d 7 -pe|awk 'NR != 2 {print $1,$2,$5,$6,$7}'|column -t
echo ""
$SGEDIR/qacct -d 7 |awk 'NR != 3 {print $1,$2,$5,$6,$7}'|column -t
echo -e "\n\n"



echo ""
echo -e "<hr>"
##Prints the number of currently running jobs
echo -e "<h1>[30-DAY JOB SUMMARY]</h1>"
echo ""
echo "Number of running jobs = "$rjobs
echo ""
##mcjobs is the number of completed jobs in a month (30 days)
mcjobs=$($SGEDIR/qacct -d 30 -j|awk 'BEGIN {RS = "=============================================================="};{FS="\n"}; {print $9}'|wc -l)
echo "Number of completed jobs = "$mcjobs
echo "--------------------"
##mtjobs is the total number of jobs
mtjobs=$(expr "$rjobs" + "$mcjobs")
echo "<h3>Total jobs in 30 days = "$mtjobs 
echo "</h3>"

echo -e "<h3>AVERAGES</h3>"
echo -e ""
mtslots=$(qacct -d 30 -j | awk 'BEGIN {RS = "=============================================================="};{FS="\n"}; {print $17}' | awk '{print $2}'| awk '{total = total + $1}END{print total}')
echo "Slots/Job = "$((mtslots / mcjobs))
echo -n "Wallclock/Job = "
qacct -d 30 | awk -v mjobs=$mcjobs 'NR > 3 {print $1/mjobs}'
echo -n "CPU/Job = "
qacct -d 30 | awk -v mjobs=$mcjobs 'NR > 3 {print $4/mjobs}'
echo -n "Memory/Job = "
qacct -d 30 | awk -v mjobs=$mcjobs 'NR > 3 {print $5/mjobs}'
echo -n "IO/Job = "
qacct -d 30 | awk -v mjobs=$mcjobs 'NR > 3 {print $6/mjobs}'
echo -e ""

echo -e "<h3>\n\nTOP 5 USERS BY CPU TIME (Completed jobs only)\n</h3>"
echo -e "User \t\t CPU\n---------------------------------------------"
$SGEDIR/qacct -d 30 -o | sort -k5 -n -r | head -n 5| awk '{print $1,"= "$5}'
echo ""

echo -e "<h3>\n\nTOP 5 USERS BY I/O (Completed jobs only)\n</h3>"
echo -e "User \t\t IO\n---------------------------------------------"
$SGEDIR/qacct -d 30 -o | sort -k7 -n -r | head -n 5 | awk '{print $1,"= "$7}'
echo ""



echo ""
##Prints the parallel enviroments (PE's) used with job data
echo "<h2>Grid Engine (SGE) Parallel Environment Stats</h2>"

$SGEDIR/qacct -d 30 -pe | awk 'NR != 2 {print $0}' | column -t | gnuplot peplot.gp
mv peplot.png 30day-peplot.png
echo "<img src="30day-peplot.png"/>"


$SGEDIR/qacct -d 30 -pe|awk 'NR != 2 {print $1,$2,$5,$6,$7}'|column -t
echo ""
$SGEDIR/qacct -d 30 |awk 'NR != 3 {print $1,$2,$5,$6,$7}'|column -t






echo ""
echo -e "<hr>"
##Prints the number of currently running jobs
echo -e "<h1>[180-DAY JOB SUMMARY]</h1>"
echo ""
echo "Number of running jobs = "$rjobs
echo ""
##sixmcjobs is the number of completed jobs in a month (180 days)
sixmcjobs=$($SGEDIR/qacct -d 180 -j|awk 'BEGIN {RS = "=============================================================="};{FS="\n"}; {print $9}'|wc -l)
echo "Number of completed jobs = "$sixmcjobs
echo "--------------------"
##sixmtjobs is the total number of jobs
sixmtjobs=$(expr "$rjobs" + "$sixmcjobs")
echo "<h3>Total jobs in 180 days = "$sixmtjobs 
echo "</h3>"
echo -e "<h3>AVERAGES</h3>"
echo -e ""
sixmtslots=$(qacct -d 180 -j | awk 'BEGIN {RS = "=============================================================="};{FS="\n"}; {print $17}' | awk '{print $2}'| awk '{total = total + $1}END{print total}')
echo "Slots/Job = "$((sixmtslots / sixmcjobs))
echo -n "Wallclock/Job = "
qacct -d 180 | awk -v sixmjobs=$sixmcjobs 'NR > 3 {print $1/sixmjobs}'
echo -n "CPU/Job = "
qacct -d 180 | awk -v sixmjobs=$sixmcjobs 'NR > 3 {print $4/sixmjobs}'
echo -n "Memory/Job = "
qacct -d 180 | awk -v sixmjobs=$sixmcjobs 'NR > 3 {print $5/sixmjobs}'
echo -n "IO/Job = "
qacct -d 180 | awk -v sixmjobs=$sixmcjobs 'NR > 3 {print $6/sixmjobs}'
echo -e ""

echo -e "<h3>\n\nTOP 5 USERS BY CPU TIME (Completed jobs only)\n</h3>"
echo -e "User \t\t CPU\n---------------------------------------------"
$SGEDIR/qacct -d 180 -o | sort -k5 -n -r | head -n 5| awk '{print $1,"= "$5}'
echo ""

echo -e "<h3>\n\nTOP 5 USERS BY I/O (Completed jobs only)\n</h3>"
echo -e "User \t\t IO\n---------------------------------------------"
$SGEDIR/qacct -d 180 -o | sort -k7 -n -r | head -n 5 | awk '{print $1,"= "$7}'
echo ""

echo ""
##Prints the parallel enviroments (PE's) used with job data
echo "<h2>Grid EnginGE)SGE) Parallel Environment Stats</h2>"

$SGEDIR/qacct -d 180 -pe | awk 'NR != 2 {print $0}' | column -t | gnuplot peplot.gp
mv peplot.png 180day-peplot.png
echo "<img src="180day-peplot.png"/>"


$SGEDIR/qacct -d 180 -pe|awk 'NR != 2 {print $1,$2,$5,$6,$7}'|column -t
echo ""
$SGEDIR/qacct -d 180 |awk 'NR != 3 {print $1,$2,$5,$6,$7}'|column -t


#echo -e "\nCURRENT STORAGE\n"
#echo -n "/home = "
#du -s /home
#echo " "
#echo -n "/scratch = "
#du -s /scratch
#echo " "
#echo -n "/cm/shared = "
#du -s /cm/shared
#echo " "
#echo -n "/lustre = "
#du -s /lustre
#echo " "
#echo -n "/RC = "
#du -s /RC

echo "</pre> </body> </html>"

