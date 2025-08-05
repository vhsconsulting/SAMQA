create index samqa.payroll_contribution_n1 on
    samqa.payroll_contribution (
        invoice_id
    );


-- sqlcl_snapshot {"hash":"1999862fee089905ae3304ea9bc236981f7281b8","type":"INDEX","name":"PAYROLL_CONTRIBUTION_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAYROLL_CONTRIBUTION_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAYROLL_CONTRIBUTION</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}