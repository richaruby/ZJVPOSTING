@EndUserText.label: 'FB70 Upload - Posted Today (API)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_FB70_PostedToday
  as select from zfb70_hdr
  
{
  key header_uuid         as Headeruuid,
  key company_code        as CompanyCode,
  key belnr               as AccountingDocument,
  key gjahr               as FiscalYear,
      posting_date        as PostingDate,
      transaction_type    as DocumentType,
      created_by          as CreatedBy,
      currency            as DocumentCurrency
}
where
    belnr <> ''
    and posting_date = $session.system_date
