create index samqa.balance_register_v2 on
    samqa.balance_register (
        txn_date
    );


-- sqlcl_snapshot {"hash":"7b17ddf74b59c5399925ef998027bb8cd66e09d9","type":"INDEX","name":"BALANCE_REGISTER_V2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BALANCE_REGISTER_V2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BALANCE_REGISTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TXN_DATE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}