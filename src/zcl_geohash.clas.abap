class zcl_geohash definition
  public
  final
  create public .

  public section.

    types:
      ty_tude type p length 16 decimals 12 .

    constants c_max_hash_length type i value 12 ##NO_TEXT.

    methods constructor .
    class-methods class_constructor .
    class-methods encode_geo_hash
      importing
        !i_longitude      type ty_tude
        !i_latitude       type ty_tude
        !i_length         type i default 8
      returning
        value(r_geo_hash) type string .
    class-methods decode_geo_hash
      importing
        !i_geo_hash  type string
      exporting
        !e_longitude type ty_tude
        !e_latitude  type ty_tude .
  protected section.
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

    types: begin of ty_code,
             code type string,
           end of ty_code.
    types: ty_code_t type standard table of ty_code with empty key.

    class-data mt_base32_code1 type ty_base32_t1 .
    class-data mt_base32_code2 type ty_base32_t2 .
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
    class-methods: get_code_neighbor importing i_table        type standard table
                                               i_member       type string
                                     returning value(r_table) type ty_code_t.

ENDCLASS.



CLASS ZCL_GEOHASH IMPLEMENTATION.


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

  endmethod.


  method constructor.
  endmethod.


  method decode_geo_hash.

    types: numc5 type n length 5.

    data(length) = strlen( i_geo_hash ).

    if length <= 0.
      return.
    endif.

    if length > c_max_hash_length.
      length = c_max_hash_length.
    endif.

    data(geo_hash) = to_lower( i_geo_hash ).

    data(hash_index) = 0.

    do length times.

      data(base32) = geo_hash+hash_index(1).

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
          e_tude  = e_longitude
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
          e_tude  = e_latitude
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


  method encode_geo_hash.

    if i_length < 1.
      return.
    endif.

    if i_length > c_max_hash_length.
      data(hash_length) = c_max_hash_length.
    else.
      hash_length = i_length.
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
          i_tude  = i_longitude
        importing
          e_left  = longitude_left
          e_right = longitude_right
          e_bin  = data(longitude_bin_temp)
      ).

      get_bin(
        exporting
          i_left  = latitude_left
          i_right = latitude_right
          i_tude  = i_latitude
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
ENDCLASS.
