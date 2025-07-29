create index samqa.employer_payment_detail_u2 on
    samqa.employer_payment_detail (
        transaction_id
    );


-- sqlcl_snapshot {"hash":"53064496e31d9f7b224ae93a1cb05e64c89f0f0d","type":"INDEX","name":"EMPLOYER_PAYMENT_DETAIL_U2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_PAYMENT_DETAIL_U2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_PAYMENT_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}