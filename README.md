# geohash-abap
Geohash utitlies in ABAP

ABAP Version: 740 or higher

## Encoding
    data(hash) = zcl_geohash=>encode(
      longitude = '119.9314500000'
      latitude  = '28.4751600000'
      length    = 11
    ).
Default value of length is 8.

## Decoding
    zcl_geohash=>decode(
      exporting
        geohash   = hash
      importing
        longitude = data(longitude)
        latitude  = data(latitude)
    ).
## Neighbors
    data(neighbors) = zcl_geohash=>neighbors( 'wtj3cper' ).
## TODO
- [x] Get neighbors.
- [ ] Unit testing.
- [ ] Distance.
- [ ] Hash validation.
