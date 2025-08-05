create index samqa.claim_invoice_posting_n3 on
    samqa.claim_invoice_posting (
        change_num
    );


-- sqlcl_snapshot {"hash":"4af1c04696cadb6456cef5f7fa43d9341d7e7ab7","type":"INDEX","name":"CLAIM_INVOICE_POSTING_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_INVOICE_POSTING_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_INVOICE_POSTING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CHANGE_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}