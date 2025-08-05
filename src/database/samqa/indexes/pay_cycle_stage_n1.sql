create index samqa.pay_cycle_stage_n1 on
    samqa.pay_cycle_stage (
        enrollment_detail_id
    );


-- sqlcl_snapshot {"hash":"dc5b098408dbe2ee977b18ae822ebb08a0bea17c","type":"INDEX","name":"PAY_CYCLE_STAGE_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAY_CYCLE_STAGE_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAY_CYCLE_STAGE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENROLLMENT_DETAIL_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}