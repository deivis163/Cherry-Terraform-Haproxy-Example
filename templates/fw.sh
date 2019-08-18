iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s ${ main } -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -s ${ floating } -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j DROP
iptables-save > /etc/iptables.rules
