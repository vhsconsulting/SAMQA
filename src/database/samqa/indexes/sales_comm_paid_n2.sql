create index samqa.sales_comm_paid_n2 on
    samqa.sales_comm_paid (
        account_type
    );


-- sqlcl_snapshot {"hash":"728243c4a1be9378470b12abf48addbc46c1131d","type":"INDEX","name":"SALES_COMM_PAID_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SALES_COMM_PAID_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SALES_COMM_PAID</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACCOUNT_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}