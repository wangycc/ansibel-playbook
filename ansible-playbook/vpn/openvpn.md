公司需求：
     1.PROD有一台服务器作为运维工具运行系统，上面运行着ansibel，zabbix，jenkins等等运维管理服务
     2.保证一些入口安全，现在需要这台服务器作为PROD内网入口，只允许本地网络通过内网访问PROD环境192.168.1.0/24网段，除了web入口服务，拒绝其他一切PROD外网访问。
     
VPN服务器：
     em1: 210.14.132.216   外网
     em2: 192.168.1.125/24 内网
一，安装openvpn源
     
yum install epel-release -y   epel源本身自带

二、安装oepnvpn

yum install openvpn -y

三、安装证书的生成工具

yum -y install easy-rsa -y

四、设置oepnvpn配置文件


cp -R /usr/sharr/easy-rsa   /etc/openvpn

cp /usr/share/doc/openvpn-2.3.10/sample/sample-config-files/server.conf /etc/openvpn

 
五、开始创建根证书

cd /etc/openvpn/easy-rsa/2.0
. vars      
./clean-all
./build-ca
----------------------------------------------------------------------注释分割线----------------------------------------
一路回车就可以，为了安全起见还是需要给证书设置密码。
vars #定义的全局配置变量
clean-all  ##会清除所有已经创建的证书
build-ca  创建服务器根证书

  vars里面定义了openvpn相关的全局配置变量

KEY_SIZE定义生成私钥的大小，一般为1024或2048，默认为2048位。这个就是我们在执行build-dh命令生成dh2048文件的依据。

CA_EXPIRE定义CA证书的有效期，默认是3650天，即10年。

KEY_EXPIRE定义密钥的有效期，默认是3650天，即10年。

KEY_COUNTRY定义所在的国家。

KEY_PROVINCE定义所在的省份。

KEY_CITY定义所在的城市。

KEY_ORG定义所在的组织。

KEY_EMAIL定义邮箱地址。

KEY_OU定义所在的单位。

KEY_NAME定义openvpn服务器的名称。

以上就是vars配置文件的全部内容，有关vars配置文件的使用，我们也可以系统的默认配置。
----------------------------------------------------------------------------------------------------------------------
六、给服务器创建server的key

./build-key-server server
最后选择输入y即可。
七、给用户创建秘钥


./build-key wangyichen

七、创建DH

./build-dh
#此时我们所有的创建文件，都会在/etc/openvpn/easy-rsa/2.0/keys这个目录。
八、配置openvpn 的server.conf文件

[wangyichen@st002 zabbix]$ cat /etc/openvpn/server.conf | egrep -v "^#|^$|^;"

local 210.14.132.216
port 9001
proto tcp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh2048.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "route 192.168.1.0 255.255.255.0"
client-to-client
duplicate-cn
keepalive 10 120
comp-lzo
max-clients 100
user openvpn
group openvpn
persist-key
persist-tun
status openvpn-status.log
verb 3

———————————————分割线————————————————————————————————————————————————————————————
local 210.14.132.216

定义openvpn监听的IP地址，如果是服务器单网卡的也可以不注明，但是服务器是多网卡的建议注明。

port 9001

定义openvpn监听的的端口，默认为9001端口。

proto tcp

;proto udp

定义openvpn使用的协议，默认使用UDP。如果是生产环境的话，建议使用TCP协议。

dev tun

;dev tap

定义openvpn运行时使用哪一种模式，openvpn有两种运行模式一种是tap模式，一种是tun模式。

tap模式也就是桥接模式，通过软件在系统中模拟出一个tap设备，该设备是一个二层设备，同时支持链路层协议。

tun模式也就是路由模式，通过软件在系统中模拟出一个tun路由，tun是ip层的点对点协议。

具体使用哪一种模式，需要根据自己的业务进行定义。

ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt

定义openvpn使用的CA证书文件，该文件通过build-ca命令生成，CA证书主要用于验证客户证书的合法性。

cert /etc/openvpn/easy-rsa/2.0/keys/server.crt


定义openvpn服务器端使用的证书文件。

key /etc/openvpn/easy-rsa/2.0/keys/server.key


定义openvpn服务器端使用的秘钥文件，该文件必须严格控制其安全性。

dh /etc/openvpn/easy-rsa/2.0/keys/dh2048.pem

定义Diffie hellman文件。

server 10.8.0.0 255.255.255.0

定义openvpn在使用tun路由模式时，分配给client端分配的IP地址段。

ifconfig-pool-persist ipp.txt

定义客户端和虚拟ip地址之间的关系。特别是在openvpn重启时,再次连接的客户端将依然被分配和断开之前的IP地址。

;server-bridge 10.8.0.4 255.255.255.0 10.8.0.50 10.8.0.100

定义openvpn在使用tap桥接模式时，分配给客户端的IP地址段。

;push “route 192.168.1.0 255.255.255.0”

向客户端推送的路由信息，假如客户端的IP地址为10.8.0.2，要访问192.168.1.0网段的话，使用这条命令就可以了。

;client-config-dir ccd

这条命令可以指定客户端IP地址。

使用方法是在/etc/openvpn/创建ccd目录，然后创建在ccd目录下创建以客户端命名的文件。比如要设置客户端 ilanni为10.8.0.100这个IP地址，只要在 /etc/openvpn/ccd/ilanni文件中包含如下行即可:

ifconfig-push 10.8.0.200 255.255.255.0

push “redirect-gateway def1 bypass-dhcp”

这条命令可以重定向客户端的网关，在进行翻墙时会使用到。

;push “dhcp-option DNS 208.67.222.222”

向客户端推送的DNS信息。

假如客户端的IP地址为10.8.0.2，要访问192.168.10.0网段的话，使用这条命令就可以了。如果有网段的话，可以多次出现push route关键字。同时还要配合iptables一起使用。

client-to-client

这条命令可以使客户端之间能相互访问，默认设置下客户端间是不能相互访问的。

duplicate-cn

定义openvpn一个证书在同一时刻是否允许多个客户端接入，默认没有启用。

keepalive 10 120

定义活动连接保时期限

comp-lzo

启用允许数据压缩，客户端配置文件也需要有这项。

;max-clients 100

定义最大客户端并发连接数量

;user nobody

;group nogroup

定义openvpn运行时使用的用户及用户组。

persist-key

通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第一次使用的keys。

persist-tun

通过keepalive检测超时后，重新启动VPN，一直保持tun或者tap设备是linkup的。否则网络连接，会先linkdown然后再linkup。

status openvpn-status.log

把openvpn的一些状态信息写到文件中，比如客户端获得的IP地址。

log openvpn.log

记录日志，每次重新启动openvpn后删除原有的log信息。也可以自定义log的位置。默认是在/etc/openvpn/目录下。

;log-append openvpn.log

记录日志，每次重新启动openvpn后追加原有的log信息。

verb 3

设置日志记录冗长级别。

;mute 20

重复日志记录限额
------------------------------------------------------------------------------------------------------------------------

以上就是openvpn服务器端server.conf配置文件的内容。
九、设置iptables，开启openvpn端口，做nat转发

echo 1 > /proc/sys/net/ipv4/ip_forward   ##设置ip转发，当然我们应该写在/etc/sysctl.conf
firewall-cmd --add-port=9001/tcp
iptables -t nat -A POSTROUTING -o em2 -s 10.8.0.0/24 -j MASQUERADE
10、启动oepnvpn服务
cd /etc/openvpn
openvpn --config server.con &

11、Linux客户端配置

client
dev tun
proto tcp
remote 210.14.132.216 9001
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert wangyichen.crt
key wangyichen.key
comp-lzo
verb 3

