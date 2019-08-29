# geohash-abap
Geohash utitlies in ABAP


## Encoding
    data(hash) = zcl_geohash=>encode_geo_hash(
      i_longitude = '116.402843'
      i_latitude  = '39.999375'
      i_length    = 11
    ).
Default value of i_length is 8.

## Decoding
    zcl_geohash=>decode_geo_hash(
      exporting
        i_geo_hash = hash
      importing
        e_longitude = data(longitude)
        e_latitude  = data(latitude)
    ).
