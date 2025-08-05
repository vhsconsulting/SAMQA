create index samqa.online_fsa_hra_plan_staging_n5 on
    samqa.online_fsa_hra_plan_staging (
        plan_type
    );


-- sqlcl_snapshot {"hash":"d924beaab86991f9bb1ef72ee5c48a1f43328e04","type":"INDEX","name":"ONLINE_FSA_HRA_PLAN_STAGING_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_FSA_HRA_PLAN_STAGING_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_FSA_HRA_PLAN_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}