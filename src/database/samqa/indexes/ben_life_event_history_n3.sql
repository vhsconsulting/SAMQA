create index samqa.ben_life_event_history_n3 on
    samqa.ben_life_event_history (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"4c4ddb05e9389e22d9104fc79c5ac47546bf5932","type":"INDEX","name":"BEN_LIFE_EVENT_HISTORY_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_LIFE_EVENT_HISTORY_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_LIFE_EVENT_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}