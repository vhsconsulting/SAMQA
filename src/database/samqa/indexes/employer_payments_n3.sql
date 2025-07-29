create index samqa.employer_payments_n3 on
    samqa.employer_payments ( trunc(check_date) );


-- sqlcl_snapshot {"hash":"b704b599aa43660f7b90407393e0e69ed8070542","type":"INDEX","name":"EMPLOYER_PAYMENTS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_PAYMENTS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_PAYMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRUNC(\"CHECK_DATE\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}