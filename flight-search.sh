#!/bin/bash

firstDepartureDate=${1-"2012-04-06"}
lastDepartureDate=${2-"2012-06-08"}
origin=${3-"SYR"}
dest=${4-"CPT"}

browser="chromium-browser"
engines=( hipmunk kayak expedia travelocity skyscanner )


today=`date +%-j`
firstDepartureDay=`date --date "$firstDepartureDate" +%-j`
lastDepartureDay=`date --date "$lastDepartureDate" +%-j`

echo firstDepartureDate $firstDepartureDate
echo today $today
echo firstDepartureDay $firstDepartureDay
echo lastDepartureDay $lastDepartureDay

daysUntilFirstDepartureDate=$(($firstDepartureDay - $today))
daysUntilLastDepartureDate=$(($lastDepartureDay - $today))

echo daysUntilFirstDepartureDate $daysUntilFirstDepartureDate
echo daysUntilLastDepartureDate $daysUntilLastDepartureDate

declare -a departDates
declare -a returnDates
#TODO: +- 3 days
for((n=0,daysAhead=daysUntilFirstDepartureDate;daysAhead <= daysUntilLastDepartureDate;n++,daysAhead+=7)); do
	departDates[$n]=`date --date="$daysAhead days" +%F`
	returnDates[$n]=`date --date="$(($daysAhead + 9)) days" +%F`
	echo $daysAhead ${departDates[$n]}
done

j=0
declare -a urls

for engine in ${engines[*]}; do
	case $engine in
		hipmunk) s='"http://www.hipmunk.com/#!$origin.$dest,`date --date=${departDates[i]} +%b%d`.`date --date=${returnDates[i]} +%b%d`"';;
		kayak) s='"http://www.kayak.com/#/flights/$origin,nearby-$dest/${departDates[i]}/${returnDates[i]}"';;
		expedia) s='"http://www.expedia.com/Flights-Search?trip=roundtrip&leg1=from:$origin,to:$dest,departure:$(echo $(date -d ${departDates[i]} +%m-%d-%Y) | sed -e s/-/%2F/g)TANYT&leg2=from:CPT,to:SYR,departure:$(echo $(date -d ${returnDates[i]} +%m-%d-%Y) | sed -e s/-/%2F/g)TANYT&passengers=children:0,adults:1,seniors:0,infantinlap:Y&options=cabinclass:economy,nopenalty:N,sortby:price&mode=search&mdpdtl=FLT:SYR:CPT"';; 
		travelocity) s='"http://travel.travelocity.com/flights/InitialSearch.do?Service=TRAVELOCITY&flightType=roundtrip&dateTypeSelect=exactDates&dateLeavingTime=Anytime&dateReturningTime=Anytime&adults=1&children=0&seniors=0&leavingDate=`date --date=${departDates[i]} +%-m/%-d/%Y`&returningDate=`date --date=${returnDates[i]} +%-m/%-d/%Y`&leavingFrom=$origin&goingTo=$dest"';; 
		#cheapoair) s='"http://www.cheapoair.com/Default.aspx?tabid=1685&sid=$i&oa=$origin&da=$dest&adt=1&chd=0&snr=0&infl=0&infs=0&dd=`date --date=${departDates[i]} +%m-%d-%Y`&rd=`date --date=${departDates[i]} +%m-%d-%Y`&tt=ROUNDTRIP&lc=1"';;
		#priceline
		skyscanner) s='"http://www.skyscanner.com/flights/`echo $origin | tr '[A-Z]' '[a-z]'`/`echo $dest | tr '[A-Z]' '[a-z]'`/`date --date=${departDates[i]} +%y%m%d`/`date --date=${returnDates[i]} +%y%m%d`/"' ;;
	esac	

	for((i=0;i < n;i++,j++)); do
		urls[$j]=`eval echo $s`
	done
done


for url in ${urls[*]}; do
	#open in chromium
	echo $url
	$browser $url &
	sleep .2	#chromium seems to time out when you open too many tabs at once
done;
