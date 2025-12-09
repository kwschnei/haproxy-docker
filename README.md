# haproxy-docker
Proxy server, terminates SSL at proxy.

This repository contains the necessary items to create a proxy that will terminate SSL and pass unencrypted traffic to the servers behind it. The instructions are specific to configuring HAProxy to route traffic to a PowerSchool server. This write-up assumes two things: 1) you're using a debian-based linux distribution to run the proxy on, and 2) you're going to use DNS-based authentication to get the SSL certificates.

Definitions:
  - FQDN: fullly qualified domain name, (e.g. ps.testdistrict.org). Everywhere you see this, you should use your server's name that you would type into the address bar of your browser.

1) Install packages to automate SSL issuance:
   - sudo apt update
   - sudo apt install certbot
     - If you plan on using DNS-based authentication, add the appropriate plugin for your provider to the above command, like python3-certbot-dns-cloudlfare, python3-certbot-dns-linode, python3-certbot-dns-digitalocean, etc.
2) Copy files from the repository to your preferred docker host. For the remainder of these instructions, the assumption is that you're running this on top of a Debian-based Linux since that's what I'm familiar with. If you're running on Windows or something else, you'll need to adapt the instructions.
3) Navigate to the config folder and run the following command to generate DH paramaters for encryption: openssl dhparam -out dhparams.pem 4096
4) Edit config/haproxy.cfg. Make sure to complete this step in the order listed, or your subsequence replacements won't find any matching results.
   - Replace all instances of FQDN1ABBR with a shortened version of your DNS name (substitute a - for the .).
   - Replace all instances of FQDN1IPADDR with the IP address of your server.
   - Replace all instances of FQDN1 with the fully qualified domain name of your server. 
5) Edit docker-compose.yaml and replace all instances of PROXYIPADDR with the IP address of the server on which you are running the docker container.
7) Uncomment the appropriate line and add your API key to /etc/letsencrypt/.secrets/api_key.ini
8) Generate your SSL certificate(s) using one of the examples below (depending on provider):
   - certbot certonly --dns-digitalocean --dns-digitalocean-credentials /etc/letsencrypt/.secrets/api_key.ini --dns-digitalocean-propagation-seconds 60 -d FQDN
   - certbot certonly --linode --dns-linode-credentials /etc/letsencrypt/.secrets/api_key.ini --dns-linode-propogation-seconds 120 -d FQDN
   - certbot certonly --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/.secrets/api_key.ini --dns-cloudflare-propagation-seconds 60 -d FQDN
10) Modify /etc/letsencrypt/renewal-hooks/post/haproxy.sh
    - Replace DOMAIN with your FQDN.
    - Replace PATH with the location of the docker folder
11) Ensure that the file is executable: sudo chmod +x /etc/letsencrypt/renewal-hooks/post/haproxy.sh
11) Manually run the command for the first time (afterwards, it will automatically run with each renewal)
    - cat /etc/letsencrypt/live/DOMAIN/privkey.pem /etc/letsencrypt/live/DOMAIN/fullchain.pem | tee PATH/docker/haproxy/config/ssl/DOMAIN.pem
    - docker-compose -f PATH/docker/haproxy/docker-compose.yml down
    - docker-compose -f PATH/docker/haproxy/docker-compose.yml up -d
12) Configure the PowerSchool server and Global Server settings so it is not using SSL directly. See the national PSUG mailing list for additional <a href="https://groups.io/g/PSUG/topic/116640440#msg248394">discussion.</a> 

Additional reading:
- Certbot Linode DNS <a href="https://certbot-dns-linode.readthedocs.io/en/stable/">documentation</a>
- Certbot CloudFlare DNS <a href="https://certbot-dns-cloudflare.readthedocs.io/en/stable/">documentation</a>
- Certbot DigitalOcean DNS <a href="https://certbot-dns-digitalocean.readthedocs.io/en/stable/">documentation</a>
