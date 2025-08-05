create index samqa.enrollment_edi_detail_n1 on
    samqa.enrollment_edi_detail (
        subscriber_number
    );


-- sqlcl_snapshot {"hash":"d1f0356d2d8da14fcdf52b6cd978569b5fc1a928","type":"INDEX","name":"ENROLLMENT_EDI_DETAIL_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENROLLMENT_EDI_DETAIL_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENROLLMENT_EDI_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SUBSCRIBER_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}