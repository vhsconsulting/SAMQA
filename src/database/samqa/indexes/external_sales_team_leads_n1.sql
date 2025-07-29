create index samqa.external_sales_team_leads_n1 on
    samqa.external_sales_team_leads (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"5385cbf89f99f9a2c3db0a3b4a6b007452af7353","type":"INDEX","name":"EXTERNAL_SALES_TEAM_LEADS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EXTERNAL_SALES_TEAM_LEADS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EXTERNAL_SALES_TEAM_LEADS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}