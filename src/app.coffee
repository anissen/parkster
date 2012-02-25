
port = Number(process.env.PORT or 3000)
require('zappa') port, ->
  mongoose = require 'mongoose'
  mongoose.connect 'mongodb://localhost/test'

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

  @post '/parking/:id/:lat/:lng/': ->
    @saveParking @params.lat, @params.lng, @params.id

  @get '/parking/:lat/:lng/': ->
    lat = @params.lat
    lng = @params.lng
    @getParkings lat, lng

  @helper getParkings: (lat, lng, searchRadius = 0.3) ->
    ParkingModel
      .where('lat').gte(lat - searchRadius)
      .where('lat').lte(lat + searchRadius)
      .where('lng').gte(lng - searchRadius)
      .where('lng').lte(lng + searchRadius)
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
      mapMarkers.push marker

    clearMarkers = () =>
      for marker in mapMarkers
        marker.setMap null
      mapMarkers = []

    setMapType = (type) =>
      mapType = type

    initializeMaps = () =>
      mapOptions = 
        center: new google.maps.LatLng 55.716667, 12.566667 # Copenhagen
        zoom: 6
        mapTypeId: google.maps.MapTypeId.ROADMAP
      window.parkmap = map = new google.maps.Map document.getElementById('map_canvas'), mapOptions

      google.maps.event.addListener map, 'click', (event) => 
        lat = event.latLng.lat()
        lng = event.latLng.lng()
        switch mapType
          when 'menu-add-parking'
            addMarker lat, lng
            @emit marker: {lat: lat, lng: lng}          
          when 'menu-search-parking'
            clearMarkers()
            @emit search: {lat: lat, lng: lng}

    $ =>
      initializeMaps()
      $('a[data-toggle="tab"]').bind('click', ((event) ->
        tab = $(this)
        event.preventDefault()
        $('a[data-toggle="tab"]').closest('li').removeClass 'active'
        tab.closest('li').addClass 'active'
        setMapType tab.attr('id')
      ))
