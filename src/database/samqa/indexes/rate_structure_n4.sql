create index samqa.rate_structure_n4 on
    samqa.rate_structure (
        plan_type
    );


-- sqlcl_snapshot {"hash":"37d178a04dcfedd15ed40b203ed0315e049e29a4","type":"INDEX","name":"RATE_STRUCTURE_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>RATE_STRUCTURE_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>RATE_STRUCTURE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}