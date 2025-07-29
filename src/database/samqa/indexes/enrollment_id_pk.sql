create unique index samqa.enrollment_id_pk on
    samqa.online_fsa_hra_staging (
        enrollment_id
    );


-- sqlcl_snapshot {"hash":"2fbdd980d9196211d1a7d0cb2bed353eb941693f","type":"INDEX","name":"ENROLLMENT_ID_PK","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_ID_PK</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_FSA_HRA_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENROLLMENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}