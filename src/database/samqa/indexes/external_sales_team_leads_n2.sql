create index samqa.external_sales_team_leads_n2 on
    samqa.external_sales_team_leads (
        ref_entity_id,
        ref_entity_type
    );


-- sqlcl_snapshot {"hash":"8b12b793ae99269ac33323fb5435f873e65e7350","type":"INDEX","name":"EXTERNAL_SALES_TEAM_LEADS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EXTERNAL_SALES_TEAM_LEADS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EXTERNAL_SALES_TEAM_LEADS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>REF_ENTITY_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>REF_ENTITY_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}