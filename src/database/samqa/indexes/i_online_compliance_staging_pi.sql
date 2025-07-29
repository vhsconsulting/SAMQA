create index samqa.i_online_compliance_staging_pi on
    samqa.online_compliance_staging (
        batch_number,
        entrp_id
    );


-- sqlcl_snapshot {"hash":"a26c7469907ae0b1ee68ce47bc4edc8b2ecd9d6f","type":"INDEX","name":"I_ONLINE_COMPLIANCE_STAGING_PI","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>I_ONLINE_COMPLIANCE_STAGING_PI</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_COMPLIANCE_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}