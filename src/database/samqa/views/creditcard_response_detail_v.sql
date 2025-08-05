create or replace force editionable view samqa.creditcard_response_detail_v (
    batch_number,
    invoice_id,
    cc_amount,
    session_id,
    cust_first_name,
    cust_last_name,
    billing_address1,
    billing_address2,
    billing_city,
    billing_state,
    billing_zip,
    transaction_id,
    transaction_response_code,
    auth_code,
    msg_code,
    transaction_description,
    account_type,
    account_number,
    transaction_time,
    creation_date
) as
    select
        batch_number,
        invoice_id,
        cc_amount,
        session_id,
        cust_first_name,
        cust_last_name,
        billing_address1,
        billing_address2,
        billing_city,
        billing_state,
        billing_zip,
        transaction_id,
        transaction_response_code,
        auth_code,
        msg_code,
        transaction_description,
        account_type,
        account_number,
        transaction_time,
        sysdate creation_date
    from
        creditcard_response_detail,
        json_table ( creditcard_response_detail.document_data, '$[*]'
                columns (
                    invoice_id varchar2 ( 255 ) path '$.transactResponse.invoice_id',
                    cc_amount varchar2 ( 255 ) path '$.transactResponse.invoice_amount',
                    session_id varchar2 ( 255 ) path '$.transactResponse.session_id',
                    cust_first_name varchar2 ( 255 ) path '$.transactResponse.cust_first_name',
                    cust_last_name varchar2 ( 255 ) path '$.transactResponse.cust_last_name',
                    billing_address1 varchar2 ( 255 ) path '$.transactResponse.billing_address1',
                    billing_address2 varchar2 ( 255 ) path '$.transactResponse.billing_address2',
                    billing_city varchar2 ( 255 ) path '$.transactResponse.billing_city',
                    billing_state varchar2 ( 255 ) path '$.transactResponse.billing_state',
                    billing_zip varchar2 ( 255 ) path '$.transactResponse.billing_zip',
                    transaction_id varchar2 ( 255 ) path '$.transactResponse.transaction_id',
                    transaction_response_code varchar2 ( 255 ) path '$.transactResponse.transaction_response_code',
                    auth_code varchar2 ( 255 ) path '$.transactResponse.auth_code',
                    msg_code varchar2 ( 255 ) path '$.transactResponse.ref_id',
                    account_type varchar2 ( 255 ) path '$.transactResponse.account_type',
                    account_number varchar2 ( 255 ) path '$.transactResponse.account_number',
                    transaction_time varchar2 ( 255 ) path '$.transactResponse.dateTime',
                    transaction_description varchar2 ( 255 ) path '$.transactResponse.transaction_description'
                )
            )
        as jbios
    where
        document_type = 'FEE_CC_PAYMENT';


-- sqlcl_snapshot {"hash":"b58d0277cf4863a641d34e2d5b3544150bba4b18","type":"VIEW","name":"CREDITCARD_RESPONSE_DETAIL_V","schemaName":"SAMQA","sxml":""}