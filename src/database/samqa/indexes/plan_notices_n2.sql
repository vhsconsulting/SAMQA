create index samqa.plan_notices_n2 on
    samqa.plan_notices (
        notice_type
    );


-- sqlcl_snapshot {"hash":"46f606ba1d4010eb349847b0b46148306ac94125","type":"INDEX","name":"PLAN_NOTICES_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PLAN_NOTICES_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PLAN_NOTICES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>NOTICE_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}