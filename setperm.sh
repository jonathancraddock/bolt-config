clear
echo Set permissions throughout "Bolt" folder structure.
echo ==================================================

echo
echo Reset default permissions:
echo Takes a couple of minutes...
echo

cd /var/www
sudo chown $USER:www-data -R bolt
find . -type d -exec sudo chmod 0755 {} \;
find . -type f -exec sudo chmod 0644 {} \;

echo
echo Set secure Bolt site permissions:
echo

cd /var/www/bolt
for dir in app/cache/ app/database/ public/thumbs/ ; do
    find $dir -type d -print0 | xargs -0 chmod u+rwx,g+rwxs,o+rx-w
    find $dir -type f -print0 | xargs -0 chmod u+rw-x,g+rw-x,o+r-wx > /dev/null 2>&1
done

echo
echo Set secure back-end permissions:
echo

cd /var/www/bolt
for dir in app/config/ extensions/ public/extensions/ public/files/ public/theme/ ; do
    find $dir -type d -print0 | xargs -0 chmod u+rwx,g+rwxs,o+rx-w
    find $dir -type f -print0 | xargs -0 chmod u+rw-x,g+rw-x,o+r-wx > /dev/null 2>&1
done
