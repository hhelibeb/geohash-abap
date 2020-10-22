# geohash-abap
Geohash utitlies in ABAP

ABAP Version: 740 or higher

## Sample
### Encoding
```abap
    data(hash) = zcl_geohash=>encode(
      longitude = '119.9314500000'
      latitude  = '28.4751600000'
      length    = 11
    ).
```    
Default value of length is 8.

### Decoding
```abap
    zcl_geohash=>decode(
      exporting
        geohash   = 'wtj3cper'
      importing
        longitude = data(longitude)
        latitude  = data(latitude)
    ).
```    
### Neighbors
```abap
    data(neighbors) = zcl_geohash=>neighbors( 'wtj3cper' ).
```        
### Hash Validation
```abap
    data(valid) = zcl_geohash=>validate( 'wtj3cper' ).
```
## TODO
- [x] Get neighbors.
- [x] Unit testing.
- [x] Hash validation.
- [ ] Class split.

