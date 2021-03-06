## Some notes on Bolt Base-2018 theme

The Base-2018 theme is a nice looking default template. The following are some notes and memory jogs for future reference.

#### Links

* Bulma (flexbox css framework) - https://bulma.io/
* Twig (template engine) - https://twig.symfony.com/doc/2.x/
* Bolt (docs) - https://docs.bolt.cm/3.6/getting-started/introduction
* Font Awesome (icons) - https://fontawesome.com/

### Wireframes

There's a set of wireframes available under: File Management... View Edit Templates.

### About Us

The "Aside" on the homepage features an "about" block. The title can be anything, but ensure the unique alias is set to "about-us".

### Hero

Opening the homepage you're greeted with "A Sample Site, The amazing payoff goes here". This legend comes from: Configuration... Main configuration. The "sitename" value will also be added to the left-side of the Navbar.

The hero background image is the image associated with the "homepage" page. (In its "large" homepage size, it appears to be 615px tall?)

### Navbar Menu

Menu is configured in a YAML file: Configuration... Menu set up. 

```yaml
main:
    - label: Home
      title: This is the first menu item.
      path: homepage
      class: first
    - label: Articles
      path: entry/1
      submenu:
          - label: Recipes
            path: entry/2
          - label: Evil Plans
            title: Not to be disclosed!
            class: menu-item-class
            path: entry/3
```

Menu in page footer is inserted differently, as follows:

```twig
            <div class="level-right">
                {{ menu(
                    identifier = 'main',
                    template = 'partials/_sub_menu_footer.twig',
                    params = {'withsubmenus': false}
                ) }}
            </div>
```

It's the same as the navbar menu, but the dropdown is removed from the second menu item.

See: https://docs.bolt.cm/configuration/menus

Annoyingly, the `is-fixed-top` property of the navbar stops the hamburger menu from scrolling and with half a dozen entries the default Android keyboard obscures the search box.

Experimenting with a simple jQuery function, below. Gave the navbar and burger an id.

```html
<nav id="navbar" class="navbar is-fixed-top is-primary" role="navigation" aria-label="main navigation">
...
<span id="hamburger" class="navbar-burger" data-target="navbar-toggle">
```

And use the following Javascript/jQuery to allow the navbar to scroll off the screen when the hamburger menu is open. The `scrollTop` feels like a bit of a compromise, but required to avoid a manual scroll after opening the menu.

```javascript
$(document).ready(function() {

// Un-fix navbar when burger menu is open
  $('#hamburger').click(function() {
    if ( $('#navbar').hasClass('is-fixed-top') ) {
      $('html, body').animate({ scrollTop: 0 }, 'fast');
      $('#navbar').removeClass('is-fixed-top');
    } else {
      $('#navbar').addClass('is-fixed-top');
    };    
  });

});
```

### Footer

Noticed that the "footer" does not stick to the bottom of the page when there is insufficient content to push it down. The solution suggested here appears to work well: https://philipwalton.github.io/solved-by-flexbox/demos/sticky-footer/

Incorporated their apprach in `/partials/_master.twig` and added the following CSS to `/css/theme.css`.

```css
/* Push footer to bottom of window if content less than full height */
.Site { display: flex; min-height: 100vh; flex-direction: column; }
.Site-content { flex: 1; }
```

### Linking to CSS and JS

Example (highlight.js) of linking to CSS and JS assets from Twig template.

```html
<link rel="stylesheet" href="{{ asset('css/solarized-light.css', 'theme') }}">
<script src="{{ asset('js/highlight.pack.js', 'theme') }}"></script>
```

Didn't like the width of the grey border around the pre-formatted code, so added this:

```css
/* Reduce grey border on highlight.js code blocks */
.content pre {
    padding: 1px;
}
```

### Launch a full-size image into a Modal

Experimental - but I think it could be useful. The scenario is that you place various (multiple) "thumbnail" images into the text of a Bolt entry, page, etc. Give the thumbnail a class of `popimg`. A jQuery function launches the full image into a Modal if the thumbnail is clicked.

```javascript
// Open the "full" image of a thumbnail inside a modal
  $('.popimg').click(function() {
    var sourceImg = $(this).attr("src");
    var modalImg = "/files"+sourceImg.substr(sourceImg.indexOf("c/")+1);
    $('img#modalsrc').attr("src",modalImg);
    $('div.modal').addClass('is-active');
  });
```

A simple CSS edit give the pointer its usual (finger) behaviour.

```css
/* Treat any image of class 'popimg' as if it were a link */
img.popimg {
    cursor: pointer;
}
```

And the empty modal is place directly beneath the `content` DIV in `index.twig`.

```html
<div class="content">
                    
<div class="modal">
  <div class="modal-background"></div>
    <div class="modal-content">
      <p class="image is-4by3">
        <img id="modalsrc" src="" alt="">
      </p>
    </div>
  <button class="modal-close is-large" aria-label="close"></button>
</div>
```

The string has to be manipulated slightly to substitute `/thumbs/200x125c/` with the path `/files/`. The pixel dimensions will often be different, but it will always end with a `c/`.

Hence...  
`<p><img alt="" class="popimg" src="/thumbs/200x125c/2019-07/allyourbasecats.jpg" /></p>`  
...will launch as...  
`/files/2019-07/allyourbasecats.jpg`.
