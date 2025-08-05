-- liquibase formatted sql
-- changeset SAMQA:1754374171303 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\crm_subscriber_import_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/crm_subscriber_import_v.sql:null:5d9d0cbb457dae85056d3489e1be9fd421817058:create

create or replace force editionable view samqa.crm_subscriber_import_v (
    pers_id,
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
    end_date
) as
    select
        a.pers_id,
        b.acc_id,
        a.first_name
        || ' '
        || a.last_name,
        b.acc_num                                 acc_num,
        null                                      website,
        a.email,
        a.phone_day,
        a.phone_even                              alternate_phone,
        null,
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
        null                                      sic_code,
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
        'Subscriber'                              client_type,
        b.account_status,
        b.broker_id,
        pc_broker.get_broker_lic(b.broker_id)     broker_lic,
        pc_broker.get_broker_name(b.broker_id)    broker_name,
        to_char(b.end_date, 'MM/DD/YYYY')         close_date
    from
        person  a,
        account b
    where
            a.pers_id = b.pers_id
        and b.account_status = 1
        and b.account_type = 'HSA'
    union
    select
        a.pers_id,
        b.acc_id,
        a.first_name
        || ' '
        || a.last_name,
        b.acc_num                                 acc_num,
        null                                      website,
        a.email,
        a.phone_day,
        a.phone_even                              alternate_phone,
        null,
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
        null                                      sic_code,
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
        'Subscriber'                              client_type,
        b.account_status,
        b.broker_id,
        pc_broker.get_broker_lic(b.broker_id)     broker_lic,
        pc_broker.get_broker_name(b.broker_id)    broker_name,
        to_char(b.end_date, 'MM/DD/YYYY')         close_date
    from
        person  a,
        account b
    where
            a.pers_id = b.pers_id
        and b.account_status = 1
        and b.account_type in ( 'HRA', 'FSA' )
        and exists (
            select
                *
            from
                ben_plan_enrollment_setup c
            where
                    c.acc_id = b.acc_id
                and c.plan_end_date > sysdate
        );

