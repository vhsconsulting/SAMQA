create index samqa.invoice_parameters_n2 on
    samqa.invoice_parameters (
        bank_acct_id
    );


-- sqlcl_snapshot {"hash":"85313a6ca20c411441eb10589948bed5638ad177","type":"INDEX","name":"INVOICE_PARAMETERS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_PARAMETERS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INVOICE_PARAMETERS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BANK_ACCT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}