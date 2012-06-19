# Copyright (C) 2012 Jonathan Vasquez
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Checks to see if the binaries exist
checkBinaries() {
    for X in ${JV_INIT_BINS}; do
		echo "Checking for ${X}"
		
        if [ ${X} = hostid ]; then
            if [ ! -f "${JV_USR_BIN}/${X}" ]; then
                errorBinaryNoExist ${X}
            fi
        elif [ ${X} = busybox ]; then
            if [ ! -f "${JV_BIN}/${X}" ]; then
                errorBinaryNoExist ${X}
            fi
        else
            if [ ! -f "${JV_SBIN}/${X}" ]; then
                errorBinaryNoExist ${X}
            fi
        fi
    done
}

# Function won't be used, but must be declared so script doesn't fail
checkModules() {
    echo "No modules will be checked"
}

# Copy the required binary files into the initramfs
copyBinaries() {
    echo "Copying binaries...\n"

    for X in ${JV_INIT_BINS}; do
	echo "Copying ${X}"
	    if [ "${X}" = "hostid" ]; then
		        cp ${JV_USR_BIN}/${X} ${JV_LOCAL_BIN}
	    elif [ "${X}" = "busybox" ]; then
		        cp ${JV_BIN}/${X} ${JV_LOCAL_BIN}
		elif [ "${X}" = "lvm" ]; then
			# Copy the static lvm binary and rename it to lvm
			cp ${JV_SBIN}/${X}.static ${JV_LOCAL_SBIN}/${X}
        else
			cp ${JV_SBIN}/${X} ${JV_LOCAL_SBIN} 
	    fi
    done
}

# Function won't be used, but must be declared so script doesn't fail
copyModules() {
    echo "No modules will be copied...\n"
}

# Copy all the dependencies of the binary files into the initramfs
copyDependencies() {
    echo "Copying dependencies...\n"
	
    for X in ${JV_INIT_BINS}; do
		echo "Gathering dependencies for ${X}"
		
	    if [ "${X}" = "busybox" ] || [ "${X}" = "hostid" ]; then
            if [ "${JV_LIB_PATH}" = "32" ]; then
			echo "32 bit for ${X}"
		        DEPS="$(ldd bin/${X} | awk ''${JV_LIB32}' {print $1}' | sed -e "s%${JV_LIB32}%%")"				
            else
		        DEPS="$(ldd bin/${X} | awk ''${JV_LIB64}' {print $1}' | sed -e "s%${JV_LIB64}%%")"	
            fi
	    else
            if [ "${JV_LIB_PATH}" = "32" ]; then
		        DEPS="$(ldd sbin/${X} | awk ''${JV_LIB32}' {print $1}' | sed -e "s%${JV_LIB32}%%")"
            else
		        DEPS="$(ldd sbin/${X} | awk ''${JV_LIB64}' {print $1}' | sed -e "s%${JV_LIB64}%%")"
            fi
	    fi 

	    for Y in ${DEPS}; do
			echo "Copying ${Y}"
			
            if [ "${JV_LIB_PATH}" = "32" ]; then
		        cp -Lf ${JV_LIB32}/${Y} ${JV_LOCAL_LIB}
            else
		        cp -Lf ${JV_LIB64}/${Y} ${JV_LOCAL_LIB64}
            fi
	    done
    done
}

# Create the empty mtab file in /etc and copy the init file into the initramfs
# also sed will modify the initramfs to add additional information
configureInit() {
    echo "Making mtab, and creating/configuring init...\n"

    touch etc/mtab

    if [ ! -f "etc/mtab" ]; then
        echo "Error created mtab file.. exiting\n" && exit
    fi

    # Copy the init script
    cd ${TMPDIR} && cp ${HOME_DIR}/files/${INIT_FILE} init

    # Substitute correct values in using % as delimeter
    # to avoid the slashes in the MOD_PATH [/lib/modules...]
    #sed -i -e '9s%""%"'${LVM_POOL_NAME}'"%' -e '10s%""%"'${LVM_ROOT_NAME}'"%' init

    if [ ! -f "init" ]; then
        echo "Error creating init file.. exiting\n" && cleanUp && exit
    fi
}
