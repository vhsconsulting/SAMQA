create index samqa.cobra_disbursements on
    samqa.cobra_disbursements (
        client_id
    );


-- sqlcl_snapshot {"hash":"b5846e969feabc7acd6cfd098db4e6d830351a93","type":"INDEX","name":"COBRA_DISBURSEMENTS","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>COBRA_DISBURSEMENTS</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>COBRA_DISBURSEMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLIENT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}