### Scraper parallelization for speeding things up
## trap underlying processes and kill all on exit
trap "exit" INT TERM ERR
trap "kill 0" EXIT
## open the monitoring bash script in a different terminal
gnome-terminal -x sh -c 'bash "/home/jmr/Dropbox/Current projects/thesis_papers/transparency, media, and compliance with HR Rulings/ecthr_media&compliance/data/media_data/alternative_sources/scrape/helpers/monitor_scrapers.sh"'
### start the loop
for value in {1..20}
do
  	# check if connected to the internet
	wget -q --tries=10 --timeout=20 --spider http://google.com
	## if yes, go on...
	if [[ $? -eq 0 ]]; then
		  	echo ">>wifi state: Online"
      		### automatically connect to a random vpn
			# check if connected to a vpn
			VPNCON=`expressvpn status`
			if [[ "$VPNCON" != "Not connected" ]]; then
				# disconnect from previous
				expressvpn disconnect
			fi
			# refresh list of available servers
			expressvpn refresh
			# list them, turn to table, and subset the alias collumn. Store it in a temp file.
			expressvpn list | tail -n+4 | column -t | awk '$1 != "Type" { print }' |  cut -d ' ' -f 1 > data.tmp
			# randomly sample an alias
			ARRAY_SIZE=`wc -l data.tmp | awk {'print $1'}`
			RND_VPN=`shuf -i 1-$ARRAY_SIZE -n 1`
			VPN=`sed "${RND_VPN}q;d" data.tmp`
			# remove temp file
			rm -f data.tmp
			## connect to the randomly sampled vpn
			expressvpn connect $VPN
      ## prep an array with the scripts to run in parallel
      # path to the parent folder
      cd "/home/jmr/Dropbox/Current projects/thesis_papers/transparency, media, and compliance with HR Rulings/ecthr_media&compliance/data/media_data/alternative_sources/scrape/country-level"
      # your scripts go her
      myscrapers=("./Romania/scripts/1_scrape_Romania.R" \
		  "./Turkey/scripts/1_scrape_turkey.R")
      ### parallelized run of the scrapers. If one stops, kill all and re-iterate
      parallel --jobs 0 --halt now,fail=1 Rscript ::: ${myscrapers[@]}
  else
       echo ">>wifi state: Offline"
  fi
sleep $(( ( RANDOM % 45 )  + 30 ))
done
wait
