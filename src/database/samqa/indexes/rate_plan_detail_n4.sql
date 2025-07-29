create index samqa.rate_plan_detail_n4 on
    samqa.rate_plan_detail (
        rate_plan_id,
        rate_code
    );


-- sqlcl_snapshot {"hash":"177ad1235f3c7c219566d7147e690e489fb8b646","type":"INDEX","name":"RATE_PLAN_DETAIL_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>RATE_PLAN_DETAIL_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>RATE_PLAN_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>RATE_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>RATE_CODE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}