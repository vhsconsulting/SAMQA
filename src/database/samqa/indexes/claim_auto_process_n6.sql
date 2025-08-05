create index samqa.claim_auto_process_n6 on
    samqa.claim_auto_process (
        batch_number
    );


-- sqlcl_snapshot {"hash":"efade52aada0496f874d170eef4a7dd516a0fba6","type":"INDEX","name":"CLAIM_AUTO_PROCESS_N6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_AUTO_PROCESS_N6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_AUTO_PROCESS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}