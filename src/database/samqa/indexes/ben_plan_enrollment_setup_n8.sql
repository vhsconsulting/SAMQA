create index samqa.ben_plan_enrollment_setup_n8 on
    samqa.ben_plan_enrollment_setup (
        ben_plan_id_main
    );


-- sqlcl_snapshot {"hash":"5f71d3a9326c9906f0c7743d5648482c054e8040","type":"INDEX","name":"BEN_PLAN_ENROLLMENT_SETUP_N8","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_ENROLLMENT_SETUP_N8</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_ENROLLMENT_SETUP</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BEN_PLAN_ID_MAIN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}