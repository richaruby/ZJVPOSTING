CLASS zcl_jvpost_parallel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES : tt_head TYPE STANDARD TABLE OF ZI_FB70_Header WITH EMPTY KEY,
            tt_item TYPE STANDARD TABLE OF ZI_FB70_Item WITH EMPTY KEY.
    DATA: it_head  TYPE  TABLE OF ZI_FB70_Header,
          it_item  TYPE  TABLE OF ZI_FB70_Item,
          it_log_n TYPE  TABLE OF zdb_jv_log,
          wa_log_n TYPE  zdb_jv_log.
    INTERFACES if_serializable_object .
    INTERFACES if_abap_parallel .

    METHODS constructor
      IMPORTING
        gt_head TYPE tt_head
        gt_item TYPE tt_item .

    METHODS save_log.
    METHODS reverse_doc .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_JVPOST_PARALLEL IMPLEMENTATION.


  METHOD constructor.
    it_head = gt_head .
    it_item = gt_item .
  ENDMETHOD.


  METHOD if_abap_parallel~do.
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
          lv_item_amount  TYPE zfb70_itm-net_amount,
          lv_result       TYPE string,
          lv_posnr        TYPE posnr,
          it_log          TYPE TABLE OF zdb_jv_log,
          lv_result2(100) TYPE c,
          wa_log          TYPE zdb_jv_log.
*          ls_reverse TYPE LINE OF lt_reverse.
    CONSTANTS:
      c_bus_trans TYPE c LENGTH 4 VALUE 'RFIV', "Journal entry   "Journal voucher
      c_curr_role TYPE c LENGTH 2 VALUE '00'.

    DATA : c_doc_type  TYPE c LENGTH 2  .
    c_doc_type = 'KR' .
    LOOP AT it_head ASSIGNING FIELD-SYMBOL(<ls_hdr>).
      IF <ls_hdr>-Reverse NE 'X'.
        c_doc_type = <ls_hdr>-doctype .
        IF <ls_hdr>-doctype = 'KR'.
          DATA(bus_trns) = 'RFIV'.
        ELSEIF  <ls_hdr>-doctype = 'KG'.
          bus_trns = 'RFIV'.
        ELSEIF  <ls_hdr>-doctype = 'DR'.
          bus_trns = 'RFIC'.
        ELSEIF  <ls_hdr>-doctype = 'DG'.
          bus_trns = 'RFIC'.
        ELSEIF  <ls_hdr>-doctype = 'KZ'.
**        bus_trns = 'RFPO'.
          bus_trns = 'RFPI'.
          c_doc_type = 'KZ'.
        ELSEIF  <ls_hdr>-doctype = 'DZ'.
          bus_trns = 'RFPI'.
        ELSEIF  <ls_hdr>-doctype = 'SA'.
          bus_trns = 'RFBU'.
        ENDIF.


        CLEAR: ls_doc_h, lv_buzei, lv_total_amount.

        "Header mapping
        ls_doc_h-%cid = <ls_hdr>-HeaderUUID.
        ls_doc_h-%param-companycode                = <ls_hdr>-CompanyCode.
        ls_doc_h-%param-documentreferenceid        = <ls_hdr>-reference.
        ls_doc_h-%param-createdbyuser              = sy-uname.
        ls_doc_h-%param-businesstransactiontype    = bus_trns.
        ls_doc_h-%param-accountingdocumenttype     = c_doc_type .
        ls_doc_h-%param-documentdate               = <ls_hdr>-InvoiceDate.
        ls_doc_h-%param-postingdate                = <ls_hdr>-PostingDate.
        ls_doc_h-%param-accountingdocumentheadertext = <ls_hdr>-HeaderText.

        ls_doc_h-%param-taxdeterminationdate = <ls_hdr>-InvoiceDate.
        ls_doc_h-%param-taxreportingdate     = <ls_hdr>-InvoiceDate.


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
        LOOP AT it_item ASSIGNING FIELD-SYMBOL(<ls_itm>)
          WHERE HeaderUUID = <ls_hdr>-HeaderUUID.

          IF <ls_itm>-GlAccount IS NOT INITIAL.
            CLEAR: ls_glitem, ls_glcurrency.
            lv_buzei = lv_buzei + 1.

            ls_glitem-glaccountlineitem = lv_buzei.
            ls_glitem-%control-glaccountlineitem = if_abap_behv=>mk-on.

            ls_glitem-glaccount = <ls_itm>-GlAccount.
            ls_glitem-%control-glaccount = if_abap_behv=>mk-on.

            ls_glitem-CostCenter = <ls_itm>-costcenter .
            ls_glitem-%control-costcenter = if_abap_behv=>mk-on.


            ls_glitem-profitcenter = <ls_itm>-ProfitCenter.
            ls_glitem-%control-profitcenter = if_abap_behv=>mk-on.

            IF <ls_itm>-housebank IS NOT INITIAL.
              ls_glitem-HouseBank = <ls_itm>-housebank .
              ls_glitem-%control-housebank = if_abap_behv=>mk-on.
            ENDIF.

            IF <ls_itm>-bank_acc IS NOT INITIAL.
              ls_glitem-HouseBankAccount = <ls_itm>-bank_acc .
              ls_glitem-%control-HouseBankAccount = if_abap_behv=>mk-on.
            ENDIF.

            ls_glitem-BusinessPlace = <ls_hdr>-BusinessPlace .
            ls_glitem-%control-BusinessPlace = if_abap_behv=>mk-on.

            ls_glitem-assignmentreference = <ls_hdr>-reference.
            ls_glitem-%control-assignmentreference = if_abap_behv=>mk-on.

            ls_glitem-documentitemtext = <ls_hdr>-text.
            ls_glitem-%control-documentitemtext = if_abap_behv=>mk-on.

*            IF <ls_hdr>-TaxCode IS NOT INITIAL.
            ls_glitem-taxcode = <ls_hdr>-TaxCode.
            ls_glitem-%control-taxcode = if_abap_behv=>mk-on.

*            ENDIF.

            ls_glitem-taxjurisdiction = ''.
            ls_glitem-%control-taxjurisdiction = if_abap_behv=>mk-on.
*        ls_glitem-plant = <ls_itm>-plant.
*        ls_glitem-%control-plant = if_abap_behv=>mk-on.
            IF <ls_itm>-DrcrInd = 'H'
                 OR <ls_itm>-DrcrInd = 'C'
                 OR <ls_itm>-DrcrInd = 'CR'.
              ls_glcurrency-journalentryitemamount  = <ls_itm>-NetAmount * -1.
            ELSE.
              ls_glcurrency-journalentryitemamount  = <ls_itm>-NetAmount.
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
            ls_aritem-specialglcode = <ls_itm>-SpecialGlIndicator.ls_aritem-%control-specialglcode = if_abap_behv=>mk-on.
            ls_aritem-businessplace = <ls_itm>-BusinessPlace.ls_aritem-%control-businessplace = if_abap_behv=>mk-on.
            ls_aritem-assignmentreference = <ls_itm>-AssignmentReference.ls_aritem-%control-assignmentreference = if_abap_behv=>mk-on.
            ls_aritem-documentitemtext = <ls_itm>-ItemText.ls_aritem-%control-documentitemtext = if_abap_behv=>mk-on.
            ls_aritem-taxcode = <ls_itm>-TaxCode.ls_aritem-%control-taxcode = if_abap_behv=>mk-on.
            ls_aritem-taxjurisdiction = ''.ls_aritem-%control-taxjurisdiction = if_abap_behv=>mk-on.
            IF <ls_itm>-DrcrInd = 'H'.
              ls_custcurrency-journalentryitemamount = <ls_itm>-NetAmount * -1.
            ELSE.
              ls_custcurrency-journalentryitemamount = <ls_itm>-NetAmount.
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
            ls_apitem-specialglcode = <ls_itm>-SpecialGlIndicator.ls_apitem-%control-specialglcode = if_abap_behv=>mk-on.
            ls_apitem-businessplace = <ls_itm>-BusinessPlace.ls_apitem-%control-businessplace = if_abap_behv=>mk-on.
            ls_apitem-assignmentreference = <ls_itm>-AssignmentReference.ls_apitem-%control-assignmentreference = if_abap_behv=>mk-on.
            ls_apitem-documentitemtext = <ls_itm>-ItemText.ls_apitem-%control-documentitemtext = if_abap_behv=>mk-on.
            ls_apitem-paymentmethod = <ls_itm>-PaymentMethod.ls_apitem-%control-paymentmethod = if_abap_behv=>mk-on.
*            ls_apitem-taxcode = <ls_itm>-TaxCode.ls_apitem-%control-taxcode = if_abap_behv=>mk-on.
*            ls_apitem-taxjurisdiction = ''.ls_apitem-%control-taxjurisdiction = if_abap_behv=>mk-on.

*            IF <ls_hdr>-TaxCode IS NOT INITIAL.
*              ls_glitem-taxcode = <ls_hdr>-TaxCode.
*              ls_glitem-%control-taxcode = if_abap_behv=>mk-on.
*
*            ENDIF.

            ls_glitem-taxjurisdiction = ''.
            ls_glitem-%control-taxjurisdiction = if_abap_behv=>mk-on.

            IF <ls_itm>-DrcrInd = 'H'.
              ls_vencurrency-journalentryitemamount = <ls_itm>-NetAmount * -1.
            ELSE.
              ls_vencurrency-journalentryitemamount = <ls_itm>-NetAmount.
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
          CLEAR : lv_posnr, lv_result2.
          LOOP AT ls_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
            lv_posnr = lv_posnr + 1.
            IF lv_posnr GT 1.
              lv_result = <ls_reported_deep>-%msg->if_message~get_text( ) .
              IF lv_result2 IS INITIAL.
                wa_log-mess = lv_result .
              ELSE.
                CONCATENATE wa_log-mess lv_result
                INTO wa_log-mess SEPARATED BY space .
              ENDIF.
            ENDIF.
            CLEAR lv_result .
          ENDLOOP.
          lv_posnr = lv_posnr + 1.
          wa_log-header_uuid = <ls_hdr>-HeaderUUID .
          wa_log-line = lv_posnr .
          wa_log-company_code = <ls_hdr>-CompanyCode.
          wa_log-posting_date = <ls_hdr>-PostingDate.
          wa_log-status       = 'E' .
          wa_log-transaction_type =   <ls_hdr>-TransactionType.
          wa_log-created_by = cl_abap_context_info=>get_user_alias(  ).
          wa_log-created_dt = cl_abap_context_info=>get_system_date(  ).
*        wa_log-mess = lv_result2 .
          APPEND wa_log TO it_log .
          CLEAR : wa_log .

          IF it_log[] IS NOT INITIAL.
            it_log_n[] = it_log[] .
*          INSERT zdb_jv_log FROM TABLE @it_log .
**          COMMIT WORK.
*          IF sy-subrc IS NOT INITIAL.
*
*          ENDIF.

          ENDIF.

        ELSE.
          COMMIT ENTITIES BEGIN
          RESPONSE OF i_journalentrytp
          FAILED DATA(lt_commit_failed)
          REPORTED DATA(lt_commit_reported).


          IF lt_commit_reported IS NOT INITIAL.
            LOOP AT lt_commit_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_invoice>).
              IF <ls_invoice>-AccountingDocument IS NOT INITIAL.
                lv_posnr = lv_posnr + 1.
                wa_log-header_uuid = <ls_hdr>-HeaderUUID .
                wa_log-line = lv_posnr .
                wa_log-company_code = <ls_hdr>-CompanyCode.
                wa_log-posting_date = <ls_hdr>-PostingDate.
                wa_log-transaction_type =   <ls_hdr>-TransactionType.
                wa_log-created_by = cl_abap_context_info=>get_user_alias(  ).
                wa_log-created_dt = cl_abap_context_info=>get_system_date(  ).
                wa_log-status       = 'S' .
*              lv_result = <ls_reported_deep>-%msg->if_message~get_text( ).
                wa_log-belnr = <ls_invoice>-AccountingDocument .
                wa_log-gjahr = <ls_invoice>-FiscalYear .
                wa_log-mess = lv_result.
                APPEND wa_log TO it_log .
                CLEAR : wa_log .
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



**            IF lv_header_uuid IS NOT INITIAL.
*              UPDATE zfb70_hdr
*                SET belnr = @<ls_invoice>-AccountingDocument
*                WHERE header_uuid = @<ls_hdr>-header_uuid.
**            ENDIF.

              ELSE.

              ENDIF.

            ENDLOOP.

          ENDIF.
*        ENDIF.
          COMMIT ENTITIES END.
        ENDIF.
        IF it_log[] IS NOT INITIAL.
          INSERT zdb_jv_log FROM TABLE @it_log .
*        COMMIT WORK.
          IF sy-subrc IS NOT INITIAL.

          ENDIF.

        ENDIF.
        CALL METHOD save_log.
      ELSE.
        CALL METHOD reverse_doc.
      ENDIF.
      CLEAR :it_log, lt_commit_reported , lt_commit_failed, ls_reported, ls_failed, ls_mapped, lt_doc_h.
    ENDLOOP.
  ENDMETHOD.


  METHOD reverse_doc.
    DATA : lv_result  TYPE string,
           lv_result2 TYPE string,
           lv_posnr   TYPE posnr,
           lt_reverse TYPE TABLE FOR ACTION IMPORT i_journalentrytp~reverse,
           ls_reverse LIKE LINE OF lt_reverse,
           lt_doc_h   TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
           ls_doc_h   LIKE LINE OF lt_doc_h.

    CLEAR ls_reverse.
    CONSTANTS:
      c_bus_trans TYPE c LENGTH 4 VALUE 'RFIV', "Journal entry   "Journal voucher
      c_curr_role TYPE c LENGTH 2 VALUE '00'.

    DATA : c_doc_type  TYPE c LENGTH 2  .
*    c_doc_type = 'KR' .
    LOOP AT it_head ASSIGNING FIELD-SYMBOL(<ls_hdr>).
      ls_reverse-AccountingDocument = <ls_hdr>-Belnr.
      ls_reverse-CompanyCode  = <ls_hdr>-CompanyCode.
      ls_reverse-FiscalYear   = <ls_hdr>-Gjahr.
*      ls_reverse- = <ls_hdr>-HeaderUUID.

      ls_reverse-%param-ReversalReason       = <ls_hdr>-Reversereason.
      ls_reverse-%param-PostingDate          = cl_abap_context_info=>get_system_date(  )."        "Original document

      APPEND ls_reverse TO lt_reverse.

      MODIFY ENTITIES OF i_journalentrytp
        ENTITY journalentry
        EXECUTE reverse FROM lt_reverse
        FAILED   DATA(ls_rev_failed)
        REPORTED DATA(ls_rev_reported)
        MAPPED   DATA(ls_rev_mapped).

      IF ls_rev_failed IS NOT INITIAL.
        CLEAR : lv_posnr, lv_result2.
        LOOP AT ls_rev_reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_revdeep>).
          lv_posnr = lv_posnr + 1.
*          IF lv_posnr GT 1.
          lv_result = <ls_reported_revdeep>-%msg->if_message~get_text( ) .
          IF lv_result2 IS INITIAL.
            wa_log_n-mess = lv_result .
          ELSE.
            CONCATENATE wa_log_n-mess lv_result
            INTO wa_log_n-mess SEPARATED BY space .
          ENDIF.
*          ENDIF.
          CLEAR lv_result .
        ENDLOOP.

        LOOP AT ls_rev_failed-journalentry ASSIGNING FIELD-SYMBOL(<ls_failed_revdeep>).
          lv_posnr = lv_posnr + 1.
*          IF lv_posnr GT 1.
          lv_result = <ls_failed_revdeep>-%fail-cause .
          IF lv_result2 IS INITIAL.
            wa_log_n-mess = lv_result .
          ELSE.
            CONCATENATE wa_log_n-mess lv_result
            INTO wa_log_n-mess SEPARATED BY space .
          ENDIF.
*          ENDIF.
          CLEAR lv_result .
        ENDLOOP.
        lv_posnr = lv_posnr + 1.
        wa_log_n-header_uuid = <ls_hdr>-HeaderUUID .
        wa_log_n-line = lv_posnr .
        wa_log_n-company_code = <ls_hdr>-CompanyCode.
        wa_log_n-posting_date = <ls_hdr>-PostingDate.
        wa_log_n-status       = 'E' .
        wa_log_n-transaction_type =   <ls_hdr>-TransactionType.
        wa_log_n-created_by = cl_abap_context_info=>get_user_alias(  ).
        wa_log_n-created_dt = cl_abap_context_info=>get_system_date(  ).
*        wa_log-mess = lv_result2 .
        APPEND wa_log_n TO it_log_n .
        CLEAR : wa_log_n .

      ELSE.

        COMMIT ENTITIES BEGIN
                  RESPONSE OF i_journalentrytp
                  FAILED   DATA(lt_commit_revfailed)
                  REPORTED DATA(lt_commit_revreported).


        IF lt_commit_revreported IS NOT INITIAL.
          LOOP AT lt_commit_revreported-journalentry ASSIGNING FIELD-SYMBOL(<ls_invoicerev>).
            IF <ls_invoicerev>-AccountingDocument IS NOT INITIAL.
              lv_posnr = lv_posnr + 1.
              wa_log_n-header_uuid = <ls_hdr>-HeaderUUID .
              wa_log_n-line = lv_posnr .
              wa_log_n-company_code = <ls_hdr>-CompanyCode.
              wa_log_n-posting_date = <ls_hdr>-PostingDate.
              wa_log_n-transaction_type =   <ls_hdr>-TransactionType.
              wa_log_n-created_by = cl_abap_context_info=>get_user_alias(  ).
              wa_log_n-created_dt = cl_abap_context_info=>get_system_date(  ).
              wa_log_n-status       = 'S' .
              wa_log_n-belnr = <ls_hdr>-Belnr.
              wa_log_n-gjahr = <ls_hdr>-Gjahr.
              wa_log_n-reverse_doc = <ls_invoicerev>-AccountingDocument.
              wa_log_n-reverse_yr = <ls_invoicerev>-FiscalYear .
              wa_log_n-mess = lv_result.
              APPEND wa_log_n TO it_log_n .
              CLEAR : wa_log_n .

            ENDIF.

          ENDLOOP.

        ENDIF.

        COMMIT ENTITIES END.


      ENDIF.
      CALL METHOD save_log.
    ENDLOOP.
  ENDMETHOD.


  METHOD save_log.
    IF it_log_n[] IS NOT INITIAL.
      MODIFY zdb_jv_log FROM TABLE @it_log_n[].
      CLEAR : it_log_n[].
    ENDIF.
  ENDMETHOD.
ENDCLASS.
