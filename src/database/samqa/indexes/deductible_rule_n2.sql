create index samqa.deductible_rule_n2 on
    samqa.deductible_rule (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"e5bee88b7abcf010a8ed0e90e20f45f502e2e59d","type":"INDEX","name":"DEDUCTIBLE_RULE_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEDUCTIBLE_RULE_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEDUCTIBLE_RULE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}