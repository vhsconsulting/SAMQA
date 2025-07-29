create index samqa.claim_auto_process_n3 on
    samqa.claim_auto_process (
        process_status
    );


-- sqlcl_snapshot {"hash":"eb595897ee08ad8a470611450b32a3eb8130a289","type":"INDEX","name":"CLAIM_AUTO_PROCESS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_AUTO_PROCESS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_AUTO_PROCESS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PROCESS_STATUS</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}