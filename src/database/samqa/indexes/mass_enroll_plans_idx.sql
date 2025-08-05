create index samqa.mass_enroll_plans_idx on
    samqa.mass_enroll_plans (
        mass_enrollment_id
    );


-- sqlcl_snapshot {"hash":"74c8ed28435d14968258cd8899733e72dd607a39","type":"INDEX","name":"MASS_ENROLL_PLANS_IDX","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>MASS_ENROLL_PLANS_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>MASS_ENROLL_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>MASS_ENROLLMENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}