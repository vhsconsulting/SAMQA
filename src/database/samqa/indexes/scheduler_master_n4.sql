create index samqa.scheduler_master_n4 on
    samqa.scheduler_master (
        payment_method
    );


-- sqlcl_snapshot {"hash":"6b96688d64235ca2fc26ce8fd322b16f37a70922","type":"INDEX","name":"SCHEDULER_MASTER_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SCHEDULER_MASTER_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SCHEDULER_MASTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PAYMENT_METHOD</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}