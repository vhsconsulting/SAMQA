create index samqa.ach_transfer_n3 on
    samqa.ach_transfer ( trunc(transaction_date) );


-- sqlcl_snapshot {"hash":"debea078788c9fe39ba3a6f64bf84a99e6205b35","type":"INDEX","name":"ACH_TRANSFER_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACH_TRANSFER_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACH_TRANSFER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRUNC(\"TRANSACTION_DATE\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}