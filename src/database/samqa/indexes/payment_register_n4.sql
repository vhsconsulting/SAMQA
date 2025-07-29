create index samqa.payment_register_n4 on
    samqa.payment_register (
        claim_type
    );


-- sqlcl_snapshot {"hash":"bdd9f5c77c03b3a1677b8bf3e0626cded3bf40d0","type":"INDEX","name":"PAYMENT_REGISTER_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAYMENT_REGISTER_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAYMENT_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}