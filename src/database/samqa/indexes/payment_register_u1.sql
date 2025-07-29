create index samqa.payment_register_u1 on
    samqa.payment_register (
        payment_register_id
    );


-- sqlcl_snapshot {"hash":"a1bf44aa5a7d6c800944d8d54f5bec909d45a19a","type":"INDEX","name":"PAYMENT_REGISTER_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAYMENT_REGISTER_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAYMENT_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PAYMENT_REGISTER_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}