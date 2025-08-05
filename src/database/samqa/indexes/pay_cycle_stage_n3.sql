create index samqa.pay_cycle_stage_n3 on
    samqa.pay_cycle_stage (
        batch_number
    );


-- sqlcl_snapshot {"hash":"e97c74d9951730958b7e5f1834a4b3b12a1764a9","type":"INDEX","name":"PAY_CYCLE_STAGE_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAY_CYCLE_STAGE_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAY_CYCLE_STAGE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}