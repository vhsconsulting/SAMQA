create index samqa.eb_settlement_2 on
    samqa.eb_settlement (
        claim_id
    );


-- sqlcl_snapshot {"hash":"04225c8faeba1a5fea5c2eeecf2e90e8f367ed3c","type":"INDEX","name":"EB_SETTLEMENT_2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EB_SETTLEMENT_2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EB_SETTLEMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}