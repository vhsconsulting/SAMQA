create index samqa.eb_settlement_3 on
    samqa.eb_settlement (
        pers_id
    );


-- sqlcl_snapshot {"hash":"35b67b1d6650ada5edd315d7e91070447a03b37e","type":"INDEX","name":"EB_SETTLEMENT_3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EB_SETTLEMENT_3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EB_SETTLEMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PERS_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}