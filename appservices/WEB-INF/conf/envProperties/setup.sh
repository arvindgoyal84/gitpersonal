#!/bin/bash
# 
#	Athenahealth Confidential 
#	Allen Lee
#	The installation script to automatically configure SOLR master, slave or standalone.

# -------------------------------------------------
#
ENVS="gm gma dma dmb dmc dmd dme qma qmb qmc qmd qme lma dvp qap drr stg prd"
#Note: For testing, ust this: DEST_DIR=/opt/epocrates/new
#
#Note: for Real deployment, set to root!!!!
DEST_DIR=/
# -------------------------------------------------
#
#Deploy files to the real Directory!
#
# ===================================================================================
cpx() {
    fx=$1
    dx=$2
    #echo ________________________________________________________
    #Rename the exist file so we have history.  But disable this one until you need it!!!!!
    #if [ -f $dx/$fx ]; then
        #cd  $dx
        #echo sudo cp -rfp $fx $fx.$DT
        #sudo cp -rfp $fx $fx.$DT
    #fi
    echo sudo cp -rfp $fx $dx
    sudo cp -rfp $fx $dx
}
# -------------------------------------------------
#
#
# get the environment settings
# -------------------------------------------------
# ===================================================================================
checkEnv() {
[ -e /etc/sysconfig/epocrates ] || { echo /etc/sysconfig/epocrates does not exist. Please make sure it does before running this script ; exit 1; }

. /etc/sysconfig/epocrates

echo The EPOX Environment is ${EPOX_ENVIRONMENT}

#quit if there isn't environment settings
[[ $EPOX_ENVIRONMENT == "" ]] && { echo The epocrates file exists but the environment variable for EPOX_ENVIRONMENT is blank; exit 1 ; }
}

# -------------------------------------------------
#
#Copy property files to staging directory for process
#
# -------------------------------------------------
# ===================================================================================
prepareStagingFiles() {
if [ -d staging ] ; then
echo rm -rf staging/*
rm -rf staging
fi
mkdir staging
echo Dir:`pwd`
cp -r `ls | grep -v staging | grep -v one-time.bash` staging/
if [ $? -ne 0 ]; then
    echo cp -r ls \| grep -v staging \| grep -v one-time.bash staging/
    echo "command2 broke it"
fi
#echo remove unwanted files
#echo rm -f staging/*
rm -f staging/*
#echo ls -l staging/*
ls -l staging/*
}
# -------------------------------------------------
#
# Find this environment property files!
#
# -------------------------------------------------
# ===================================================================================
prepareEnvFiles() {
cd staging

echo Staging dir=`pwd`
echo

echo Here are all files consist of $EPOX_ENVIRONMENT extension and after RENAME
find . -name *.$EPOX_ENVIRONMENT | sed -e "p;s/.$EPOX_ENVIRONMENT\$//"
echo 
#echo Pause for your reading...
#sleep 5

let count=`find . -name *.$EPOX_ENVIRONMENT |wc -l`
echo Total $EPOX_ENVIRONMENT ENV files count = $count 
if [[ count -gt 0 ]] ; then
  echo Copy file extension of $EPOX_ENVIRONMENT to without $EPOX_ENVIRONMENT extension...
  find . -name *.$EPOX_ENVIRONMENT | sed -e "p;s/.$EPOX_ENVIRONMENT\$//" | xargs -n2 cp
  if [ $? -ne 0 ]; then
      echo "command3 broke it"
  fi
else
  echo "No ENV files to be renamed!"
fi
}

#-------------------------------------
#
# Delete Environmental files not belong to this Env.
#
#-------------------------------------
# ===================================================================================
deleteWrongEnvFiles() {
#echo "Next is to delete Wrong ENV Files!"
for wrongEnv in ${ENVS} ; do
  if [ $wrongEnv != "${EPOX_ENVIRONMENT}" ]; then
    let toBeDelete=`find . -name *.$wrongEnv | wc -l`
    if [[ toBeDelete -gt 0 ]] ; then
      #echo "find . -name *.$wrongEnv | xargs rm -f"
      find . -name *.$wrongEnv | xargs rm -f
      echo Delete $toBeDelete $wrongEnv ENV files!
    fi
  fi
done

let myEnvFileCount=`find . -name "*.$EPOX_ENVIRONMENT" | wc -l`
if [[ myEnvFileCount -gt 0 ]] ; then
  echo
  echo Delete $myEnvFileCount $EPOX_ENVIRONMENT MY ENV files!
  echo
  find . -name "*.$EPOX_ENVIRONMENT" | xargs rm -f
else
  echo "No ENV files to be renamed!"
fi
}
#-------------------------------------
#
# Copy and delpoy the files to the right place
#
#-------------------------------------
# ===================================================================================
deployFiles() {
echo
echo deployFiles...
echo
STAGINGDIR=`pwd`
echo
echo Current Directory=$STAGINGDIR
echo Files Will be Deployed to: $DEST_DIR
#echo Pause for five seconds...
#sleep 3

for file in $(find .)
do
if [ -f $file ] ; then
  DIR=`dirname ${file}`
  if [ ! -d ${DEST_DIR}/${DIR} ] ; then
    #echo mkdir -p ${DEST_DIR}/${DIR}
    mkdir -p ${DEST_DIR}/${DIR}
  fi
    cpx $STAGINGDIR/$file ${DEST_DIR}/${DIR}
fi
done
}
#-------------------------------------
#
# Copy and delpoy the files to the right place
#
#-------------------------------------
# ===================================================================================
specialFileHandling() {
echo
echo specialFileHandling...
echo
STAGINGDIR=`pwd`
echo
echo specialFileHandling Current Directory=$STAGINGDIR
#Note: To Developers: Any files that need special handling will be executed below!!!! 

}

# ===================================================================================
#-------------------------------------
#|
#| Main scrip starts here!!!!!!!!!!!!!!!!
#|
#============================================
echo `pwd`
#-------------------------------------
#|
#| Check /etc/sysconfig/epocrates file.  If file does not exist, program won't run!
#============================================
checkEnv
#-------------------------------------
#|
#| Copy env property files to staging directory for process.
#============================================
prepareStagingFiles
#-------------------------------------
#|
#| After files Copied to staging, prepare them. For example, remove the $env and delete files belong to other $env!
#============================================
prepareEnvFiles
#-------------------------------------
#|
#| After files were prepared, delete files belong to other $env!
#============================================
deleteWrongEnvFiles
#-------------------------------------
#|
#| Copy files to the right location.
#============================================
deployFiles
#-------------------------------------
#-------------------------------------
#|
#| Some files after deployment, still need to have special handling, like crontab, etc.
#============================================
specialFileHandling

echo
echo Done
echo
