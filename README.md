# WordpressProgetto
Descrizione dell'Infrastruttura:
Ho utilizzato un architettura monolitica, cioe' tutti i componenti, compreso il server web di WordPress e il server di database MySQL, sono ospitati all'interno della stessa istanza EC2.

VPC e Subnet:
Ho configurato una Virtual Private Cloud (VPC) con l'indirizzo IP base 10.0.0.0/16. All'interno di questa VPC, ho creato due subnet:
Subnet pubblica (publica): La subnet 10.0.0.0/24 nella zona di disponibilità us-east-1a. Questa subnet è destinata a ospitare l'istanza EC2 di WordPress. La configurazione include il mapping di un indirizzo IP pubblico all'avvio dell'istanza.
Subnet privata (privata): La subnet 10.0.1.0/24 nella zona di disponibilità us-east-1b. Questa subnet ospita l'istanza EC2 di MySQL ed è isolata dalla rete pubblica.


Internet Gateway:
Ho creato un Internet Gateway e l'ho associato alla VPC. Questo permette alle risorse all'interno della VPC, come le istanze EC2, di comunicare con Internet e di essere accessibili dall'esterno.


Security Groups:
Ho definito due gruppi di sicurezza:
wordpress_sg: Questo gruppo di sicurezza è associato all'istanza EC2 di WordPress. È configurato per consentire il traffico in ingresso sulla porta 80 (HTTP) e sulla porta 22 (SSH) per la gestione remota dell'istanza. 


EC2 Instances:
Ho creato un istanza EC2:
Istanza EC2 di WordPress: Questa istanza è posizionata nella subnet pubblica (publica) e utilizza il gruppo di sicurezza wordpress_sg. Viene assegnato un indirizzo IP pubblico per consentire l'accesso dall'esterno.


Elastic IP:
Ho associato un indirizzo IP elastico all'istanza di WordPress. Questo indirizzo IP rimane costante anche dopo eventuali riavvii dell'istanza, garantendo la stabilità dell'indirizzo di accesso.


Connessione tra MySQL e WordPress:
WordPress utilizza un database locale, il database si trova sulla directory /var/www/html all'interno del file wp-config.php
L'applicazione WordPress richiede dati dal database MySQL per funzionare, come post, pagine, impostazioni, ecc.

Comandi usati per installare WordPress:
dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel -y
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

Inizia database e Apache httpd server:
sudo systemctl start mariadb httpd
mysql -u root -p
Ho create un user ed un database a questo punto.

Crea un file di configurazione 
cp wordpress/wp-config-sample.php wordpress/wp-config.php
nano wordpress/wp-config.php  qui ho inserito il nome del database, l utente e la password

Esegui lo script di installazione
cp -r wordpress/* /var/www/html/

Usa I files di Apache per fare funzionare I permalinks(url permanenti) di Wordpress
sudo nano /etc/httpd/conf/httpd.conf   e configura   AllowOverride None a  AllowOverride ALL.

Installa PHP server-side programming language
sudo dnf install php-gd
dnf list | grep php
sudo dnf install -y php8.1-gd

Concedi file di proprieta’ ad Apache server
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0644 {} \;

Installa WordPress on Amazon Linux 2023
sudo systemctl enable httpd && sudo systemctl enable mariadb
sudo chkconfig httpd on && sudo chkconfig mysqld on
sudo service mysqld start
sudo service httpd start







