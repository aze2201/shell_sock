# Shell_sock server to connect IoT device pty terminal
Connect to IoT device (behind NAT) via x509 key, without SSH low level keys in autorized_keys 

### dependecies
Server:
`nc`,`socat`,`openssl`,`make` (for installation only)

Client:
`socat`,`openssl`,`make` (for installation only)


Agent:
`ssh -t root@proxy "nc -l -s 127.0.0.1 -p 4445; pkill -f 'nc -l -s 127.0.0.1 -p 4445'",pty,raw,echo=0`
