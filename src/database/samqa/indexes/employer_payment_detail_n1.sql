create index samqa.employer_payment_detail_n1 on
    samqa.employer_payment_detail (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"e5d0dcc1a2ca43137ceeb52ab5281a7045da8626","type":"INDEX","name":"EMPLOYER_PAYMENT_DETAIL_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_PAYMENT_DETAIL_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_PAYMENT_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}