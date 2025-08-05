create or replace force editionable view samqa.payees_v (
    vendor_name,
    address,
    city,
    state,
    zip,
    vendor_type,
    vendor_tax_id,
    acc_id,
    vendor_acc_num,
    vendor_id
) as
    select
        vendor_name,
        address1
        || ' '
        || address2 address,
        city,
        state,
        zip,
        vendor_type,
        vendor_tax_id,
        acc_id,
        vendor_acc_num,
        vendor_id
    from
        vendors;


-- sqlcl_snapshot {"hash":"34ad2ffddd4363fe746f2947f20e4f7543f0b64a","type":"VIEW","name":"PAYEES_V","schemaName":"SAMQA","sxml":""}