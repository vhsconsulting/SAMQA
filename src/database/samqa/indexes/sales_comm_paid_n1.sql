create index samqa.sales_comm_paid_n1 on
    samqa.sales_comm_paid (
        salesrep_id
    );


-- sqlcl_snapshot {"hash":"6bd04e0ec7956fc1ed5097844745682bb57b3ace","type":"INDEX","name":"SALES_COMM_PAID_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SALES_COMM_PAID_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SALES_COMM_PAID</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SALESREP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}