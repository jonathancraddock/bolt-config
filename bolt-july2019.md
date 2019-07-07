## LOG

VM running Ubuntu 18.04 LTS and Apache. (Also has a NodeRED install via an Apache reverse proxy.)

Need to add PHP. Following suggestions in this guide:
https://www.linuxbabe.com/ubuntu/install-lamp-stack-ubuntu-18-04-server-desktop

```bash
sudo apt install php7.2 libapache2-mod-php7.2 php7.2-mysql php-common php7.2-cli php7.2-common php7.2-json php7.2-opcache php7.2-readline

sudo a2enmod php7.2

sudo systemctl restart apache2
```

## Install composer

```bash
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

sudo php composer-setup.php
```

^-- note that earlier NodeRED install created a .config folder with very restricted permissions, hence the sudo, but I'd be concerned this may cause problems later. Reset ownwership of ~/.composer folder.

```bash
sudo chown jonathan:jonathan -R ~/.composer
sudo chmod 744 -R ~/.composer
```

To enable composer to run globally:

```bash
sudo mv composer.phar /usr/local/bin/composer

composer -V
```
^- *Note the UPPER-case "V" because a lower-case "v" is rather more verbose...*

## PHP Dependencies

Bolt has the following PHP prerequisites, and I've highlighted the ones that don't appear to be installed by default on my 18.04 VM.

```php
<?php
  phpinfo(INFO_MODULES);
?>
```
^- *A simple PHP script will show what's currently enabled.*

* pdo
* mysqlnd (to use MySQL as a database)
* pgsql (to use PostgreSQL as a database)
* openssl
* **curl**
* **gd**
* **intl** (optional but recommended)
* json
* **mbstring** (optional but recommended)
* **opcache** (optional but recommended)
* posix
* **xml**
* fileinfo
* exif
* **zip**

```bash
sudo apt-get update
sudo apt-get install php7.2-curl php7.2-gd php7.2-intl php7.2-mbstring php7.2-opcache php7.2-xml php7.2-zip

sudo apt-get install sqlite3
sudo apt-get install php7.2-sqlite3

cd /etc/php/7.2/apache2
sudo nano php.ini
```
^- *Later in install process, realised SQLite was missed...*

Uncomment the following lines in php.ini

```bash
extension=curl
extension=fileinfo
extension=gd2
...
extension=mbstring
extension=exif
...
extension=openssl
...
extension=pdo_sqlite
...
extension=sqlite3
```

Restart Apache.

`sudo systemctl restart apache2`

## New Bolt Project / Update with Composer

Navigate to "parent" folder, in this case:

`cd /var/www`

Create a folder with appropriate permissions:

```bash
sudo mkdir /var/www/bolt
sudo chown jonathan:www-data -R bolt
find . -type d -exec sudo chmod 0755 {} \;
find . -type f -exec sudo chmod 0644 {} \;
cd bolt
```

Next, carry out a "quick install".

```bash
curl -O https://bolt.cm/distribution/bolt-latest.tar.gz
tar -xzf bolt-latest.tar.gz --strip-components=1
php app/nut init

$ Welcome to Bolt! - version 3.6.9.
```

Create a `setperm.sh` permissions script in the bolt folder:

`nano setperm.sh`

```bash
cd /var/www/bolt

for dir in app/cache/ app/database/ public/thumbs/ ; do
  find $dir -type d -print0 | xargs -0 chmod u+rwx,g+rwxs,o+rx-w
  find $dir -type f -print0 | xargs -0 chmod u+rw-x,g+rw-x,o+r-wx > /dev/null 2>&1
done

for dir in app/config/ extensions/ public/extensions/ public/files/ public/theme/ ; do
  find $dir -type d -print0 | xargs -0 chmod u+rwx,g+rwxs,o+rx-w
  find $dir -type f -print0 | xargs -0 chmod u+rw-x,g+rw-x,o+r-wx > /dev/null 2>&1
done

cd /var/www
sudo chown jonathan:www-data -R bolt
```

FOOTNOTE:
Composer appears to be failing without a swapfile:

```bash
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1
sudo chmod 0600 /var/swap.1
```
  
Update Bolt install with composer:

```bash
composer update
```

## Create a virtual host:

Modify `dir.conf` to look for `PHP` files first:

```
sudo nano /etc/apache2/mods-enabled/dir.conf
```

Enable Apache rewrite:

```bash
sudo a2enmod rewrite
```

Edit a new virtual host.

```bash
cd /etc/apache2/sites-available
sudo nano bolt.conf
```

Point Apache at the `bolt/public` folder:

```bash
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName bolt.example.com

        DocumentRoot /var/www/bolt/public

        <Directory "/var/www/bolt/public">
          AllowOverride All
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Test the config, enable the site and restart Apache:

```bash
sudo apache2ctl configtest
sudo a2ensite bolt.conf
sudo systemctl restart apache2
```

At this stage it should be possible to (insecurely) access the Bolt welcome wizard.




