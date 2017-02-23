#!/bin/bash
if [ ! -f "$1" ]; then echo -e "Gimme a real file, kthnx.\n"; exit; fi
sh= ; sm= ; ss= ; eh= ; em= ; es= ;
f=${1##*/}; CHAPTERS=${f:0:-4}.chapters; VTT=${f:0:-4}.vtt; VTTEMP=$VTT.tmp;
echo "WEBVTT" > $VTT; > $CHAPTERS; > $VTTEMP; i=1;
while IFS= read -r LINE; do
    start_seconds=`echo $LINE | cut -d ' ' -f 1 | rev | cut -c 4- | rev`
    sh=`printf %02d $(bc <<< "$start_seconds / 3600")`
    sm=`printf %02d $(bc <<< "$start_seconds / 60")`
    ss=`printf %06.3f $(bc <<< "$start_seconds % 60")`
    if [ "$i" -gt 1 ]; then
        if (( `bc <<< "$start_seconds < $end_seconds"` )); then
            echo -e "WARNING: chapter overlap at $chapter_name"
        fi
        ofs=`printf %06.3f $(bc <<< "$ss - 0.002")`
        sed "s/$eh:$em:$es/$sh:$sm:$ofs/2" $VTTEMP >> $VTT
    fi
    end_seconds=`echo $LINE | cut -d ' ' -f 2 | rev | cut -c 4- | rev`
    eh=`printf %02d $(bc <<< "$end_seconds / 3600")`
    em=`printf %02d $(bc <<< "$end_seconds / 60")`
    es=`printf %06.3f $(bc <<< "$end_seconds % 60")`
    chapter_name=`echo $LINE | cut -d ' ' -f 3-`
    echo -e "\n$i\n$sh:$sm:$ss --> $eh:$em:$es\n$chapter_name" > $VTTEMP
    echo -e "CHAPTER$i=$sh:$sm:$ss\nCHAPTER"$i"NAME=$chapter_name" >> $CHAPTERS
    ((i=$i+1))
done < $1
cat $VTTEMP >> $VTT
rm $VTTEMP
