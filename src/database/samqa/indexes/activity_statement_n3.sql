create index samqa.activity_statement_n3 on
    samqa.activity_statement (
        batch_number
    );


-- sqlcl_snapshot {"hash":"af86381a4b5239ff859db6adebfa042e46826c05","type":"INDEX","name":"ACTIVITY_STATEMENT_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACTIVITY_STATEMENT_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACTIVITY_STATEMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}