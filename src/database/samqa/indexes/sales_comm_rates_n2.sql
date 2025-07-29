create index samqa.sales_comm_rates_n2 on
    samqa.sales_comm_rates (
        account_category
    );


-- sqlcl_snapshot {"hash":"628d679388d2474a9a94412b6a827f6606db6820","type":"INDEX","name":"SALES_COMM_RATES_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SALES_COMM_RATES_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SALES_COMM_RATES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACCOUNT_CATEGORY</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}