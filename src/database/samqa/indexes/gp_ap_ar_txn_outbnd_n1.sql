create index samqa.gp_ap_ar_txn_outbnd_n1 on
    samqa.gp_ap_ar_txn_outbnd (
        entity_id,
        entity_type
    );


-- sqlcl_snapshot {"hash":"08cc31f3047ccfa934f9f188b4746313a4dde6e5","type":"INDEX","name":"GP_AP_AR_TXN_OUTBND_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>GP_AP_AR_TXN_OUTBND_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>GP_AP_AR_TXN_OUTBND</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTITY_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ENTITY_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}