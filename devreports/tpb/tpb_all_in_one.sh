#
# start the script in the correct directory
#
cd $HOME/reports/tpb

echo 
echo "**************************************************************"
echo " TPB All In One script started at `date` "
echo "**************************************************************"

#
# rename the logfiles to .OLD to keep the last 2 files
#

echo
echo "Renaming of logfiles started at `date`"

rename .log .log.OLD billing*.log
#
# Define on which environment we're on and set some variables accordingly to keep the script generic for all environments
#

echo
echo "Defining the environment at `date`"

SID=$ORACLE_SID

if [ $SID = `echo DEVCNLJW` ]
then
  SERVER="dehze01-lsv364"
elif [ $SID = `echo TSTCNLJW` ]
then
  SERVER="dehze01-lsv365"
elif [ $SID = `echo ACCCNLJW` ]
then
  SERVER="dehze01-lsv367"
elif [ $SID = `echo PRDCNLJW` ]
then
  SERVER="dehze01-lsv369"
else
  echo
  echo "Could not define the Environment so nothing will be processed"
  echo
  echo "**************************************************************"
  echo " TPB All In One script finished at `date` "
  echo "**************************************************************"
  echo

  exit
fi

ENV=$SERVER"_"$SID

echo
echo "Environment = "$ENV
echo
echo "Billinginterfacedaemon started at `date`"

#
# Run the billinginterfacedaemon to retrieve the WMS to Billing transactions
#
billinginterfacedae.sh -m $HOME/xml/WMSInterfaceMapping.xml -s $ENV -p dcsdba/dcsabd -b $ENV -a dcsdba/dcsabd -u RCL-WMS -y RCL-WMS -1 -f -o $HOME/reports/tpb/billinginterfacedaemon.log -L 3

#
# Check if the parameter passed is not empty, else set to ALL
#
if [ -z "$1" ]
then
  TYPE=ALL
else
  TYPE=$1
fi

#
# Run the billingprocdae for either ALL or per CLIENT based on the parameter passed in the scheduled program
#
if [ $TYPE = `echo ALL` ]
then

  echo
  echo "Type = ALL , Billingprocdae for ALL started at `date`"

  billingprocdae -p -1 -f -e tim.grol@nl.rhenus.com -E1 -o $HOME/reports/tpb/billingprocdae_ALL.log -L 3 -Z "Europe/Amsterdam"
elif [ $TYPE = `echo CLIENT` ]
then

  echo 
  echo "Type = CLIENT so retrieve the ClientIDs and write these into a file"
  echo "Client file created at `date` with Clients:"
  echo

  #
  # Create the file with all Client_ID's from the TPB Client Group
  #
  GRP=TPB
  sqlplus -S $ORACLE_USR @extract_tpb_clients.sql $GRP

  #
  # Run the billingprocdae for all processes and all Clients
  #

  echo
  echo "Now reading the Clients file and create a logfile and run the Billingprocdae per Client"

  while read CLIENT
  do
    echo
    echo "Billingprocdae for Client "$CLIENT" started at `date`"

    LOGFILE="$HOME/reports/tpb/billingprocdae_"$CLIENT".log"
    billingprocdae -A $CLIENT -p -1 -f -e tim.grol@nl.rhenus.com -E1 -o $LOGFILE -L 3 -Z "Europe/Amsterdam"

    echo "Billingprocdae for Client "$CLIENT" finished at `date`"
  done < tpb_clients.txt

  echo
  echo "Billingprocdae per Client for all Clients finished at `date`"  

  else
    echo
    echo "Could not define the Type so nothing will be processed"
    echo
    echo "**************************************************************"
    echo " TPB All In One script finished at `date` "
    echo "**************************************************************"
    echo

    exit
fi

  echo
  echo "**************************************************************"
  echo " TPB All In One script finished at `date` "
  echo "**************************************************************"
  echo

