create or replace force editionable view samqa.toolkit_v (
    form_id,
    url,
    form_name,
    section_type,
    product_type
) as
    select
        form_id,
        file_name url,
        form_name,
        section_type,
        product_type
    from
        website_forms
    where
            company_name = 'SHA'
        and category = 'TOOLKIT';


-- sqlcl_snapshot {"hash":"d119d5fc3acface2f5781d5b86686c5f0fbaf9d0","type":"VIEW","name":"TOOLKIT_V","schemaName":"SAMQA","sxml":""}