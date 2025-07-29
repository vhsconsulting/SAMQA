create index samqa.employer_deposits_u1 on
    samqa.employer_deposits (
        employer_deposit_id
    );


-- sqlcl_snapshot {"hash":"19479ae9ca8c7e754b192abb24212f4f0855570a","type":"INDEX","name":"EMPLOYER_DEPOSITS_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_DEPOSITS_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_DEPOSITS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EMPLOYER_DEPOSIT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}