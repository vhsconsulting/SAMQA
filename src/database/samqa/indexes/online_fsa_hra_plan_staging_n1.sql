create index samqa.online_fsa_hra_plan_staging_n1 on
    samqa.online_fsa_hra_plan_staging (
        enrollment_id
    );


-- sqlcl_snapshot {"hash":"ecf46a8cba36407b39ef6b69729a07637b10dc66","type":"INDEX","name":"ONLINE_FSA_HRA_PLAN_STAGING_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_FSA_HRA_PLAN_STAGING_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_FSA_HRA_PLAN_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENROLLMENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}