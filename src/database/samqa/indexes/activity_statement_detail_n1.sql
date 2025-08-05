create index samqa.activity_statement_detail_n1 on
    samqa.activity_statement_detail (
        statement_id
    );


-- sqlcl_snapshot {"hash":"14e0aa6c3e3fd50585453bbfa999956d2186f4c9","type":"INDEX","name":"ACTIVITY_STATEMENT_DETAIL_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACTIVITY_STATEMENT_DETAIL_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACTIVITY_STATEMENT_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>STATEMENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}