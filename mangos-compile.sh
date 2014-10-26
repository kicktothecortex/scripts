#!/bin/bash
#
# Dark-iCE MaNGOS Auto-Compiler Script
# by cortexkicker
# last edited: 2010.07.30
while [ option != "0" ]
do
  clear
  echo "	MANGOS DARK-ICE COMPILER SCRIPT"
  echo
  echo "===================================="
  echo "1. Check/Install required packages"
  echo "2. Download sources from git"
  echo "3. Configure and compile/install"
  #echo "4. Setup/Fill Database"
  #echo "5. Select folder with dbc/maps/vmaps to copy"
  echo "0. Exit"
  echo
  echo "Enter a selection:"
  read option

  case "$option" in
    "1" )
      echo "Running 'sudo apt-get update' and installing necessary packages"
      sudo apt-get update
      sudo apt-get install build-essential gcc g++ cpp automake autoconf make patch libmysql++-dev libtool libcurl4-openssl-dev libssl-dev grep binutils subversion zlibc libc6 nano git-core pkg-config libtbb-dev unrar mysql-server
      echo "Press any key to continue..."
      read -n1 any_key
    ;;
    "2" )
      echo "Downloading Dark-iCE sources from GitHub..."
      mkdir mangos
      cd mangos
      git clone http://github.com/Darkrulerz/Core.git
      git clone http://github.com/Darkrulerz/scriptdev2.git
      cp -R Core Core-bin
      cp -R scriptdev2 Core-bin/src/bindings/ScriptDev2
      echo "Done."
      echo "Press any key to continue..."
      read -n1 any_key
    ;;
    "3" )
      cd mangos/Core-bin
      autoreconf --install --force
      mkdir objdir
      cd objdir
      ../configure --prefix=/opt/mangos --sysconfdir=/opt/mangos/etc --enable-cli --enable-ra --datadir=/opt/mangos

      CORENUM=`cat /proc/cpuinfo | grep processor | wc -l`
      make -j $CORENUM
      sudo make install
      sudo cp /opt/mangos/etc/mangosd.conf.dist /opt/mangos/etc/mangosd.conf
      sudo cp /opt/mangos/etc/realmd.conf.dist /opt/mangos/etc/realmd.conf
      echo "Press any key to continue..."
      read -n1 any_key
    ;;
    "4" )
      #cd mangos
      #git clone http://github.com/Darkrulerz/Database.git
      #cd Database/Full\ Database/
      #unrar e Project*.rar
      #PASS='your password'

      #mysql -u root --password=$PASS < ./01.\ Database\ Creation.sql
      #mysql -u root --password=$PASS characters < ./02.\ Characters\ Database.sql
      #mysql -u root --password=$PASS realmd < ./03.\ Realm\ Database.sql
      #mysql -u root --password=$PASS scriptdev2 < ./04.\ ScriptDev2\ Database.sql
      #mysql -u root --password=$PASS mangos < ./mangos.sql
      echo "Not implemented yet"
      echo "Press any key to continue..."
      read -n1 any_key
    ;;
    "5" )
      echo "Not implemented yet"
      echo "Press any key to continue..."
      read -n1 any_key
    ;;
    "0" )
      exit 0
    ;;
  esac
done
exit 0
