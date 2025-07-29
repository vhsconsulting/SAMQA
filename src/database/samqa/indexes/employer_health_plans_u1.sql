create index samqa.employer_health_plans_u1 on
    samqa.employer_health_plans (
        health_plan_id
    );


-- sqlcl_snapshot {"hash":"2ac74baf0fb7060aeb03377cb948fb2344b4cb57","type":"INDEX","name":"EMPLOYER_HEALTH_PLANS_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_HEALTH_PLANS_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_HEALTH_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>HEALTH_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}