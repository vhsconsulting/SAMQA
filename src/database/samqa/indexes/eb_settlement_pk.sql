create index samqa.eb_settlement_pk on
    samqa.eb_settlement (
        settle_num
    );


-- sqlcl_snapshot {"hash":"62c1e33312105020d4fba6d62c5acb7978089fcb","type":"INDEX","name":"EB_SETTLEMENT_PK","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EB_SETTLEMENT_PK</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EB_SETTLEMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SETTLE_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}