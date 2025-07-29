create index samqa.income_f2 on
    samqa.income ( trunc(fee_date) );


-- sqlcl_snapshot {"hash":"839ef40e61a1db9909f0c21e445c3e6757f0d696","type":"INDEX","name":"INCOME_F2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INCOME_F2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INCOME</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRUNC(\"FEE_DATE\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}