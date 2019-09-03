class zcl_geohash definition
  public
  final
  create public .

  public section.


    types: begin of ty_hash,
             hash type string,
           end of ty_hash.
    types: ty_hash_t type standard table of ty_hash with empty key.

    types:
      ty_tude type p length 16 decimals 12 .

    constants c_max_hash_length type i value 12 ##NO_TEXT.

    class-methods class_constructor .
    class-methods encode
      importing
        !longitude        type ty_tude
        !latitude         type ty_tude
        !length           type i default 8
      returning
        value(r_geo_hash) type string .
    class-methods decode
      importing
        !geohash   type string
      exporting
        !longitude type ty_tude
        !latitude  type ty_tude .

    class-methods neighbors importing geohash          type string
                            returning value(neighbors) type ty_hash_t.

    class-methods validate importing geohash      type string
                           returning value(valid) type abap_bool.

  private section.

    types:
      begin of ty_base32,
        decimals type i,
        base32   type string,
      end of ty_base32 .
    types:
      ty_base32_t1 type hashed table of ty_base32 with unique key decimals .
    types:
      ty_base32_t2 type hashed table of ty_base32 with unique key base32 .

    types: begin of ty_neighbors_odd,
             f1 type string,
             f2 type string,
             f3 type string,
             f4 type string,
             f5 type string,
             f6 type string,
             f7 type string,
             f8 type string,
           end of ty_neighbors_odd.
    types: ty_neighbors_odd_t type standard table of ty_neighbors_odd with empty key.

    types: begin of ty_neighbors_even,
             f1 type string,
             f2 type string,
             f3 type string,
             f4 type string,
           end of ty_neighbors_even.
    types: ty_neighbors_even_t type standard table of ty_neighbors_even with empty key.

    class-data mt_base32_code1 type ty_base32_t1 .
    class-data mt_base32_code2 type ty_base32_t2 .

    class-data mt_neighbors_odd type ty_neighbors_odd_t.
    class-data mt_neighbors_even type ty_neighbors_even_t.

    constants c_longitude_min type ty_tude value '-180.00' ##NO_TEXT.
    constants c_longitude_max type ty_tude value '180.00' ##NO_TEXT.
    constants c_latitude_min type ty_tude value '-90.00' ##NO_TEXT.
    constants c_latitude_max type ty_tude value '90.00' ##NO_TEXT.
    constants c_zero type c value '0' ##NO_TEXT.
    constants c_one type c value '1' ##NO_TEXT.

    class-methods bin_to_dec
      importing
        !i_bin       type string default '0'
      returning
        value(r_dec) type int4 .
    class-methods dec_to_bin
      importing
        !i_dec       type int4
      returning
        value(r_bin) type string .

    class-methods get_bin
      importing
        !i_left  type ty_tude
        !i_right type ty_tude
        !i_tude  type ty_tude
      exporting
        !e_left  type ty_tude
        !e_right type ty_tude
        !e_bin   type char1 .
    class-methods get_tude
      importing
        !i_left  type ty_tude
        !i_right type ty_tude
        !i_bin   type string
      exporting
        !e_left  type ty_tude
        !e_right type ty_tude
        !e_tude  type ty_tude .

    class-methods: get_index importing index          type i
                                       offset         type i
                                       max_index      type i
                             returning value(r_index) type i.
    class-methods: get_code_neighbor importing i_table        type standard table
                                               i_member       type string
                                     returning value(r_table) type ty_hash_t.

endclass.



class zcl_geohash implementation.


  method bin_to_dec.

    if contains( val = i_bin regex = `[^01]` ).
      return.
    endif.

    data(length) = strlen( i_bin ).

    data(l_index) = 0.

    do length times.

      data(temp) = i_bin+l_index(1).

      if temp = 1.
        r_dec = r_dec + 2 ** ( length - l_index - 1 ).
      endif.

      l_index = l_index + 1.

    enddo.

  endmethod.


  method class_constructor.

    mt_base32_code1 = value #(
      ( decimals = 0  base32 = '0' )
      ( decimals = 1  base32 = '1' )
      ( decimals = 2  base32 = '2' )
      ( decimals = 3  base32 = '3' )
      ( decimals = 4  base32 = '4' )
      ( decimals = 5  base32 = '5' )
      ( decimals = 6  base32 = '6' )
      ( decimals = 7  base32 = '7' )
      ( decimals = 8  base32 = '8' )
      ( decimals = 9  base32 = '9' )
      ( decimals = 10 base32 = 'b' )
      ( decimals = 11 base32 = 'c' )
      ( decimals = 12 base32 = 'd' )
      ( decimals = 13 base32 = 'e' )
      ( decimals = 14 base32 = 'f' )
      ( decimals = 15 base32 = 'g' )
      ( decimals = 16 base32 = 'h' )
      ( decimals = 17 base32 = 'j' )
      ( decimals = 18 base32 = 'k' )
      ( decimals = 19 base32 = 'm' )
      ( decimals = 20 base32 = 'n' )
      ( decimals = 21 base32 = 'p' )
      ( decimals = 22 base32 = 'q' )
      ( decimals = 23 base32 = 'r' )
      ( decimals = 24 base32 = 's' )
      ( decimals = 25 base32 = 't' )
      ( decimals = 26 base32 = 'u' )
      ( decimals = 27 base32 = 'v' )
      ( decimals = 28 base32 = 'w' )
      ( decimals = 29 base32 = 'x' )
      ( decimals = 30 base32 = 'y' )
      ( decimals = 31 base32 = 'z' )
    ).

    mt_base32_code2 = mt_base32_code1.

    mt_neighbors_odd = value #(
     (  f1 = 'b' f2 = 'c' f3 = 'f' f4 = 'g' f5 = 'u' f6 = 'v' f7 = 'y' f8 = 'z' )
     (  f1 = '8' f2 = '9' f3 = 'd' f4 = 'e' f5 = 's' f6 = 't' f7 = 'w' f8 = 'x' )
     (  f1 = '2' f2 = '3' f3 = '6' f4 = '7' f5 = 'k' f6 = 'm' f7 = 'q' f8 = 'r' )
     (  f1 = '0' f2 = '1' f3 = '4' f4 = '5' f5 = 'h' f6 = 'j' f7 = 'n' f8 = 'p' )
    ).

    mt_neighbors_even = value #(
     (  f1 = 'p' f2 = 'r' f3 = 'x' f4 = 'z' )
     (  f1 = 'n' f2 = 'q' f3 = 'w' f4 = 'y' )
     (  f1 = 'j' f2 = 'm' f3 = 't' f4 = 'v' )
     (  f1 = 'h' f2 = 'k' f3 = 's' f4 = 'u' )
     (  f1 = '5' f2 = '7' f3 = 'e' f4 = 'g' )
     (  f1 = '4' f2 = '6' f3 = 'd' f4 = 'f' )
     (  f1 = '1' f2 = '3' f3 = '9' f4 = 'c' )
     (  f1 = '0' f2 = '2' f3 = '8' f4 = 'b' )
    ).

  endmethod.


  method decode.

    types: numc5 type n length 5.

    data(length) = strlen( geohash ).

    if length <= 0.
      return.
    endif.

    if length > c_max_hash_length.
      length = c_max_hash_length.
    endif.

    data(geo_hash_internal) = to_lower( geohash ).

    data(hash_index) = 0.

    do length times.

      data(base32) = geo_hash_internal+hash_index(1).

      data(decimals) = value #( mt_base32_code2[ base32 = base32 ]-decimals optional ).

      data(bin5) = conv numc5( dec_to_bin( decimals ) ).

      data: mix_bin       type string,
            longitude_bin type string,
            latitude_bin  type string.

      mix_bin = mix_bin && bin5.

      hash_index = hash_index + 1.

    enddo.

    data(bin_index) = 0.

    do strlen( mix_bin ) times.

      data(bin) = mix_bin+bin_index(1).

      if bin_index mod 2 = 0.
        longitude_bin = longitude_bin && bin.
      else.
        latitude_bin = latitude_bin && bin.
      endif.

      bin_index = bin_index + 1.

    enddo.

    data(longitude_left)  = c_longitude_min.
    data(longitude_right) = c_longitude_max.
    data(latitude_left)   = c_latitude_min.
    data(latitude_right)  = c_latitude_max.


    data(longitude_index) = 0.

    do strlen( longitude_bin ) times.

      data(bin_longitude) = longitude_bin+longitude_index(1).

      get_tude(
        exporting
          i_left  = longitude_left
          i_right = longitude_right
          i_bin   = bin_longitude
        importing
          e_left  = longitude_left
          e_right = longitude_right
          e_tude  = longitude
      ).

      longitude_index = longitude_index + 1.

    enddo.

    data(latitude_index) = 0.

    do strlen( latitude_bin ) times.

      data(bin_latitude) = latitude_bin+latitude_index(1).

      get_tude(
        exporting
          i_left  = latitude_left
          i_right = latitude_right
          i_bin   = bin_latitude
        importing
          e_left  = latitude_left
          e_right = latitude_right
          e_tude  = latitude
      ).

      latitude_index = latitude_index + 1.

    enddo.

  endmethod.


  method dec_to_bin.

    "ignore negative number
    data(temp) = 0.
    data(dec) = i_dec.

    while dec > 0.
      temp = dec mod 2.
      dec  = dec / 2 - temp.
      r_bin = r_bin && conv char1( temp ).
    endwhile.

    r_bin = reverse( r_bin ).

  endmethod.


  method encode.

    if length < 1.
      return.
    endif.

    if length > c_max_hash_length.
      data(hash_length) = c_max_hash_length.
    else.
      hash_length = length.
    endif.

    data(loop_times) = hash_length * 5 / 2 + 1.

    data: longitude_bin type string,
          latitude_bin  type string,
          mix_bin       type string.

    data(longitude_left)  = c_longitude_min.
    data(longitude_right) = c_longitude_max.
    data(latitude_left)   = c_latitude_min.
    data(latitude_right)  = c_latitude_max.

    do loop_times times.

      get_bin(
        exporting
          i_left  = longitude_left
          i_right = longitude_right
          i_tude  = longitude
        importing
          e_left  = longitude_left
          e_right = longitude_right
          e_bin  = data(longitude_bin_temp)
      ).

      get_bin(
        exporting
          i_left  = latitude_left
          i_right = latitude_right
          i_tude  = latitude
        importing
          e_left  = latitude_left
          e_right = latitude_right
          e_bin  = data(latitude_bin_temp)
      ).

      mix_bin = mix_bin && longitude_bin_temp && latitude_bin_temp.

    enddo.

    data(code_index) = 0.

    do hash_length times.

      data(offset) = code_index * 5 .
      data(bin)    = mix_bin+offset(5).

      r_geo_hash = r_geo_hash && value #(
        mt_base32_code1[ decimals = bin_to_dec( i_bin = bin  ) ]-base32 optional ).

      code_index = code_index + 1.

    enddo.

  endmethod.


  method get_bin.

    data(mid) = conv ty_tude( ( i_left + i_right ) / 2 ).

    if i_tude <= mid.
      e_bin   = c_zero.
      e_left  = i_left.
      e_right = mid.
    else.
      e_bin   = c_one.
      e_left  = mid.
      e_right = i_right.
    endif.

  endmethod.


  method get_code_neighbor.

    data(table_descr) = cast cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( i_table ) ).

    data(column_count) = lines(
      cast cl_abap_structdescr( table_descr->get_table_line_type( ) )->components ).


    data(col_index) = 1.

    loop at i_table assigning field-symbol(<line>).

      data(row_index) = sy-tabix.

      col_index = 1.

      while col_index <= column_count.

        assign component col_index of structure <line> to field-symbol(<field>).
        if sy-subrc = 0.
          if <field> = i_member.
            data(found) = abap_true.
            exit.
          endif.
        endif.

        col_index = col_index + 1.

      endwhile.

      if found = abap_true.
        exit.
      endif.

    endloop.

    if found = abap_false.
      return.
    endif.


    types: begin of ty_direction,
             row type i,
             col type i,
           end of ty_direction.

    data: direction_index_table type standard table of ty_direction.

    direction_index_table = value #(
      ( row = -1 col =  -1  )
      ( row = -1 col =   0  )
      ( row = -1 col =  +1  )
      ( row =  0 col =  -1  )
      ( row =  0 col =  +1  )
      ( row =  1 col =  -1  )
      ( row =  1 col =   0  )
      ( row =  1 col =  +1  )
    ).

    data(row_count) = lines( i_table ).

    loop at direction_index_table assigning field-symbol(<direction_index>).

      data(row_result) = get_index( index = row_index offset = <direction_index>-row max_index = row_count ).
      data(col_result) = get_index( index = col_index offset = <direction_index>-col max_index = column_count ).

      read table i_table assigning <line> index row_result.
      if sy-subrc = 0.
        assign component col_result of structure <line> to <field>.
        if sy-subrc = 0.
          r_table = value #( base r_table ( hash = <field> ) ).
        endif.
      endif.

    endloop.

  endmethod.


  method get_index.

    if abs( offset ) >= max_index.
      return.
    endif.

    r_index = index + offset.

    if r_index > max_index .
      r_index = offset.
    endif.

    if r_index <= 0.
      r_index = max_index + r_index.
    endif.

  endmethod.


  method get_tude.

    data(mid) = conv ty_tude( ( i_left + i_right ) / 2 ).

    if i_bin = c_zero.
      e_left  = i_left.
      e_right = mid.
      e_tude  = ( i_left + mid ) / 2.
    else.
      e_left  = mid.
      e_right = i_right.
      e_tude  = ( mid + i_right ) / 2.
    endif.

  endmethod.


  method neighbors.

    if geohash is initial.
      return.
    endif.

    data(geohash_internal) = to_lower( geohash ).

    data(length) = strlen( geohash_internal ).

    data(offset) = length - 1.

    data(suffix) = geohash_internal+offset(1).

    if length mod 2 = 0.
      data(code_table) = get_code_neighbor( i_table = mt_neighbors_even i_member = suffix ).
    else.
      code_table       = get_code_neighbor( i_table = mt_neighbors_odd  i_member = suffix ).
    endif.

    data(prefix) = geohash_internal(offset).

    loop at code_table assigning field-symbol(<hash>).
      neighbors = value #( base neighbors ( hash = prefix && <hash>-hash ) ).
    endloop.

  endmethod.


  method validate.

    valid = abap_false.

    if geohash is initial .
      return.
    endif.

    if strlen( geohash ) > c_max_hash_length.
      return.
    endif.

    data(geohash_internal) = to_lower( geohash ).

    data(geohash_index) = 0.

    do strlen( geohash ) times.

      data(hash) = geohash_internal+geohash_index(1).

      if not line_exists( mt_base32_code2[ base32 = hash ] ).
        return.
      endif.

      geohash_index = geohash_index + 1.

    enddo.

    valid = abap_true.

  endmethod.
endclass.
