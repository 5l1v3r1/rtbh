NOW=`date "+%Y%m%d-%H%M%S"`
RTBH_HOME=${HOME}/rtbh
GIT=/usr/local/bin/git --git-dir=${RTBH_HOME}/.git --work-tree=${RTBH_HOME}

all: fetchBL genIPlist

fetchBL:
	${RTBH_HOME}/bin/fetchBlockLists.pl ${RTBH_HOME}/urls.txt

genIPlist:
	${RTBH_HOME}/bin/genIPlist.pl ${RTBH_HOME}/etc/* > ${RTBH_HOME}/blist
	${GIT} add ${RTBH_HOME}/blist
	${GIT} diff ${RTBH_HOME}/blist
	${GIT} commit -m "block list updated ${NOW}" ${RTBH_HOME}/blist
