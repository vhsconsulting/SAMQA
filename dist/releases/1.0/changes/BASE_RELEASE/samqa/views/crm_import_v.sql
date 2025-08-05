-- liquibase formatted sql
-- changeset SAMQA:1754374171192 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\crm_import_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/crm_import_v.sql:null:669d3693586694a71da3d893ecafd8a4a8a1e512:create

create or replace force editionable view samqa.crm_import_v (
    entrp_id,
    acc_id,
    name,
    acc_num,
    website,
    entrp_email,
    entrp_phones,
    alternate_phone,
    entrp_fax,
    address,
    city,
    state,
    zip,
    country,
    shipping_street,
    shipping_city,
    shipping_state,
    shipping_postal_code,
    shipping_country,
    description,
    a_type,
    industry,
    annual_revenue,
    employees,
    sic_code,
    ticker,
    parent_account_id,
    ownership,
    campaign_id,
    rating,
    assigned_user_name,
    assigned_to,
    date_created,
    date_modified,
    modified_by,
    created_by,
    deleted,
    acc_manager,
    salesrep_id,
    client_type,
    account_status,
    broker_id,
    broker_lic,
    broker_name,
    end_date,
    ein
) as
    select
        a.entrp_id,
        b.acc_id,
        a.name,
        b.acc_num                                 acc_num,
        null                                      website,
        a.entrp_email,
        a.entrp_phones,
        null                                      alternate_phone,
        a.entrp_fax,
        a.address,
        a.city,
        a.state,
        a.zip,
        'USA'                                     country,
        null                                      shipping_street,
        null                                      shipping_city,
        null                                      shipping_state,
        null                                      shipping_postal_code,
        null                                      shipping_country,
        a.note                                    description,
        b.account_type                            a_type,
        null                                      industry,
        null                                      annual_revenue,
        null                                      employees,
        a.entrp_code                              sic_code,
        null                                      ticker,
        b.acc_id                                  parent_account_id,
        null                                      ownership,
        null                                      campaign_id,
        null                                      rating,
        'admin'                                   assigned_user_name,
        null                                      assigned_to,
        to_char(b.creation_date, 'MM/DD/YYYY')    date_created,
        to_char(b.last_update_date, 'MM/DD/YYYY') date_modified,
        null                                      modified_by,
        null                                      created_by,
        null                                      deleted,
        (
            select
                salesrep_id
            from
                salesrep c
            where
                    role_type = 'AM'
                and c.salesrep_id = b.salesrep_id
        )                                         am,
        (
            select
                salesrep_id
            from
                salesrep c
            where
                    role_type = 'SALESREP'
                and c.salesrep_id = b.salesrep_id
        )                                         salesrep_id,
        'Employer'                                client_type,
        b.account_status,
        b.broker_id,
        pc_broker.get_broker_lic(b.broker_id)     broker_lic,
        pc_broker.get_broker_name(b.broker_id)    broker_name,
        to_char(b.end_date, 'YYYY-MM-DD')         close_date,
        a.entrp_code                              ein
    from
        enterprise a,
        account    b
    where
        a.entrp_id = b.entrp_id;

