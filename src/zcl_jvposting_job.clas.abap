CLASS zcl_jvposting_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
*    INTERFACES if_apj_dt_exec_object.
*    INTERFACES if_apj_rt_exec_object.
*    INTERFACES if_oo_adt_classrun.
      INTERFACES : if_oo_adt_classrun ,
      if_apj_dt_exec_object,
      if_apj_rt_exec_object.

  PRIVATE SECTION.
    CONSTANTS:
      c_bus_trans TYPE c LENGTH 4 VALUE 'RFIV', "Journal entry
      c_doc_type  TYPE c LENGTH 2 VALUE 'KR',   "Journal voucher
      c_curr_role TYPE c LENGTH 2 VALUE '00'.

    METHODS post_jv_documents.
ENDCLASS.



CLASS ZCL_JVPOSTING_JOB IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.


  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
*    post_jv_documents( ).
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    "Allow manual execution from ADT
    post_jv_documents( ).
  ENDMETHOD.


  METHOD post_jv_documents.
    DATA: lt_hdr    TYPE STANDARD TABLE OF zfb70_hdr,
          lt_itm    TYPE STANDARD TABLE OF zfb70_itm,
          lv_result TYPE string.

    "TODO: add a status flag in ZFB70_HDR to avoid reposting the same data
    SELECT * FROM zfb70_hdr
    WHERE belnr IS INITIAL
    INTO TABLE @lt_hdr.
    IF lt_hdr IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zfb70_itm
      FOR ALL ENTRIES IN @lt_hdr
      WHERE header_uuid = @lt_hdr-header_uuid
      INTO TABLE @lt_itm.

    DATA: lt_doc_h        TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
          ls_doc_h        LIKE LINE OF lt_doc_h,
          ls_glitem       LIKE LINE OF ls_doc_h-%param-_glitems,
          ls_glcurrency   LIKE LINE OF ls_glitem-_currencyamount,
          ls_aritem       LIKE LINE OF ls_doc_h-%param-_aritems,
          ls_apitem       LIKE LINE OF ls_doc_h-%param-_apitems,
          ls_custcurrency LIKE LINE OF ls_aritem-_currencyamount,
          ls_vencurrency  LIKE LINE OF ls_apitem-_currencyamount,
          lv_buzei        TYPE i,
          lv_total_amount TYPE zfb70_itm-net_amount,
          lv_item_amount  TYPE zfb70_itm-net_amount.

    LOOP AT lt_hdr ASSIGNING FIELD-SYMBOL(<ls_hdr>).
      IF <ls_hdr>-doctype = 'KR'.
        DATA(bus_trns) = 'RFIV'.
      ELSEIF  <ls_hdr>-doctype = 'KG'.
        bus_trns = 'RFIV'.
      ELSEIF  <ls_hdr>-doctype = 'DR'.
        bus_trns = 'RFIC'.
      ELSEIF  <ls_hdr>-doctype = 'DG'.
        bus_trns = 'RFIC'.
      ELSEIF  <ls_hdr>-doctype = 'KZ'.
        bus_trns = 'RFPO'.
      ELSEIF  <ls_hdr>-doctype = 'DZ'.
        bus_trns = 'RFPI'.
      ELSEIF  <ls_hdr>-doctype = 'SA'.
        bus_trns = 'RFBU'.
      ENDIF.


      CLEAR: ls_doc_h, lv_buzei, lv_total_amount.

      "Header mapping
      ls_doc_h-%cid = <ls_hdr>-header_uuid.
      ls_doc_h-%param-companycode                = <ls_hdr>-company_code.
      ls_doc_h-%param-documentreferenceid        = <ls_hdr>-reference.
      ls_doc_h-%param-createdbyuser              = sy-uname.
      ls_doc_h-%param-businesstransactiontype    = bus_trns.
      ls_doc_h-%param-accountingdocumenttype     = c_doc_type.
      ls_doc_h-%param-documentdate               = <ls_hdr>-invoice_date.
      ls_doc_h-%param-postingdate                = <ls_hdr>-posting_date.
      ls_doc_h-%param-accountingdocumentheadertext = <ls_hdr>-header_text.
      ls_doc_h-%param-taxdeterminationdate = <ls_hdr>-invoice_date.
      ls_doc_h-%param-taxreportingdate     = <ls_hdr>-invoice_date.


      ls_doc_h-%param-%control-companycode             = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-documentreferenceid     = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-createdbyuser           = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-businesstransactiontype = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-accountingdocumenttype  = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-documentdate            = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-postingdate             = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-accountingdocumentheadertext = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-taxdeterminationdate = if_abap_behv=>mk-on.
      ls_doc_h-%param-%control-taxreportingdate = if_abap_behv=>mk-on.

      "Item mapping (GL)
      LOOP AT lt_itm ASSIGNING FIELD-SYMBOL(<ls_itm>)
        WHERE header_uuid = <ls_hdr>-header_uuid.

        IF <ls_itm>-gl_account IS NOT INITIAL.
          CLEAR: ls_glitem, ls_glcurrency.
          lv_buzei = lv_buzei + 1.

          ls_glitem-glaccountlineitem = lv_buzei.
          ls_glitem-%control-glaccountlineitem = if_abap_behv=>mk-on.

          ls_glitem-glaccount = <ls_itm>-gl_account.
          ls_glitem-%control-glaccount = if_abap_behv=>mk-on.

          ls_glitem-CostCenter = <ls_itm>-costcenter .
          ls_glitem-%control-costcenter = if_abap_behv=>mk-on.


          ls_glitem-profitcenter = <ls_itm>-profit_center.
          ls_glitem-%control-profitcenter = if_abap_behv=>mk-on.

          IF <ls_itm>-housebank IS NOT INITIAL.
            ls_glitem-HouseBank = <ls_itm>-housebank .
            ls_glitem-%control-housebank = if_abap_behv=>mk-on.
          ENDIF.

          IF <ls_itm>-bank_acc IS NOT INITIAL.
            ls_glitem-HouseBankAccount = <ls_itm>-bank_acc .
            ls_glitem-%control-HouseBankAccount = if_abap_behv=>mk-on.
          ENDIF.

          ls_glitem-BusinessPlace = <ls_hdr>-business_place .
          ls_glitem-%control-BusinessPlace = if_abap_behv=>mk-on.

          ls_glitem-assignmentreference = <ls_hdr>-reference.
          ls_glitem-%control-assignmentreference = if_abap_behv=>mk-on.

          ls_glitem-documentitemtext = <ls_hdr>-text.
          ls_glitem-%control-documentitemtext = if_abap_behv=>mk-on.

          ls_glitem-taxcode = <ls_itm>-tax_code.
          ls_glitem-%control-taxcode = if_abap_behv=>mk-on.

          ls_glitem-taxjurisdiction = ''.
          ls_glitem-%control-taxjurisdiction = if_abap_behv=>mk-on.

*        ls_glitem-plant = <ls_itm>-plant.
*        ls_glitem-%control-plant = if_abap_behv=>mk-on.
          IF <ls_itm>-drcr_ind = 'H'
               OR <ls_itm>-drcr_ind = 'C'
               OR <ls_itm>-drcr_ind = 'CR'.
            ls_glcurrency-journalentryitemamount  = <ls_itm>-net_amount * -1.
          ELSE.
            ls_glcurrency-journalentryitemamount  = <ls_itm>-net_amount.
          ENDIF.
          ls_glcurrency-%control-journalentryitemamount = if_abap_behv=>mk-on.

          IF <ls_itm>-currency IS NOT INITIAL.
            ls_glcurrency-currency = <ls_itm>-currency.
          ELSE.
            ls_glcurrency-currency = <ls_hdr>-currency.
          ENDIF.
          ls_glcurrency-%control-currency = if_abap_behv=>mk-on.

          ls_glcurrency-currencyrole = '00'.
          ls_glcurrency-%control-currencyrole = if_abap_behv=>mk-on.

          ls_glitem-%control-_currencyamount = if_abap_behv=>mk-on.
          ls_doc_h-%param-%control-_glitems  = if_abap_behv=>mk-on.

          APPEND ls_glcurrency TO ls_glitem-_currencyamount.
          APPEND ls_glitem     TO ls_doc_h-%param-_glitems.
        ENDIF.
        "Customer (AR) at item level (same as lhc_zi_accdoc_v2)
        IF <ls_itm>-kunnr IS NOT INITIAL.
          CLEAR: ls_aritem, ls_custcurrency.
          lv_buzei = lv_buzei + 1.
          ls_aritem-glaccountlineitem = lv_buzei.ls_aritem-%control-glaccountlineitem = if_abap_behv=>mk-on.
          ls_aritem-customer = <ls_itm>-kunnr.ls_aritem-%control-customer = if_abap_behv=>mk-on.
          ls_aritem-specialglcode = <ls_itm>-special_gl_indicator.ls_aritem-%control-specialglcode = if_abap_behv=>mk-on.
          ls_aritem-businessplace = <ls_itm>-business_place.ls_aritem-%control-businessplace = if_abap_behv=>mk-on.
          ls_aritem-assignmentreference = <ls_itm>-assignment_reference.ls_aritem-%control-assignmentreference = if_abap_behv=>mk-on.
          ls_aritem-documentitemtext = <ls_itm>-item_text.ls_aritem-%control-documentitemtext = if_abap_behv=>mk-on.
          ls_aritem-taxcode = <ls_itm>-tax_code.ls_aritem-%control-taxcode = if_abap_behv=>mk-on.
          ls_aritem-taxjurisdiction = ''.ls_aritem-%control-taxjurisdiction = if_abap_behv=>mk-on.
          IF <ls_itm>-drcr_ind = 'H'.
            ls_custcurrency-journalentryitemamount = <ls_itm>-net_amount * -1.
          ELSE.
            ls_custcurrency-journalentryitemamount = <ls_itm>-net_amount.
          ENDIF.
          ls_custcurrency-%control-journalentryitemamount = if_abap_behv=>mk-on.
          ls_custcurrency-currency = <ls_itm>-currency.ls_custcurrency-%control-currency = if_abap_behv=>mk-on.

          ls_custcurrency-currencyrole = '00'.ls_custcurrency-%control-currencyrole = if_abap_behv=>mk-on.

          ls_aritem-%control-_currencyamount = if_abap_behv=>mk-on.
          ls_doc_h-%param-%control-_aritems = if_abap_behv=>mk-on.

          APPEND ls_custcurrency TO ls_aritem-_currencyamount.
          APPEND ls_aritem TO ls_doc_h-%param-_aritems.
        ENDIF.


        "Vendor (AP) at item level (same as lhc_zi_accdoc_v2)
        IF <ls_itm>-lifnr IS NOT INITIAL.
          CLEAR: ls_apitem, ls_vencurrency.
          lv_buzei = lv_buzei + 1.
          ls_apitem-glaccountlineitem = lv_buzei.ls_apitem-%control-glaccountlineitem = if_abap_behv=>mk-on.
          ls_apitem-supplier = <ls_itm>-lifnr.ls_apitem-%control-supplier = if_abap_behv=>mk-on.
          ls_apitem-specialglcode = <ls_itm>-special_gl_indicator.ls_apitem-%control-specialglcode = if_abap_behv=>mk-on.
          ls_apitem-businessplace = <ls_itm>-business_place.ls_apitem-%control-businessplace = if_abap_behv=>mk-on.
          ls_apitem-assignmentreference = <ls_itm>-assignment_reference.ls_apitem-%control-assignmentreference = if_abap_behv=>mk-on.
          ls_apitem-documentitemtext = <ls_itm>-item_text.ls_apitem-%control-documentitemtext = if_abap_behv=>mk-on.
          ls_apitem-paymentmethod = <ls_itm>-payment_method.ls_apitem-%control-paymentmethod = if_abap_behv=>mk-on.
          ls_apitem-taxcode = <ls_itm>-tax_code.ls_apitem-%control-taxcode = if_abap_behv=>mk-on.
          ls_apitem-taxjurisdiction = ''.ls_apitem-%control-taxjurisdiction = if_abap_behv=>mk-on.

          IF <ls_itm>-drcr_ind = 'H'.
            ls_vencurrency-journalentryitemamount = <ls_itm>-net_amount * -1.
          ELSE.
            ls_vencurrency-journalentryitemamount = <ls_itm>-net_amount.
          ENDIF.
          ls_vencurrency-%control-journalentryitemamount = if_abap_behv=>mk-on.

          ls_vencurrency-currency = <ls_itm>-currency.ls_vencurrency-%control-currency = if_abap_behv=>mk-on.

*          ls_vencurrency-currencyrole = c_curr_role.
*          ls_vencurrency-%control-currencyrole = if_abap_behv=>mk-on.

          ls_apitem-%control-_currencyamount = if_abap_behv=>mk-on.
          ls_doc_h-%param-%control-_apitems = if_abap_behv=>mk-on.

          APPEND ls_vencurrency TO ls_apitem-_currencyamount.
          APPEND ls_apitem TO ls_doc_h-%param-_apitems.
        ENDIF.
      ENDLOOP.

      IF ls_doc_h-%param-_glitems IS NOT INITIAL.
        APPEND ls_doc_h TO lt_doc_h.
      ENDIF.


      IF lt_doc_h IS INITIAL.
        RETURN.
      ENDIF.

      MODIFY ENTITIES OF i_journalentrytp
        ENTITY journalentry
        EXECUTE post FROM lt_doc_h
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported)
        MAPPED   DATA(ls_mapped).

      IF ls_failed IS NOT INITIAL.
        LOOP AT ls_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
          lv_result = <ls_reported_deep>-%msg->if_message~get_text( ).
        ENDLOOP.


      ELSE.
        COMMIT ENTITIES BEGIN
        RESPONSE OF i_journalentrytp
        FAILED DATA(lt_commit_failed)
        REPORTED DATA(lt_commit_reported).


        IF lt_commit_reported IS NOT INITIAL.
          LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_invoice>).
            IF <ls_invoice>-AccountingDocument IS NOT INITIAL.
              "We used %cid = header_uuid when posting; use it to update the header row
              DATA(lv_header_uuid) = VALUE sysuuid_x16( ).
              FIELD-SYMBOLS <lv_cid> TYPE any.

              ASSIGN COMPONENT '%cid' OF STRUCTURE <ls_invoice> TO <lv_cid>.
              IF sy-subrc = 0 AND <lv_cid> IS NOT INITIAL.
                lv_header_uuid = <lv_cid>.
              ELSE.
                "Fallback depending on RAP response shape
                ASSIGN COMPONENT '%cid_ref' OF STRUCTURE <ls_invoice> TO <lv_cid>.
                IF sy-subrc = 0 AND <lv_cid> IS NOT INITIAL.
                  lv_header_uuid = <lv_cid>.
                ENDIF.
              ENDIF.

*            IF lv_header_uuid IS NOT INITIAL.
              UPDATE zfb70_hdr
                SET belnr = @<ls_invoice>-AccountingDocument
                WHERE header_uuid = @<ls_hdr>-header_uuid.
*            ENDIF.

            ELSE.

            ENDIF.

          ENDLOOP.

        ENDIF.
*        ENDIF.
        COMMIT ENTITIES END.
      ENDIF.
    ENDLOOP.

    "TODO: update ZFB70_HDR with posted document number / status if needed

  ENDMETHOD.
ENDCLASS.
