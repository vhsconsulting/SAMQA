create index samqa.ar_invoice_dist_plans_n1 on
    samqa.ar_invoice_dist_plans (
        invoice_id
    );


-- sqlcl_snapshot {"hash":"a17a21d7e850a7d0251c3209ca53f6b57d55fcf6","type":"INDEX","name":"AR_INVOICE_DIST_PLANS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_DIST_PLANS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE_DIST_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}