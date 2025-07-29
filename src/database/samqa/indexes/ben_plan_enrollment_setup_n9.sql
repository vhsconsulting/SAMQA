create index samqa.ben_plan_enrollment_setup_n9 on
    samqa.ben_plan_enrollment_setup (
        plan_type
    );


-- sqlcl_snapshot {"hash":"41c26e4589e3b276083a9c98b12f745e5f99941f","type":"INDEX","name":"BEN_PLAN_ENROLLMENT_SETUP_N9","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_ENROLLMENT_SETUP_N9</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_ENROLLMENT_SETUP</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}