create index samqa.rate_plan_detail_n3 on
    samqa.rate_plan_detail (
        coverage_type
    );


-- sqlcl_snapshot {"hash":"77ad312dea18067fe832d75d6e1abd42f704f250","type":"INDEX","name":"RATE_PLAN_DETAIL_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>RATE_PLAN_DETAIL_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>RATE_PLAN_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>COVERAGE_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}