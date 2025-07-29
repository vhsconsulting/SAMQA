create index samqa.employer_payment_detail_n6 on
    samqa.employer_payment_detail (
        employer_payment_id
    );


-- sqlcl_snapshot {"hash":"eac57a33776c45a8df5ccdddcbea2c24fc861912","type":"INDEX","name":"EMPLOYER_PAYMENT_DETAIL_N6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_PAYMENT_DETAIL_N6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_PAYMENT_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EMPLOYER_PAYMENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}