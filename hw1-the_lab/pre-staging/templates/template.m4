hostname __hostname__
ip domain-name lab.local
username cisco privilege 15 secret cisco
crypto key zeroize rsa
crypto key generate rsa general-keys label SSH modulus 2048
ip ssh version 2
line vty 0 4
  login local
  transport input ssh
interface FastEthernet0/0
  ip address __oob_ip__ 255.255.255.0
  no shutdown
