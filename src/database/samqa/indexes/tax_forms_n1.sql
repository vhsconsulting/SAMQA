create index samqa.tax_forms_n1 on
    samqa.tax_forms (
        acc_id
    );


-- sqlcl_snapshot {"hash":"7672c1307dc640e4489022784a0a843f2e2763a9","type":"INDEX","name":"TAX_FORMS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>TAX_FORMS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>TAX_FORMS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}