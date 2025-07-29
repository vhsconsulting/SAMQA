create index samqa.ar_invoice_n4 on
    samqa.ar_invoice (
        bank_acct_id
    );


-- sqlcl_snapshot {"hash":"93b869884bccaea124cf4a7ef69e49db9e53a367","type":"INDEX","name":"AR_INVOICE_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BANK_ACCT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}