create index samqa.ben_life_event_history_b1 on
    samqa.ben_life_event_history (
        acc_num
    );


-- sqlcl_snapshot {"hash":"730452d71c0fee49bc4ca74c64b9743e9cb93e9f","type":"INDEX","name":"BEN_LIFE_EVENT_HISTORY_B1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_LIFE_EVENT_HISTORY_B1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_LIFE_EVENT_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}