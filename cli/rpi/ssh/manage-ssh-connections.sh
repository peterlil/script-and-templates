# The ECDSA host key for raspberrypi has changed. 
# To remove old entry, use below
ip="192.168.1.89"
ssh-keygen -f "/home/linuxpl/.ssh/known_hosts" -R $ip

# A new fingerprint for the ECDSA key sent by the remote host.
# To remove old entry, use below
name="rpi1"
ssh-keygen -f "/home/linuxpl/.ssh/known_hosts" -R $name
