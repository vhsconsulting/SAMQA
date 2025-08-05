create index samqa.cobra_disbursement_detail on
    samqa.cobra_disbursement_detail (
        cobra_disbursement_id
    );


-- sqlcl_snapshot {"hash":"5b77cd3da68923241368369ac60b625169c0aefd","type":"INDEX","name":"COBRA_DISBURSEMENT_DETAIL","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>COBRA_DISBURSEMENT_DETAIL</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>COBRA_DISBURSEMENT_DETAIL</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>COBRA_DISBURSEMENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}