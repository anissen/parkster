port = Number(process.env.PORT or 3000)
require('zappa') port, ->
  # MongoDB Setup
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

  @get '/:id/:lat/:lng/': ->
    saveParking @params.lat, @params.lng, @params.id

  saveParking = (lat, lng, user = 'Anonymous', comment = 'No comment') ->
    parkingModel          = new ParkingModel
    parkingModel.user     = user
    parkingModel.lat      = lat
    parkingModel.lng      = lng
    parkingModel.date     = new Date()
    parkingModel.comment  = "No comment"

    parkingModel.save ((err) => 
      if !err
        console.log 'Parking registered successfully'
      else 
        console.log 'Failed to registered parking'
    )

  @on connection: ->
    ParkingModel.find {}, (err, docs) =>
      @emit markers: {markers: docs}

  @on marker: ->
    saveParking @data.lat, @data.lng
    @broadcast marker: {lat: @data.lat, lng: @data.lng}

  @client '/index.js': ->
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

    initializeMaps = () =>
      mapOptions = 
        center: new google.maps.LatLng 55.716667, 12.566667 # Copenhagen
        zoom: 6
        mapTypeId: google.maps.MapTypeId.ROADMAP
      window.parkmap = map = new google.maps.Map document.getElementById('map_canvas'), mapOptions

      google.maps.event.addListener map, 'click', (event) => 
        lat = event.latLng.lat()
        lng = event.latLng.lng()
        addMarker lat, lng
        @emit marker: {lat: lat, lng: lng}

    $ =>
      initializeMaps()      