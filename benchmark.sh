#!/bin/bash

echo -e "\nbenchmark.sh -n<number of requests> -c<number of concurrency> <URL1> <URL2> ..."
echo -e "\nEx: benchmark.sh -n100 -c10 http://www.google.com/ http://www.bing.com/ \n"

## Gnuplot settings

echo "set terminal jpeg size 1280,720
set size 1,1
set output 'benchmark_${1}_${2}.jpg'
set title 'Benchmark: ${1} ${2}'
set key left top
set grid y
set xdata time
set timefmt '%s'
set format x '%S'
set xlabel 'seconds'
set ylabel 'response time (ms)'
set datafile separator '\t' " > /tmp/plotme

#echo "set terminal jpeg
#set output 'benchmark_${1}_${2}.png'
#set title 'Benchmark: ${1} ${2}'
#set size 1,1
#set grid y
#set xlabel 'request'
#set ylabel 'response time (ms)' " > /tmp/plotme

## Loop over parameters
c=1
for var in "$@"
do
    ## skipping first parameters (concurrency and requests)
    if [ $c -gt 2 ]
    then
        ## apache-bench
        ab $1 $2 -g "gnuplot_${c}.out" "${var}"
        ## if for concat stuff
        if [ $c -gt 3 ]
        then
                #echo -e ", 'gnuplot_${c}.out' using 9 smooth sbezier with lines title '${var}' \\" >> /tmp/plotme
                echo -e ", 'gnuplot_${c}.out' every ::2 using 2:5 title '${var}' with points \\" >> /tmp/plotme
        else
                #echo -e "plot 'gnuplot_${c}.out' using 9 smooth sbezier with lines title '${var}' \\" >> /tmp/plotme
                echo -e "plot 'gnuplot_${c}.out' every ::2 using 2:5 title '${var}' with points \\" >> /tmp/plotme
        fi
    fi
    let c++
done
## plotting

gnuplot /tmp/plotme
echo -e "\n Success! Result image is: benchmark_${1}_${2}.jpg"
