create unique index samqa.expense_id_pk on
    samqa.plan_eligibile_expenses (
        expense_id
    );


-- sqlcl_snapshot {"hash":"70954cf555f07603959933052a83999db6f6f137","type":"INDEX","name":"EXPENSE_ID_PK","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EXPENSE_ID_PK</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PLAN_ELIGIBILE_EXPENSES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EXPENSE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}