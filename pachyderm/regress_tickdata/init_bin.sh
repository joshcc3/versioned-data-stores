for i in 01 02 03 04; do
 for j in 01 02 03 04 05 06 07 08 09 10; do
  for k in 00 01 02 03 04 05 06 07 08 09 10; do
  for l in 00 01 02 03 04 05 06 07 08 09 10; do
   mkdir -p 2018/$i/$j/$k/;
   touch 2018/$i/$j/$k/$l.csv;
   echo "id,bid,ask" > 2018/$i/$j/$k/$l.csv;
   echo "SPX,`shuf -i 2000-3000 -n 1`,`shuf -i 2500-4000 -n 1`" >> 2018/$i/$j/$k/$l.csv ;
   echo "DJX,`shuf -i 1000-1500 -n 1`,`shuf -i 1500-3000 -n 1`" >> 2018/$i/$j/$k/$l.csv;
   echo "RUT,`shuf -i 10000-20000 -n 1`,`shuf -i 15000-35000 -n 1`" >> 2018/$i/$j/$k/$l.csv;
  done;
  done;
 done;
done