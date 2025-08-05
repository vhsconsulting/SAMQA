create index samqa.sales_commission_history_n1 on
    samqa.sales_commission_history (
        acc_num
    );


-- sqlcl_snapshot {"hash":"5bc798324d39a47ffa0fea042fc7ea495f3b0439","type":"INDEX","name":"SALES_COMMISSION_HISTORY_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SALES_COMMISSION_HISTORY_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SALES_COMMISSION_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}