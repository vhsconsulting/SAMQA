create index samqa.income_f3 on
    samqa.income ( trunc(due_date, 'fmmm') );


-- sqlcl_snapshot {"hash":"bea3dee823e679bb44ee63134fc7cee5cb1c77a9","type":"INDEX","name":"INCOME_F3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INCOME_F3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INCOME</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRUNC(\"DUE_DATE\",'fmmm')</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}