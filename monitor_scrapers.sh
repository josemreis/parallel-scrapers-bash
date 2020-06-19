cd '/home/jmr/Dropbox/Current projects/thesis_papers/transparency, media, and compliance with HR Rulings/ecthr_media&compliance/data/media_data/alternative_sources/scrape'
DIR=./country-level
## start the while loop monitoring the folder changes
inotifywait -m -r -e create --timefmt '%H:%M' --format '%w' $DIR | while read CURFILE
do
  ## get the file size
  FILESIZE=$(stat -c%s "$CURFILE")
  DENOMINATOR=1024
  ## as Kb
  z=$((FILESIZE / DENOMINATOR))
  echo "$CURFILE created -> Size: $z kb"
done
