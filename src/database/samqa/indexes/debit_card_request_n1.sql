create index samqa.debit_card_request_n1 on
    samqa.debit_card_request (
        card_id
    );


-- sqlcl_snapshot {"hash":"55c5e4b7bf52290292135d02b3535b552084d63c","type":"INDEX","name":"DEBIT_CARD_REQUEST_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEBIT_CARD_REQUEST_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEBIT_CARD_REQUEST</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CARD_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}