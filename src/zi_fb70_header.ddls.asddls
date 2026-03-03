@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FB70 Upload - Header (Interface)'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_FB70_Header
  as select from zfb70_hdr
  composition [0..*] of ZI_FB70_Item as _Items
{
  key header_uuid         as HeaderUUID,

      company_code        as CompanyCode,
      transaction_type    as TransactionType,
      invoice_date        as InvoiceDate,
      posting_date        as PostingDate,
      reference           as Reference,

      @Semantics.amount.currencyCode: 'Currency'
      gross_amount        as GrossAmount,
      currency            as Currency,

      tax_calc_ind        as TaxCalcInd,
      tax_code            as TaxCode,
      business_place      as BusinessPlace,
      section_code        as SectionCode,
      text                as Text,
      gst_partner         as GstPartner,
      place_of_supply     as PlaceOfSupply,
      kunnr               as Kunnr,
      lifnr               as Lifnr,

      baseline_date       as BaselineDate,
      payment_term        as PaymentTerm,
      assignment          as Assignment,
      header_text         as HeaderText,

      withholding_tax_ind as WithholdingTaxInd,
      belnr               as Belnr,
      gjahr               as Gjahr,
      reverse_doc         as Reversedoc,
      reverse_yr          as Reverseyr,
      reverse             as Reverse,
      reverse_reason      as Reversereason,
      status              as Status,
      message             as Message,
      created_by          as CreatedBy,
      created_at          as CreatedAt,
      last_changed_by     as LastChangedBy,
      last_changed_at     as LastChangedAt,
      doctype             as Doctype,

      _Items
}
