#!/bin/bash
cd $HOME 
git clone git://git.savannah.gnu.org/screen.git
cd screen/src
./autogen.sh
./configure
make
sudo make install
