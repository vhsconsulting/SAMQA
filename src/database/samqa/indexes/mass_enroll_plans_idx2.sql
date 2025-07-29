create index samqa.mass_enroll_plans_idx2 on
    samqa.mass_enroll_plans (
        batch_number
    );


-- sqlcl_snapshot {"hash":"ede49a42a5a982e06a11ec6a40b8de43c317b58a","type":"INDEX","name":"MASS_ENROLL_PLANS_IDX2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>MASS_ENROLL_PLANS_IDX2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>MASS_ENROLL_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}