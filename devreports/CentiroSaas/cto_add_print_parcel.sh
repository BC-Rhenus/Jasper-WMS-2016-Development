#!/bin/bash

# This script is used for integration with Centiro Saas.
# It will execute the add and print webservice call or the delete and add shipment web service.
# When delete and add shipment is called it is because an operator has run a WMS report to execute a user carrier update while an order / shipment is already in progress.

cd $HOME/reports/CentiroSaas

MYSOURCE="$HOME/reports/CentiroSaas/cto_add_print_parcel.sh"
# Loop true all options to set all required parameters
# When a value suposed to null it is populated as XXXXX because so far no luck in passing null values to sql scrips

# Default printer id

while [ -n "$1" ]; do # while loop starts

	case "$1" in
			# To identify the site id in which the operation must be executed.
	-S) 	siteid="$2"
			echo $siteid	
			shift
			;;
			
			# used for carrier update can be null depending on what the operator has entered. 
	-s)		oldshipmentid="$2"
			echo $oldshipmentid
			shift
			;;
			
			# The unique client identifier.
	-C)		clientid="$2"
			echo $clientid
			shift
			;;
			
			# Unique order id. Can be null depending on what the operator has entered or wat action the operator did.
	-O) 	orderid="$2"
			echo $orderid
			shift
			;;
			
			# WMS move task pallet id.
	-P)		palletid="$2"
			echo $palletid
			shift
			;;
			
			# Printer to which the labels must be send.
	-E)		printerid="$2"
			echo $printerid
			shift
			;;
			
			# WMS move task container id.
	-c)		containerid="$2"
			echo $containerid
			shift
			;;
			
			# Unique Key to identify what Run tasks executed the task, Used for logging.
	-R)		rtkkey="$2"
			echo $rtkkey
			shift
			;;
			
			# Workstation from which the action was taken.
	-W)		workstation="$2"
			echo $workstation
			shift
			;;
			
			# Regular add and print or force carrier update whith existing parcels.
			# allowed values : addandprint or updatecarrier
	-T)		procestype="$2"
			echo $procestype
			shift
			;;
			
			# Help menu
	-h)		echo " Ensure parameters are always enclosed by double quotes."
			echo " -S  Used to identify the site id"
			echo " -s  Used to identify the current shipment id for carrier update"
			echo " -C  Used to identify the client id"
			echo " -O  Used to identify the order id"
			echo " -P  Used to identify the pallet id"
			echo " -E  Used to identify the printer id required for carrier update when parcels exist"
			echo " -c  Used to indentofy the container id"
			echo " -R  Used to identify teh run task key"
			echo " -W  Used to identify the workstation"
			exit
			;;
	--)
		shift # The double dash makes them parameters
		break
		;;
	*) echo "Option $1 not recognized" ;;
	esac
	shift
done

isupdate="U"
isyes="Y"
isno="N"

# add log record
echo "Find proces type"
if	[[ $procestype == 'addandprint' ]]; then
	echo "Call add_print_parcel procedure"
	MYSTRING="Call.add.and.print.Parcel"
	sqlplus -S $ORACLE_USR @create_cto_log_record.sql $MYSOURCE $MYSTRING
	sqlplus -S $ORACLE_USR @build_and_call_add_print_parcel_webservice.sql $siteid $clientid $orderid $palletid $containerid $rtkkey $workstation
else
	echo "call force carrier update procedure"
	MYSTRING="Call.add.shipment.with.labels"
	sqlplus -S $ORACLE_USR @create_cto_log_record.sql $MYSOURCE $MYSTRING
	sqlplus -S $ORACLE_USR @cto_force_carrier_update.sql $siteid $clientid $printerid $orderid $oldshipmentid $rtkkey
fi

# During add/print parcel it is possible to generate labels for multiple parcels in one run. 
# In this step we fetch all parcel id's that where generated via the run task.
# The run task key is used to connect al labels to the current run.

# Add log record
MYSTRING="Create.temp.file.with.parcel.ids."$rtkkey".txt"
sqlplus -S $ORACLE_USR @create_cto_log_record.sql $MYSOURCE $MYSTRING

parcelids=$rtkkey".txt"
echo "temporary filename that contains all parcel ids = "$parcelids
sqlplus -S $ORACLE_USR @fetch_parcel_ids.sql $rtkkey $parcelids


# Loop passed all parcel ids and fetch and print the label linked to it to the defined printer
echo "start looping all parcel ids"

# add log record
MYSTRING="Start.looping.all.parcel.ids."
sqlplus -S $ORACLE_USR @create_cto_log_record.sql $MYSOURCE $MYSTRING

while read parcelid shipmentid printer copies contenttype
do
	if	[[ $shipmentid == 'X' ]]; then
		echo "No more labels to print for shipment id " $shipmentid " and parcel id " $parcelid " from run task " $rtkkey
		# add log record
		MYSTRING="No.more.parcels.to.process."
		sqlplus -S $ORACLE_USR @create_cto_log_record.sql $MYSOURCE $MYSTRING
		continue
	fi
	if	[[ $printer	== 'X' ]]; then
		echo "No printer specified for shipment id " $shipmentid " and parcel id " $parcelid " from run task " $rtkkey
		# add log record
		MYSTRING="No.printer.specified.for.parcel.label."
		sqlplus -S $ORACLE_USR @create_cto_log_record.sql $MYSOURCE $MYSTRING
		continue
	else
		# set name of label file

		# add log record
		MYSTRING="Create.temp.ship.label.file."$shipmentid"_"$parcelid"_"$rtkkey".zpl"
		sqlplus -S $ORACLE_USR @create_cto_log_record.sql $MYSOURCE $MYSTRING

		labelfile=$shipmentid"_"$parcelid"_"$rtkkey".zpl"
		labelfiledecode=$shipmentid"_"$parcelid"_"$rtkkey"_decode.zpl"
		# Fetch label ZPL and add to file
		sqlplus -S $ORACLE_USR @fetch_labels.sql $shipmentid $parcelid $rtkkey $labelfile
		END=$copies

		# Redo print assignment until number of copies is reached.
		for ((i=1;i<=END;i++)); do
			# print the zpl file to printer
			# add log record
			MYSTRING="Printed.copy.nr."
			sqlplus -S $ORACLE_USR @create_cto_log_record.sql $MYSOURCE $MYSTRING
			
			# to prevent characterset issues it is better to fetch and print the BASE64 code and decode while printing.
			# The label string is not always encoded and so we must check the content to see if it is BASE64 Y/N. 
			# When the label string contains the ^ symbol it is not encoded.
			
			sqlplus -S $ORACLE_USR @print_monitoring_log_record.sql $rtkkey $isupdate $isyes $isno
			if	[[ $contenttype == 'ZPL' ]]; then
			# not BASE64
				lp -d $printer $labelfile;rm -f $labelfile
			
			else
			# base64 file
			
				# Decode BASE64 code and print and remove
				cat $labelfile | base64 --decode > $labelfiledecode;lp -d $printer $labelfiledecode;rm -f $labelfiledecode; rm -f $labelfile
			fi
		done

		echo "Started printing label "$labelfile" on printer "$printer
		# remove label file from server
		# rm -f $labelfile
	fi
done < $parcelids
sqlplus -S $ORACLE_USR @print_monitoring_log_record.sql $rtkkey $isupdate $isno $isyes
# remove parcel ids file
rm -f $parcelids

exit

