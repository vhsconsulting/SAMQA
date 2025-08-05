create index samqa.metavante_card_balances_u1 on
    samqa.metavante_card_balances (
        acc_num
    );


-- sqlcl_snapshot {"hash":"6bbf9b2c21b5d4814d2e0c7243d51200ff191350","type":"INDEX","name":"METAVANTE_CARD_BALANCES_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_CARD_BALANCES_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_CARD_BALANCES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}