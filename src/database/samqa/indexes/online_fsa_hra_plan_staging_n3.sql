create index samqa.online_fsa_hra_plan_staging_n3 on
    samqa.online_fsa_hra_plan_staging (
        batch_number
    );


-- sqlcl_snapshot {"hash":"f59c914482933beee55adaea6be447936a86a587","type":"INDEX","name":"ONLINE_FSA_HRA_PLAN_STAGING_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_FSA_HRA_PLAN_STAGING_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_FSA_HRA_PLAN_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}