Parkster
=============

"Parking made easy"

Routes
------

### Create a new parking
POST to

    /parking/latitude/longitude/

e.g.

    /parking/13/52/

### Get parkings
GET from

    /parking/latitude/longitude/
    /parking/latitude/longitude/latitude-radius/longitude-radius/
  
e.g.

    /parking/13/52/
    /parking/13/52/0.2/0.4/

The default value for latitude-radius is 0.2 and 0.4 for longitude-radius.