## Some notes on Bolt Base-2018 them

The Base-2018 theme is a nice looking default template. The following are some notes and memory jogs for future reference.

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

### Footer

Noticed that the "footer" does not stick to the bottom of the page when there is insufficient content to push it down. The solution suggested here appears to work well: https://philipwalton.github.io/solved-by-flexbox/demos/sticky-footer/

Incorporated this apprach in: /partials/_master.twig


