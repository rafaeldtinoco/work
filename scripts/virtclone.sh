#!/bin/bash

# this script creates a new VM based on an OLD template one (templates must be
# updated only when no child VMs exist orelse you will break the cloned VMs by
# changing the base QCOW disks)

ARG0=$(basename $0)
MACHINE=$1
CLONE=$2
OLDDIR=$PWD
MAINDIR=$(dirname $0)
LOGFILE=/tmp/virtxxx.log
[ "$MAINDIR" == "." ] && MAINDIR=$(pwd)

echo -n > $LOGFILE

LIBVIRTDIR=/var/lib/libvirt/images
MACHINEDIR=$LIBVIRTDIR/$MACHINE
CLONEDIR=$LIBVIRTDIR/$CLONE

TEMPLATES="mobkvmamd64 mobkvmi686 mobqemuamd64 mobqemuarm64 mobqemuarmhf mobqemui686"

getout() {
    echo ERROR: $@
    cd $OLDDIR
    exit 1
}

QEMUIMG=$(which qemu-img)
SUDO=$(which sudo)
VIRTCLONE=$(which virt-clone)
VIRSH=$(which virsh)

[ ! $QEMUIMG ] && getout "no qemu-img found"
[ ! $SUDO ] && getout "no sudo found"
[ ! $VIRTCLONE ] && getout "no virt-clone found"
[ ! $VIRSH ] && getout "no virsh found"

[ ! $MACHINE ] && getout "machine not informed"

if [ x$MACHINE == x"list" ]; then
    sudo ls -1 $LIBVIRTDIR
    exit 0
fi

[ ! -d $LIBVIRTDIR ] && getout "no libvirt dir found"
[ ! -d $MACHINEDIR ] && getout "no machine dir found"

[ ! -f $MACHINEDIR/vmlinuz ] && getout "machine's vmlinuz not found"
[ ! -f $MACHINEDIR/initrd.img ] && getout "machine's initrd.img not found"
[ ! -f $MACHINEDIR/disk01.ext4.qcow2 ] && getout "machine's disk not found"

if [ x$ARG0 == x"virtclone.sh" ]; then

    [ ! $CLONE ] && getout "clone not informed"
    [ -d $CLONEDIR ] && getout "clone already exists"

    $SUDO mkdir $CLONEDIR
    [ ! -d $CLONEDIR ] && getout "clone dir could not be created"

    $SUDO cp $MACHINEDIR/vmlinuz $CLONEDIR/vmlinuz
    $SUDO cp $MACHINEDIR/initrd.img $CLONEDIR/initrd.img
    $SUDO $QEMUIMG create -f qcow2 -b $MACHINEDIR/disk01.ext4.qcow2 \
                $CLONEDIR/disk01.ext4.qcow2 2>&1 >> $LOGFILE 2>&1

    $SUDO $VIRTCLONE --preserve-data \
                --connect qemu:///system \
                --original $MACHINE \
                --name $CLONE \
                --file $CLONEDIR/disk01.ext4.qcow2 2>&1 >> $LOGFILE 2>&1

    $SUDO $VIRSH dumpxml $CLONE > /tmp/$$.xml
    $SUDO sed -i "s:$MACHINE:$CLONE:g" /tmp/$$.xml 2>&1 >> $LOGFILE 2>&1
    $SUDO $VIRSH define /tmp/$$.xml 2>&1 >> $LOGFILE 2>&1
    $SUDO rm /tmp/$$.xml

    echo "running:"
    echo "- qcowhostname.sh $CLONE"
    qcowhostname.sh $CLONE
    echo "- qcowhome.sh $CLONE"
    qcowhome.sh $CLONE

elif [ x$ARG0 == x"virtcopy.sh" ] || [ x$ARG0 == x"virtexactcopy.sh" ]; then

    [ ! $CLONE ] && getout "dest not informed"
    [ -d $CLONEDIR ] && getout "dest already exists"

    $SUDO mkdir $CLONEDIR
    [ ! -d $CLONEDIR ] && getout "dest dir could not be created"

    $SUDO cp $MACHINEDIR/vmlinuz $CLONEDIR/vmlinuz
    $SUDO cp $MACHINEDIR/initrd.img $CLONEDIR/initrd.img
    $SUDO cp $MACHINEDIR/disk01.ext4.qcow2 $CLONEDIR/disk01.ext4.qcow2

    $SUDO $VIRTCLONE --preserve-data \
                --connect qemu:///system \
                --original $MACHINE \
                --name $CLONE \
                --file $CLONEDIR/disk01.ext4.qcow2 2>&1 >> $LOGFILE 2>&1

    $SUDO $VIRSH dumpxml $CLONE > /tmp/$$.xml
    $SUDO sed -i "s:$MACHINE:$CLONE:g" /tmp/$$.xml 2>&1 >> $LOGFILE 2>&1
    $SUDO $VIRSH define /tmp/$$.xml 2>&1 >> $LOGFILE 2>&1
    $SUDO rm /tmp/$$.xml

    if [ x$ARG0 == x"virtcopy.sh" ]; then
        echo "running:"
        echo "- qcowhostname.sh $CLONE"
        qcowhostname.sh $CLONE
        echo "- qcowhome.sh $CLONE"
        qcowhome.sh $CLONE
    fi

elif [ x$ARG0 == x"virtdel.sh" ]; then

    for temp in $TEMPLATES; do
        if [ x$MACHINE == x"$temp" ]; then
            getout "can't del a template, sorry"
        fi
    done

    [ ! -d $MACHINEDIR ] && getout "clone dir could not be found"

    $SUDO $VIRSH undefine $MACHINE 2>&1 >> $LOGFILE 2>&1

    $SUDO rm -f $MACHINEDIR/vmlinuz
    $SUDO rm -f $MACHINEDIR/initrd.img
    $SUDO rm -f $MACHINEDIR/disk01.ext4.qcow2
    $SUDO rmdir $MACHINEDIR

fi
