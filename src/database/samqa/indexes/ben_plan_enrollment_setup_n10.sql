create index samqa.ben_plan_enrollment_setup_n10 on
    samqa.ben_plan_enrollment_setup (
        product_type
    );


-- sqlcl_snapshot {"hash":"4e1e45e3d3e5e08629c79dfc3d4abe3fb9890ba7","type":"INDEX","name":"BEN_PLAN_ENROLLMENT_SETUP_N10","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_ENROLLMENT_SETUP_N10</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_ENROLLMENT_SETUP</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PRODUCT_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}