#!/bin/sh

# Title:	chownme.sh
# Description:	Changes ownerships of certain UpStage folders to the current user.
# Notes:	
# Author:	AUT 2007 team: Endre Bernhardt
# Modification History: 
# Version	Date		Person	Description
# 1.0		??/??/??	EB	Started
# 1.1		12/09/07	PQ	Changed hard-coded "upstageuser" to dynamically get
#					the username with "$USER". Added this header.
# 1.2		14/09/07	PQ	Changed $USER to $USERNAME otherwise it will only get
#					the username of the currently logged in terminal user.
#

chown -R $USERNAME /var/local/log/upstage/
chown -R $USERNAME /var/local/run/upstage/
chown -R $USERNAME /usr/local/share/upstage/
