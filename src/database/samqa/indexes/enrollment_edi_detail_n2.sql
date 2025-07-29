create index samqa.enrollment_edi_detail_n2 on
    samqa.enrollment_edi_detail (
        orig_system_ref
    );


-- sqlcl_snapshot {"hash":"3f3909c09cc585a16cd2ab7b463bda1097113c64","type":"INDEX","name":"ENROLLMENT_EDI_DETAIL_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_EDI_DETAIL_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENROLLMENT_EDI_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ORIG_SYSTEM_REF</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}