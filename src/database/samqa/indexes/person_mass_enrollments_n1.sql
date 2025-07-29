create index samqa.person_mass_enrollments_n1 on
    samqa.person (
        mass_enrollment_id
    );


-- sqlcl_snapshot {"hash":"d042b487531c5662c4047ad665c414ad090f857c","type":"INDEX","name":"PERSON_MASS_ENROLLMENTS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PERSON_MASS_ENROLLMENTS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>PERSON</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>MASS_ENROLLMENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}