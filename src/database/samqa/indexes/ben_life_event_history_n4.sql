create index samqa.ben_life_event_history_n4 on
    samqa.ben_life_event_history (
        ben_plan_id
    );


-- sqlcl_snapshot {"hash":"112fc87f70664223e76388d388ac4b142ebc44ef","type":"INDEX","name":"BEN_LIFE_EVENT_HISTORY_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_LIFE_EVENT_HISTORY_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_LIFE_EVENT_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BEN_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}