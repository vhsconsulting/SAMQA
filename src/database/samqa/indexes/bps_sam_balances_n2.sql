create index samqa.bps_sam_balances_n2 on
    samqa.bps_sam_balances (
        sam_bal
    );


-- sqlcl_snapshot {"hash":"be258902500466595b0b0955c02bbd1a4bcf8702","type":"INDEX","name":"BPS_SAM_BALANCES_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BPS_SAM_BALANCES_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BPS_SAM_BALANCES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SAM_BAL</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}