create index samqa.claim_ee_automation_gt_n5 on
    samqa.claim_ee_automation_gt (
        ee_balance
    );


-- sqlcl_snapshot {"hash":"e8c25362c86249c921fa528d06b815e7ca248714","type":"INDEX","name":"CLAIM_EE_AUTOMATION_GT_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_EE_AUTOMATION_GT_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIM_EE_AUTOMATION_GT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EE_BALANCE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <INDEX_ATTRIBUTES></INDEX_ATTRIBUTES>\n   </TABLE_INDEX>\n</INDEX>"}