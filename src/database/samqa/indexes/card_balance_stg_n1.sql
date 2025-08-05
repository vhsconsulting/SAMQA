create index samqa.card_balance_stg_n1 on
    samqa.card_balance_stg (
        employee_id
    );


-- sqlcl_snapshot {"hash":"1af4a0f745d291146a71fdbc1b00e2790d44f9ab","type":"INDEX","name":"CARD_BALANCE_STG_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CARD_BALANCE_STG_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CARD_BALANCE_STG</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EMPLOYEE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}