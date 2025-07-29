create index samqa.user_login_history_n2 on
    samqa.user_login_history (
        user_name
    );


-- sqlcl_snapshot {"hash":"b8513393bac652cd0a7d6c57c7b34b0fc1e5ef46","type":"INDEX","name":"USER_LOGIN_HISTORY_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>USER_LOGIN_HISTORY_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>USER_LOGIN_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>USER_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}