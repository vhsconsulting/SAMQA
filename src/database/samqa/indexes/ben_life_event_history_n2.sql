create index samqa.ben_life_event_history_n2 on
    samqa.ben_life_event_history (
        acc_id
    );


-- sqlcl_snapshot {"hash":"43533f8b23b2a48513a301f063f7321a7856f378","type":"INDEX","name":"BEN_LIFE_EVENT_HISTORY_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_LIFE_EVENT_HISTORY_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_LIFE_EVENT_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}