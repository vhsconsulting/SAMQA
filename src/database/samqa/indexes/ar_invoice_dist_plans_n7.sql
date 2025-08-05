create index samqa.ar_invoice_dist_plans_n7 on
    samqa.ar_invoice_dist_plans (
        product_type
    );


-- sqlcl_snapshot {"hash":"a7b331947c566eebd9fd6345b7fdfa49eb934f00","type":"INDEX","name":"AR_INVOICE_DIST_PLANS_N7","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_DIST_PLANS_N7</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE_DIST_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PRODUCT_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}