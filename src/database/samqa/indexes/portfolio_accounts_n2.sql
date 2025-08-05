create index samqa.portfolio_accounts_n2 on
    samqa.portfolio_accounts (
        tax_id
    );


-- sqlcl_snapshot {"hash":"4a48ed41f7e0c8eb82542c44b660915ded278f7d","type":"INDEX","name":"PORTFOLIO_ACCOUNTS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PORTFOLIO_ACCOUNTS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PORTFOLIO_ACCOUNTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TAX_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}