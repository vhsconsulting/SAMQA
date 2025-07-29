create index samqa.rate_plan_detail_n2 on
    samqa.rate_plan_detail (
        rate_plan_id
    );


-- sqlcl_snapshot {"hash":"e5a255deecbdfa9f879e3ed23bf2573d88d9bdf7","type":"INDEX","name":"RATE_PLAN_DETAIL_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>RATE_PLAN_DETAIL_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>RATE_PLAN_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>RATE_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}