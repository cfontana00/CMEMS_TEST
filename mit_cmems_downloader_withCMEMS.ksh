#!/bin/ksh

# This script downloads a specific domain of a list of Copernicus products
# it dumps in output dir files like med-cmcc-cur-an-fc-d-20210916.nc

# It needs the following software to be installed:
# - curl
# - xmllint
# - jq
# - motuclient.py (https://pypi.org/project/motuclient/)

typeset -r VERSION="1.1";

typeset -r PYTHON="python3";
typeset -r CMEMS="copernicusmarine";


typeset CONF_FILE;
typeset RUN_DATE;
typeset MOTU_DIR;
typeset -r MOTU_FILE="motuclient.py";
typeset -r JQ="jq";
typeset OUTPUT_DIR;

typeset -f usage;
typeset -f getConfItem;
typeset -f printConfSkeleton;

function usage {
	echo -e -n "\n";
	echo "NAME";
	echo -e "\t$(basename $0) - Download a specific domain of a list of Copernicus products";
	echo -e -n "\n";
	echo "SYNOPSYS";
	echo -e "\t$(basename $0) [-d rundate (YYYYMMDD)] [-o output-directory] [-c configuration-file] [-m motuclient-directory] [-h] [-v] [-s]";
	echo -e -n "\n";
	echo "DESCRIPTION";
	echo -e "\tmotuclient is required. Install from .tar.gz as specified at https://github.com/clstoulouse/motu-client-python.";
	echo -e -n "\n";
	echo -e "\tBefore starting the user has to configure the script for the specific domain using";
	echo -e "\ta \".json\" configuration file. A skeleton file can be obtained using option \"-s\"";
	echo -e -n "\n";
	echo -e "\tIn that file:";
	echo -e "\t- username and password are mandatory (https://resources.marine.copernicus.eu/?option=com_sla)";
	echo -e "\t- the geobox is mandatory";
	echo -e "\t- \"services\" and \"products\" \"name\" attributes are mandatory";
	echo -e "\t- omitting product \"variables\" attribute means all variables of that product";
	echo -e "\t- omitting \"domain_depth_min\" and \"domain_depth_max\" means all depths";
	echo -e -n "\n";
	echo -e "\tOptions on command line override those in the configuration file.";
	echo -e -n "\n";
	echo -e "\tIf rundate is missing current date is used.";
	echo -e -n "\n";
	echo "EXAMPLE";
	echo -e "\t$(basename $0) -d $(date +"%Y%m%d") -o /tmp -c /usr/local/etc/$(basename $0 .sh).json -m /usr/local/bin";
	echo -e -n "\n";
	echo "AUTHOR";
	echo -e "\tAlberto Brosich.";
	echo -e -n "\n";
}

function getConfItem {
	RESULT=$(${JQ} --compact-output --raw-output --monochrome-output ".${1}" ${CONF_FILE});

	if [ "${RESULT}" != "null" ]; then
		echo "${RESULT}";
	else
		echo "";
	fi
}

function printConfSkeleton {
${JQ} <<EOF
{
"motu_user": "username",
"motu_password": "password",
"domain_lat_min": 00.0,
"domain_lat_max": 00.0,
"domain_lon_min": 00.0,
"domain_lon_max": 00.0,
"domain_depth_min": 0.0,
"domain_depth_max": 0000.0,
"days_before": 7,
"days_after": 3,
"output_dir": "out_dir",
"motu_dir": "/usr/local/bin",
"motu_server": "http://nrt.cmems-du.eu/motu-web/Motu",
"csw_catalog_url_template": "https://resources.marine.copernicus.eu/?option=com_csw&view=details&tab=info&product_id=%s&format=xml",
"services": [{"name": "MEDSEA_ANALYSIS_FORECAST_PHY_006_013","products": [{"name": "cur","variables": ["uo", "vo"]},{"name": "sal","variables": ["so"]},{"name": "tem","variables": ["thetao"]}]},{"name": "MEDSEA_ANALYSIS_FORECAST_BIO_006_014","products": [{"name": "nut","variables": ["no3", "po4"]},{"name": "bio","variables": ["o2"]},{"name": "car","variables": ["dissic"]}]}]}
EOF
}

function log_message {
	echo "[$(date --rfc-3339=seconds)] $1";
}


# list of arguments expected in the input
optstring="c:d:m:o:hvs"

while getopts ${optstring} arg; do
	case ${arg} in
	h)
		usage;
		exit 0;
		;;
	c)
		CONF_FILE="${OPTARG}";
		;;
	d)
		RUN_DATE="${OPTARG}";
		;;
	m)
		MOTU_DIR="${OPTARG}";
		;;
	o)
		OUTPUT_DIR="${OPTARG}";
		;;
	s)
		printConfSkeleton;
		exit 0;
		;;
	v)
		echo "Version: ${VERSION}";
		exit 0;
		;;
	?)
		usage >&2;
		exit 10;
		;;
	esac
done


CONF_FILE=motu_downloader.json

typeset -r MOTU_SERVER=$(getConfItem "motu_server");
typeset -r MOTU_USER=$(getConfItem "motu_user");
typeset -r MOTU_PWD=$(getConfItem "motu_password");

typeset -r DOMAIN_LAT_MIN=$(getConfItem "domain_lat_min");
typeset -r DOMAIN_LAT_MAX=$(getConfItem "domain_lat_max");
typeset -r DOMAIN_LON_MIN=$(getConfItem "domain_lon_min");
typeset -r DOMAIN_LON_MAX=$(getConfItem "domain_lon_max");
typeset DOMAIN_DEPTH_MIN=$(getConfItem "domain_depth_min");
typeset DOMAIN_DEPTH_MAX=$(getConfItem "domain_depth_max");

typeset -i -r DAYS_BEFORE=$(getConfItem "days_before");
typeset -i -r DAYS_AFTER=$(getConfItem "days_after");

typeset -r CSW_CATALOG_URL_TEMPLATE=$(getConfItem "csw_catalog_url_template");

typeset TEMP_FILE;

typeset DOMAIN_DATE_MIN;
typeset DOMAIN_DATE_MAX;

# compute start and end dates
DOMAIN_DATE_MIN=$(date --date "${RUN_DATE} - ${DAYS_BEFORE} days" +"%F") || exit 2;
DOMAIN_DATE_MAX=$(date --date "${RUN_DATE} + ${DAYS_AFTER} days" +"%F") || exit 2;

# depth limits are not mandatory
if [ -z "${DOMAIN_DEPTH_MIN}" ]; then
	DOMAIN_DEPTH_MIN=0;
fi
if [ -z "${DOMAIN_DEPTH_MAX}" ]; then
	DOMAIN_DEPTH_MAX=9999;
fi

TEMP_FILE=$(mktemp);

trap "rm -f ${TEMP_FILE}" EXIT


echo "CONFIGURATION : "${CONF_FILE}


seq 0 $(($(getConfItem "services | length") - 1)) |\
while read SERVICE_INDEX
do
	SERVICE=$(getConfItem "services[${SERVICE_INDEX}].name");

	# loop on product of the current service
        echo 'LIST_PROD '
        getConfItem "services[${SERVICE_INDEX}].products[].name"


	getConfItem "services[${SERVICE_INDEX}].products[].name" |\
	while read PRODUCT_ID
	do
		# get vars from configuration file
		VAR_OPTS=$(getConfItem "services[${SERVICE_INDEX}].products[] | select (.name == \"${PRODUCT_ID}\")  | .variables[] | walk(\"-v \" + .)" | tr '\n' ' ');

echo "PRODUCT:"${PRODUCT_ID}


copernicusmarine subset \
-i ${PRODUCT_ID} \
-x ${DOMAIN_LON_MIN} \
-X ${DOMAIN_LON_MAX} \
-y ${DOMAIN_LAT_MIN} \
-Y ${DOMAIN_LAT_MAX} \
-z ${DOMAIN_DEPTH_MIN} \
-Z ${DOMAIN_DEPTH_MAX} \
${VAR_OPTS} \
-t ${DOMAIN_DATE_MIN} \
-T ${DOMAIN_DATE_MAX} \
-o  . \
-f ${PRODUCT_ID}-${RUN_DATE}.nc \
--force-download


	done
done


