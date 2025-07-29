create index samqa.payment_register_n1 on
    samqa.payment_register (
        batch_number
    );


-- sqlcl_snapshot {"hash":"5e346ad02bd419740a332d8ad90b23ac340ca23f","type":"INDEX","name":"PAYMENT_REGISTER_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAYMENT_REGISTER_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAYMENT_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}