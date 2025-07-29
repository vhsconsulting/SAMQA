create index samqa.invoice_parameters_n4 on
    samqa.invoice_parameters (
        division_code
    );


-- sqlcl_snapshot {"hash":"906b62eb102708700f0141165fb02ab311deb15f","type":"INDEX","name":"INVOICE_PARAMETERS_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_PARAMETERS_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INVOICE_PARAMETERS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>DIVISION_CODE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}