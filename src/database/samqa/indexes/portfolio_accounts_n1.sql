create index samqa.portfolio_accounts_n1 on
    samqa.portfolio_accounts (
        acc_num
    );


-- sqlcl_snapshot {"hash":"bf237edd67f8139f5ea3a5890ebd70d169d72f5e","type":"INDEX","name":"PORTFOLIO_ACCOUNTS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PORTFOLIO_ACCOUNTS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PORTFOLIO_ACCOUNTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}