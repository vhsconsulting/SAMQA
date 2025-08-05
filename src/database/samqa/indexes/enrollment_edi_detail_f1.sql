create index samqa.enrollment_edi_detail_f1 on
    samqa.enrollment_edi_detail (
        status_cd
    );


-- sqlcl_snapshot {"hash":"12a74d014294b9d260069ee7912b2f8cb258276d","type":"INDEX","name":"ENROLLMENT_EDI_DETAIL_F1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_EDI_DETAIL_F1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENROLLMENT_EDI_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>STATUS_CD</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}