create index samqa.payment_register_n6 on
    samqa.payment_register (
        claim_id
    );


-- sqlcl_snapshot {"hash":"964d1a26acdf8c6e4bd0a35dcb0bab3bb94138c4","type":"INDEX","name":"PAYMENT_REGISTER_N6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAYMENT_REGISTER_N6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAYMENT_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}