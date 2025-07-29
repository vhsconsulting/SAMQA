create index samqa.checks_batch_n2 on
    samqa.checks_batch (
        cobra_payment_id
    );


-- sqlcl_snapshot {"hash":"4ecb6550283c4a7f7d39b7ea37e8fd505f3397a1","type":"INDEX","name":"CHECKS_BATCH_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CHECKS_BATCH_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CHECKS_BATCH</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>COBRA_PAYMENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}