create index samqa.mass_enroll_plans_n2 on
    samqa.mass_enroll_plans (
        ben_plan_id
    );


-- sqlcl_snapshot {"hash":"5d46e1178c49b7a46028ddccd94a61f5b6c6272d","type":"INDEX","name":"MASS_ENROLL_PLANS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>MASS_ENROLL_PLANS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>MASS_ENROLL_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BEN_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}