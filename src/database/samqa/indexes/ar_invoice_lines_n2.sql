create index samqa.ar_invoice_lines_n2 on
    samqa.ar_invoice_lines (
        rate_code
    );


-- sqlcl_snapshot {"hash":"4e55fd03854ed7aa9689768c8e94313c3f68d1a1","type":"INDEX","name":"AR_INVOICE_LINES_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_LINES_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE_LINES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>RATE_CODE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}