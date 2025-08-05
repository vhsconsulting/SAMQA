create index samqa.enrollment_edi_detail_n3 on
    samqa.enrollment_edi_detail (
        maintenance_cd
    );


-- sqlcl_snapshot {"hash":"444f3c4afaf0565b4e9e9eb0393cddf842d503f6","type":"INDEX","name":"ENROLLMENT_EDI_DETAIL_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_EDI_DETAIL_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENROLLMENT_EDI_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>MAINTENANCE_CD</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}