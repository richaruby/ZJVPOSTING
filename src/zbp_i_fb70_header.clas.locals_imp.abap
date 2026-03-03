CLASS lhc_ZI_FB70_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_FB70_Header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZI_FB70_Header RESULT result.

    METHODS zjvpost FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_FB70_Header~zjvpost.

ENDCLASS.

CLASS lhc_ZI_FB70_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD zjvpost.
    DATA : it_head TYPE TABLE OF ZI_FB70_Header,
           wa_head TYPE ZI_FB70_Header , "zfb70_hdr,
           it_item TYPE TABLE OF ZI_FB70_Item,
           wa_item TYPE ZI_FB70_Item . "zfb70_itm.

    DATA: lt_poparallel TYPE cl_abap_parallel=>t_in_inst_tab .

    READ ENTITIES OF ZI_FB70_Header IN LOCAL MODE
    ENTITY ZI_FB70_Header
    ALL FIELDS WITH CORRESPONDING #( keys )
*            FIELDS ( Plant  Matnr Quantity Batch Ebeln Mblnr Mjahr Currency ) WITH CORRESPONDING #( keys )
    RESULT DATA(members).

    LOOP AT members ASSIGNING FIELD-SYMBOL(<fs_head>).
      MOVE-CORRESPONDING <fs_head> TO wa_head .
      APPEND wa_head TO it_head .
      CLEAR : wa_head .
    ENDLOOP.

    READ ENTITIES OF ZI_FB70_Header IN LOCAL MODE
     ENTITY ZI_FB70_Header
     BY \_Items
     ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_item1).

    IF lt_item1 IS NOT INITIAL OR it_head IS NOT INITIAL.
      LOOP AT lt_item1 ASSIGNING FIELD-SYMBOL(<fs_item1>).
        MOVE-CORRESPONDING <fs_item1> TO wa_item.
        APPEND wa_item TO it_item .
        CLEAR : wa_item .
      ENDLOOP.

      DATA(lo_proc) = NEW cl_abap_parallel( p_percentage = 30 )  .

      INSERT NEW zcl_jvpost_parallel(  gt_head = CORRESPONDING #( it_head ) gt_item = CORRESPONDING #( it_item )  )
          INTO TABLE lt_poparallel.

      IF lt_poparallel IS NOT INITIAL .

        lo_proc->run_inst(  EXPORTING p_in_tab = lt_poparallel
                                     p_debug = abap_false
                            IMPORTING p_out_tab = DATA(lt_finished)  ).
      ENDIF.

      READ TABLE it_head INTO wa_head INDEX 1.
      SELECT * FROM zdb_jv_log WHERE header_uuid = @wa_head-HeaderUUID
      INTO TABLE @DATA(it_log).
      IF it_log[] IS NOT INITIAL.
        LOOP AT it_log INTO DATA(wa_log2)  .
          IF wa_log2-belnr IS  INITIAL and wa_log2-reverse_doc is initial .
*            APPEND VALUE #(
*              %tky = members[ 1 ]-%tky
*              %msg = new_message_with_text(
*                       severity = if_abap_behv_message=>severity-error
*                       text     = wa_log2-mess
*                     )
*            ) TO failed-zi_fb70_header.

            APPEND VALUE #(
              %tky = members[ 1 ]-%tky
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text     = wa_log2-mess
                     )
            ) TO reported-zi_fb70_header.

*            EXIT.
          ELSE.
            CONCATENATE 'Document' wa_log2-belnr 'in year' wa_log2-gjahr 'posted' INTO DATA(lv_success).
            APPEND VALUE #(
            %tky = members[ 1 ]-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = lv_success
                   )
          ) TO reported-zi_fb70_header.



            CLEAR : lv_success .
          ENDIF.

          MODIFY ENTITIES OF ZI_FB70_Header IN LOCAL MODE
          ENTITY ZI_FB70_Header
          UPDATE FROM VALUE #(
            (
              %tky                 = members[ 1 ]-%tky  "keys[ 1 ]-%tky
*                      grn_101              = wa_log-grn_101
              Belnr            = wa_log2-belnr
              Gjahr            = wa_log2-gjahr
              Reversedoc       = wa_log2-reverse_doc
              Reverseyr        = wa_log2-reverse_yr
              Status           = wa_log2-status
              Message          = wa_log2-mess
              %control-Belnr  = if_abap_behv=>mk-on
              %control-Gjahr  = if_abap_behv=>mk-on
              %control-Message   = if_abap_behv=>mk-on
              %control-Status   = if_abap_behv=>mk-on
              %control-Reversedoc   = if_abap_behv=>mk-on
              %control-Reverseyr   = if_abap_behv=>mk-on
*                        %control-grn_101     = if_abap_behv=>mk-on
            )
           )
          MAPPED DATA(lt_upd_mapped)
          FAILED DATA(lt_upd_failed)
          REPORTED DATA(lt_upd_reported) .

          "Read Updated Entry
          READ ENTITIES OF ZI_FB70_Header IN LOCAL MODE
            ENTITY ZI_FB70_Header
            ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_updated_xlhead).

          "Send Status back to front end
          members = VALUE #(
            FOR lwa_upd_head IN lt_updated_xlhead
            (
              %tky      = lwa_upd_head-%tky
*                    %is_draft = lwa_upd_head-%is_draft
*                    %param    =
            )
          ).
        ENDLOOP.

      ENDIF.
    ENDIF.





  ENDMETHOD.

ENDCLASS.
