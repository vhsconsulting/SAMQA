create index samqa.claim_auto_process_n2 on
    samqa.claim_auto_process (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"63216a8386723f00e904a6f9feeca30b0bb771c2","type":"INDEX","name":"CLAIM_AUTO_PROCESS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_AUTO_PROCESS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_AUTO_PROCESS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}