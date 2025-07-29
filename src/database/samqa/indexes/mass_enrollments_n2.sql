create index samqa.mass_enrollments_n2 on
    samqa.mass_enrollments (
        ssn
    );


-- sqlcl_snapshot {"hash":"affc78ae54dd7ed96583cc9376478c864fe3f8bb","type":"INDEX","name":"MASS_ENROLLMENTS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>MASS_ENROLLMENTS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>MASS_ENROLLMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}