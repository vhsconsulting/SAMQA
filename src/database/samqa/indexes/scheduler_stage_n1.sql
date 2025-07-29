create unique index samqa.scheduler_stage_n1 on
    samqa.scheduler_stage (
        scheduler_stage_id
    );


-- sqlcl_snapshot {"hash":"c9dd68fcbf444e52006001857b3e35ef6657fe6e","type":"INDEX","name":"SCHEDULER_STAGE_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SCHEDULER_STAGE_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SCHEDULER_STAGE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SCHEDULER_STAGE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}