create index samqa.employer_online_enrollment_n2 on
    samqa.employer_online_enrollment (
        ein_number
    );


-- sqlcl_snapshot {"hash":"0b7a36bd8ac4b0496526e0d50bcb038596d44a97","type":"INDEX","name":"EMPLOYER_ONLINE_ENROLLMENT_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_ONLINE_ENROLLMENT_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_ONLINE_ENROLLMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EIN_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}