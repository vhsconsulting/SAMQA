create index samqa.scheduler_master_n2 on
    samqa.scheduler_master (
        contributor
    );


-- sqlcl_snapshot {"hash":"a387502f3add79494495f60c38bca147ace47854","type":"INDEX","name":"SCHEDULER_MASTER_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SCHEDULER_MASTER_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SCHEDULER_MASTER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CONTRIBUTOR</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}