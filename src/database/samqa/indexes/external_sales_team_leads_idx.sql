create index samqa.external_sales_team_leads_idx on
    samqa.external_sales_team_leads (
        ref_entity_id
    );


-- sqlcl_snapshot {"hash":"f4ffc6b546b38a0672aba8300e28af8d749f7506","type":"INDEX","name":"EXTERNAL_SALES_TEAM_LEADS_IDX","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EXTERNAL_SALES_TEAM_LEADS_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EXTERNAL_SALES_TEAM_LEADS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>REF_ENTITY_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}