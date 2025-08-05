create or replace force editionable view samqa.website_forms_v (
    form_id,
    form_name,
    file_name,
    product_type,
    company_name,
    url,
    note,
    mmyyyy,
    creation_date,
    created_by,
    last_updated_date,
    last_updated_by
) as
    select
        form_id,
        form_name,
        file_name,
        product_type,
        company_name,
        url,
        note,
        to_char(sysdate, 'MMYYYY') mmyyyy,
        sysdate                    creation_date,
        get_user_id(v('APP_USER')) created_by,
        sysdate                    last_updated_date,
        get_user_id(v('APP_USER')) last_updated_by
    from
        website_forms;


-- sqlcl_snapshot {"hash":"7241551c6b67005fbf6cf5ce44243cdd2cfc3906","type":"VIEW","name":"WEBSITE_FORMS_V","schemaName":"SAMQA","sxml":""}