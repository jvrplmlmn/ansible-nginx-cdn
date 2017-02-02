# ansible-nginx-cdn

[![Build Status](https://travis-ci.org/jvrplmlmn/ansible-nginx-cdn.svg?branch=master)](https://travis-ci.org/jvrplmlmn/ansible-nginx-cdn)


## Instructions

### Minimum required applications

It is assumed that Ansible and at least Vagrant are installed.

This was written and tested using the following Ansible version:

```
$ ansible --version
ansible 2.2.0.0
```

Vagrant version:

```
$ vagrant version
Installed Version: 1.9.1
Latest Version: 1.9.1
```

### Install the role dependencies

```bash
ansible-galaxy install -r requirements.yml
```

### Provision the VM

It is possible to provision a VM using Vagrant. Take into account that a private IP address has been configured, in order to allow forwarding of the privileged ports (< 1024). Feel free to edit the `Vagrantfile` to use a different IP address.

```
$ vagrant up
```

### Test it

Vagrant will forward the ports `80`, `443` and `8080`.

On the ports `80` and `443` Nginx is listening for `HTTP` and `HTTPS` traffic.

`HTTP` traffic is redirected to `HTTPS`:

```
$ curl -i http://192.168.33.10:80/api/regions
HTTP/1.1 301 Moved Permanently
Server: nginx
Date: Thu, 02 Feb 2017 16:32:40 GMT
Content-Type: text/html
Content-Length: 178
Connection: keep-alive
Location: https://192.168.33.10/api/regions

<html>
<head><title>301 Moved Permanently</title></head>
<body bgcolor="white">
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

Making two or more consecutive requests will show that we're getting the content from the cache. Pay attention to the `ETag`, `Last-Modified` and `X-Cache-Status` headers:

**Test cached static resources:**

```
$ curl -i -X GET -L https://192.168.33.10/user/themes/cabify/img/favicon.ico --insecure -D - -o /dev/null --silent
HTTP/1.1 200 OK
Server: nginx
Date: Thu, 02 Feb 2017 17:28:21 GMT
Content-Type: image/x-icon
Content-Length: 32988
Connection: keep-alive
Last-Modified: Wed, 11 May 2016 22:09:45 GMT
ETag: "5733ada9-80dc"
X-Cache-Status: MISS
Accept-Ranges: bytes

$ curl -i -X GET -L https://192.168.33.10/user/themes/cabify/img/favicon.ico --insecure -D - -o /dev/null --silent
HTTP/1.1 200 OK
Server: nginx
Date: Thu, 02 Feb 2017 17:28:24 GMT
Content-Type: image/x-icon
Content-Length: 32988
Connection: keep-alive
Last-Modified: Wed, 11 May 2016 22:09:45 GMT
ETag: "5733ada9-80dc"
X-Cache-Status: HIT
Accept-Ranges: bytes
```

**Test caching of responses:**

```
$ curl -i -X GET -L https://192.168.33.10/api/regions --insecure -D - -o /dev/null
Server: nginx
Date: Thu, 02 Feb 2017 17:30:57 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 9155
Connection: keep-alive
Status: 200 OK
Cache-Control: max-age=3600, public
X-Country-Code: BE
X-Powered-By: Phusion Passenger Enterprise 5.0.29
X-Cache-Status: MISS

$ curl -i -X GET -L https://192.168.33.10/api/regions --insecure -D - -o /dev/null --silent
HTTP/1.1 200 OK
Server: nginx
Date: Thu, 02 Feb 2017 17:31:01 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 9155
Connection: keep-alive
Status: 200 OK
Cache-Control: max-age=3600, public
X-Country-Code: BE
X-Powered-By: Phusion Passenger Enterprise 5.0.29
X-Cache-Status: HIT

```



On the port `8080` we can reach the [nginx-requests-stats](https://github.com/jvrplmlmn/nginx-requests-stats) application:

```
$ curl http://192.168.33.10:8080/version --silent | jq .
{
  "version": "0.3.0"
}
$ curl http://192.168.33.10:8080/count --silent | jq .
{
  "requests": 1
}
```

```
curl -i -X GET -L https://192.168.33.10/user/themes/cabify/img/favicon.ico --insecure -D - -o /dev/null --silent
```

## Using Docker (via test-kitchen)

Alternatively, we can use `test-kitchen` to provision a Docker container fully provisioned by Ansible and verified by InSpec.

### Install

Assuming that we're using OS X and we have `brew` and `brew cask` available, we can get everything with:

```bash
brew update
brew cask install docker
brew cask install chefdk
brew cask install inspec
chef gem install kitchen-docker
chef gem install kitchen-ansible
chef gem install kitchen-sync
```

**Docker**

```
$ docker version
Client:
 Version:      1.12.5
 API version:  1.24
 Go version:   go1.6.4
 Git commit:   7392c3b
 Built:        Fri Dec 16 06:14:34 2016
 OS/Arch:      darwin/amd64

Server:
 Version:      1.12.5
 API version:  1.24
 Go version:   go1.6.4
 Git commit:   7392c3b
 Built:        Fri Dec 16 06:14:34 2016
 OS/Arch:      linux/amd64
```

**Kitchen (ChefDK)**
```
$ chef --version
Chef Development Kit Version: 1.1.16
chef-client version: 12.17.44
delivery version: master (83358fb62c0f711c70ad5a81030a6cae4017f103)
berks version: 5.2.0
kitchen version: 1.14.2
```

**InSpec**
```
$ inspec version
1.7.2
```

### Provision

```bash
$ kitchen verify
-----> Starting Kitchen (v1.14.2)
-----> Creating <default-ubuntu-1604>...
Sending build context to Docker daemon 558.1 kB57.1 kB
(...)
```

### Test

Use [this](#test-it) instructions, but replace the IP address with `localhost`.
