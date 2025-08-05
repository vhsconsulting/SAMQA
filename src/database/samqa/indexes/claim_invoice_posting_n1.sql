create index samqa.claim_invoice_posting_n1 on
    samqa.claim_invoice_posting (
        claim_id
    );


-- sqlcl_snapshot {"hash":"bb17e9b55a2eeb8d7dcd919763cb094988ac83ac","type":"INDEX","name":"CLAIM_INVOICE_POSTING_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_INVOICE_POSTING_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_INVOICE_POSTING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}