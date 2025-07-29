create index samqa.employer_divisions_u1 on
    samqa.employer_divisions (
        division_code,
        entrp_id
    );


-- sqlcl_snapshot {"hash":"836d649a693a98cd5b89c30652c335f26c80c654","type":"INDEX","name":"EMPLOYER_DIVISIONS_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_DIVISIONS_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_DIVISIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>DIVISION_CODE</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}