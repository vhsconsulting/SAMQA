create index samqa.sales_commission_history_n10 on
    samqa.sales_commission_history (
        ssn
    );


-- sqlcl_snapshot {"hash":"b8aad7999d9e7fa23778f7820d887c3df4b50870","type":"INDEX","name":"SALES_COMMISSION_HISTORY_N10","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SALES_COMMISSION_HISTORY_N10</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SALES_COMMISSION_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}