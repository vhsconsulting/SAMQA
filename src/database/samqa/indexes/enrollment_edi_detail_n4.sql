create index samqa.enrollment_edi_detail_n4 on
    samqa.enrollment_edi_detail (
        person_type
    );


-- sqlcl_snapshot {"hash":"a7498df239ab210ba9b7b98bcebfdee2551b62d0","type":"INDEX","name":"ENROLLMENT_EDI_DETAIL_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_EDI_DETAIL_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENROLLMENT_EDI_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PERSON_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}