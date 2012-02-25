
div class: 'row', ->
  div class: 'span10', ->
    a class: 'thumbnail', ->
      div id: 'map_canvas', style: 'height: 600px'
div class: 'row', ->
  div class: 'span10 tabbable tabs-below', ->
  	ul class: 'nav nav-tabs', ->
      li class: 'active', ->
        a href: '#addParking', id: 'menu-add-parking', 'data-toggle': "tab", 'Tilføj parkering'
      li ->
        a href: '#searchParking', id: 'menu-search-parking', 'data-toggle': "tab", 'Søg parkering'