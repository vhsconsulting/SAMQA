create index samqa.mass_enroll_plans_n3 on
    samqa.mass_enroll_plans (
        effective_date,
        plan_type
    );


-- sqlcl_snapshot {"hash":"5041c502747a38bb22b8e68a7306578c6f8cd192","type":"INDEX","name":"MASS_ENROLL_PLANS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>MASS_ENROLL_PLANS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>MASS_ENROLL_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EFFECTIVE_DATE</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}