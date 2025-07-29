create index samqa.sales_commission_history_n2 on
    samqa.sales_commission_history (
        ga_id
    );


-- sqlcl_snapshot {"hash":"5aae0227418e2a93ece3fc2f8445ed881a388b38","type":"INDEX","name":"SALES_COMMISSION_HISTORY_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SALES_COMMISSION_HISTORY_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SALES_COMMISSION_HISTORY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>GA_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}