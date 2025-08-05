create index samqa.rate_plan_detail_u7 on
    samqa.rate_plan_detail (
        plan_id
    );


-- sqlcl_snapshot {"hash":"7c3bbd6f818e502c65b3f19f437e29318033d55a","type":"INDEX","name":"RATE_PLAN_DETAIL_U7","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>RATE_PLAN_DETAIL_U7</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>RATE_PLAN_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}