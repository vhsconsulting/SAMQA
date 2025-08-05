create index samqa.i_nacha_process_log_prim on
    samqa.nacha_process_log (
        transaction_id,
        flg_processed
    );


-- sqlcl_snapshot {"hash":"8bb829a6652fe1a1b0818723cc975e6f45dc5108","type":"INDEX","name":"I_NACHA_PROCESS_LOG_PRIM","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>I_NACHA_PROCESS_LOG_PRIM</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>NACHA_PROCESS_LOG</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FLG_PROCESSED</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}