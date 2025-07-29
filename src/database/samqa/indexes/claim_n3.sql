create index samqa.claim_n3 on
    samqa.claim (
        pers_patient
    );


-- sqlcl_snapshot {"hash":"a1e63934e5641747ee9a7cd703fa2e92c0f6a441","type":"INDEX","name":"CLAIM_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PERS_PATIENT</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}