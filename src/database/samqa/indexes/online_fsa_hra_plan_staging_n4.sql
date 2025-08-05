create index samqa.online_fsa_hra_plan_staging_n4 on
    samqa.online_fsa_hra_plan_staging (
        org_ben_plan_id
    );


-- sqlcl_snapshot {"hash":"0459901d47ac51616dd9e98bbe3f368d252ada74","type":"INDEX","name":"ONLINE_FSA_HRA_PLAN_STAGING_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_FSA_HRA_PLAN_STAGING_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_FSA_HRA_PLAN_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ORG_BEN_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}