create index samqa.online_enrollment_n2 on
    samqa.online_enrollment (
        ssn
    );


-- sqlcl_snapshot {"hash":"7ec2bd559cd0edf2bd36c1977fd4066a89f41bce","type":"INDEX","name":"ONLINE_ENROLLMENT_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_ENROLLMENT_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_ENROLLMENT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}