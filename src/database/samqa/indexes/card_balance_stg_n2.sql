create index samqa.card_balance_stg_n2 on
    samqa.card_balance_stg (
        plan_type
    );


-- sqlcl_snapshot {"hash":"6478a4ca6d60c9a3e803c53dfc80b76ea4015919","type":"INDEX","name":"CARD_BALANCE_STG_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CARD_BALANCE_STG_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CARD_BALANCE_STG</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}