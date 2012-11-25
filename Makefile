RTBH_HOME=${HOME}/rtbh

all: fetchBL

fetchBL:
	${RTBH_HOME}/bin/fetchBlockLists.pl ${RTBH_HOME}/urls.txt
