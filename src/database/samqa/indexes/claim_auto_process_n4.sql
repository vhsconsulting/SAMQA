create index samqa.claim_auto_process_n4 on
    samqa.claim_auto_process (
        invoice_status
    );


-- sqlcl_snapshot {"hash":"6a3474b3709e21ebeb5c81c701c9f5d4c4ef552e","type":"INDEX","name":"CLAIM_AUTO_PROCESS_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_AUTO_PROCESS_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_AUTO_PROCESS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_STATUS</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}