create unique index samqa.deposit_register_u1 on
    samqa.deposit_register (
        deposit_register_id
    );


-- sqlcl_snapshot {"hash":"9627995135df913b454f957e824721c8cd4df366","type":"INDEX","name":"DEPOSIT_REGISTER_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEPOSIT_REGISTER_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEPOSIT_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>DEPOSIT_REGISTER_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}