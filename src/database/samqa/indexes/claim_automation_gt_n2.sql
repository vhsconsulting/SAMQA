create index samqa.claim_automation_gt_n2 on
    samqa.claim_automation_gt (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"edd01d1f730e1b9ceb55f57f0dbf6371cab4eb5b","type":"INDEX","name":"CLAIM_AUTOMATION_GT_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_AUTOMATION_GT_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_AUTOMATION_GT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <INDEX_ATTRIBUTES></INDEX_ATTRIBUTES>\n   </TABLE_INDEX>\n</INDEX>"}