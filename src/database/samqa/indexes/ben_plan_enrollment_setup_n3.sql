create index samqa.ben_plan_enrollment_setup_n3 on
    samqa.ben_plan_enrollment_setup (
        acc_id,
        plan_start_date,
        plan_end_date
    );


-- sqlcl_snapshot {"hash":"05440aae11dac8268f7e737c18bc73d576aea42e","type":"INDEX","name":"BEN_PLAN_ENROLLMENT_SETUP_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_ENROLLMENT_SETUP_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_ENROLLMENT_SETUP</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_START_DATE</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_END_DATE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}