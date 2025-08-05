create index samqa.online_fsa_hra_plan_staging_n2 on
    samqa.online_fsa_hra_plan_staging (
        ben_plan_id
    );


-- sqlcl_snapshot {"hash":"9aad03a85fc80361f95de0df42dbca3e6164c6a5","type":"INDEX","name":"ONLINE_FSA_HRA_PLAN_STAGING_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_FSA_HRA_PLAN_STAGING_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_FSA_HRA_PLAN_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BEN_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}