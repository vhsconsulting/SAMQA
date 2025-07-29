create index samqa.ar_invoice_n6 on
    samqa.ar_invoice (
        batch_number
    );


-- sqlcl_snapshot {"hash":"e00f4d991736f8665b8498978e2f681ddbc8b393","type":"INDEX","name":"AR_INVOICE_N6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_N6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}