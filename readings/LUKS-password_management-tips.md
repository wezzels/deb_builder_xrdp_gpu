see what drives are encrypted:
    sudo cat /etc/crypttab

Password add:
    sudo cryptsetup luksAddKey /dev/sda3

To remove  password:
    sudo cryptsetup luksRemoveKey /dev/sda3

View slots:
    sudo cryptsetup luksDump /dev/sda3
