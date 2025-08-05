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


-- sqlcl_snapshot {"hash":"cc8e16ce00c6a077bd5b46412f6dc75631ff26cc","type":"MATERIALIZED_VIEW","name":"CRM_EMPLOYER_MV","schemaName":"SAMQA","sxml":"\n  <MATERIALIZED_VIEW xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CRM_EMPLOYER_MV</NAME>\n   <COL_LIST>\n      <COL_LIST_ITEM>\n         <NAME>ACC_NUM_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ACC_ID_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>BROKER_HASH_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SALES_DIRECTOR_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ACCOUNT_MANAGER_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ACCOUNTSTATUS_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ADDRESS_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>CITY_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>STATE_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ZIP_C</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>CRM_ID</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>CLIENTTYPE_C</NAME>\n      </COL_LIST_ITEM>\n   </COL_LIST>\n   <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n   <PHYSICAL_PROPERTIES>\n      <HEAP_TABLE></HEAP_TABLE>\n   </PHYSICAL_PROPERTIES>\n   <BUILD>IMMEDIATE</BUILD>\n   <REFRESH>\n      <COMPLETE></COMPLETE>\n      <LOCAL_ROLLBACK_SEGMENT>\n         <DEFAULT></DEFAULT>\n      </LOCAL_ROLLBACK_SEGMENT>\n      <CONSTRAINTS>ENFORCED</CONSTRAINTS>\n   </REFRESH>\n   \n</MATERIALIZED_VIEW>"}