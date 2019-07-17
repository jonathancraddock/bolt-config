## Creating "Friendly" Outbound Product Links

Scenario: embed neat looking product links into a Bolt site, eg/ example.com/product/0451231899, that call a PHP script to handle the client's geographic location, potentially add in any affiliate codes, and then redirect to an online store in their territory. Such that a link such as the example above could redirect to:

* US https://www.amazon.com/dp/0307949486 (North America)
* GB https://www.amazon.co.uk/dp/0307949486 (England)
* IN https://www.amazon.in/dp/0307949486 (India)
* JP https://www.amazon.co.jp/dp/0307949486 (Japan)

Every link is "The Girl with the Dragon Tattoo", in four different regions.

### /links/.htaccess

Seemed better to leave Bolt's own `.htaccess` file alone and create a new one in a subfolder. I'm testing with a subfolder `./public/links`.

```bash
# .htaccess in a Bolt subfolder, "./public/links"

# Enable rewrites
RewriteEngine on

# Take URL "/links/n" and send "n" to a PHP script in same folder
RewriteRule ^([0-9]+) locale.php?prod=$1 [L]

# For any URL not matching the format above, send it to a 404 page
RewriteCond %{QUERY_STRING} !prod=
RewriteRule ^(.*) /404 [QSA,L]
```

I believe the rewrite rules are reprocessed with every change, and was initially frustrated by my "catch-all" rule killing the rule above because it caught every URL as soon as it was rewritten. Introducing the rewrite condition and searching for the "prod" query appears to have sorted that out. The catch-all now only applies to un-rewritten URLs.

### /links/locale.php

> Still a work in progress...

Currently this script is simply echo'ing some info back to the browser. Initially, gather some info:

```php
$userip = clientip();
$locale = file_get_contents('https://your.api.com/geo?ip='.$userip);
$product = $_GET["prod"];
```

The function `clientip()` is one I've used before and appears to be fairly reliable. I've written my own API in Node-Red to return me a two letter country code for any IP address. There are plenty available, but here are two free-ish examples:

* https://ipinfodb.com/api allows 2 queries per second on their free tier.
* https://ipinfo.io/ allows 1000 queries per day on their demo tier.

The client location should be written to a cookie and re-read, to reduce the number/frequency of API calls.

```php
function clientip()
{
    if (!empty($_SERVER['HTTP_CLIENT_IP']))
    {
      $ip=$_SERVER['HTTP_CLIENT_IP'];
    }
    elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))
    {
      $ip=$_SERVER['HTTP_X_FORWARDED_FOR'];
    }
    else
    {
      $ip=$_SERVER['REMOTE_ADDR'];
    }
    return $ip;
}
```

Having obtained the client's IP, and looked up the geographic location (which will require translating to the domain suffix) and got the product code, some sort of redirect is presumably required:

```php
header("Location: https://www.amazon.".$suffix."/dp/".$prod);
die();
```

It's obviously slightly more complicated than this. Not all Amazon "/dp" references are numeric, for example. (Merely a proof of concept at this stage.)
