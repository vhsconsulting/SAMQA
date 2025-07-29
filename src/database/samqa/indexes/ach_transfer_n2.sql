create index samqa.ach_transfer_n2 on
    samqa.ach_transfer (
        transaction_type
    );


-- sqlcl_snapshot {"hash":"2c1814c7cf35e1ae427a6894f480df190559e34c","type":"INDEX","name":"ACH_TRANSFER_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACH_TRANSFER_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACH_TRANSFER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}