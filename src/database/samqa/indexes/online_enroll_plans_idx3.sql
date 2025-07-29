create index samqa.online_enroll_plans_idx3 on
    samqa.online_enroll_plans (
        batch_number
    );


-- sqlcl_snapshot {"hash":"fcd812aeeeeb216137c048a55dafccfe80d01b09","type":"INDEX","name":"ONLINE_ENROLL_PLANS_IDX3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_ENROLL_PLANS_IDX3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_ENROLL_PLANS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}