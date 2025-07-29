create index samqa.employer_deposits_u2 on
    samqa.employer_deposits (
        list_bill
    );


-- sqlcl_snapshot {"hash":"cd97f608370559b96378e34658877b23d2869f23","type":"INDEX","name":"EMPLOYER_DEPOSITS_U2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_DEPOSITS_U2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_DEPOSITS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>LIST_BILL</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}