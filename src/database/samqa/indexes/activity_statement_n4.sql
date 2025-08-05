create index samqa.activity_statement_n4 on
    samqa.activity_statement (
        acc_num
    );


-- sqlcl_snapshot {"hash":"69ed3eec5d0ff40f6b3604ac2281f45bdc3ddf1f","type":"INDEX","name":"ACTIVITY_STATEMENT_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACTIVITY_STATEMENT_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACTIVITY_STATEMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}