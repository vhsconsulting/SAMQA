create index samqa.deductible_rule_detail_n1 on
    samqa.deductible_rule_detail (
        entity
    );


-- sqlcl_snapshot {"hash":"6b687e8c0cbb0c82d795a58e8d0e28b95b039a03","type":"INDEX","name":"DEDUCTIBLE_RULE_DETAIL_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEDUCTIBLE_RULE_DETAIL_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEDUCTIBLE_RULE_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTITY</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}