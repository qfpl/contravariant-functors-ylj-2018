set terminal png size 1000,500 enhanced font "Sans,20"
set output 'bench.png'

red  = "#FF0000";
blue = "#0000FF";

set yrange [0:5000]
set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9
set xtics format ""
set grid ytics

set title "Time in milliseconds (lower is better)"
plot "bench.dat" using 2:xtic(1) title "cassava" linecolor rgb red, \
              '' using 3 title "sv" linecolor rgb blue
