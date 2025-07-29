create index samqa.deductible_balance_n2 on
    samqa.deductible_balance (
        pers_id
    );


-- sqlcl_snapshot {"hash":"f784acd151524fdb053489ff7582223f3663951b","type":"INDEX","name":"DEDUCTIBLE_BALANCE_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEDUCTIBLE_BALANCE_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEDUCTIBLE_BALANCE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PERS_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}