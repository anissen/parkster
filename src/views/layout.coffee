doctype 5
html ->
  head ->
    title 'Parkster'
    #description 'Accessable parking made easy'
    #author 'Anders Nissen'

    ###
    <!-- HTML5 shim, for IE6-8 support of HTML elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
    ###

    # scripts
    #script src: 'https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.js'
    script src: '/socket.io/socket.io.js'
    script src: '/zappa/jquery.js'
    script src: '/zappa/zappa.js'
    script src: 'http://maps.googleapis.com/maps/api/js?key=&sensor=true'
    script src: '/index.js'

    # styles
    link rel: 'stylesheet', href: 'http://twitter.github.com/bootstrap/assets/css/bootstrap.css'
    link rel: 'stylesheet', href: 'http://twitter.github.com/bootstrap/assets/css/bootstrap-responsive.css'
    link rel: 'stylesheet', href: '/stylesheets/style.css'

    # fav and touch icons
    #link rel: 'shortcut icon', href: 'http://twitter.github.com/bootstrap/examples/images/favicon.ico'
    #link rel: 'apple-touch-icon', href: 'http://twitter.github.com/bootstrap/examples/images/apple-touch-icon.png'
    #link rel: 'apple-touch-icon', sizes: '72x72', href: 'http://twitter.github.com/bootstrap/examples/images/apple-touch-icon-72x72.png'
    #link rel: 'apple-touch-icon', sizes: '114x114', href: 'http://twitter.github.com/bootstrap/examples/images/apple-touch-icon-114x114.png'

  body ->
    div class: 'container', ->
      # main hero unit for a primary marketing message or call to action
      div class: 'hero-unit', ->
        h1 'Parkster'
        p 'Placeholder'
        @body

    #script src: 'http://twitter.github.com/bootstrap/assets/js/bootstrap-tab.js'