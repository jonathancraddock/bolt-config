# Testing Bolt on a local VM

This document is a series of notes and config made while testing Bolt on a local VM. I'd previously always used the so called "flattened" installation process, but would perfer to use "composer". These are some draft notes for my future reference.

## VM Basic Setup

New VM, 1 cpu, 512mb, 20gb SSD. Install Ubuntu 16 with usual defaults.

LAMP, Standard Utils, OpenSSH. Named it "bolttest" in DNS. Reboot. Test in browser. Setup PuTTY. Connect and run an apt-get update / upgrade.

May require one or both of the following:

```
sudo usermod -aG sudo jonathan
sudo usermod -aG www-data jonathan
```

## Install composer

Based on: https://getcomposer.org/download/  
And: https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx

```
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

php composer-setup.php

php -r "unlink('composer-setup.php');"

sudo mv composer.phar /usr/local/bin/composer
```

Composer will now run globally.

## Bolt Prerequisites

Some additional PHP and Sqlite modules:

```
sudo apt-get update
sudo apt-get install php libapache2-mod-php php-mcrypt php-sqlite3 php-gd php-curl
sudo apt-get install php-pdo php-gmp php-json php-mbstring php-posix php-xml php-fileinfo php-exif
sudo apt-get install php7.0-zip
```

Modify `dir.conf` to look for PHP files first:

```
sudo nano /etc/apache2/mods-enabled/dir.conf
```

Enable Apache rewrite:

```
sudo a2enmod rewrite
```

Point Apache at the `bolt/public` folder:

```
cd /etc/apache2/sites-available

DocumentRoot /var/www/bolt/public
<Directory "/var/www/bolt/public">
  AllowOverride All
</Directory>
```

Add an Apache server name IP address:

```
sudo nano /etc/apache2/apache2.conf
```

Add near the end of the file:

```
# Adding a ServerName directive, use IP address
ServerName xx.xx.xx.xx
```

Restart Apache and check config:

```
sudo systemctl restart apache2
sudo apache2ctl configtest
```

(There's warning that the "bolt" sub-folder does not exist yet.)

## Install Bolt

Based on: https://docs.bolt.cm/3.3/installation/quick-install

Create a `bolt` sub-folder under `/var/www/...`

```
sudo mkdir /var/www/bolt
cd /var/www
sudo chown www-data:www-data -R bolt
sudo chmod 775 -R bolt
cd bolt
```

^-- ***UPDATE - This is not correct, trying the permissions below:***

```
sudo mkdir /var/www/bolt
cd /var/www
sudo chown jonathan:www-data -R bolt
find . -type d -exec sudo chmod 0755 {} \;
find . -type f -exec sudo chmod 0644 {} \;
cd bolt
```

## Install Bolt using "quick install":

```
curl -O https://bolt.cm/distribution/bolt-latest.tar.gz
tar -xzf bolt-latest.tar.gz --strip-components=1
php app/nut init
```

In this example:

```
Welcome to Bolt! - version 3.3.6.
```

Set permissions:
Create a script, eg/ `setperm.sh` in bolt folder.

```
for dir in app/cache/ app/database/ public/thumbs/ ; do
  find $dir -type d -print0 | xargs -0 chmod u+rwx,g+rwxs,o+rx-w
  find $dir -type f -print0 | xargs -0 chmod u+rw-x,g+rw-x,o+r-wx > /dev/null 2>&1
done

for dir in app/config/ extensions/ public/extensions/ public/files/ public/theme/ ; do
  find $dir -type d -print0 | xargs -0 chmod u+rwx,g+rwxs,o+rx-w
  find $dir -type f -print0 | xargs -0 chmod u+rw-x,g+rw-x,o+r-wx > /dev/null 2>&1
done
```

Save it and run as follows:

```
sudo sh ./setperm.sh
```

Reset ownership of Bolt folders:

```
cd /var/www
sudo chown www-data:www-data -R bolt
```

^- Don't...!

Test in a browser:

You should be taken straight to the "firstuser" setup wizard.

## Upgrade with Composer

Rename the `.dist` distribution file.s

```
cd /var/www/bolt
sudo mv composer.json.dist composer.json
sudo mv composer.lock.dist composer.lock
```

Then run with:

```
composer update
```
