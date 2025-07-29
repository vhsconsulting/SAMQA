create index samqa.sales_team_member_n1 on
    samqa.sales_team_member (
        emplr_id
    );


-- sqlcl_snapshot {"hash":"e281e362d523bd0dc967e379c4951cad27fa5a53","type":"INDEX","name":"SALES_TEAM_MEMBER_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SALES_TEAM_MEMBER_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SALES_TEAM_MEMBER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EMPLR_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}