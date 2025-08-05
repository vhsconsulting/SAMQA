create index samqa.pay_cycle_stage_n2 on
    samqa.pay_cycle_stage (
        ben_plan_id
    );


-- sqlcl_snapshot {"hash":"d1d38b397a786c14d32d8958945cc16bf9de0bbc","type":"INDEX","name":"PAY_CYCLE_STAGE_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAY_CYCLE_STAGE_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PAY_CYCLE_STAGE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BEN_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}