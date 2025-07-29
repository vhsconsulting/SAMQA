create index samqa.demo_processed_yn on
    samqa.debit_card_updates (
        demo_processed
    );


-- sqlcl_snapshot {"hash":"b7ffcef1eacc23fdfc95f1774726183ece362a50","type":"INDEX","name":"DEMO_PROCESSED_YN","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEMO_PROCESSED_YN</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEBIT_CARD_UPDATES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>DEMO_PROCESSED</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}