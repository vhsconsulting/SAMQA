create index samqa.employer_online_enrollment_n1 on
    samqa.employer_online_enrollment (
        acc_num,
        entrp_id
    );


-- sqlcl_snapshot {"hash":"c974907636a7e47543441e505c3c94405bdb8fed","type":"INDEX","name":"EMPLOYER_ONLINE_ENROLLMENT_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_ONLINE_ENROLLMENT_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_ONLINE_ENROLLMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}