create index samqa.employer_payments_n5 on
    samqa.employer_payments (
        plan_type
    );


-- sqlcl_snapshot {"hash":"a5b84d4bc0ee42bc76af4a93e64d039755609687","type":"INDEX","name":"EMPLOYER_PAYMENTS_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMPLOYER_PAYMENTS_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMPLOYER_PAYMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PLAN_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}