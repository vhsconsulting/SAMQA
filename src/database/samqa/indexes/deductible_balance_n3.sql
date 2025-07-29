create index samqa.deductible_balance_n3 on
    samqa.deductible_balance (
        claim_id
    );


-- sqlcl_snapshot {"hash":"4d7a0dd11fd42e6429f886d1d47f97d29f066110","type":"INDEX","name":"DEDUCTIBLE_BALANCE_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEDUCTIBLE_BALANCE_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>DEDUCTIBLE_BALANCE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}