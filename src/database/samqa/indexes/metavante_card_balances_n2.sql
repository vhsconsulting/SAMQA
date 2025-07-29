create index samqa.metavante_card_balances_n2 on
    samqa.metavante_card_balances (
        plan_type
    );


-- sqlcl_snapshot {"hash":"5c879167c8866e5e9073cc0694a0eb2ab641a04a","type":"INDEX","name":"METAVANTE_CARD_BALANCES_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_CARD_BALANCES_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_CARD_BALANCES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}