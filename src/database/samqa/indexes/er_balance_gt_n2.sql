create index samqa.er_balance_gt_n2 on
    samqa.er_balance_gt (
        product_type
    );


-- sqlcl_snapshot {"hash":"a6dbbde6c05fef337424335c8f2c00e9516a1bd4","type":"INDEX","name":"ER_BALANCE_GT_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ER_BALANCE_GT_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ER_BALANCE_GT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PRODUCT_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}