create index samqa.ben_plan_denials_idx on
    samqa.ben_plan_denials (
        ben_plan_id
    );


-- sqlcl_snapshot {"hash":"3e45d0e14f4be1ca8d15165d75c4f62556d42012","type":"INDEX","name":"BEN_PLAN_DENIALS_IDX","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_DENIALS_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_DENIALS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BEN_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}