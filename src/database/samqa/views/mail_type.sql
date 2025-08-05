create or replace force editionable view samqa.mail_type (
    lookup_name,
    mail_code,
    mail_name
) as
    select
        lookup_name,
        lookup_code mail_code,
        meaning     mail_name
    from
        lookups
    where
        lookup_name = 'MAIL_TYPE';


-- sqlcl_snapshot {"hash":"0b6608a192e72fdc24081f35643d899f0586255e","type":"VIEW","name":"MAIL_TYPE","schemaName":"SAMQA","sxml":""}