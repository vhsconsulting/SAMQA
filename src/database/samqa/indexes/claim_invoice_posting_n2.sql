create index samqa.claim_invoice_posting_n2 on
    samqa.claim_invoice_posting (
        invoice_id
    );


-- sqlcl_snapshot {"hash":"d02de3b190258e47c95dc458a2b59d14c4e0ff90","type":"INDEX","name":"CLAIM_INVOICE_POSTING_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_INVOICE_POSTING_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_INVOICE_POSTING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}