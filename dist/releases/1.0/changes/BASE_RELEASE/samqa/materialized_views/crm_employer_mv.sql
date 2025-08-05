-- liquibase formatted sql
-- changeset SAMQA:1754373935081 stripComments:false logicalFilePath:BASE_RELEASE\samqa\materialized_views\crm_employer_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/materialized_views/crm_employer_mv.sql:null:cc8e16ce00c6a077bd5b46412f6dc75631ff26cc:create

create materialized view samqa.crm_employer_mv (
    acc_num_c,
    acc_id_c,
    broker_hash_c,
    sales_director_c,
    account_manager_c,
    accountstatus_c,
    address_c,
    city_c,
    state_c,
    zip_c,
    crm_id,
    clienttype_c
) build immediate using index
    refresh complete
    on demand
    using enforced constraints
    disable on query computation
    disable query rewrite
as
    select
        "acc_num_c"                    acc_num_c,
        "acc_id_c"                     acc_id_c,
        "broker_hash_c"                broker_hash_c,
        "sales_director_c"             sales_director_c,
        "account_manager_c"            account_manager_c,
        "accountstatus_c"              accountstatus_c,
        c."billing_address_street"     address_c,
        c."billing_address_city"       city_c,
        c."billing_address_state"      state_c,
        c."billing_address_postalcode" zip_c,
        c."id"                         crm_id,
        "clienttype_c"                 clienttype_c
    from
        "accounts_cstm"@sugarprod a,
        "accounts"@sugarprod      c
    where
        c."id" = a."id_c";

