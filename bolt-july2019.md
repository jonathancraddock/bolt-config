## LOG

VM running Ubuntu 18.04 LTS and Apache. (Also has a NodeRED install via an Apache reverse proxy.)

Need to add PHP. Following suggestions in this guide:
https://www.linuxbabe.com/ubuntu/install-lamp-stack-ubuntu-18-04-server-desktop

```bash
sudo apt install php7.2 libapache2-mod-php7.2 php7.2-mysql php-common php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-readline

sudo a2enmod php7.2

sudo systemctl restart apache2
```

Install composer.

```bash
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

sudo php composer-setup.php
```

^-- note that earlier NodeRED install created a .config folder with very restricted permissions, hence the sudo.

To enable composer to run globally:

```bash
sudo mv composer.phar /usr/local/bin/composer

composer -V
```