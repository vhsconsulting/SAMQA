create unique index samqa.ben_plan_enrollment_setup_u1 on
    samqa.ben_plan_enrollment_setup (
        ben_plan_id
    );


-- sqlcl_snapshot {"hash":"52debfe7247d9e650b269de6cdf12ac225d5c587","type":"INDEX","name":"BEN_PLAN_ENROLLMENT_SETUP_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_ENROLLMENT_SETUP_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_ENROLLMENT_SETUP</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BEN_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}