create index samqa.employer_health_plans_n1 on
    samqa.employer_health_plans (
        health_plan_id,
        entrp_id
    );


-- sqlcl_snapshot {"hash":"9f94c1934d42b3bbed1dd95a49e11c849c17bbc9","type":"INDEX","name":"EMPLOYER_HEALTH_PLANS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_HEALTH_PLANS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_HEALTH_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>HEALTH_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}