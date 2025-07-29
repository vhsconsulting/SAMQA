create index samqa.bps_sam_balances_u2 on
    samqa.bps_sam_balances (
        acc_id
    );


-- sqlcl_snapshot {"hash":"4671aae05245d848dd3b871e011def36d07aac4a","type":"INDEX","name":"BPS_SAM_BALANCES_U2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BPS_SAM_BALANCES_U2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BPS_SAM_BALANCES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}