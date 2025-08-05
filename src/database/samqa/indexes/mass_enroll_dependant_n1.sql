create index samqa.mass_enroll_dependant_n1 on
    samqa.mass_enroll_dependant (
        ssn
    );


-- sqlcl_snapshot {"hash":"02d66da8e623bb71e99fd0c9bbc4c8ad43e1961b","type":"INDEX","name":"MASS_ENROLL_DEPENDANT_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>MASS_ENROLL_DEPENDANT_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>MASS_ENROLL_DEPENDANT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}