create index samqa.card_balance_external_n1 on
    samqa.card_balance_gt (
        employee_id
    );


-- sqlcl_snapshot {"hash":"8cee21bc9da7483702fc14d61bbe3e6e65f63fb4","type":"INDEX","name":"CARD_BALANCE_EXTERNAL_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CARD_BALANCE_EXTERNAL_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CARD_BALANCE_GT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EMPLOYEE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <INDEX_ATTRIBUTES></INDEX_ATTRIBUTES>\n   </TABLE_INDEX>\n</INDEX>"}