create index samqa.ar_invoice_dist_plans_n3 on
    samqa.ar_invoice_dist_plans (
        invoice_id,
        entrp_id
    );


-- sqlcl_snapshot {"hash":"ed95ec916cad685a9343547336e1ddde715a61e2","type":"INDEX","name":"AR_INVOICE_DIST_PLANS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_DIST_PLANS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE_DIST_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}