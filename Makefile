NOW=`date "+%Y%m%d-%H%M%S"`
RTBH_HOME=${HOME}/rtbh
GIT=/usr/local/bin/git --git-dir=${RTBH_HOME}/.git --work-tree=${RTBH_HOME}

all: fetchBL blist domlist

fetchBL:
	${RTBH_HOME}/bin/fetchBlockLists.pl ${RTBH_HOME}/urls.txt

IPLISTS=${RTBH_HOME}/etc/ip/*
blist: IPLISTS
	${RTBH_HOME}/bin/genIPlist.pl ${IPLISTS} > ${RTBH_HOME}/blist
	${GIT} add ${RTBH_HOME}/blist
	${GIT} diff ${RTBH_HOME}/blist
	${GIT} commit -m "block list updated ${NOW}" ${RTBH_HOME}/blist

DOMLISTS=${RTBH_HOME}/etc/domain/http:..d*.txt ${RTBH_HOME}/etc/domain/http:..d*.csv
domlist:
	${RTBH_HOME}/bin/genDomains.pl ${DOMLISTS} > ${RTBH_HOME}/domlist

