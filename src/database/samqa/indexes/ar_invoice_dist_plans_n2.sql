create index samqa.ar_invoice_dist_plans_n2 on
    samqa.ar_invoice_dist_plans (
        invoice_id,
        acc_id
    );


-- sqlcl_snapshot {"hash":"d9e509dddf9fc4d0fefede9c01cd61a6ad2dc654","type":"INDEX","name":"AR_INVOICE_DIST_PLANS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_DIST_PLANS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE_DIST_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}