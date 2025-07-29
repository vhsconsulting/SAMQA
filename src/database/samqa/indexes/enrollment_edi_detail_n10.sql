create index samqa.enrollment_edi_detail_n10 on
    samqa.enrollment_edi_detail (
        ssn
    );


-- sqlcl_snapshot {"hash":"1f136e33b39e67371d15e4e4cb12d162e6307063","type":"INDEX","name":"ENROLLMENT_EDI_DETAIL_N10","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_EDI_DETAIL_N10</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENROLLMENT_EDI_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}