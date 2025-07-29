create unique index samqa.debit_card_request_u1 on
    samqa.debit_card_request (
        debit_card_request_id
    );


-- sqlcl_snapshot {"hash":"a703927fef7d22b9df4301e83d76feecf69712de","type":"INDEX","name":"DEBIT_CARD_REQUEST_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEBIT_CARD_REQUEST_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEBIT_CARD_REQUEST</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>DEBIT_CARD_REQUEST_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}