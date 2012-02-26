
port = Number(process.env.PORT or 3000)
require('zappa') port, ->
  mongoose = require 'mongoose'
  databaseConnectionString = process.env.PARKSTER_MONGODB_CONNECTION_STRING or 'mongodb://localhost/test'
  mongoose.connect databaseConnectionString

  console.log 'Database string: ' + databaseConnectionString

  #@set 'log level', 1 # disable socket.io info type logs

  # Declare schema for model
  Schema = mongoose.Schema
  ParkingSchema = new Schema
    lat     : Number
    lng     : Number
    date    : Date
    user    : String
    comment : String

  ParkingModel = mongoose.model 'parkings', ParkingSchema

  @enable 'serve jquery'

  @stylus '/stylesheets/style.css': '''
    body
      padding-top 20px
      background url('http://icanhasnoise.com/254768/200x200/6') repeat
    '''
  
  @get '/': ->
    @render 'index'

  @post '/parking/:lat/:lng/': ->
    @saveParking @params.lat, @params.lng

  @get '/parking/:lat/:lng/': ->
    lat = @params.lat
    lng = @params.lng
    @getParkings lat, lng

  @get '/parking/:lat/:lng/:latRadius/:lngRadius/': ->
    lat = @params.lat
    lng = @params.lng
    latRadius = @params.latRadius
    lngRadius = @params.lngRadius
    @getParkings lat, lng, latRadius, lngRadius

  @helper getParkings: (lat, lng, latSearchRadius = 0.2, lngSearchRadius = 0.4) ->
    ParkingModel
      .where('lat').gte(lat - latSearchRadius)
      .where('lat').lte(lat + latSearchRadius)
      .where('lng').gte(lng - lngSearchRadius)
      .where('lng').lte(lng + lngSearchRadius)
      .run @emitMarkers

  @helper emitMarkers: (err, docs) ->
    @emit markers: {markers: docs}

  @helper saveParking: (lat, lng, user = 'Anonymous', comment = 'No comment') ->
    parkingModel          = new ParkingModel
    parkingModel.user     = user
    parkingModel.lat      = lat
    parkingModel.lng      = lng
    parkingModel.date     = new Date()
    parkingModel.comment  = "No comment"

    parkingModel.save ((err) -> 
      if !err
        console.log 'Parking registered successfully'
      else 
        console.log 'Failed to registered parking'
    )

  @on connection: ->
    ParkingModel.find {}, @emitMarkers

  @on search: ->
    lat = @data.lat
    lng = @data.lng
    @getParkings lat, lng

  @on marker: ->
    @saveParking @data.lat, @data.lng
    @broadcast marker: {lat: @data.lat, lng: @data.lng}



  # -------------- CLIENT -----------------

  @client '/index.js': ->
    mapMarkers = []
    mapType = 'menu-add-parking'
    searchRectangle = null
    infoWindow = null

    @connect()

    @on markers: ->
      if @data.markers
        for mark in @data.markers
          addMarker mark.lat, mark.lng

    @on marker: ->
      if @data
        addMarker @data.lat, @data.lng

    addMarker = (lat, lng) => 
      marker = new google.maps.Marker
        position: new google.maps.LatLng lat, lng
        map: window.parkmap
        animation: google.maps.Animation.DROP
        title: 'Parking'
        content: 'Parking at ' + lat + ', ' + lng
      google.maps.event.addListener marker, 'click', onMarkerClick
      mapMarkers.push marker

    clearMarkers = () =>
      for marker in mapMarkers
        marker.setMap null
      mapMarkers = []

    setMapType = (type) =>
      mapType = type

    onMarkerClick = () ->
      marker = this
      infoWindow.setContent '<h3>Parking</h3>' + marker.content

      infoWindow.open window.parkmap, marker

    addMarkerTool = (lat, lng) =>
      searchRectangle.map = null
      addMarker lat, lng
      @emit marker: {lat: lat, lng: lng}  

    searchTool = (lat, lng) =>
      clearMarkers()
      latSearchRadius = 0.2
      lngSearchRadius = 0.4
      
      # Get the current bounds, which reflect the bounds before the zoom.
      rectOptions =
        strokeColor: "#FF0000"
        strokeOpacity: 0.8
        strokeWeight: 2
        fillColor: "#FF0000"
        fillOpacity: 0.35
        map: window.parkmap
        bounds: new google.maps.LatLngBounds(
          new google.maps.LatLng(lat - latSearchRadius, lng - lngSearchRadius), 
          new google.maps.LatLng(lat + latSearchRadius, lng + lngSearchRadius))
      
      searchRectangle.setOptions rectOptions

      @emit search: {lat: lat, lng: lng}

    initializeMaps = () =>
      mapOptions = 
        center: new google.maps.LatLng 56.5, 11.5
        zoom: 7
        mapTypeId: google.maps.MapTypeId.ROADMAP
      window.parkmap = map = new google.maps.Map document.getElementById('map_canvas'), mapOptions

      searchRectangle = new google.maps.Rectangle()

      infoWindow = new google.maps.InfoWindow()

      google.maps.event.addListener map, 'click', (event) => 
        lat = event.latLng.lat()
        lng = event.latLng.lng()
        infoWindow.close()
        switch mapType
          when 'menu-add-parking'
            addMarkerTool lat, lng        
          when 'menu-search-parking'
            searchTool lat, lng

    $ =>
      initializeMaps()
      $('a[data-toggle="tab"]').bind('click', ((event) ->
        tab = $(this)
        event.preventDefault()
        $('a[data-toggle="tab"]').closest('li').removeClass 'active'
        tab.closest('li').addClass 'active'
        setMapType tab.attr('id')
      ))
