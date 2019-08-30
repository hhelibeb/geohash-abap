# geohash-abap
Geohash utitlies in ABAP


## Encoding
    data(hash) = zcl_geohash=>encode(
      i_longitude = '119.9314500000'
      i_latitude  = '28.4751600000'
      i_length    = 11
    ).
Default value of i_length is 8.

## Decoding
    zcl_geohash=>decode(
      exporting
        i_geo_hash = hash
      importing
        e_longitude = data(longitude)
        e_latitude  = data(latitude)
    ).
## TODO
* Get neighbors.
* Unit testing.
* Distance.
* Hash validation.
