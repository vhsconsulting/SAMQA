create index samqa.portfolio_accounts_n3 on
    samqa.portfolio_accounts (
        entity_type,
        entity_id
    );


-- sqlcl_snapshot {"hash":"67f4d7d687e5fb58e4bdfbfa703af66e9f43adf5","type":"INDEX","name":"PORTFOLIO_ACCOUNTS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PORTFOLIO_ACCOUNTS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PORTFOLIO_ACCOUNTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTITY_TYPE</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ENTITY_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}