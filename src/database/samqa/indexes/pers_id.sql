create index samqa.pers_id on
    samqa.debit_card_updates (
        pers_id
    );


-- sqlcl_snapshot {"hash":"cddbe1eca88179fa5bdf09f73c38c2cf7e8405e6","type":"INDEX","name":"PERS_ID","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PERS_ID</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEBIT_CARD_UPDATES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PERS_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}