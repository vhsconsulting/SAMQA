create index samqa.portfolio_accounts_n4 on
    samqa.portfolio_accounts (
        user_id
    );


-- sqlcl_snapshot {"hash":"6bebcfaa252801a5797c79bdedb8584a5cee2b4f","type":"INDEX","name":"PORTFOLIO_ACCOUNTS_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PORTFOLIO_ACCOUNTS_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PORTFOLIO_ACCOUNTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>USER_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}