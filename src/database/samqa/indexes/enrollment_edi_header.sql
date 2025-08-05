create index samqa.enrollment_edi_header on
    samqa.enrollment_edi_header (
        header_id
    );


-- sqlcl_snapshot {"hash":"75d9065f0b65ee914dfbfdd044d2ddeb0e7c133e","type":"INDEX","name":"ENROLLMENT_EDI_HEADER","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_EDI_HEADER</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENROLLMENT_EDI_HEADER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>HEADER_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}