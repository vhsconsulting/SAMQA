create index samqa.bps_sam_balances_n3 on
    samqa.bps_sam_balances (
        bal_dff
    );


-- sqlcl_snapshot {"hash":"67e5719967bbbc03f97a1ec63019d21c3c3a332a","type":"INDEX","name":"BPS_SAM_BALANCES_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BPS_SAM_BALANCES_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BPS_SAM_BALANCES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BAL_DFF</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}