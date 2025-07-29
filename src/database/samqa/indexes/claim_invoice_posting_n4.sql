create index samqa.claim_invoice_posting_n4 on
    samqa.claim_invoice_posting (
        transaction_id
    );


-- sqlcl_snapshot {"hash":"37b578287ebf4142d19d08762aa40aef6e6fa74e","type":"INDEX","name":"CLAIM_INVOICE_POSTING_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_INVOICE_POSTING_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_INVOICE_POSTING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}