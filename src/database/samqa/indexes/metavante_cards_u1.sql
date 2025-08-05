create unique index samqa.metavante_cards_u1 on
    samqa.metavante_cards (
        metavante_card_id
    );


-- sqlcl_snapshot {"hash":"dbf941818d17cbe13049a8213c4cac9c67663177","type":"INDEX","name":"METAVANTE_CARDS_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_CARDS_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_CARDS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>METAVANTE_CARD_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}