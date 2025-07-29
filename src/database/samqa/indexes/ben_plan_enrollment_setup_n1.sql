create index samqa.ben_plan_enrollment_setup_n1 on
    samqa.ben_plan_enrollment_setup (
        acc_id
    );


-- sqlcl_snapshot {"hash":"b69f75d627f57ad7f488c0c22bb7fa75c41f1259","type":"INDEX","name":"BEN_PLAN_ENROLLMENT_SETUP_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_ENROLLMENT_SETUP_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_ENROLLMENT_SETUP</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}