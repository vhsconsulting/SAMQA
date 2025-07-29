create index samqa.ben_plan_renewals_idx on
    samqa.ben_plan_renewals (
        ben_plan_id
    );


-- sqlcl_snapshot {"hash":"a154205ec236f7f46887280df9eb31ede4bd6c35","type":"INDEX","name":"BEN_PLAN_RENEWALS_IDX","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_RENEWALS_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_RENEWALS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BEN_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}