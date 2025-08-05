create index samqa.mass_enroll_dependant_n2 on
    samqa.mass_enroll_dependant (
        subscriber_ssn
    );


-- sqlcl_snapshot {"hash":"d521b018eacf6cd54bd57a705949a1eba60fe719","type":"INDEX","name":"MASS_ENROLL_DEPENDANT_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>MASS_ENROLL_DEPENDANT_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>MASS_ENROLL_DEPENDANT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SUBSCRIBER_SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}