create index samqa.user_login_history_n1 on
    samqa.user_login_history (
        user_id
    );


-- sqlcl_snapshot {"hash":"8f8f170697b32fc76c511508d3ea2f7fb7ff8f43","type":"INDEX","name":"USER_LOGIN_HISTORY_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>USER_LOGIN_HISTORY_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>USER_LOGIN_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>USER_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}