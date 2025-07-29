create index samqa.plan_notices_n3 on
    samqa.plan_notices (
        test_result
    );


-- sqlcl_snapshot {"hash":"270679d619f8a732dbd2faac44513740c59aeb52","type":"INDEX","name":"PLAN_NOTICES_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PLAN_NOTICES_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PLAN_NOTICES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TEST_RESULT</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}