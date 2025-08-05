create index samqa.ben_plan_enrollment_setup_n11 on
    samqa.ben_plan_enrollment_setup (
        funding_options
    );


-- sqlcl_snapshot {"hash":"2eeb04e13dca739666f67df1006d4958648cf357","type":"INDEX","name":"BEN_PLAN_ENROLLMENT_SETUP_N11","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_ENROLLMENT_SETUP_N11</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_ENROLLMENT_SETUP</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>FUNDING_OPTIONS</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}