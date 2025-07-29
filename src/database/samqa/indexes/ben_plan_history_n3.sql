create index samqa.ben_plan_history_n3 on
    samqa.ben_plan_history (
        life_event_code
    );


-- sqlcl_snapshot {"hash":"32e21452353b3e32d01938fa6414599ac7812b7a","type":"INDEX","name":"BEN_PLAN_HISTORY_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_HISTORY_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>LIFE_EVENT_CODE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}