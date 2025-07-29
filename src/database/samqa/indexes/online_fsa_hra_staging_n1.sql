create index samqa.online_fsa_hra_staging_n1 on
    samqa.online_fsa_hra_staging (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"a74736bef49b62b6dab3b793eeef08126ef099d4","type":"INDEX","name":"ONLINE_FSA_HRA_STAGING_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_FSA_HRA_STAGING_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_FSA_HRA_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}