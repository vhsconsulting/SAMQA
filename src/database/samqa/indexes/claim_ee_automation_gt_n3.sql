create index samqa.claim_ee_automation_gt_n3 on
    samqa.claim_ee_automation_gt (
        pers_id
    );


-- sqlcl_snapshot {"hash":"8e73fd88ea06124f9a36c6d0c3648b2dcfc3d7a6","type":"INDEX","name":"CLAIM_EE_AUTOMATION_GT_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_EE_AUTOMATION_GT_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_EE_AUTOMATION_GT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PERS_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <INDEX_ATTRIBUTES></INDEX_ATTRIBUTES>\n   </TABLE_INDEX>\n</INDEX>"}