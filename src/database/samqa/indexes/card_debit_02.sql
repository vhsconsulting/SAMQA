create index samqa.card_debit_02 on
    samqa.card_debit (
        emitent
    );


-- sqlcl_snapshot {"hash":"03a9885c213d1dfc604f82dd0550e2c110cf28de","type":"INDEX","name":"CARD_DEBIT_02","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CARD_DEBIT_02</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CARD_DEBIT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EMITENT</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}