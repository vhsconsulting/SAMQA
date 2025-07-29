create unique index samqa.expense_id_pk2 on
    samqa.eligibile_expenses_staging (
        expense_id
    );


-- sqlcl_snapshot {"hash":"d74a2512b358c6fd0a7541450293aae02d1c4d04","type":"INDEX","name":"EXPENSE_ID_PK2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EXPENSE_ID_PK2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ELIGIBILE_EXPENSES_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EXPENSE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}