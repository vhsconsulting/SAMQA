create index samqa.scheduler_master_n5 on
    samqa.scheduler_master ( trunc(payment_start_date),
    trunc(payment_end_date) );


-- sqlcl_snapshot {"hash":"45c9a99d0ead36c0d19e9e25c8c1790d8e92082f","type":"INDEX","name":"SCHEDULER_MASTER_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SCHEDULER_MASTER_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SCHEDULER_MASTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRUNC(\"PAYMENT_START_DATE\")</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>TRUNC(\"PAYMENT_END_DATE\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}