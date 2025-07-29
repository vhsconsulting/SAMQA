create index samqa.online_hfsa_enroll_stage_n2 on
    samqa.online_hfsa_enroll_stage (
        plan_type
    );


-- sqlcl_snapshot {"hash":"2440e7a4b112c51457fa739ab51c2162d979d059","type":"INDEX","name":"ONLINE_HFSA_ENROLL_STAGE_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_HFSA_ENROLL_STAGE_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_HFSA_ENROLL_STAGE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}