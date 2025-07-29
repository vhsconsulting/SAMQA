create index samqa.ben_plan_history_n2 on
    samqa.ben_plan_history (
        plan_type
    );


-- sqlcl_snapshot {"hash":"66fe95893e6ef98fe1060b61fcecfb74eab5f61e","type":"INDEX","name":"BEN_PLAN_HISTORY_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_HISTORY_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}