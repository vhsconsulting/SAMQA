create index samqa.er_balance_gt_n1 on
    samqa.er_balance_gt (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"d37fad892816f7f060056be9b0cfed025bb65d77","type":"INDEX","name":"ER_BALANCE_GT_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ER_BALANCE_GT_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ER_BALANCE_GT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}