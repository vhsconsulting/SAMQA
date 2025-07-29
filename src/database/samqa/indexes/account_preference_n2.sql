create index samqa.account_preference_n2 on
    samqa.account_preference (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"cb612f1cd689a31051f9fb4197dc8a1a2c6a69cb","type":"INDEX","name":"ACCOUNT_PREFERENCE_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACCOUNT_PREFERENCE_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACCOUNT_PREFERENCE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}