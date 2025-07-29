create index samqa.investment_fk2_i on
    samqa.investment (
        invest_id
    );


-- sqlcl_snapshot {"hash":"d5821a7fc5b497d2ae3af6c41608f7b83f42ba96","type":"INDEX","name":"INVESTMENT_FK2_I","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVESTMENT_FK2_I</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INVESTMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVEST_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}