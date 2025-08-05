create unique index samqa.enrollment_detail_id_pk on
    samqa.online_fsa_hra_plan_staging (
        enrollment_detail_id
    );


-- sqlcl_snapshot {"hash":"07980b43e9061dce0204ffb0cc6e372164a910ae","type":"INDEX","name":"ENROLLMENT_DETAIL_ID_PK","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_DETAIL_ID_PK</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_FSA_HRA_PLAN_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENROLLMENT_DETAIL_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}