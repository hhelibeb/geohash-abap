*"* use this source file for your ABAP unit test classes

class ltc_geohash definition final for testing
duration short risk level harmless.

  private section.

    types: begin of ty_geohash,
             latitude  type zcl_geohash=>ty_tude,
             longitude type zcl_geohash=>ty_tude,
             hash      type string,
           end of ty_geohash.
    types: ty_geohash_t type standard table of ty_geohash with empty key.

    types: begin of ty_validation,
             hash  type string,
             valid type abap_bool,
           end of ty_validation.
    types: ty_validaton_t type standard table of ty_validation with empty key.

    types: begin of ty_neighbors,
             hash      type string,
             neighbors type zcl_geohash=>ty_hash_t,
           end of ty_neighbors.

    types: ty_neighbors_t type standard table of ty_neighbors with empty key.

    methods: setup.

    methods: encode_test for testing.
    methods: decode_test for testing.
    methods: validate_test for testing.
    methods: neighbors_test for testing.


endclass.

class ltc_geohash implementation.

  method setup.

  endmethod.

  method encode_test.

    data: encode_test_data type ty_geohash_t.

    encode_test_data = value #(
      ( hash = 'sb54v4xk18jg' latitude = '0.497818518'  longitude = '38.19850525'  )
      ( hash = '00upjeyjb54g' latitude = '-84.52917818' longitude = '-174.1250573' )
      ( hash = 'kkfwu0udnhxk' latitude = '-17.09023839' longitude = '14.94785328'  )
      ( hash = 'gp2cx4ywjhyj' latitude = '86.06108453'  longitude = '-43.62854601' )
      ( hash = 'h0g4tmrp0cut' latitude = '-85.31174589' longitude = '4.459114168'  )
      ( hash = 'v471duxnbttv' latitude = '57.94583029'  longitude = '49.34924197'  )
      ( hash = 'h78n33z47k3j' latitude = '-69.20384412' longitude = '11.31468581'  )
      ( hash = 'gvtw7yer4bhh' latitude = '77.07304075'  longitude = '-3.346243298' )
      ( hash = '0fqwy0pgxxwj' latitude = '-76.15658458' longitude = '-136.8347301' )
      ( hash = 'dj53wuppzfrx' latitude = '28.41198826'  longitude = '-85.12310079' )
    ).

    loop at encode_test_data assigning field-symbol(<test_data>).

      data(result) = zcl_geohash=>encode(
                       latitude  = <test_data>-latitude
                       longitude = <test_data>-longitude
                       length    = 12
                     ).
      cl_aunit_assert=>assert_equals(
        act = result
        exp = <test_data>-hash
        msg = 'result:' && result && '<>' && <test_data>-hash
      ).
    endloop.

  endmethod.

  method decode_test.

    data: decode_test_data type ty_geohash_t.

    decode_test_data = value #(
     ( hash = 'sb54v4xk18jg' latitude = '0.49781858'   longitude = '38.19850517'  )
     ( hash = '7zzzzzzz'     latitude = '-0.00008583'  longitude = '-0.00017166'  )
     ( hash = 'jfztj3cper'   latitude = '-73.64140302' longitude = '89.52910602'  )
     ( hash = '9xzwj4trc'    latitude = '44.66352224'  longitude = '-101.72612429'  )
    ).

    loop at decode_test_data assigning field-symbol(<test_data>)..
      zcl_geohash=>decode(
         exporting
           geohash = <test_data>-hash
         importing
           latitude  = data(latitude)
           longitude = data(longitude)
      ).
      cl_aunit_assert=>assert_equals(
        act = latitude
        exp = <test_data>-latitude
        msg = 'latitude:' && latitude && '<>' && <test_data>-latitude
      ).
      cl_aunit_assert=>assert_equals(
        act = longitude
        exp = <test_data>-longitude
        msg = 'longitude:' && longitude && '<>' && <test_data>-longitude
      ).
    endloop.

  endmethod.

  method validate_test.

    data: validate_test_data type ty_validaton_t.

    validate_test_data = value #(
      ( hash = 'sb54v4xk18jg'    valid = abap_true )
      ( hash = '00upjeyjb54g'    valid = abap_true )
      ( hash = 'kkfwu0udnhxk'    valid = abap_true )
      ( hash = 'gp2cx4ywjhyj'    valid = abap_true )
      ( hash = 'h0g4tmrp0cut'    valid = abap_true )
      ( hash = 'v471duxnbttv'    valid = abap_true )
      ( hash = 'h78n33z47k3j'    valid = abap_true )
      ( hash = 'H78N33Z47K3J'    valid = abap_true )
      ( hash = 'gvtw7yer4bhh'    valid = abap_true )
      ( hash = 'GVTW7YER4BHH'    valid = abap_true )
      ( hash = '0fqwy0pgxxwj'    valid = abap_true )
      ( hash = '0FQWY0PGXXWJ'    valid = abap_true )
      ( hash = 'dj53wuppzfrx'    valid = abap_true )
      ( hash = 'dj53wuppzfrxzz'  valid = abap_false )
      ( hash = 'dj53wuppzfrx1'   valid = abap_false )
      ( hash = 'a3zs'            valid = abap_false )
      ( hash = 'ccc[]'           valid = abap_false )
      ( hash = '%sl3'            valid = abap_false )
      ( hash = 'leftxxzzc'       valid = abap_false )
      ( hash = 'ics123'          valid = abap_false )
      ( hash = 'IcS123'          valid = abap_false )
      ( hash = 'omthxxxqls'      valid = abap_false )
      ( hash = '\7zzzzz'         valid = abap_false )
    ).

    loop at validate_test_data assigning field-symbol(<test_data>).
      data(result) = zcl_geohash=>validate( <test_data>-hash ).
      cl_aunit_assert=>assert_equals(
        act = result
        exp = <test_data>-valid
        msg = 'valid:' && result && '<>' && <test_data>-valid
    ).
    endloop.

  endmethod.

  method neighbors_test.

    data: neighbors_test_data type ty_neighbors_t.

    neighbors_test_data = value #(
      ( hash = 'wx4g' neighbors = value #(
                        ( hash = 'wx4e' )
                        ( hash = 'wx4s' )
                        ( hash = 'wx4u' )
                        ( hash = 'wx4d' )
                        ( hash = 'wx4f' )
                        ( hash = 'wx5h' )
                        ( hash = 'wx55' )
                        ( hash = 'wx54' )
                      )
      )
      ( hash = 'wxfzbxvr' neighbors = value #(
                        ( hash = 'y84b08j2' )
                        ( hash = 'wxfzbxvq' )
                        ( hash = 'wxfzbxvx' )
                        ( hash = 'wxfzbxvp' )
                        ( hash = 'y84b08j8' )
                        ( hash = 'y84b08j0' )
                        ( hash = 'wxfzbxvw' )
                        ( hash = 'wxfzbxvn' )
                      )
      )
      ( hash = 'y84b08j2' neighbors = value #(
                        ( hash = 'y84b08j3' )
                        ( hash = 'y84b08j8' )
                        ( hash = 'wxfzbxvr' )
                        ( hash = 'y84b08j0' )
                        ( hash = 'y84b08j9' )
                        ( hash = 'y84b08j1' )
                        ( hash = 'wxfzbxvx' )
                        ( hash = 'wxfzbxvp' )
                      )
      )
      ( hash = 'ezs42' neighbors = value #(
                        ( hash = 'ezefr' )
                        ( hash = 'ezs43' )
                        ( hash = 'ezefx' )
                        ( hash = 'ezs48' )
                        ( hash = 'ezs49' )
                        ( hash = 'ezefp' )
                        ( hash = 'ezs40' )
                        ( hash = 'ezs41' )
                      )
      )
    ).

    LOOP AT neighbors_test_data ASSIGNING FIELD-SYMBOL(<test_data>).

      DATA(result) = zcl_geohash=>neighbors( <test_data>-hash ).

      sort: result by hash,
            <test_data>-neighbors by hash.

      DO lines( <test_data>-neighbors ) TIMES.

        DATA(result_hash) = value #( result[ sy-index ]-hash OPTIONAL ).
        DATA(expect_hash) = value #( <test_data>-neighbors[ sy-index ]-hash OPTIONAL ).
        cl_aunit_assert=>assert_equals(
          act = result_hash
          exp = expect_hash
          msg = 'hash:' && <test_data>-hash && '. result:' && result_hash && '<>' && expect_hash
        ).
      ENDDO.

    ENDLOOP.

  endmethod.

endclass.
