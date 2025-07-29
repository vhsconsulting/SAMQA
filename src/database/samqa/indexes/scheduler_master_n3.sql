create index samqa.scheduler_master_n3 on
    samqa.scheduler_master (
        bank_acct_id
    );


-- sqlcl_snapshot {"hash":"53b3a32617b1860f101a850060fc47f888b01220","type":"INDEX","name":"SCHEDULER_MASTER_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SCHEDULER_MASTER_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SCHEDULER_MASTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BANK_ACCT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}