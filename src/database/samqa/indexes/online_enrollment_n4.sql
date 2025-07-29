create index samqa.online_enrollment_n4 on
    samqa.online_enrollment (
        batch_number,
        entrp_id,
        ssn
    );


-- sqlcl_snapshot {"hash":"0dbafff224ecdab00107c3a15cf76654cc55fafe","type":"INDEX","name":"ONLINE_ENROLLMENT_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_ENROLLMENT_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_ENROLLMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}