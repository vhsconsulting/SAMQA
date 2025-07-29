create index samqa.bps_sam_balances_u1 on
    samqa.bps_sam_balances (
        acc_num
    );


-- sqlcl_snapshot {"hash":"b22a5ead52157f4250f772c09ec50594aa568e86","type":"INDEX","name":"BPS_SAM_BALANCES_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BPS_SAM_BALANCES_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BPS_SAM_BALANCES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}