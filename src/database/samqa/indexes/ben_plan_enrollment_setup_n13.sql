create index samqa.ben_plan_enrollment_setup_n13 on
    samqa.ben_plan_enrollment_setup (
        claim_reimbursed_by
    );


-- sqlcl_snapshot {"hash":"0d9bdaeb5267fa9f4dbba246149a18922b160592","type":"INDEX","name":"BEN_PLAN_ENROLLMENT_SETUP_N13","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_ENROLLMENT_SETUP_N13</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_ENROLLMENT_SETUP</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_REIMBURSED_BY</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}