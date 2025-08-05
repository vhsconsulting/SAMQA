create index samqa.enrollment_edi_error_n1 on
    samqa.enrollment_edi_detail_error (
        detail_id
    );


-- sqlcl_snapshot {"hash":"df6742da00a85ba80ce55c5df957bacf30b108ae","type":"INDEX","name":"ENROLLMENT_EDI_ERROR_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_EDI_ERROR_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENROLLMENT_EDI_DETAIL_ERROR</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>DETAIL_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}