create index samqa.ben_life_event_history_u1 on
    samqa.ben_life_event_history (
        life_event_id
    );


-- sqlcl_snapshot {"hash":"c471d78fac128b50ec30b13d58f1417dfe85b4ab","type":"INDEX","name":"BEN_LIFE_EVENT_HISTORY_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_LIFE_EVENT_HISTORY_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_LIFE_EVENT_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>LIFE_EVENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}